# frozen_string_literal: true
class User < ActiveRecord::Base
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

  def self.batchuser
    User.find_by_user_key(batchuser_key) || User.create!(Devise.authentication_keys.first => batchuser_key)
  end

  def self.batchuser_key
    'batchuser'
  end

  def self.audituser
    User.find_by_user_key(audituser_key) || User.create!(Devise.authentication_keys.first => audituser_key)
  end

  def self.audituser_key
    'audituser'
  end

  def ldap_exist?
    return true if login == 'jcoyne' && Rails.env.development?
    if ldap_last_update.blank? || ((Time.now - ldap_last_update) > 24 * 60 * 60)
      return ldap_exist!
    end
    ldap_available
  end

  def ldap_exist!
    return false if login.blank?
    exist = check_ldap_exist!
    if Hydra::LDAP.connection.get_operation_result.code == 0
      Rails.logger.debug "exist = #{exist}"
      attrs = {}
      attrs[:ldap_available] = exist
      attrs[:ldap_last_update] = Time.now
      update_attributes(attrs)
      # TODO: Should we retry here if the code is 51-53???
    else
      Rails.logger.warn "LDAP error checking exists for #{login}, reason (code: #{Hydra::LDAP.connection.get_operation_result.code}): #{Hydra::LDAP.connection.get_operation_result.message}"
      return false
    end
    exist
  end

  # Groups that user is a member of
  def groups
    if groups_last_update.blank? || ((Time.now - groups_last_update) > 24 * 60 * 60)
      return groups!
    end
    group_list.split(";?;")
  end

  def groups!
    return [] if login.blank?
    list = self.class.groups(login)

    if Hydra::LDAP.connection.get_operation_result.code == 0
      list.sort!
      Rails.logger.debug "$#{login}$ groups = #{list}"
      attrs = {}
      attrs[:group_list] = list.join(";?;")
      attrs[:groups_last_update] = Time.now
      update_attributes(attrs)
      # TODO: Should we retry here if the code is 51-53???
    else
      Rails.logger.warn "Error getting groups for #{login} reason: #{Hydra::LDAP.connection.get_operation_result.message}"
      return []
    end
    list
  end

  def self.groups(login)
    groups = retry_unless(7.times, -> { Hydra::LDAP.connection.get_operation_result.code == 53 }) do
      begin
        Hydra::LDAP.groups_for_user(Net::LDAP::Filter.eq('uid', login)) do |result|
          result.first[:psmemberof].select { |y| y.starts_with? 'cn=umg/' }.map { |x| x.sub(/^cn=/, '').sub(/,dc=psu,dc=edu/, '') }
        end
      rescue
        []
      end
    end
    groups
  end

  def self.query_ldap_by_name_or_id(id_or_name_part)
    person_filter = "(| (eduPersonPrimaryAffiliation=STUDENT) (eduPersonPrimaryAffiliation=FACULTY) (eduPersonPrimaryAffiliation=STAFF) (eduPersonPrimaryAffiliation=EMPLOYEE))))"
    filter = Net::LDAP::Filter.construct("(& (| (uid=#{id_or_name_part}* ) (givenname=#{id_or_name_part}*) (sn=#{id_or_name_part}*)) #{person_filter})")
    users = begin
              retry_unless(7.times, -> { Hydra::LDAP.connection.get_operation_result.code == 53 }) do
                Hydra::LDAP.get_user(filter, ['uid', 'displayname'])
              end
            rescue
              []
            end
    # handle the issue that searching with a few letters returns more than 1000 items wich causes an error in the system
    if users.nil? && (Hydra::LDAP.connection.get_operation_result[:message] == "Size Limit Exceeded")
      filter2 = Net::LDAP::Filter.construct("(& (uid=#{id_or_name_part}* ) #{person_filter})")
      users = begin
                retry_unless(7.times, -> { Hydra::LDAP.connection.get_operation_result.code == 53 }) do
                  Hydra::LDAP.get_user(filter2, ['uid', 'displayname'])
                end
              rescue
                []
              end
    end
    users.map { |u| { id: u[:uid].first, text: "#{u[:displayname].first} (#{u[:uid].first})" } }
  end

  def self.query_ldap_by_name(given_name, surname)
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

  def self.get_users(name_filter)
    person_filter = "(| (eduPersonPrimaryAffiliation=STUDENT) (eduPersonPrimaryAffiliation=FACULTY) (eduPersonPrimaryAffiliation=STAFF) (eduPersonPrimaryAffiliation=EMPLOYEE) (eduPersonPrimaryAffiliation=RETIREE) (eduPersonPrimaryAffiliation=EMERITUS) (eduPersonPrimaryAffiliation=MEMBER)))"
    filter = Net::LDAP::Filter.construct("(& (& #{name_filter}) #{person_filter})")
    retry_unless(7.times, -> { Hydra::LDAP.connection.get_operation_result.code == 53 }) do
      Hydra::LDAP.get_user(filter, ['uid', 'givenname', 'sn', 'mail', 'eduPersonPrimaryAffiliation'])
    end
  rescue
    []
  end

  def populate_attributes
    # update exist cache
    exist = ldap_exist!
    Rails.logger.warn "No ldapentry exists for #{login}" unless exist
    return unless exist

    begin
      entry = directory_attributes.first
    rescue
      Rails.logger.warn "Error getting directory entry: #{Hydra::LDAP.connection.get_operation_result.message}"
      return
    end

    attrs = {}
    attrs[:email] = get_net_attribute(entry, :mail)
    attrs[:display_name] = get_net_attribute(entry, :displayname)
    attrs[:address] = get_net_attribute_with_new_lines(entry, :postaladdress)
    attrs[:admin_area] = get_net_attribute(entry, :psadminarea)
    attrs[:department] = get_net_attribute(entry, :psdepartment)
    attrs[:title] =  get_net_attribute(entry, :title)
    attrs[:office] = get_net_attribute_with_new_lines(entry, :psofficelocation)
    attrs[:chat_id] = get_net_attribute(entry, :pschatname)
    attrs[:website] = get_net_attribute_with_new_lines(entry, :labeleduri)
    attrs[:affiliation] = get_net_attribute(entry, :edupersonprimaryaffiliation)
    attrs[:telephone] = get_net_attribute(entry, :telephonenumber)
    update_attributes(attrs)

    # update the group cache also
    groups!
  end

  def directory_attributes(attrs = [])
    self.class.directory_attributes(login, attrs)
  end

  def self.directory_attributes(login, attrs = [])
    attrs = begin
              retry_unless(7.times, -> { Hydra::LDAP.connection.get_operation_result.code == 53 }) do
                Hydra::LDAP.get_user(Net::LDAP::Filter.eq('uid', login), attrs)
              end
            rescue
              []
            end
    attrs
  end

  def self.from_url_component(component)
    user = super(component)
    if user.nil?
      user = User.new(login: component, email: component, system_created: true, logged_in: false)
      if user.check_ldap_exist!
        user.populate_attributes
      else
        user = nil
      end
    end
    user
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

  def check_ldap_exist!
    return false if login.blank?
    begin
      return retry_unless(7.times, -> { Hydra::LDAP.connection.get_operation_result.code == 53 }) do
        begin
          Hydra::LDAP.does_user_exist?(Net::LDAP::Filter.eq('uid', login))
        # There is a weird error where the result is nil this retries until that error stops
        rescue => e
          logger.warn "rescued exception: #{e}"
          sleep(Sufia.config.retry_unless_sleep)
        end
      end
    rescue
      false
    end
  end

  private

    def get_net_attribute(entry, attribute_name, blank_return = nil)
      entry.attribute_names.include?(attribute_name) ? entry[attribute_name].first : blank_return
    end

    def get_net_attribute_with_new_lines(entry, attribute_name)
      attribute = get_net_attribute(entry, attribute_name, "").tr('$', "\n")
      attribute.blank? ? nil : attribute
    end
end
