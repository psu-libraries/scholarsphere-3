# frozen_string_literal: true

module GenericWorksHelper
  def wait_for_page(redirect_url)
    Timeout.timeout(Capybara.default_max_wait_time * 5) do
      loop until current_path == redirect_url
    end
  end

  def find_work_by_title(title)
    GenericWork.where(Solrizer.solr_name('title', :stored_searchable, type: :string) => title).first
  end
end

RSpec.configure do |config|
  config.include GenericWorksHelper
end
