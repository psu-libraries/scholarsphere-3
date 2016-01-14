class NameDisambiguationService
  attr_reader :name, :email_for_name_cache, :results

  def initialize(name)
    @name = name
    @email_for_name_cache = {}
    @results = []
  end

  def disambiguate
    query_result = login_name(name) || email_in_name(name)
    return query_result unless query_result.blank?

    multiple_names(name)
    results
  end

  private

    def login_name(id)
      attrs = User.directory_attributes(id, [:uid, :givenname, :sn, :mail, :eduPersonPrimaryAffiliation])
      return nil if attrs.count < 1
      [results_hash(attrs.first)]
    end

    # "thing" is an awful name - it's a placeholder to make this a pure function
    def email_in_name(thing)
      return unless thing.include?("@")
      parts = thing.split(" ")
      emails = parts.reject { |part| !part.include?("@") }
      results = []
      Array(emails).each do |email|
        id = email.split('@')[0]
        results << (login_name(id) || results_hash(mail: [email]))
      end
      results
    end

    def multiple_names(multi_name)
      multi_name.split(/and|;/).each do |n|
        n.gsub!(/\([^)]*\)/, "")
        n.strip!
        query_result = email_for_name(n)
        results << query_result unless query_result.blank?
      end
    end

    def results_hash(opts)
      {
        id:          opts.fetch(:uid, [""]).first,
        given_name:  opts.fetch(:givenname, [""]).first,
        surname:     opts.fetch(:sn, [""]).first,
        email:       opts.fetch(:mail).first,
        affiliation: opts.fetch(:eduPersonPrimaryAffiliation, [])
      }
    end

    def email_for_name(emailname)
      return "" if emailname.blank?
      return @email_for_name_cache[emailname] unless @email_for_name_cache[emailname].blank?

      # normal name
      emailname.gsub!(/[^\w\s,']/, ' ')
      parsed = Namae::Name.parse(emailname)
      result = try_name(parsed.given, parsed.family)

      result ||= title_before_name(parsed) || two_words_in_last_name(emailname) || title_after_name(emailname)

      Rails.logger.error("got zero for #{emailname}") if result.nil?

      @email_for_name_cache[emailname] = result
      @email_for_name_cache[emailname]
    end

    def try_name(given, family)
      return nil if family.blank?
      possible_users = User.query_ldap_by_name(given, family)
      return nil if possible_users.count == 0
      if possible_users.count > 1
        Rails.logger.error("Returning #{possible_users.first} but got more than name for given name #{given} and family name #{name}")
        return nil
      end
      possible_users.first
    end

    # namething is an awful variable name, but it distinguished this var from the class "name" var
    def name_parts(namething, count)
      parts = namething.split(" ")
      first_name_count = parts.count - count
      return nil if count < 1
      { given: parts.first(first_name_count).join(" "), family: parts.last(count).join(" ") }
    end

    def title_before_name(parsed)
      return unless parsed
      result = nil
      if parsed.given && parsed.given.count(" ") >= 1
        parts = name_parts(parsed.given, 1)
        result = try_name(parts[:family], parsed.family)
      end
      result
    end

    def two_words_in_last_name(emailname)
      result = nil
      if emailname.count(" ") > 2
        parts = name_parts(emailname, 2)
        result = try_name(parts[:given], parts[:family])
      end
      result
    end

    # titles after the name that namae had trouble parsing
    def title_after_name(emailname)
      result = nil
      if emailname.count(',') > 0
        new_name = emailname.split(',')[0]
        result = email_for_name(new_name) if new_name.count(' ') > 0
      end
      result
    end
end
