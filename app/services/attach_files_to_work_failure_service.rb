# frozen_string_literal: true
class AttachFilesToWorkFailureService < Sufia::MessageUserService
  attr_reader :user, :filename

  def initialize(user, file)
    @user = user
    @filename = file.respond_to?(:original_filename) ? file.original_filename : ::File.basename(file)
  end

  def message
    "#{filename} failed to be added"
  end

  def subject
    "File failed to attach"
  end
end
