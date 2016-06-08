# frozen_string_literal: true
class UserMailer < ActionMailer::Base
  default from: Rails.application.config.action_mailer.default_options.fetch(:from)

  def acknowledgment_email(params)
    mail(to: params[:contact_form][:email],
         subject: "ScholarSphere Contact Form - #{params[:contact_form][:subject]}")
  end
end
