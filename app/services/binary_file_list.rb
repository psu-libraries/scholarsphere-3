# frozen_string_literal: true

class BinaryFileList
  def self.list_files(io)
    file_set_ids_hash = ActiveFedora::SolrService.query('has_model_ssim:FileSet', fl: 'id', rows: FileSet.count + 100)
    file_set_ids = file_set_ids_hash.map { |id_hash| id_hash['id'] }.sort
    file_set_ids.each do |id|
      begin
        puts id
        fs = FileSet.find(id)
        fs.files.each do |file|
          file_digest = clean_digest(file.digest.first)
          found = false
          if file.versions.all.count.positive?
            file.versions.all.each do |version|
              version_file = ActiveFedora::File.find(ActiveFedora::File.uri_to_id(version.uri))
              digest = clean_digest(version_file.digest.first)
              io.puts digest
              found = true if file_digest == digest
            end
          end
          io.puts file_digest unless found
        end
      rescue StandardError => e
        puts e
      end
    end
  end

  def self.clean_digest(digest)
    clean = digest.to_s[9, 100]
    "/#{clean[0, 2]}/#{clean[2, 2]}/#{clean[4, 2]}/#{clean}"
  end
end
