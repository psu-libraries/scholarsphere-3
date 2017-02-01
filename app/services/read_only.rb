# frozen_string_literal: true
class ReadOnly
  class << self
    def read_only?
      ScholarSphere::Application.config.respond_to?(:read_only) && ScholarSphere::Application.config.read_only
    end

    def announcement_text
      homepage_text.blank? ? default_read_only_announcement : homepage_text
    end

    private

      def homepage_text
        block = ContentBlock.find_by(name: 'annoucement_text')
        return "" unless block
        block.value.html_safe
      end

      def default_read_only_announcement
        'The system is currently in read only mode for maintenance. Please try again later to upload or modify your ScholarSphere content.'
      end
  end
end
