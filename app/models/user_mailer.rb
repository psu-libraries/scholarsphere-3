# frozen_string_literal: true
class UserMailer < ActionMailer::Base
  def response_for_information(email, first_name)
    @view_data = { email: email, first_name: first_name }

    attachments['scholarsphere-information.pdf'] = File.read(Rails.root.join('public/scholarsphere-landing-response.pdf'))
    mail(to: email, bcc: ScholarSphere::Application.config.landing_email, from: ScholarSphere::Application.config.landing_from_email, subject: "ScholarSphere - We're here to help")
  end
end
