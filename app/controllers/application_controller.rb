# frozen_string_literal: true
class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior
  include CurationConcerns::ApplicationControllerBehavior
  include Sufia::Controller
  include CurationConcerns::ThemedLayoutController
  include Devise::Behaviors::HttpHeaderAuthenticatableBehavior

  with_themed_layout '1_column'

  protect_from_forgery with: :exception

  before_action :clear_session_user, :filter_notify

  rescue_from ActiveFedora::ObjectNotFoundError,
              AbstractController::ActionNotFound,
              ActionController::RoutingError,
              ActionDispatch::Cookies::CookieOverflow,
              ActionView::Template::Error,
              ActiveRecord::RecordNotFound,
              ActiveRecord::StatementInvalid,
              Blacklight::Exceptions::ECONNREFUSED,
              Blacklight::Exceptions::InvalidSolrID,
              Errno::ECONNREFUSED,
              NameError,
              Net::LDAP::LdapError,
              Redis::CannotConnectError,
              RSolr::Error::Http,
              Ldp::BadRequest,
              StandardError,
              RuntimeError, with: :render_error_page unless Rails.env.development?

  # Mysql2 isn't loaded in Travis, so we'll skip testing it
  rescue_from Mysql2::Error, with: :render_error_page unless Rails.env.test?

  # Clears any user session and authorization information by:
  #   * forcing the session to be restarted on every request
  #   * ensuring the user will be logged out if REMOTE_USER is not set
  #   * clearing the entire session including flash messages
  def clear_session_user
    return nil_request if request.nil?
    search = session[:search].dup if session[:search]
    return_url = session[:user_return_to].dup if session[:user_return_to]
    request.env['warden'].logout unless user_logged_in?
    session[:search] = search
    session[:user_return_to] = return_url
  end

  # Overrides CurationConcerns::ApplicationControllerBehavior to use our error presenter with the default
  # Scholarsphere::Error exception
  def render_404
    @presenter = ErrorPresenter.new
    @presenter.log_exception
    render template: '/error', layout: 'error', formats: [:html], status: @presenter.status
  end

  # @param [Exception] exception
  # Renders a custom error page based on the class type of the exception.
  # Preserves existing behavior in {CurationConcerns::ApplicationControllerBehavior} and
  # {Hydra::Controller::ControllerBehavior} which applies special redirects to login pages
  # when {CanCan::AccessDenied} is raised.
  def render_error_page(exception)
    if exception.is_a?(CanCan::AccessDenied)
      deny_access(exception)
    else
      @presenter = ErrorPresenter.new(exception)
      @presenter.log_exception
      render template: '/error', layout: 'error', formats: [:html], status: @presenter.status
    end
  end

  # Remove bogus error messages and extraneous paperclip errors.
  # Return a nil messages if that was the only content.
  # If we show a transition page in the future we may want to display it then.
  # If a block is given, it should execute something along the lines of
  # redirect_to controller_name_path(new_id), status: :moved_permanently
  def filter_notify
    return unless flash[:alert].present?
    flash[:alert] = filtered_flash_messages
    flash[:alert] = nil if flash[:alert].blank?
  end

  def handle_legacy_url_prefix
    legacy_prefix = 'scholarsphere:'
    id = params[:id].to_s
    return id unless id.start_with?(legacy_prefix)
    new_id = id[legacy_prefix.length..-1]
    yield new_id if block_given?
    new_id
  end

  protected

    def user_logged_in?
      user_signed_in? && (valid_user?(request.headers) || Rails.env.test?)
    end

    def has_access?
      return if current_user && current_user.ldap_exist? && !ReadOnly.read_only?
      if ReadOnly.read_only?
        @announcement = ReadOnly.announcement_text
        render template: '/error/read_only', layout: 'homepage', formats: [:html], status: 503
      else
        logger.error "User: `#{current_user.user_key}' does not exist in ldap"
        render 'curation_concerns/base/unauthorized', status: :unauthorized
      end
    end

    def filtered_flash_messages
      [flash[:alert]].flatten.reject do |item|
        item == 'You need to sign in or sign up before continuing.' ||
          item =~ /is not recognized by the 'identify' command/
      end
    end

    def nil_request
      logger.warn('Request is Nil, how weird!!!')
      nil
    end
end
