# frozen_string_literal: true

class EncodingService
  def self.call(content)
    content.encode('utf-8', invalid: :replace, undef: :replace)
  rescue StandardError => e
    "#{I18n.t('scholarsphere.encoding.error')}: #{e}"
  end
end
