# frozen_string_literal: true

module LinkChecker
  # Returns an array of all iframe links containing YouTube videos
  def youtube_links
    all('iframe[src*="youtube"]').map do |iframe|
      iframe[:src]
    end
  end

  def anchor_links
    links = all('a').map do |page_link|
      page_link[:href] if page_link[:href].include?('#')
    end
    links.uniq.compact.delete_if(&:blank?)
  end

  def external_links
    links = all('a').map do |page_link|
      page_link[:href] unless page_link[:href].match(Capybara.current_session.server.host)
    end
    links.uniq.compact.delete_if(&:blank?)
  end
end

RSpec.configure do |config|
  config.include LinkChecker
end
