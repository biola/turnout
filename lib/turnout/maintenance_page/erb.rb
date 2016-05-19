require 'erb'
require 'tilt'
require 'tilt/erb'
require_relative './html'
module Turnout
  module MaintenancePage
    class Erb < Turnout::MaintenancePage::HTML

      def content
        Tilt.new(File.expand_path(path)).render(self, {reason: reason}.merge(@options))
      end

      def self.extension
        'html.erb'
      end
    end
  end
end
