require 'test_helper_without_rails'
require 'support/webserver_helper'
require "mechanize"

class DomainRedirectsTest < Minitest::Test
  include WebserverHelper

  def setup
    @agent = Mechanize.new { |a|
      a.follow_redirect = false
    }
  end

  def test_redirections
    redirections.each do |start_url, expected_url|
      page = nil
      actual_code = begin
        page = @agent.get(start_url)
        page.code
      rescue Mechanize::ResponseCodeError => e
        e.response_code
      end

      assert_code "301", actual_code, "for #{start_url}"
      if page
        assert_has_header "location".freeze, page, "for #{start_url}"
        assert_equal expected_url, header(page, "location"), "URL de redirection incorrecte".freeze
      end
    end
  end

  def test_http_codes
    http_codes.each do |url, expected_code|
      actual_code = begin
        @agent.get(url).code
      rescue Mechanize::ResponseCodeError => e
        e.response_code
      end
      assert_code expected_code, actual_code, "for #{url}"
    end
  end
  
  def redirections
    case webserver_env
    when "production"
      {
        "http://example.com/".freeze         => "https://www.example.com/".freeze,
        "https://example.com/".freeze        => "https://www.example.com/".freeze,
        "http://www.example.com/".freeze     => "https://www.example.com/".freeze,
        "http://assets.example.com/".freeze  => "https://assets.example.com/".freeze,
        "http://assets0.example.com/".freeze => "https://assets0.example.com/".freeze,
        "http://assets1.example.com/".freeze => "https://assets1.example.com/".freeze,
        "http://assets2.example.com/".freeze => "https://assets2.example.com/".freeze,
        "http://assets3.example.com/".freeze => "https://assets3.example.com/".freeze,
      }
    when "staging"
      {
        "http://staging.example.com/".freeze        => "https://www-staging.example.com/".freeze,
        "https://staging.example.com/".freeze       => "https://www-staging.example.com/".freeze,
        "http://www-staging.example.com/".freeze    => "https://www-staging.example.com/".freeze,
        # l'accès aux assets en HTTP est autorisé sur staging
        # "http://assets-staging.example.com/".freeze => "https://assets-staging.example.com/".freeze,
      }
    when "development"
      {
        "http://local.example.com/".freeze => "https://local.example.com/".freeze,
      }
    else
      fail ArgumentError, "Liste de redirections indéterminée"
    end
  end
  
  def http_codes
    case webserver_env
    when "production"
      {
        "https://www.example.com/".freeze     => "200".freeze,
        "https://assets.example.com/".freeze  => "403".freeze,
        "https://assets0.example.com/".freeze => "403".freeze,
        "https://assets1.example.com/".freeze => "403".freeze,
        "https://assets2.example.com/".freeze => "403".freeze,
        "https://assets3.example.com/".freeze => "403".freeze,
      }
    when "staging"
      {
        "https://www-staging.example.com/".freeze     => "200".freeze,
        "https://assets-staging.example.com/".freeze  => "403".freeze,
      }
    when "development"
      {
        "https://local.example.com/".freeze     => "200".freeze,
      }
    else
      fail ArgumentError, "Liste de redirections indéterminée"
    end
  end

end