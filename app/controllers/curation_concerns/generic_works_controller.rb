# frozen_string_literal: true
# Generated via
#  `rails generate curation_concerns:work GenericWork`

class CurationConcerns::GenericWorksController < ApplicationController
  include CurationConcerns::CurationConcernController
  self.curation_concern_type = GenericWork
end
