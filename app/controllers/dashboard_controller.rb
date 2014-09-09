class DashboardController < ApplicationController
  include Sufia::DashboardControllerBehavior

  def index
    @incoming = ProxyDepositRequest.where(receiving_user_id: current_user.id).reject &:deleted_file?
    @outgoing = ProxyDepositRequest.where(sending_user_id: current_user.id)
    super
  end

  protected

  # Formats the user's activities into human-readable strings used for rendering JSON
  def human_readable_user_activity
    current_user.get_all_user_activity(24*60*60).map do |event|
      [event[:action], "#{time_ago_in_words(Time.at(event[:timestamp].to_i))} ago", event[:timestamp].to_i]
    end
  end

end