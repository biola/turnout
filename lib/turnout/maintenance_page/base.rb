module Turnout
  module MaintenancePage
    class Base
      attr_reader :reason

      def initialize(reason = nil)
        @reason = reason
      end

      def rack_response(code = Turnout.config.default_response_code)
        [code, headers, body]
      end

      # Override with an array of media type strings. i.e. text/html
      def self.media_types
        raise NotImplementedError, '.media_types must be overridden in subclasses'
      end
      def media_types() self.class.media_types end

      # Override with a file extension value like 'html' or 'json'
      def self.extension
        raise NotImplementedError, '.extension must be overridden in subclasses'
      end
      def extension() self.class.extension end

      protected

      def self.inherited(subclass)
        MaintenancePage.all << subclass
      end

      def headers
        {'Content-Type' => media_types.first, 'Content-Length' => length}
      end

      def length
        content.bytesize.to_s
      end

      def body
        [content]
      end

      def content
        file_content.gsub /{{\s?reason\s?}}/, reason
      end

      def file_content
        File.read(path)
      end

      def path
        if File.exists? custom_path
          custom_path
        else
          default_path
        end
      end

      def default_path
        File.expand_path("../../../../public/#{filename}", __FILE__)
      end

      def custom_path
        Turnout.config.app_root.join('public', filename)
      end

      def filename
        "maintenance.#{extension}"
      end
    end
  end
end
