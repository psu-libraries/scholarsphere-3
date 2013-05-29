# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
class ContactFormController < ApplicationController
  include Sufia::ContactFormControllerBehavior
  def after_deliver
    ActionMailer::Base.mail(
       :from=> Sufia::Engine.config.contact_form_delivery_from,
       :to=> params[:contact_form][:email],
       :subject=> "ScholarSphere Contact Form - #{params[:contact_form][:subject]}",
       :body=> Sufia::Engine.config.contact_form_delivery_body
     ).deliver
  end 
end
