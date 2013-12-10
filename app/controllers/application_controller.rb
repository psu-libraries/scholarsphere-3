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

class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  # Adds Hydra behaviors into the application controller
  include Hydra::Controller::ControllerBehavior
  # Adds Sufia behaviors into the application controller
  include Sufia::Controller

  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions.

  layout 'sufia-two-column'

  protect_from_forgery

  ## Force the session to be restarted on every request.  The ensures that when the REMOTE_USER header is not set, the user will be logged out.
  before_filter :clear_session_user
  before_filter :set_current_user
  before_filter :filter_notify
  before_filter :notifications_number

  # Intercept errors and render user-friendly pages
  unless Rails.env.development? || Rails.env.test?
    rescue_from NameError, :with => :render_500
    rescue_from RuntimeError, :with => :render_500
    rescue_from ActionView::Template::Error, :with => :render_500
    rescue_from ActiveRecord::StatementInvalid, :with => :render_500
    rescue_from Mysql2::Error, :with => :render_500
    rescue_from Net::LDAP::LdapError, :with => :render_500
    rescue_from RSolr::Error::Http, :with => :render_500
    rescue_from Blacklight::Exceptions::ECONNREFUSED, :with => :render_500
    rescue_from Errno::ECONNREFUSED, :with => :render_500
    rescue_from Rubydora::FedoraInvalidRequest, :with => :render_500
    rescue_from ActionDispatch::Cookies::CookieOverflow, :with => :render_500
    rescue_from Redis::CannotConnectError, :with => :render_500
    rescue_from AbstractController::ActionNotFound, :with => :render_404
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    rescue_from ActionController::RoutingError, :with => :render_404
    rescue_from Blacklight::Exceptions::InvalidSolrID, :with => :render_404
  end

  def clear_session_user
    if request.nil?
      logger.warn "Request is Nil, how weird!!!"
      return
    end

    # only logout if the REMOTE_USER is not set in the HTTP headers and a user is set within warden
    # logout clears the entire session including flash messages
    search = session[:search].dup if session[:search]
    request.env['warden'].logout unless user_logged_in?
    session[:search] = search
  end

  def set_current_user
    User.current = current_user
  end

  def render_404(exception)
    logger.error("Rendering 404 page due to exception: #{exception.inspect} - #{exception.backtrace if exception.respond_to? :backtrace}")
    render :template => '/error/404', :layout => "error", :formats => [:html], :status => 404
  end

  def render_500(exception)
    logger.error("Rendering 500 page due to exception: #{exception.inspect} - #{exception.backtrace if exception.respond_to? :backtrace}")
    render :template => '/error/500', :layout => "error", :formats => [:html], :status => 500
  end

  def filter_notify
    # remove error inserted since we are not showing a page before going to web access, this error message always shows up a page too late.
    # for the moment just remove it always.  If we show a transition page in the future we may want to  display it then.
    if flash[:alert].present?
      flash[:alert] = [flash[:alert]].flatten.reject do |item|
        # first remove the bogus message
        item == 'You need to sign in or sign up before continuing.'
        # Also, remove extraneous paperclip errors for weird file types
        item =~ /is not recognized by the 'identify' command/
      end
      # then make the flash nil if that was the only message in the flash
      flash[:alert] = nil if flash[:alert].blank?
    end
  end

  def notifications_number
    @notify_number = 0
    @batches = []
    return if action_name == "index" and controller_name == "mailbox"
    if User.current
      @notify_number = User.current.mailbox.inbox(:unread => true).distinct(:id).count
      @batches = User.current.mailbox.inbox.map { |msg| msg.last_message.body[/<a class="batchid ui-helper-hidden">(.*)<\/a>The file(.*)/,1] }.select { |val| !val.blank? }
    end
  end

 protected
  def user_logged_in?
    user_signed_in?
  end

  def has_access?
    unless current_user && current_user.ldap_exist?
      logger.error "User: `#{current_user.user_key}' does not exist in ldap"
      render :template => '/error/401', :layout => "error", :formats => [:html], :status => 401
    end
  end
end
