# frozen_string_literal: true

class Feed

  DEFAULT_ICON  = CONFIG.fetch('default_icon')  { 'https://upload.wikimedia.org/wikipedia/en/thumb/4/43/Feed-icon.svg/128px-Feed-icon.svg' }
  DEFAULT_TITLE = CONFIG.fetch('default_title') { 'RSS' }

  attr_reader :icon_url, :last_item, :title, :url

  def initialize(feed_hash)
    @url      = feed_hash.fetch('url')
    @title    = feed_hash.fetch('title')    { DEFAULT_TITLE }
    @icon_url = feed_hash.fetch('icon_url') { DEFAULT_ICON }
  end

  def new_item?
    last_fetched_item = fetch.items.first

    return false if last_fetched_item.nil? || last_fetched_item.link == @last_item&.link

    @last_item = last_fetched_item

    true
  end

  private

  def fetch
    response = HTTParty.get(url)

    RSS::Parser.parse(response.body)
  end

end
