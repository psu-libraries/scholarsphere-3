# frozen_string_literal: true

require 'open-uri'

if ENV['REPOSITORY_EXTERNAL_FILES'] == 'true'
  module ActiveFedora
    class File
      def redirect_content
        fedora_config = Rails.application.config_for(:fedora)
        open(
          uri,
          http_basic_authentication: [fedora_config['user'], fedora_config['password']],
          allow_redirections: :all
        )
      end

      # If the object's content is empty, assume it is Fedora external
      # content and use the Fedora redirect
      def local_or_remote_content(ensure_fetch = true)
        if new_record?
          if @content.present? && (@content.respond_to? :path)
            return @content
          else
            path = file_path
            return ::File.new(path)
          end
        end

        @content ||= ensure_fetch ? remote_content : @ds_content
        @content.rewind if behaves_like_io?(@content)
        return @content if @content.nil?
        @content = redirect_content # if content_empty?
        @content
      end

      def persisted_size
        if remote?
          ActiveFedora.fedora.connection.head(ldp_source.head.response.headers['location']).response['content-length'].to_f
        else
          ldp_source.head.content_length unless new_record?
        end
      end

      def remote?
        return true if new_record?
        ldp_source.head.response.status == 307
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

      def destroy
        # store off attributes before the record is deleted
        is_remote = remote?
        lfile_path = file_path

        # delete the record
        result = super

        # delete the binary store directory for the file if it is remote
        if is_remote
          bag_directory = Pathname(lfile_path).parent.parent
          FileUtils.rm_rf(bag_directory)
        end
        result
      end

      def file_path
        return unless remote?
        Scholarsphere::Pairtree.new(self, nil).storage_path(file_url)
      end

      def file_url
        url = mime_type.split('URL="')[1][0..-2] if mime_type.present? && mime_type.include?('URL=')
        url ||= attribute_url
        url
      end

      def attribute_url
        local_mime_type = metadata.attributes['http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasMimeType'].first
        local_mime_type.split('url="')[1][0..-2]
      end
    end
  end
end
