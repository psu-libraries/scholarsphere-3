# frozen_string_literal: true

class SitemapRegenerateJob < ApplicationJob
  def perform
    Rake::Task['sitemap:generate'].invoke
    Rake::Task['sitemap:ping'].invoke
  end
end
