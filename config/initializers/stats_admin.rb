# -*- coding: utf-8 -*-=
# frozen_string_literal: true

class Sufia::StatsAdmin
  def self.matches?(request)
    current_user = request.env['warden'].user
    return false if current_user.blank?

    current_user.groups.include? ScholarSphere::Application.config.admin_group
  end
end
