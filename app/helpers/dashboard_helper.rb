module DashboardHelper

  include Sufia::DashboardHelperBehavior

  def render_sent_transfers
    if @outgoing.present?
      render partial: 'transfers/sent'
    else
      "You haven't transferred any files."
    end
  end

  def render_received_transfers
    if @incoming.present?
      render partial: 'transfers/received'
    else
      "You haven't received any file transfer requests"
    end
  end

end
