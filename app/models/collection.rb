class Collection < ActiveFedora::Base
  include Sufia::Collection

  before_save :update_permissions
  validates :title, presence: true

  def terms_for_display
    [:creator, :date_modified, :date_uploaded]
  end
  
  def terms_for_editing
    [:title, :description] + terms_for_display - [:date_modified, :date_uploaded]
  end
  
  # Test to see if the given field is required
  # @param [Symbol] key a field
  # @return [Boolean] is it required or not
  def required?(key)
    self.class.validators_on(key).any?{|v| v.kind_of? ActiveModel::Validations::PresenceValidator}
  end
  
  def to_param
    noid
  end

  def update_permissions
    self.visibility = "open"
  end
end
