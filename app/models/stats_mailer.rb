# frozen_string_literal: true
class StatsMailer < ActionMailer::Base
  def stats_mail(start_datetime, end_datetime)
    @presenter = StatsPresenter.new(start_datetime, end_datetime)

    attachments[::I18n.t("statistic.report.csv.file_name", date_str: @presenter.date_str)] = GenericFileListToCSVService.new(::GenericFile.find_by_date_created(start_datetime, end_datetime)).csv

    mail(to: ScholarSphere::Application.config.stats_email, from: ScholarSphere::Application.config.stats_from_email, subject: ::I18n.t("statistic.report.subject"))
  end
end
