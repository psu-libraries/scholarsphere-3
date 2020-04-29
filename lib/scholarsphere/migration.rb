# frozen_string_literal: true

module Scholarsphere
  module Migration
    class Error < StandardError; end

    require 'data_report'
    require 'depositors_report'
    require 'work'
    require 'creator'
    require 'depositor'
    require 'export_service'
    require 'resource'
    require 'job'
  end
end
