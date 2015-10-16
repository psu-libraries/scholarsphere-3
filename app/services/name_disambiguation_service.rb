class NameDisambiguationService
  attr_reader :name, :email_for_name

  def initialize(name)
    @name = name
    @email_for_name = {}
  end

  def disambiguate
    # check if it is an ID
    login_results = login_name(name)
    return [login_results] unless login_results.blank?

    email_results = email_in_name(name)
    return [email_results] unless email_results.blank?

    results = []

    # check for multiples
    names  = name.split(/and|;/)
    names.each do |name|
      name.gsub!(/\([^)]*\)/,"")
      name.strip!
      # parse each name
      # call to ldap to get the email and id
      email_results = email_for_name(name)
      results << email_results unless email_results.blank?
    end
    results
  end

  private

    private
      def login_name(name)
        attrs = User.directory_attributes(name, [:uid, :givenname, :sn, :mail, :eduPersonPrimaryAffiliation])
        return nil if attrs.count < 1
        attrs = attrs[0]
        {id: attrs[:uid][0], given_name: attrs[:givenname][0], surname: attrs[:sn][0],
           email: attrs[:mail][0] , affiliation: attrs[:eduPersonPrimaryAffiliation]}
      end

      def email_in_name(name)
        return unless name.include?("@")
        parts =  name.split(" ")
        email = parts.reject{|part| !part.include?("@")}[0]
        id = email.split('@')[0]
        result = login_name(id)
        result ||= {id: "", given_name: "", surname: "",
            email: email , affiliation: []}
      end

      def email_for_name( name)
        return "" if name.blank?
        return @email_for_name[name] unless @email_for_name[name].blank?

        # normal name
        name.gsub!(/[^\w\s,']/, ' ')
        parsed = Namae::Name.parse(name)
        result = try_name(parsed.given, parsed.family)
        if result == ""
          puts "got more than one for #{name}"
        end

        # title before the name
        if result.nil? &&  parsed.given &&parsed.given.count(" ") >= 1
          parts = name_parts(parsed.given,1)
          result = try_name(parts[:family], parsed.family)
        end

        # two words in the last name
        if result.nil? && name.count(" ") > 2
          parts = name_parts(name,2)
          result = try_name(parts[:given], parts[:family])
        end

        # titles after the name that namae had trouble parsing
        if result.nil? && name.count(',') > 0
          new_name = name.split(',')[0]
          result = email_for_name( new_name) if new_name.count(' ') > 0
        end

        if result.nil?
          puts "got zero for #{name}"
        end

        @email_for_name[name] = result
        return @email_for_name[name]
      end

      def try_name(given, family)
        return nil if family.blank?
        possible_users  = User.query_ldap_by_name(given, family)
        case possible_users.count
          when 1
            possible_users[0]
          when 0
            nil
          else
            ""
        end
      end

      def name_parts(name, count)
        parts = name.split(" ")
        first_name_count = parts.count - count
        return nil if count < 1
        {given: parts.first(first_name_count).join(" "), family: parts.last(count).join(" ")}
      end

end
