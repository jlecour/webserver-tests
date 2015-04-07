require 'test_helper_without_rails'
require 'support/webserver_helper'
require "mechanize"
require "nokogiri"

class AssetsAccessibilityTest < Minitest::Test
  include WebserverHelper

  def setup
    @agent = Mechanize.new
    @page = @agent.get("https://#{domain}/")
    @html_doc = Nokogiri::HTML(@page.body)
  end

  def test_rss_feeds
    feeds = @html_doc.search("//head/link[@type='application/rss+xml']")

    # Il y a au moins 1 flux RSS
    assert feeds.size >= 1, "Pas de flux RSS trouvé"

    feeds.each do |doc|
      url = doc["href"]
      assert_status_ok @agent.get(url), "for #{url}"
    end
  end

  def test_head_stylelsheets
    stylesheets = @html_doc.search("//head/link[@rel='stylesheet']")

    # Il y a au moins 1 CSS "application"
    assert stylesheets.any? { |doc|
      path = URI.parse(doc["href"]).path
      %r(\A/assets/application-\w+\.css\Z) =~ path
    }, "CSS principal manquant"

    # Tous les CSS sont accessibles et correctement configurés
    stylesheets.each do |doc|
      url = doc["href"]
      assert_cachable_asset @agent.get(url), "for #{url}"
    end
  end

  def test_head_scripts
    scripts = @html_doc.search("//head/script[@src]")

    # Il y a au moins 1 JS "application"
    assert scripts.any? { |doc|
      path = URI.parse(doc["src"]).path
      %r|\A/assets/application-\w+\.js\Z| =~ path
    }, "Script principal manquant"

    # Tous les scripts externes sont accessibles
    scripts.each do |doc|
      url = doc["src"]
      assert_cachable_asset @agent.get(url), "for #{url}"
    end
  end
  
  def test_images
    @html_doc.search("body img").each do |doc|
      url = doc["src"]
      assert_cachable_asset @agent.get(url), "for #{url}"
    end
  end

end