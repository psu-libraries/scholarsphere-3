# frozen_string_literal: true
class LdapUser
  class << self
    def get_user(filter, fields = [])
      retry_if { Hydra::LDAP.get_user(filter, fields) } || []
    end

    def get_groups(login)
      return [] if login.blank?
      retry_if { parse_ldap_groups(group_response_from_ldap(login)) } || []
    end

    def check_ldap_exist!(login)
      return false if login.blank?
      retry_if { Hydra::LDAP.does_user_exist?(Net::LDAP::Filter.eq("uid", login)) } || false
    end

    def filter_for(*people)
      return "" if people.empty?
      "(| " + people.map { |p| "(eduPersonPrimaryAffiliation=#{p.to_s.upcase})" }.join(" ") + ")))"
    end

    private

      def parse_ldap_groups(result)
        return [] if result.empty?
        result.first[:psmemberof].select { |y| y.starts_with? "cn=umg/" }.map do |x|
          x.sub(/^cn=/, "").sub(/,dc=psu,dc=edu/, "")
        end
      end

      # Retries the LDAP command up to .tries times, or catches any other kind of LDAP error without retrying.
      # return [block or nil]
      def retry_if
        tries.times.each do
          result = yield
          return result unless unwilling?
          sleep(Rails.application.config.ldap_unwilling_sleep)
        end
        Rails.logger.warn "LDAP is unwilling to perform this operation, try upping the number of tries"
        nil
      rescue Net::LDAP::Error => e
        Rails.logger.warn "Error getting LDAP response: #{ldap_error_message(e)}"
        nil
      end

      def tries
        7
      end

      # Numeric code returned by LDAP if it is feeling "unwilling"
      def unwilling?
        Hydra::LDAP.connection.get_operation_result.code == 53
      end

      # Response from LDAP
      # We have to pass a block, see https://github.com/projecthydra-labs/hydra-ldap/issues/8
      def group_response_from_ldap(login)
        Hydra::LDAP.groups_for_user(Net::LDAP::Filter.eq("uid", login)) { |r| r }
      end

      def ldap_error_message(e)
        "#{Hydra::LDAP.connection.get_operation_result.message}\nException: #{e.exception}\n#{e.backtrace.join("\n")}"
      end
  end
end
