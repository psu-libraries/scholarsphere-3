class StatsMailer < ActionMailer::Base

  def stats_mail(start_datetime, end_datetime)
    @presenter = StatsPresenter.new(start_datetime, end_datetime)

    attachments["scholarsphere-stats_#{@presenter.date_str}.csv"] = GenericFileListToCSVService.new(::GenericFile.find_by_date_created(start_datetime, end_datetime)).csv

    mail( to: ScholarSphere::Application.config.stats_email, from: ScholarSphere::Application.config.stats_from_email, subject: "ScholarSphere - Statistic Report")
  end
end
