# frozen_string_literal: true
class Scholarsphere::Config
  def self.check
    config_files = Dir.glob(File.join(Rails.root, "config", "*.yml")).map { |f| ConfigFile.new(f) }
    config_files.map(&:validate)
  end

  class ConfigFile
    attr_reader :file

    REQUIREMENTS = {
      "application.yml" => [
        "TMPDIR",
        "ffmpeg_path",
        "service_instance",
        "virtual_host",
        "stats_email",
        "google_analytics_id",
        "derivatives_path",
        "read_only"
      ]
    }.freeze

    def initialize(file)
      @file = file
    end

    def keys
      YAML.load(File.open(file)).fetch("production", {}).keys
    end

    def validate
      return true if required_keys.empty? || required_keys.uniq.sort == keys.uniq.sort
      raise Error, "Config file #{File.basename(file)} requires #{required_keys} but has #{keys}"
    end

    private

      def required_keys
        REQUIREMENTS.fetch(File.basename(file), [])
      end
  end

  class Error < StandardError; end
end
