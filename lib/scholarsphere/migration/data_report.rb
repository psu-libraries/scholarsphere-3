# frozen_string_literal: true

class DataReport
  attr_reader :rows

  def initialize(rows: nil)
    @rows = rows || 1_000_000
  end

  def versions
    FileUtils.rm_f('versions.csv')
    file = File.open('versions.csv', 'w')
    ActiveFedora::SolrService.query('has_model_ssim:FileSet', rows: rows, fl: ['id', 'title_tesim']).map do |hit|
      file.puts("#{hit.id},#{number_of_versions(hit.id)},#{hit.fetch('title_tesim', []).first}")
    end
    file.close
  end

  def file_set_permissions
    FileUtils.rm_f('file_set_permissions.csv')
    file = File.open('file_set_permissions.csv', 'w')
    work_dimensions = dimensions.map { |dim| "work_#{dim}" }
    file.puts "id,work_id,#{dimensions.join(',')},#{work_dimensions.join(',')},lease,embargo,work_lease,work_embargo,size"
    ActiveFedora::SolrService.query('has_model_ssim:FileSet', rows: rows, fl: ['id']).map do |hit|
      file.puts("#{hit.id},#{file_set_line(hit.id)}")
    end
    file.close
  end

  def file_set_addendum(ids)
    file = File.open('file_set_addendum.csv', 'w')
    ids.each do |id|
      file.puts("#{id},#{file_set_line(id)}")
    end
    file.close
  end

  private

    def number_of_versions(id)
      FileSet.find(id).original_file.versions.all.count
    rescue StandardError
      0
    end

    def dimensions
      %i[
        read_groups
        read_users
        edit_groups
        edit_users
      ]
    end

    def file_set_line(id)
      fs = FileSet.find(id)
      parent = fs.parent
      return 'No parent work' if parent.nil?

      fields = [parent.id]
      fields << dimensions.map { |dimension| fs.send(dimension).compact.sort.uniq.join(';') }
      fields << dimensions.map { |dimension| parent.send(dimension).compact.sort.uniq.join(';') }
      fields << lease_information(fs)
      fields << embargo_information(fs)
      fields << lease_information(parent)
      fields << embargo_information(parent)
      fields << fs.file_size.first
      fields.join(',')
    rescue StandardError => e
      e.message
    end

    def lease_information(resource)
      return if resource.lease.nil?

      if resource.lease.active?
        resource.lease.lease_expiration_date.strftime('%Y-%m-%d')
      else
        resource.lease.lease_history.first
      end
    end

    def embargo_information(resource)
      return if resource.embargo.nil?

      if resource.embargo.active?
        resource.embargo.embargo_release_date.strftime('%Y-%m-%d')
      else
        resource.embargo.embargo_history.first
      end
    end
end
