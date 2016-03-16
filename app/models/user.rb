# frozen_string_literal: true
class User < ActiveRecord::Base
  extend Deprecation

  # Connects this user object to Sufia behaviors.
  include Sufia::User
  # Cache file views & downloads stats for each user
  include Sufia::UserUsageStats
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Adds acts_as_messageable for user mailboxes
  include Mailboxer::Models::Messageable
  # Workaround to retry LDAP calls a number of times
  include Sufia::Utils

  self.include_root_in_json = false

  Devise.add_module(:http_header_authenticatable,
                    strategy: true,
                    controller: :sessions,
                    model: 'devise/models/http_header_authenticatable')

  devise :http_header_authenticatable

  class << self
    def batchuser
      User.find_by_user_key(batchuser_key) || User.create!(Devise.authentication_keys.first => batchuser_key)
    end

    def batchuser_key
      'batchuser'
    end

    def audituser
      User.find_by_user_key(audituser_key) || User.create!(Devise.authentication_keys.first => audituser_key)
    end

    def audituser_key
      'audituser'
    end

    def groups(login)
      Deprecation.warn(nil, "User.groups has been deprecated, use LdapUser.get_groups instead")
      LdapUser.get_groups(login)
    end

    def query_ldap_by_name_or_id(id_or_name_part)
      person_filter = LdapUser.filter_for(:student, :faculty, :staff, :employee)
      filter = Net::LDAP::Filter.construct("(& (| (uid=#{id_or_name_part}* ) (givenname=#{id_or_name_part}*) (sn=#{id_or_name_part}*)) #{person_filter})")
      users = LdapUser.get_user(filter, ['uid', 'displayname'])
      # handle the issue that searching with a few letters returns more than 1000 items wich causes an error in the system
      if users.nil? && (Hydra::LDAP.connection.get_operation_result[:message] == "Size Limit Exceeded")
        filter2 = Net::LDAP::Filter.construct("(& (uid=#{id_or_name_part}* ) #{person_filter})")
        users = LdapUser.get_user(filter2, ['uid', 'displayname'])
      end
      users.map { |u| { id: u[:uid].first, text: "#{u[:displayname].first} (#{u[:uid].first})" } }
    end

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def query_ldap_by_name(given_name, surname)
      first_names = []
      first_names = given_name.split(/[\s.]+/) unless given_name.blank?
      users = []
      users = get_users("(givenname=#{first_names[0]}*) (givenname=*#{first_names[1]}*) (sn=#{surname})") if first_names.count >= 2
      users = get_users("(givenname=#{first_names[0]}) (sn=#{surname})") if users.count == 0 && first_names.count > 0
      users = get_users("(givenname=#{first_names[0]}*) (sn=#{surname})") if users.count == 0 && first_names.count > 0
      users = get_users("(givenname=*#{first_names[0]}*) (sn=#{surname})") if users.count == 0 && first_names.count > 0
      # users = get_users("(displayname=*#{first_names[0]}*) (displayname=*#{surname}*)") if users.count == 0
      users.map { |u| { id: u[:uid].first, given_name: u[:givenname].first, surname: u[:sn].first, email: u[:mail].first, affiliation: u[:eduPersonPrimaryAffiliation] } }
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def get_users(name_filter)
      person_filter = LdapUser.filter_for(:student, :faculty, :staff, :employee, :retiree, :emeritus, :member)
      filter = Net::LDAP::Filter.construct("(& (& #{name_filter}) #{person_filter})")
      LdapUser.get_user(filter, ['uid', 'givenname', 'sn', 'mail', 'eduPersonPrimaryAffiliation'])
    end

    def directory_attributes(login, attrs = [])
      LdapUser.get_user(Net::LDAP::Filter.eq('uid', login), attrs)
    end

    def from_url_component(component)
      user = super(component)
      return user unless user.nil?
      user = User.new(login: component, email: component, system_created: true, logged_in: false)
      if LdapUser.check_ldap_exist!(user.login)
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
    return display_name.titleize || login
  rescue
    login
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
    return group_list.split(";?;") unless groups_last_update.blank? || ((Time.now - groups_last_update) > 24 * 60 * 60)
    update_ldap_groups
  end

  def populate_attributes
    return unless ldap_user_exist? && directory_attributes
    update_user_attributes(
      email:          get_net_attribute(directory_attributes, :mail),
      display_name:   get_net_attribute(directory_attributes, :displayname),
      address:        get_net_attribute_with_new_lines(directory_attributes, :postaladdress),
      admin_area:     get_net_attribute(directory_attributes, :psadminarea),
      department:     get_net_attribute(directory_attributes, :psdepartment),
      title:          get_net_attribute(directory_attributes, :title),
      office:         get_net_attribute_with_new_lines(directory_attributes, :psofficelocation),
      chat_id:        get_net_attribute(directory_attributes, :pschatname),
      website:        get_net_attribute_with_new_lines(directory_attributes, :labeleduri),
      affiliation:    get_net_attribute(directory_attributes, :edupersonprimaryaffiliation),
      telephone:      get_net_attribute(directory_attributes, :telephonenumber),
      ldap_available: true
    )
    update_ldap_groups
  end

  def directory_attributes
    @directory_attributes ||= self.class.directory_attributes(login).first
  end

  # This override can be removed as soon as the error handler
  # for files not found has been added to Sufia.
  def trophy_files
    trophies.map do |t|
      begin
        ::GenericFile.load_instance_from_solr(t.generic_file_id)
      rescue ActiveFedora::ObjectNotFoundError
        logger.error("Invalid trophy for user #{user_key} (generic file id: #{t.generic_file_id})")
        nil
      end
    end.compact
  end

  private

    def get_net_attribute(entry, attribute_name, blank_return = nil)
      entry.attribute_names.include?(attribute_name) ? entry[attribute_name].first : blank_return
    end

    def get_net_attribute_with_new_lines(entry, attribute_name)
      attribute = get_net_attribute(entry, attribute_name, "").tr('$', "\n")
      attribute.blank? ? nil : attribute
    end

    def ldap_user_exist?
      LdapUser.check_ldap_exist!(login)
    end

    def update_ldap_groups
      list = LdapUser.get_groups(login).sort!
      return list if list.empty?
      Rails.logger.debug "$#{login}$ groups = #{list}"
      update_attributes(group_list: list.join(";?;"), groups_last_update: Time.now)
      list
    end

    def update_user_attributes(attrs = {})
      attrs.merge(ldap_last_update: Time.now)
      update_attributes(attrs)
    end
end
