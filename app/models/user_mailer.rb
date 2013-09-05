class UserMailer < ActionMailer::Base

  def response_for_information(email, first_name)
    @view_data = {email:email, first_name:first_name}

    attachments['scholarsphere-information.pdf'] = File.read(Rails.root.join('public/scholarsphere-landing-response.pdf'))
    attachments.inline['penn-state-mark.png'] = File.read(Rails.root.join('app/assets/images/penn-state-mark.png'))
    attachments.inline['scholarshere-logo.png'] = File.read(Rails.root.join('app/assets/images/scholarshere-logo.png'))
    attachments.inline['pennstate-it.png'] = File.read(Rails.root.join('app/assets/images/pennstate-it.png'))
    attachments.inline['universitylibraries.png'] = File.read(Rails.root.join('app/assets/images/universitylibraries.png'))
    mail( to: email, bcc:ScholarSphere::Application.config.landing_email, from: ScholarSphere::Application.config.landing_from_email, subject: "ScholarSphere - We'er here to help")
  end
end
