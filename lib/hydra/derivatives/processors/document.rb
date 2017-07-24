# frozen_string_literal: true

# Overriding this class to have soffice create png files, which we then generate a thumb for instead
# of a PDF.  The PDF processing seems to take much more time than the PDF processing
module Hydra::Derivatives::Processors
  class Document < Processor
    include ShellBasedProcessor

    def self.encode(path, format, outdir)
      execute "#{Hydra::Derivatives.libreoffice_path} --invisible --headless --convert-to #{format} --outdir #{outdir} #{path}"
    end

    # Converts the document to the format specified in the directives hash.
    # TODO: file_suffix and options are passed from ShellBasedProcessor.process but are not needed.
    #       A refactor could simplify this.
    def encode_file(_file_suffix, _options = {})
      convert_to_format
    ensure
      FileUtils.rm_f(converted_file)
    end

    private

      # For jpeg files, a pdf is created from the original source and then passed to the Image processor class
      # so we can get a better conversion with resizing options. Otherwise, the ::encode method is used.
      def convert_to_format
        if directives.fetch(:format) == 'jpg'
          Hydra::Derivatives::Processors::Image.new(converted_file, directives).process
        else
          output_file_service.call(File.read(converted_file), directives)
        end
      end

      def converted_file
        @converted_file ||= if directives.fetch(:format) == 'jpg'
                              # TODO: This is the only change from HydraDerivaties
                              #      It would be good if we could configure this instead of overriding
                              convert_to('png')
                            else
                              convert_to(directives.fetch(:format))
                            end
      end

      def convert_to(format)
        self.class.encode(source_path, format, Hydra::Derivatives.temp_file_base)
        File.join(Hydra::Derivatives.temp_file_base, [File.basename(source_path, '.*'), format].join('.'))
      end
  end
end
