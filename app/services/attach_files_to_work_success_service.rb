# frozen_string_literal: true
class AttachFilesToWorkSuccessService < Sufia::MessageUserService
  attr_reader :user, :filename

  def initialize(user, file)
    @user = user
    @filename = file.respond_to?(:original_filename) ? file.original_filename : ::File.basename(file)
  end

  def message
    "#{filename} was successfully added"
  end

  def subject
    "File successfully attached"
  end
end
