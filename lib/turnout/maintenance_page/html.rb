module Turnout
  module MaintenancePage
    class HTML < Base
      def reason
        super.to_s.split("\n").map{|txt| "<p>#{txt}</p>" }.join("\n")
      end

      def self.media_types
        %w{
          text/html
          application/xhtml+xml
        }
      end

      def self.extension
        'html'
      end
    end
  end
end