require 'json'

module Turnout
  module MaintenancePage
    class JSON < Base
      def reason
        super.to_s.to_json
      end

      def self.media_types
        %w{
          application/json
          text/json
          application/x-javascript
          text/javascript
          text/x-javascript
          text/x-json
        }
      end

      def self.extension
        'json'
      end
    end
  end
end