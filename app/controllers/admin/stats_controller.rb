# -*- encoding : utf-8 -*-
# frozen_string_literal: true

class Admin::StatsController < ApplicationController
  include Sufia::Admin::StatsBehavior

  def export
    respond_to do |format|
      format.html
      format.csv { send_data csv(start_datetime, end_datetime), type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=#{file_name}" }
    end
  end

  private

    def csv(start_datetime, end_datetime)
      GenericWorkListToCSVService.new(query_service.find_by_date_created(start_datetime, end_datetime)).csv
    end

    def file_name
      "scholarsphere_stats_#{start_datetime.strftime('%Y%m%dT%H%M%S')}-#{end_datetime.strftime('%Y%m%dT%H%M%S')}.csv"
    end

    def start_datetime
      return @start_datetime if @start_datetime.present?
      @start_datetime = DateTime.parse(params[:start_datetime]) if params[:start_datetime].present?
      @start_datetime ||= 1.day.ago
      @start_datetime = @start_datetime.beginning_of_day
    end

    def end_datetime
      return @end_datetime if @end_datetime.present?
      @end_datetime = DateTime.parse(params[:end_datetime]) if params[:end_datetime].present?
      if @end_datetime.blank?
        @end_datetime = 1.day.ago
        @end_datetime = start_datetime if @end_datetime < start_datetime
      end
      @end_datetime = @end_datetime.end_of_day
    end

    def query_service
      @query_service ||= Sufia::QueryService.new
    end
end
