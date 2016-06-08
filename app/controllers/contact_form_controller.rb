# frozen_string_literal: true
class ContactFormController < ApplicationController
  include Sufia::ContactFormControllerBehavior
  def after_deliver
    UserMailer.acknowledgment_email(params).deliver_now
  end
end
