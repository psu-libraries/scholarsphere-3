# frozen_string_literal: true
module Sufia::FilesController
  module BrowseEverything
    include ActiveSupport::Concern
    include ActionView::Helpers::NumberHelper

    def create
      if params[:selected_files].present?
        create_from_browse_everything(params)
      else
        super
      end
    end

    protected

      def create_from_browse_everything(params)
        Batch.find_or_create(params[:batch_id])
        parse_selected_files
        if error_files.empty?
          redirect_to self.class.upload_complete_path(params[:batch_id])
        else
          redirect_to sufia.dashboard_files_path, flash: { error: error_message }
        end
      end

      # Examines each file in params[:selected_files] and calls #create_file_from_url.
      # If the file exceeds the maximum upload size, an entry is added to @error_files
      def parse_selected_files
        params[:selected_files].each_pair do |_index, file_info|
          next if file_info.blank? || file_info["url"].blank?
          if file_info["file_size"].to_i > ScholarSphere::Application.config.max_upload_file_size
            error_files << "#{file_info['file_name']} (#{number_to_human_size(file_info['file_size'].to_i)})"
          else
            create_file_from_url(file_info["url"], file_info["file_name"])
          end
        end
      end

      # Generic utility for creating GenericFile from a URL
      # Used in to import files using URLs from a file picker like browse_everything
      def create_file_from_url(url, file_name)
        ::GenericFile.new(import_url: url, label: file_name).tap do |gf|
          actor = Sufia::GenericFile::Actor.new(gf, current_user)
          actor.create_metadata(params[:batch_id])
          gf.save!
          Sufia.queue.push(ImportUrlJob.new(gf.id))
        end
      end

    private

      def error_files
        @error_files ||= []
      end

      def error_message
        "
          All of your files were too large to upload. \n \
          #{error_files.join ', '} #{error_files.size > 1 ? 'are' : 'is'} \
          larger than the maximum file size allowed by the system \
          ( > #{number_to_human_size(ScholarSphere::Application.config.max_upload_file_size)}) \
          and will be ignored. \
        "
      end
  end
end
