class ApplicationController < ActionController::Base
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior
  include Sufia::Controller
  include Behaviors::HttpHeaderAuthenticatableBehavior

  layout 'sufia-one-column'

  protect_from_forgery

  before_filter :clear_session_user
  before_filter :filter_notify
  before_filter :notifications_number

  rescue_from ActiveFedora::ObjectNotFoundError, with: :render_404 unless Rails.env.development?

  unless Rails.env.development? || Rails.env.test?
    rescue_from AbstractController::ActionNotFound, with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionDispatch::Cookies::CookieOverflow, with: :render_500
    rescue_from ActionView::Template::Error, with: :render_500
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from ActiveRecord::StatementInvalid, with: :render_500
    rescue_from Blacklight::Exceptions::ECONNREFUSED, with: :render_500
    rescue_from Blacklight::Exceptions::InvalidSolrID, with: :render_404
    rescue_from Errno::ECONNREFUSED, with: :render_500
    rescue_from Mysql2::Error, with: :render_500
    rescue_from NameError, with: :render_500
    rescue_from Net::LDAP::LdapError, with: :render_500
    rescue_from Redis::CannotConnectError, with: :render_500
    rescue_from RSolr::Error::Http, with: :render_500
    rescue_from RuntimeError, with: :render_500
  end

  # Clears any user session and authorization information by:
  #   * forcing the session to be restarted on every request
  #   * ensuring the user will be logged out if REMOTE_USER is not set
  #   * clearing the entire session including flash messages
  def clear_session_user  
    return nil_request if request.nil?
    search = session[:search].dup if session[:search]
    request.env['warden'].logout unless user_logged_in?
    session[:search] = search
  end

  def render_404(exception)
    logger.error("Rendering 404 page due to exception: #{exception.inspect} - #{exception.backtrace if exception.respond_to? :backtrace}")
    render template: '/error/404', layout: "error", formats: [:html], status: 404
  end

  def render_500(exception)
    logger.error("Rendering 500 page due to exception: #{exception.inspect} - #{exception.backtrace if exception.respond_to? :backtrace}")
    render template: '/error/500', layout: "error", formats: [:html], status: 500
  end

  # Remove bogus error messages and extraneous paperclip errors.
  # Return a nil messages if that was the only content.
  # If we show a transition page in the future we may want to display it then.
  def filter_notify
    if flash[:alert].present?
      flash[:alert] = filtered_flash_messages
      flash[:alert] = nil if flash[:alert].blank?
    end
  end

  def handle_legacy_url_prefix
    legacy_prefix = "scholarsphere:".freeze
    id = params[:id].to_s
    if id.start_with?(legacy_prefix)
      new_id = id[legacy_prefix.length..-1]
      if block_given?
        # block should execute something along the lines of
        # redirect_to controller_name_path(new_id), status: :moved_permanently
        yield new_id
      end
    end
  end  

 protected
  def user_logged_in?
    user_signed_in? && ( valid_user?(request.headers) || Rails.env.test?)
  end

  def has_access?
    unless current_user && current_user.ldap_exist?
      logger.error "User: `#{current_user.user_key}' does not exist in ldap"
      render template: '/error/401', layout: "error", formats: [:html], status: 401
    end
  end

  def filtered_flash_messages
    [flash[:alert]].flatten.reject do |item|
      item == 'You need to sign in or sign up before continuing.'
      item =~ /is not recognized by the 'identify' command/
    end
  end

  def nil_request
    logger.warn("Request is Nil, how weird!!!")
    nil
  end
end
