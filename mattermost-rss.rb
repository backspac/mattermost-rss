# frozen_string_literal: true

require 'rss'
require 'httparty'
require 'reverse_markdown'
require 'active_support'
require 'active_support/core_ext/string/filters'

begin
  CONFIG = YAML.load_file('config.yml')
rescue Errno::ENOENT
  abort "ERROR: config.yml not found. Copy, edit and rename config-sample.yml if this has not yet been done."
end

require_relative 'lib/feed'

class MattermostRss

  attr_reader :feeds, :fetch_interval, :settings, :webhooks

  def initialize
    @fetch_interval = CONFIG.fetch('fetch_interval') { 300 }
    @feeds          = CONFIG.fetch('feeds')          { abort "No feeds provided"    }.map { |feed_hash| Feed.new(feed_hash) }
    @webhooks       = CONFIG.fetch('webhooks')       { abort "No webhooks provided" }
  end

  def work
    loop do
      feeds.each do |feed|
        feed

        next unless feed.new_item?

        webhooks.each do |webhook|
          HTTParty.post(webhook, body: {
            payload: {
              text:     format_item(feed.last_item),
              username: feed.title,
              icon_url: feed.icon_url
            }.to_json
          })
        end
      end

      sleep fetch_interval
    end
  end

  private

  def format_item(item)
    md = []

    md << <<~MARKDOWN
      ## [#{item.title}](#{item.link})
    MARKDOWN

    md << ReverseMarkdown.convert(item.description, unknown_tags: :drop)

    md.join("\n").truncate(4000, omission: "[Read more…](#{item.link})")
  end

end

MattermostRss.new.work
