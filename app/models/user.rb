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

  #put in to remove deprication warnings since the parent class overrides our login with it's own
  def login
    self[:login]
  end

  def to_s
    self[:login]
  end

  def name
    return self.display_name.titleize || self.login rescue self.login
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
    if (ldap_last_update.blank? || ((Time.now-ldap_last_update) > 24*60*60 ))
      return ldap_exist!
    end
    return ldap_available
  end

  def ldap_exist!
    return false if self.login.blank?
    exist = retry_unless(7.times, lambda { Hydra::LDAP.connection.get_operation_result.code == 53 }) do
      Hydra::LDAP.does_user_exist?(Net::LDAP::Filter.eq('uid', login))
    end rescue false
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
    return exist
  end

  # Groups that user is a member of
  def groups
    if (groups_last_update.blank? || ((Time.now-groups_last_update) > 24*60*60 ))
      return groups!
    end
    return self.group_list.split(";?;")
  end

  def groups!
    return [] if self.login.blank?
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
    return list
  end

  def self.groups(login)
    groups = retry_unless(7.times, lambda { Hydra::LDAP.connection.get_operation_result.code == 53 }) do
      Hydra::LDAP.groups_for_user(Net::LDAP::Filter.eq('uid', login)) do |result|
        result.first[:psmemberof].select{ |y| y.starts_with? 'cn=umg/' }.map{ |x| x.sub(/^cn=/, '').sub(/,dc=psu,dc=edu/, '') }
      end rescue []
    end
    return groups
  end

  def self.query_ldap_by_name_or_id(id_or_name_part)
    person_filter = "(| (eduPersonPrimaryAffiliation=STUDENT) (eduPersonPrimaryAffiliation=FACULTY) (eduPersonPrimaryAffiliation=STAFF) (eduPersonPrimaryAffiliation=EMPLOYEE))))"
    filter = Net::LDAP::Filter.construct("(& (| (uid=#{id_or_name_part}* ) (givenname=#{id_or_name_part}*) (sn=#{id_or_name_part}*)) #{person_filter})")
    users = retry_unless(7.times, lambda { Hydra::LDAP.connection.get_operation_result.code == 53 }) do
        Hydra::LDAP.get_user(filter,['uid','displayname'])
    end rescue []
    # handle the issue that searching with a few letters returns more than 1000 items wich causes an error in the system
    if (users == nil) &&   (Hydra::LDAP.connection.get_operation_result[:message]=="Size Limit Exceeded")
      filter2 = Net::LDAP::Filter.construct("(& (uid=#{id_or_name_part}* ) #{person_filter})")
      users = retry_unless(7.times, lambda { Hydra::LDAP.connection.get_operation_result.code == 53 }) do
        Hydra::LDAP.get_user(filter2,['uid','displayname'])
      end rescue []
    end
    return users.map {|u| {id: u[:uid].first, text: "#{u[:displayname].first} (#{u[:uid].first})"} }
  end

  def populate_attributes
    #update exist cache
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
    attrs[:email] = entry[:mail].first rescue nil
    attrs[:display_name] = entry[:displayname].first rescue nil
    attrs[:address] = entry[:postaladdress].first.gsub('$', "\n") rescue nil
    attrs[:admin_area] = entry[:psadminarea].first rescue nil
    attrs[:department] = entry[:psdepartment].first rescue nil
    attrs[:title] = entry[:title].first rescue nil
    attrs[:office] = entry[:psofficelocation].first.gsub('$', "\n") rescue nil
    attrs[:chat_id] = entry[:pschatname].first rescue nil
    attrs[:website] = entry[:labeleduri].first.gsub('$', "\n") rescue nil
    attrs[:affiliation] = entry[:edupersonprimaryaffiliation].first rescue nil
    attrs[:telephone] = entry[:telephonenumber].first rescue nil
    update_attributes(attrs)

    # update the group cache also
    groups!
  end

  def directory_attributes(attrs=[])
    self.class.directory_attributes(login, attrs)
  end

  def self.directory_attributes(login, attrs=[])
    attrs = retry_unless(7.times, lambda { Hydra::LDAP.connection.get_operation_result.code == 53 }) do
      Hydra::LDAP.get_user(Net::LDAP::Filter.eq('uid', login), attrs)
    end rescue []
    return attrs
  end

  def self.from_url_component(component)
    user = super(component)
    if user.nil?
      user = User.create(login: component, email: component, system_created: true, logged_in: false)
      user.populate_attributes
    end
    return user
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
end
