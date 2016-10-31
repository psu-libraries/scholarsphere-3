# frozen_string_literal: true
class ContentBlock < ActiveRecord::Base
  include Sufia::ContentBlockBehavior

  LICENSE = 'license_text'

  def self.license_text
    find_or_create_by(name: LICENSE)
  end

  def self.license_text=(value)
    license_text.update(value: value)
  end
end
