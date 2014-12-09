class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile
  include Hydra::Collections::Collectible
  include Blacklight::SolrHelper

  def file_format
    return nil if self.mime_type.blank? and self.format_label.blank?
    return self.mime_type.split('/')[1]+ " ("+self.format_label.join(", ")+")" unless self.mime_type.blank? or self.format_label.blank?
    return self.mime_type.split('/')[1] unless self.mime_type.blank?
    return self.format_label
  end

  def export_as_endnote
    end_note_format = {
      '%T' => [:title, lambda { |x| x.first }],
      '%Q' => [:title, lambda { |x| x.to_ary.slice(1, -1) }],
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
      '%~' => ScholarSphere::Application::config.application_name,
      '%W' => 'Penn State University'
    }
    text = []
    text << "%0 GenericFile"
    end_note_format.each do |endnote_key, mapping|
      if mapping.is_a? String
        values = [mapping]
      else
        values = self.send(mapping[0]) if self.respond_to? mapping[0]
        values = mapping[1].call(values) if mapping.length == 2
        values = [values] unless values.is_a? Array
      end
      next if values.empty? or values.first.nil?
      spaced_values = values.join("; ")
      text << "#{endnote_key} #{spaced_values}"
    end
    return text.join("\n")
  end

  def registered?
    read_groups.include?('registered')
  end

  def public?
    read_groups.include?('public')
  end

  def characterize
    if !content.nil? && content.content.size > 2**30
      return false
    end
    super
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
    ids.map {|id| GenericFile.load_instance_from_solr id}
  end

  def audit(force = false)
    logs = []
    self.per_version do |ver|
      logs << audit_each(ver, force)
    end
    logs
  end

  def audit_each(version, force = false)
    latest_audit = logs(version.dsid).first
    unless force
      return latest_audit unless ::GenericFile.needs_audit?(version, latest_audit)
    end
    #  Resque.enqueue(AuditJob, version.pid, version.dsid, version.versionID)
    Sufia.queue.push(AuditJob.new(version.pid, version.dsid, version.versionID))

    # run the find just incase the job has finished already
    latest_audit = logs(version.dsid).first
    latest_audit = ChecksumAuditLog.new(pass: NO_RUNS, pid: version.pid, dsid: version.dsid, version: version.versionID) unless latest_audit
    latest_audit
  end

  def self.audit(version, force = false)
    self.find(version.pid).audit_each(version,force)
  end

  def permissions=(params)
    params[:new_user_name].each { |user, access| User.from_url_component(user) } if params[:new_user_name].present?
    super(params)
  end

end
