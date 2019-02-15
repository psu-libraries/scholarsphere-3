# frozen_string_literal: true

class User < ApplicationRecord
  extend Deprecation

  include CurationConcerns::User
  include Sufia::User
  include Sufia::UserUsageStats

  # TODO: Removed in Sufia 7?
  # Workaround to retry LDAP calls a number of times
  # include Sufia::Utils

  self.include_root_in_json = false

  Devise.add_module(:http_header_authenticatable,
                    strategy: true,
                    controller: :sessions,
                    model: 'devise/models/http_header_authenticatable')

  devise :http_header_authenticatable

  class << self
    def batch_user
      User.find_by_user_key(batch_user_key) || User.create!(Devise.authentication_keys.first => batch_user_key)
    end

    def audit_user
      User.find_by_user_key(audit_user_key) || User.create!(Devise.authentication_keys.first => audit_user_key)
    end

    def groups(login)
      Deprecation.warn(nil, 'User.groups has been deprecated, use PsuDir::LdapUser.get_groups instead')
      PsuDir::LdapUser.get_groups(login)
    end

    def query_ldap_by_name_or_id(id_or_name_part)
      person_filter = PsuDir::LdapUser.filter_for(:student, :faculty, :staff, :employee)
      filter = Net::LDAP::Filter.construct("(& (| (uid=#{id_or_name_part}* ) (givenname=#{id_or_name_part}*) (sn=#{id_or_name_part}*)) #{person_filter})")
      users = PsuDir::LdapUser.get_users(filter, ['uid', 'displayname'])
      # handle the issue that searching with a few letters returns more than 1000 items wich causes an error in the system
      if users.nil? && (Hydra::LDAP.connection.get_operation_result[:message] == 'Size Limit Exceeded')
        filter2 = Net::LDAP::Filter.construct("(& (uid=#{id_or_name_part}* ) #{person_filter})")
        users = PsuDir::LdapUser.get_users(filter2, ['uid', 'displayname'])
      end
      users.map { |u| { id: u[:uid].first, text: "#{u[:displayname].first} (#{u[:uid].first})" } }
    end

    def directory_attributes(login, attrs = [])
      PsuDir::LdapUser.get_users(Net::LDAP::Filter.eq('uid', login), attrs)
    end

    def from_url_component(component)
      user = super(component)
      return user unless user.nil?

      user = User.new(login: component, email: component, system_created: true, logged_in: false)
      if PsuDir::LdapUser.check_ldap_exist!(user.login)
        user.populate_attributes
      else
        user = nil
      end
      user
    end
  end

  # put in to remove deprication warnings since the parent class overrides our login with it's own
  def login
    self[:login]
  end

  def to_s
    self[:login]
  end

  def name
    display_name.titleize || login
  rescue StandardError
    login
  end

  def administrator?
    groups.include? 'umg/up.dlt.scholarsphere-admin-viewers'
  end

  # In Sufia 7, administrators are granted edit rights via Ability, so if
  # if the administrator isn't the depositor, or isn't in the edit_users
  # group, then they're administrating the work.
  def administrating?(file)
    administrator? && (login != file.depositor && !file.edit_users.include?(login))
  end

  # Redefine this for more intuitive keys in Redis
  def to_param
    login
  end

  def ldap_exist?
    return ldap_available unless ldap_last_update.blank? || ((Time.now - ldap_last_update) > 24 * 60 * 60)

    update_user_attributes(ldap_available: ldap_user_exist?)
    ldap_available
  end

  # Groups that user is a member of
  def groups
    return group_list.split(';?;') unless groups_last_update.blank? || ((Time.now - groups_last_update) > 24 * 60 * 60)

    update_ldap_groups
  end

  def populate_attributes
    return unless ldap_user_exist? && directory_attributes

    update_user_attributes(
      email: get_net_attribute(directory_attributes, :mail),
      display_name: get_net_attribute(directory_attributes, :displayname),
      address: get_net_attribute_with_new_lines(directory_attributes, :postaladdress),
      admin_area: get_net_attribute(directory_attributes, :psadminarea),
      department: get_net_attribute(directory_attributes, :psdepartment),
      title: get_net_attribute(directory_attributes, :title),
      office: get_net_attribute_with_new_lines(directory_attributes, :psofficelocation),
      chat_id: get_net_attribute(directory_attributes, :pschatname),
      website: get_net_attribute_with_new_lines(directory_attributes, :labeleduri),
      affiliation: get_net_attribute(directory_attributes, :edupersonprimaryaffiliation),
      telephone: get_net_attribute(directory_attributes, :telephonenumber),
      ldap_available: true
    )
    update_ldap_groups
  end

  def directory_attributes
    @directory_attributes ||= self.class.directory_attributes(login).first
  end

  private

    def get_net_attribute(entry, attribute_name, blank_return = nil)
      entry.attribute_names.include?(attribute_name) ? entry[attribute_name].first : blank_return
    end

    def get_net_attribute_with_new_lines(entry, attribute_name)
      attribute = get_net_attribute(entry, attribute_name, '').tr('$', "\n")
      attribute.presence
    end

    def ldap_user_exist?
      PsuDir::LdapUser.check_ldap_exist!(login)
    end

    def update_ldap_groups
      list = PsuDir::LdapUser.get_groups(login).sort!
      return list if list.empty?

      Rails.logger.debug "$#{login}$ groups = #{list}"
      update(group_list: list.join(';?;'), groups_last_update: Time.now)
      list
    end

    def update_user_attributes(attrs = {})
      attrs.merge(ldap_last_update: Time.now)
      update(attrs)
    end
end
