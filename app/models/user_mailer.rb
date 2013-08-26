class UserMailer < ActionMailer::Base

  def response_for_information(email, name)
    @view_data = {email:email, name:name}
    attachments['scholarsphere-information.pdf'] = File.read(Rails.root.join('public/scholarsphere-landing-response.pdf'))
    attachments.inline['logo.png'] = File.read(Rails.root.join('app/assets/images/site_images/logo_psuss_shield.png'))
    mail( to: email, cc:ScholarSphere::Application.config.landing_email, from: ScholarSphere::Application.config.landing_from_email, subject: "ScholarSphere Information Response")
  end
end
