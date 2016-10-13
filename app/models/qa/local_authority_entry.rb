# frozen_string_literal: true
class Qa::LocalAuthorityEntry < ActiveRecord::Base
  belongs_to :local_authority
end
