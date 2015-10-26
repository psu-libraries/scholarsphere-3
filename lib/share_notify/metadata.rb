module ShareNotify::Metadata
  extend ActiveSupport::Concern

  included do

    property :share_notify_id, predicate: ::RDF::URI("http://scholarsphere.psu.edu/ns#shareNotifyId"), multiple: false do |index|
      index.as :stored_searchable
    end

  end

  def share_notified?
    !self.share_notify_id.nil?
  end

end
