# frozen_string_literal: true
class HomepageController < ApplicationController
  include Sufia::HomepageController

  def index
    super
    @announcement_text = ContentBlock.find_or_create_by(name: 'annoucement_text')
  end
end
