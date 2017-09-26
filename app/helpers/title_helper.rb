# frozen_string_literal: true

module TitleHelper
  include CurationConcerns::TitleHelper

  def construct_page_title(*elements)
    (elements.flatten.compact + [application_name]).join(' | ')
  end
end
