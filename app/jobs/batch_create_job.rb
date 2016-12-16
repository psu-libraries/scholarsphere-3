# frozen_string_literal: true
class BatchCreateJob < ActiveJob::Base
  queue_as :ingest

  attr_reader :user, :log

  before_enqueue do |job|
    log = job.arguments.last
    log.pending_job(self)
  end

  # This copies metadata from the passed in attribute to all of the works that
  # are members of the given upload set
  # @param [User] user
  # @param [Array<String>] titles
  # @param [Array<String>] resource_types
  # @param [Hash] attributes attributes to apply to all works
  # @param [BatchCreateOperation] log
  def perform(user, titles, resource_types, attributes, log)
    @log = log
    @log.performing!
    @user = user
    create(attributes, titles, resource_types)
  end

  private

    def create(attributes, titles = {}, resource_types = {})
      uploaded_files = attributes.delete("uploaded_files")
      remote_files = attributes.delete("remote_files")
      create_uploaded_files(titles, resource_types, attributes, uploaded_files)
      create_remote_files(titles, resource_types, attributes, remote_files)
    end

    def create_uploaded_files(titles, resource_types, attributes, uploaded_files = [])
      uploaded_files.each do |upload_id|
        title = [titles[upload_id]] if titles[upload_id]
        resource_type = [resource_types[upload_id]] if resource_types[upload_id]
        attributes = attributes.merge(uploaded_files: [upload_id],
                                      title: title,
                                      resource_type: resource_type)
        model = model_to_create(attributes)
        child_log = CurationConcerns::Operation.create!(user: user,
                                                        operation_type: "Create Work",
                                                        parent: log)
        CreateWorkJob.perform_later(user, model, attributes, child_log)
      end
    end

    def create_remote_files(titles, resource_types, attributes, remote_files = [])
      remote_files.each do |file|
        upload_id = file.fetch("url")
        attributes = attributes.merge(remote_files: [file],
                                      title: Array.wrap(titles.fetch(upload_id)),
                                      resource_type: Array.wrap(resource_types.fetch(upload_id)))
        child_log = CurationConcerns::Operation.create!(user: user,
                                                        operation_type: "Create Work",
                                                        parent: log)
        CreateWorkJob.perform_later(user, model_to_create(attributes), attributes, child_log)
      end
    end

    # Override this method if you have a different rubric for choosing the model
    # @param [Hash] attributes
    # @return String the model to create
    def model_to_create(attributes)
      Sufia.config.model_to_create.call(attributes)
    end
end
