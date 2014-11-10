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
        error_files = []
        valid_count = 0
        params[:selected_files].each_pair do |index, file_info| 
          next if file_info.blank? || file_info["url"].blank?
          if (file_info["file_size"].to_i > ScholarSphere::Application.config.max_upload_file_size)
            error_files << "#{file_info["file_name"]} (#{number_to_human_size(file_info["file_size"].to_i)})"
          else
            valid_count = valid_count+1
            create_file_from_url(file_info["url"], file_info["file_name"])
          end
        end
        flash[:error] = "#{error_files.join ", "} #{error_files.size > 1 ? "are" : "is" } larger than the maximum file size allowed by the system ( > #{ number_to_human_size(ScholarSphere::Application.config.max_upload_file_size)}) and will being ignored. "
        if valid_count > 0
          redirect_to self.class.upload_complete_path( params[:batch_id])
        else
          flash[:error] = "All of your files were too large to upload. \n"+flash[:error]
          redirect_to sufia.dashboard_files_path
        end


      end
      
      # Generic utility for creating GenericFile from a URL
      # Used in to import files using URLs from a file picker like browse_everything 
      def create_file_from_url(url, file_name, batch_id=nil)
        generic_file = ::GenericFile.new(import_url: url, label: file_name).tap do |gf|
          actor = Sufia::GenericFile::Actor.new(gf, current_user)
          actor.create_metadata(params[:batch_id])
          gf.save!
          Sufia.queue.push(ImportUrlJob.new(gf.pid))
        end
      end

  end
end
