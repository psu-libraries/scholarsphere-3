# frozen_string_literal: true

class ContactFormController < ApplicationController
  include Sufia::ContactFormControllerBehavior
  with_themed_layout '1_column'

  def after_deliver
    UserMailer.acknowledgment_email(params).deliver_now
  end

  before_action :check_recaptcha, only: :create

  def check_recaptcha
    return if verify_recaptcha(model: @contact_form)

    flash[:error] = @contact_form.errors.full_messages.map(&:to_s).join(', ')
    render :new
  end
end
