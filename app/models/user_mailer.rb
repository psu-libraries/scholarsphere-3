# frozen_string_literal: true

class UserMailer < ActionMailer::Base
  attr_reader :presenter
  default from: Rails.application.config.action_mailer.default_options.fetch(:from)

  def acknowledgment_email(params)
    return if params[:sufia_contact_form][:email].split('@').last == 'psu.edu'

    mail(to: params[:sufia_contact_form][:email],
         subject: "ScholarSphere Contact Form - #{params[:sufia_contact_form][:subject]}")
  end

  def stats_email(start_datetime, end_datetime)
    @presenter = StatsPresenter.new(start_datetime, end_datetime)
    attachments[stats_report_name] = stats_report
    mail(to: ScholarSphere::Application.config.stats_email,
         subject: ::I18n.t('statistic.report.subject'))
  end

  def user_stats_email(user:, start_date: Date.today.last_month.beginning_of_month, end_date: Date.today.last_month.end_of_month)
    @presenter = UserStatsPresenter.new(start_date: start_date, end_date: end_date, user: user)
    return if @presenter.file_downloads.zero?

    mail(to: user.email,
         subject: ::I18n.t('statistic.user_stats.subject'))
  end

  private

    def stats_report_name
      ::I18n.t('statistic.report.csv.file_name', date_str: presenter.date_str)
    end

    def stats_report
      GenericWorkListToCSVService.new(
        GenericWork.where(
          Sufia::QueryService.new.build_date_query(presenter.start_datetime, presenter.end_datetime)
        )
      ).csv
    end
end
