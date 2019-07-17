# frozen_string_literal: true

class NetworkIngestService
  def self.call(path)
    new(path).ingest
  end

  attr_reader :path

  def initialize(path)
    @path = Pathname.new(path)
  end

  def ingest
    path.children.map do |file|
      attach_file(file)
    end
  end

  private

    def attach_file(file)
      file_set = ::FileSet.new
      file_set.permissions_attributes = curation_concern.permissions.map(&:to_hash)
      file_set_actor = CurationConcerns::Actors::FileSetActor.new(file_set, user)
      file_set_actor.create_metadata(curation_concern)
      file_set_actor.create_content(File.new(file))
    end

    def curation_concern
      @curation_concern ||= GenericWork.find(path.basename.to_s)
    end

    def user
      @user ||= User.find_by(login: curation_concern.depositor)
    end
end
