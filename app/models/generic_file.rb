class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile

  def self.indexer
    GenericFileIndexingService
  end

  def file_format
    return nil if mime_type.blank? && format_label.blank?
    return mime_type.split('/')[1] + " (" + format_label.join(", ") + ")" unless mime_type.blank? || format_label.blank?
    return mime_type.split('/')[1] unless mime_type.blank?
    format_label
  end

  def export_as_endnote
    end_note_format = {
      '%T' => [:title, ->(x) { x.first }],
      '%Q' => [:title, ->(x) { x.to_ary.slice(1, -1) }],
      '%A' => [:creator],
      '%C' => [:publication_place],
      '%D' => [:date_created],
      '%8' => [:date_uploaded],
      '%E' => [:contributor],
      '%I' => [:publisher],
      '%J' => [:series_title],
      '%@' => [:isbn],
      '%U' => [:related_url],
      '%7' => [:edition_statement],
      '%R' => [:persistent_url],
      '%X' => [:description],
      '%G' => [:language],
      '%[' => [:date_modified],
      '%9' => [:resource_type],
      '%~' => ScholarSphere::Application.config.application_name,
      '%W' => 'Penn State University'
    }
    text = []
    text << "%0 GenericFile"
    end_note_format.each do |endnote_key, mapping|
      if mapping.is_a? String
        values = [mapping]
      else
        values = send(mapping[0]) if self.respond_to? mapping[0]
        values = mapping[1].call(values) if mapping.length == 2
        values = [values] unless values.is_a? Array
      end
      next if values.empty? || values.first.nil?
      spaced_values = values.join("; ")
      text << "#{endnote_key} #{spaced_values}"
    end
    text.join("\n")
  end

  def registered?
    read_groups.include?('registered')
  end

  def public?
    read_groups.include?('public')
  end

  # Get the files with a sibling relationship (belongs_to :batch)
  # The batch id is minted when visiting the upload screen and attached
  # to each file when it is done uploading.  The Batch object is not created
  # until all objects are done uploading and the user is redirected to
  # BatchController#edit.  Therefore, we must handle the case where
  # self.batch_id is set but self.batch returns nil.
  def related_files
    return [] if batch.nil?
    ids = batch.generic_file_ids.reject { |sibling| sibling == id }
    ids.map { |id| GenericFile.load_instance_from_solr id }
  end

  def self.build_date_query(start_datetime, end_datetime)
    start_date_str =  start_datetime.utc.strftime(date_format)
    end_date_str = if end_datetime.blank?
                     "*"
                   else
                     end_datetime.utc.strftime(date_format)
                   end
    "date_uploaded_dtsi:[#{start_date_str} TO #{end_date_str}]"
  end

  def url
    "#{current_host}#{Sufia::Engine.routes.url_helpers.generic_file_path(self)}"
  end

  private

    def current_host
      Rails.application.get_vhost_by_host[1].chomp("/")
    end
end
