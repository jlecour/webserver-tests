require 'test_helper_without_rails'
require 'support/webserver_helper'
require "mechanize"

class HTTPCacheTest < Minitest::Test
  include WebserverHelper

  def setup
    @agent = Mechanize.new { |a|
      a.follow_redirect = false
    }
  end

  def test_homepage_first_visit
    [
      "https://#{domain}/",
    ].each do |url|
      page = @agent.get(url)

      assert_status_ok page, "for #{url}"
      assert_has_etag page, "for #{url}"
      assert_has_last_modified page, "for #{url}"
      assert_max_age "300", page, "for #{url}"
      refute_must_revalidate page, "for #{url}"
      assert_public page, "for #{url}"
    end
  end

  def test_homepage_second_visit
    [
      "https://#{domain}/",
    ].each do |url|
      page1 = @agent.get(url)
      assert_status_ok page1, "for #{url} on 1st visit"
      
      if last_modified = last_modified_header(page1)
        # il faut reinitialiser l'agent pour vider le cache et l'historique
        @agent.reset
        page2a = @agent.get(url, [], nil, {
          "If-Modified-Since" => last_modified
        })
        assert_status_not_modified page2a, "for #{url} on 2nd visit with Last-Modified"
      else
        flunk "Last-Modified header is missing for #{url} on 1st visit"
      end
      
      if etag = etag_header(page1)
        # il faut reinitialiser l'agent pour vider le cache et l'historique
        @agent.reset
        page2b = @agent.get(url, [], nil, {
          "If-None-Match" => etag_header(page1)
        })
        assert_status_not_modified page2b, "for #{url} on 2nd visit with ETag"
      else
        flunk "ETag header is missing for #{url} on 1st visit"
      end
    end
  end

  def test_login_first_visit
    [
      "https://#{domain}/mon-compte/identification",
    ].each do |url|
      page = @agent.get(url)

      assert_max_age "0", page, "for #{url}"
      assert_must_revalidate page, "for #{url}"
      assert_private page, "for #{url}"
    end
  end
end