class ContactFormController < ApplicationController
  include Sufia::ContactFormControllerBehavior
  def after_deliver
    ActionMailer::Base.mail(
       from: Sufia::Engine.config.contact_form_delivery_from,
       to: params[:contact_form][:email],
       subject: "ScholarSphere Contact Form - #{params[:contact_form][:subject]}",
       body: Sufia::Engine.config.contact_form_delivery_body
     ).deliver_now
  end 
end
