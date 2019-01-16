# frozen_string_literal: true

class RoleMapper
  def self.roles(uid)
    u = User.find_by(login: uid)
    return [] unless u

    u.groups
  end
end
