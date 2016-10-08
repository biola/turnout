require 'i18n'
require 'i18n/backend/fallbacks'
require_relative './accept_language_parser'
require_relative '../ordered_options'

module Turnout
  class Internationalization
    class << self
      attr_reader :env
      attr_writer :env

      def initialize_i18n(env)
        @env = env
        setup_i18n_config
      end

      def i18n_config
        @i18n_config = Turnout.config.i18n
        @i18n_config =  @i18n_config.is_a?(Turnout::OrderedOptions) ? @i18n_config : Turnout::InheritableOptions.new(@i18n_config)
      end

      def turnout_page
        @turnout_page ||= Turnout.config.default_maintenance_page
      end

      def http_accept_language
        language = (env.nil? || env.empty?) ? nil : env["HTTP_ACCEPT_LANGUAGE"]
        @http_accept_language ||= Turnout::AcceptLanguageParser.new(language)
      end

      def setup_additional_helpers
        i18n_additional_helpers = i18n_config.delete(:additional_helpers)
        i18n_additional_helpers = i18n_additional_helpers.is_a?(Array) ? i18n_additional_helpers : []

        i18n_additional_helpers.each do |helper|
          turnout_page.send(:include, helper) if helper.is_a?(Module)
        end
      end

      def expanded(path)
        result = []
        if File.directory?(path)
          result.concat(Dir.glob(File.join(path, '**', '**')).map { |file| file }.sort)
        else
          result << path
        end
        result.uniq!
        result
      end

      # Returns all expanded paths but only if they exist in the filesystem.
      def existent(path)
        expanded(path).select { |f| File.exist?(f) }
      end

      # Setup i18n configuration.
      def setup_i18n_config
        return unless i18n_config.enabled
        setup_additional_helpers
        fallbacks = i18n_config.delete(:fallbacks)


        # Avoid issues with setting the default_locale by disabling available locales
        # check while configuring.
        enforce_available_locales = i18n_config.delete(:enforce_available_locales)
        enforce_available_locales = I18n.enforce_available_locales if enforce_available_locales.nil?
        I18n.enforce_available_locales = false

        i18n_config.except(:enabled, :use_language_header).each do |setting, value|
          case setting
          when :railties_load_path
            I18n.load_path.unshift(*value.map { |file| existent(file) }.flatten)
          when :load_path
            I18n.load_path += value
          else
            I18n.send("#{setting}=", value)
          end
        end


        init_fallbacks(fallbacks) if fallbacks && validate_fallbacks(fallbacks)
        I18n.backend.load_translations

        # Restore available locales check so it will take place from now on.
        I18n.enforce_available_locales = enforce_available_locales

        begin
          if i18n_config.use_language_header
            I18n.locale = http_accept_language.compatible_language_from(I18n.available_locales) || I18n.default_locale
          else
            I18n.locale = I18n.default_locale
          end
        rescue
          #nothing
        end

      end

      def array_wrap(object)
        if object.nil?
          []
        elsif object.respond_to?(:to_ary)
          object.to_ary || [object]
        else
          [object]
        end
      end

      def include_fallbacks_module
        I18n.backend.class.send(:include, I18n::Backend::Fallbacks)
      end

      def init_fallbacks(fallbacks)
        include_fallbacks_module

        args = case fallbacks
        when Turnout::OrderedOptions
          [*(fallbacks[:defaults] || []) << fallbacks[:map]].compact
        when Hash, Array
          array_wrap(fallbacks)
        else # TrueClass
          []
        end

        I18n.fallbacks = I18n::Locale::Fallbacks.new(*args)
      end

      def validate_fallbacks(fallbacks)
        case fallbacks
        when Turnout::OrderedOptions
          !fallbacks.empty?
        when TrueClass, Array, Hash
          true
        else
          raise "Unexpected fallback type #{fallbacks.inspect}"
        end
      end

    end
  end
end
