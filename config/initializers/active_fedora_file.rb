# frozen_string_literal: true

require 'open-uri'

if ENV['REPOSITORY_EXTERNAL_FILES'] == 'true'
  module ActiveFedora
    class File
      def redirect_content
        fedora_config = Rails.application.config_for(:fedora)
        StringIO.new(
          open(
            uri,
            http_basic_authentication: [fedora_config['user'], fedora_config['password']],
            allow_redirections: :all
          ).read
        )
      end

      # If the object's content is empty, assume it is Fedora external
      # content and use the Fedora redirect
      def local_or_remote_content(ensure_fetch = true)
        return @content if new_record?

        @content ||= ensure_fetch ? remote_content : @ds_content
        @content.rewind if behaves_like_io?(@content)
        return @content if @content.nil?
        @content = redirect_content # if content_empty?
        @content
      end

      # Check to see if the object's content is empty
      def content_empty?
        return false if behaves_like_io?(@content) && @content.read.empty?
        return true if @content.class == String && @content.empty?
        false
      end

      def original_name
        if super.starts_with?('http')
          super.match(/[^\/]+$/)[0]
        else
          super
        end
      end
    end
  end
end
