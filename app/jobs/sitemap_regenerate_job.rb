# frozen_string_literal: true
class SitemapRegenerateJob
  def run
    Rake::Task['sitemap:generate'].invoke
    Rake::Task['sitemap:ping'].invoke
  end
end
