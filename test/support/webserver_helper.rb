require "support/message_helper"

module WebserverHelper

  include MessageHelper

  def webserver_env
    webserver_env = ENV['WEBSERVER_ENV']
    webserver_env = "production" if webserver_env.nil? || webserver_env.empty?
    if %w(production staging development).include?(webserver_env)
      webserver_env
    else
      fail ArgumentError, "Environnement #{webserver_env} invalide"
    end
  end

  def domain
    case webserver_env
    when "production"
      "www.example.com"
    when "staging"
      "www-staging.example.com"
    when "development"
      "local.example.com"
    else
      fail ArgumentError, "Domaine indéterminé"
    end
  end

  # Custom assertions
  
  def assert_cachable_asset(page, context = nil)
    assert_status_ok page, context
    assert_max_age "315360000", page, context
    assert_public page, context
    assert_has_etag page, context
    assert_has_last_modified page, context
  end

  def assert_has_header(header, page, context = nil)
    assert page.response.key?(header), message_with_context("Header '#{header}' is missing".freeze, context)
  end

  def assert_has_etag(page, context = nil)
    assert_includes page.response.keys, "etag", message_with_context("ETag header is missing", context)
  end
  def refute_has_etag(page, context = nil)
    refute_includes page.response.keys, "etag", message_with_context("ETag header is found", context)
  end

  def assert_has_last_modified(page, context = nil)
    assert_includes page.response.keys, "last-modified", message_with_context("Last-Modified header is not found ", context)
  end

  def assert_max_age(expected, page, context = nil)
    assert_equal expected, cache_max_age(page), message_with_context("Cache-Control \"max-age\" is incorrect", context)
  end

  def assert_must_revalidate(page, context = nil)
    assert cache_must_revalidate?(page), message_with_context("Cache-Control \"must-revalidate\" is missing", context)
  end

  def refute_must_revalidate(page, context = nil)
    refute cache_must_revalidate?(page), message_with_context("Cache-Control \"must-revalidate\" is found", context)
  end

  def assert_private(page, context = nil)
    assert cache_private?(page), message_with_context("Cache-Control is not private", context)
  end

  def assert_public(page, context = nil)
    assert cache_public?(page), message_with_context("Cache-Control is not public", context)
  end

  def assert_status_ok(page, context = nil)
    assert_code("200", page, context)
  end

  def assert_status_not_modified(page, context = nil)
    assert_code("304", page, context)
  end

  def assert_code(expected_code, page_or_code, context = nil)
    actual_code = page_or_code.respond_to?(:code) ? page_or_code.code : page_or_code
    assert_equal expected_code, actual_code, message_with_context("HTTP response code is incorrect", context)
  end


  # Helper methods
  
  def header(page, key)
    page.response[key]
  end

  def status_header(page)
    header(page, "status".freeze)
  end

  def etag_header(page)
    header(page, "etag".freeze)
  end

  def last_modified_header(page)
    header(page, "last-modified".freeze)
  end

  def cache_control_header(page)
    header(page, "cache-control".freeze)
  end

  def cache_private?(page)
    cache_control_directives(page).include?("private")
  end

  def cache_public?(page)
    cache_control_directives(page).include?("public")
  end

  def cache_no_cache?(page)
    cache_control_header(page).downcase.strip == "no-cache"
  end

  def cache_must_revalidate?(page)
    cache_control_directives(page).include?("must-revalidate")
  end

  def cache_has_max_age?(page)
    cache_control_directives(page).any? { |v| v[/\Amax-age=\d\Z/] }
  end

  def cache_control_directives(page)
    cache_control_header(page).downcase.split(',').map(&:strip)
  end

  def cache_max_age(page)
    pattern = /\Amax-age\s?=\s?(\d+)\Z/
    if found = cache_control_directives(page).detect("") { |v| pattern =~ v }
      found[pattern, 1]
    end
  end

end