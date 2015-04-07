require 'test_helper_without_rails'
require 'support/webserver_helper'
require 'mechanize'

class SecurityTest < Minitest::Test
  include WebserverHelper

  def test_certificate_level
    level = "intermediate"
    output = `#{analyze_cmd(domain, level)}`

    assert_match %r|has intermediate ssl/tls\nand complies with the '#{level}' level|, output, output
    refute_match %r|consider enabling OCSP Stapling|, output, 'OCSP stapling is disabled'
  end

  def test_certificate
    output = `#{check_ssl_cert_cmd(domain)}`

    assert_match /\ASSL_CERT OK/, output, output
  end

  def test_accepts_tls_v1
    output = `#{openssl_verify_cmd(domain, "-tls1")}`

    assert_match /Verify return code: 0 \(ok\)/, output, "TLSv1 is refused"
  end

  def test_refuse_ssl_v3
    output = `#{openssl_verify_cmd(domain, "-ssl3")}`

    assert_match /sslv3 alert handshake failure/, output, "SSLv3 is accepted"
  end

  def test_hsts_header
    agent = Mechanize.new { |a|
      a.follow_redirect = false
    }
    page = agent.get("https://#{domain}")

    assert_has_header("Strict-Transport-Security", page)
  end

  def check_ssl_cert_cmd(domain)
    # check_ssl_cert is a Nagios plugin, usable outside of Nagios
    # cf. https://trac.id.ethz.ch/projects/nagios_plugins/wiki/check_ssl_cert

    args = [
      "--rootcert", root_certificate,
      "--openssl", openssl_path(:system),
      "--issuer", %Q("Gandi Standard SSL CA 2"),
      "--warning", 60,
      "--critical", 30,
      "--cn", %Q("*.example.com"),
      "--host-cn",
      "--ocsp",
      "--host", domain,
    ].join(" ")

    "vendor/check_ssl_cert/check_ssl_cert #{args}"
  end

  def analyze_cmd(domain, level = "intermediate")
    # Cipherscan helps audit SSL configuration
    # cf. https://github.com/jvehent/cipherscan

    args = [
      "-o", openssl_path(:local),
      "-l", level,
      "-t", domain
    ].join(' ')

    "vendor/cipherscan/analyze.py #{args}"
  end

  def openssl_verify_cmd(domain, options = "")
    args = [
      "-CAfile", "#{root_certificate}",
      "-connect", "#{domain}:443",
      options,
      "2>&1",
    ].join(" ")

    "echo QUIT | #{openssl_path} s_client #{args}"
  end

  def openssl_path(variant = :system)
    case variant
    when :local
      "vendor/cipherscan/openssl-darwin64"
    else
      `which openssl`.chop
    end
  end

  def root_certificate
    # The Root CA might be missing in the local trust store.
    # Caveat : using a pinned root CA won't alert you
    # if it has been revoked or blacklisted,
    # which is rare but happens.
    
    "test/support/ssl/certs/AddTrust_External_CA_Root.pem"
  end

end