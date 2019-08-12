# frozen_string_literal: true

namespace :scholarsphere do
  namespace :files do
    desc 'Creates derivatives, including thumbnails for all file sets, or using a list of ids separated by spaces'
    task :create_derivatives, [:list] => :environment do |_cmd, args|
      service = FileSetManagementService.new(args.fetch(:list, '').split(/ /))
      service.create_derivatives
      if service.errors.positive?
        puts "#{service.errors} FileSet(s) failed to process, check the Rails log"
      else
        puts 'Success!'
      end
    end

    desc 'Characterize all file sets, or supply a list of ids separated by spaces'
    task :characterize, [:list] => :environment do |_cmd, args|
      service = FileSetManagementService.new(args.fetch(:list, '').split(/ /))
      service.characterize
      if service.errors.positive?
        puts "#{service.errors} FileSet(s) failed to process, check the Rails log"
      else
        puts 'Success!'
      end
    end

    desc 'Create zip files for large works and collections'
    task zip: :environment do
      public_resources
        .select { |hit| hit['bytes_lts'] > ScholarSphere::Application.config.zipfile_size_threshold }
        .map { |hit| ZipJob.perform_later(hit.id) }
    end

    desc 'Delete zip files that no longer match our criteria'
    task delete_zips: :environment do
      ScholarSphere::Application.config.public_zipfile_directory.children.map do |file|
        zip_file = ZipFile.new(file)
        file.delete if zip_file.stale?
      end
    end

    def public_resources
      ActiveFedora::SolrService.query(
        'read_access_group_ssim:public',
        fl: ['id, bytes_lts'],
        rows: 1_000_000,
        fq: '((*:* AND has_model_ssim:GenericWork) OR (*:* AND has_model_ssim:Collection))'
      )
    end
  end
end
