class BatchController < ApplicationController
  include Sufia::BatchControllerBehavior

  # override sufia default to put creator in format PSU expects, lastname, first name
  def edit_form
    parsed = Namae::Name.parse(current_user.name)
    generic_file = ::GenericFile.new(creator: [parsed.sort_order], title: @batch.generic_files.map(&:label))
    edit_form_class.new(generic_file)
  end

  protected

    def batch_update_job
      @batch_update_job ||= ScholarsphereBatchUpdateJob.new(
        current_user.user_key,
        params[:id],
        params[:title],
        edit_form_class.model_attributes(params[:generic_file]),
        params[:visibility])
    end

end
