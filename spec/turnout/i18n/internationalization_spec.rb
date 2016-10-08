require 'spec_helper'

describe Turnout::Internationalization do

  module FakeHelper
    def fake_helper_method
    end
  end

  module FakeHelperClass
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

  let(:locales_dir) { File.expand_path("../../../locales", __FILE__) }
  let(:en_locale) { File.join(locales_dir, 'en.yml') }
  let(:de_locale) { File.join(locales_dir, 'de.yml') }
  let(:fake_paths) {[en_locale, de_locale] }


  let(:env) { {'HTTP_ACCEPT_LANGUAGE' => 'en-us' } }
  let(:subject) {  Turnout::Internationalization }
  let(:helpers) { [FakeHelper, FakeHelperClass, nil, 0, false, true, '']  }

  it 'should not have an env' do
    expect(subject.env).to eq(nil)
  end

  describe '#initialize_i18n' do

    it 'initializes the i18n ' do
      Turnout.config.i18n.enabled = true
      expect(subject).to receive(:setup_i18n_config).with(no_args).and_return(true)
      subject.initialize_i18n(env)
      expect(subject.env).to eq(env)
    end
  end

  describe '#i18n_config' do
    it 'sets the i18n config variable' do
      subject.i18n_config
      expect(subject.instance_variable_get('@i18n_config')).to eq(Turnout.config.i18n)
    end

    it 'sets the i18n config variable from a Hash' do
      original = Turnout.config.i18n
      Turnout.config.i18n = {key: :value }
      expect(Turnout::InheritableOptions).to receive(:new).with(Turnout.config.i18n)
      subject.i18n_config
      Turnout.config.i18n = original
    end
  end

  describe '#turnout_page' do
    it 'sets the turnout page' do
      subject.turnout_page
      expect(subject.instance_variable_get('@turnout_page')).to eq(Turnout.config.default_maintenance_page)
    end
  end

  describe '#http_accept_language' do
    it 'sets the http_accept_language' do
      subject.env = nil
      expect(Turnout::AcceptLanguageParser).to receive(:new).with(nil)
      subject.http_accept_language
    end

    it 'sets the http_accept_language and instantiates the parser' do
      subject.env = env
      expect(Turnout::AcceptLanguageParser).to receive(:new).with(env['HTTP_ACCEPT_LANGUAGE'])
      subject.http_accept_language
    end

    it 'sets the http_accept_language' do
      subject.env = env
      subject.http_accept_language
      expect(subject.instance_variable_get('@http_accept_language').kind_of?(Turnout::AcceptLanguageParser)).to eq(true)
    end

  end

  describe '#setup_additional_helpers' do

    it 'gets the helpers from config' do
      expect(subject.i18n_config).to receive(:delete).with(:additional_helpers).and_return([])
      subject.setup_additional_helpers
    end

    it 'includes additional helpers' do
      original = Turnout.config.i18n
      Turnout.config.i18n.additional_helpers = helpers
      helpers.each do |helper|
        expected =  helper.is_a?(Module) ? 'to' : 'to_not'
        expect(subject.turnout_page).send(expected, receive(:send).with(:include, helper))
      end
      subject.setup_additional_helpers
      Turnout.config.i18n = original
    end
  end

  describe '#setup_i18n_config' do

    before(:each) do
      allow(subject).to receive(:setup_additional_helpers).with(no_args).and_return(true)
      allow(subject.i18n_config).to receive(:delete).with(:enforce_available_locales).and_return(false)
      allow(subject.i18n_config).to receive(:delete).with(:fallbacks).and_return([])
      allow(subject.i18n_config).to receive(:except).with(:enabled, :use_language_header).and_call_original
    end

    context '#enforce_available_locales' do
      it 'sets by default enforce to false' do
        expect(subject.i18n_config).to receive(:delete).with(:fallbacks).and_return([])
        expect(I18n).to receive(:enforce_available_locales=).with(false).at_least(:once)
        subject.setup_i18n_config
      end

      it 'enforces the i18n locales if needed from config' do
        I18n.enforce_available_locales = false
        allow(subject.i18n_config).to receive(:delete).with(:enforce_available_locales).and_return(true)
        subject.setup_i18n_config
        expect(I18n.enforce_available_locales).to eq(true)
      end

      it 'enforces the i18n locales if needed if config returns nil and I18n was configured directly' do
        I18n.enforce_available_locales = true
        allow(subject.i18n_config).to receive(:delete).with(:enforce_available_locales).and_return(nil)
        subject.setup_i18n_config
        expect(I18n.enforce_available_locales).to eq(true)
        I18n.enforce_available_locales = false
      end
    end


    context '#railties_load_path' do
      let(:fake_load_path) { double }



      before(:each) do
        locales_dir
        allow(fake_load_path).to receive(:+).and_return(true)
        allow(fake_load_path).to receive(:flatten).and_return([])
      end


      it 'makes sure that unshift and flatten are happening' do
        original = Turnout.config.i18n
        Turnout.config.i18n.railties_load_path = [locales_dir]
        expect(I18n).to receive(:load_path).and_return(fake_load_path).at_least(:once)
        expect(fake_load_path).to receive(:unshift).with(*[locales_dir].map { |file| existent(file) }.flatten).and_return([])
        subject.setup_i18n_config
        Turnout.config.i18n = original
      end

      it 'sets the load path from globbed paths' do
        I18n.load_path = []
        Turnout.config.i18n.railties_load_path = [locales_dir]
        subject.setup_i18n_config
        expect(I18n.load_path).to eq([de_locale, en_locale])
      end

      it 'sets the load path from single paths' do
        I18n.load_path = []
        Turnout.config.i18n.railties_load_path = [de_locale, en_locale]
        subject.setup_i18n_config
        expect(I18n.load_path).to eq([de_locale, en_locale])
      end
    end
    context '#load_path' do
      it 'add to the load path from array' do
        I18n.load_path = []
        Turnout.config.i18n.railties_load_path = []
        Turnout.config.i18n.load_path = fake_paths
        subject.setup_i18n_config
        expect(I18n.load_path).to eq(fake_paths)
        Turnout.config.i18n.load_path = []
      end
    end

    context 'send dynamic methods to I18n' do
      it 'add to the load path from array' do
        original = Turnout.config.i18n
        Turnout.config.i18n = { key1: :value1,  key2: :value2, enabled: true }
        Turnout.config.i18n.select{|key, value| ![:enabled].include?(key) }.each do |key, value|
          expect(I18n).to receive(:send).with("#{key}=", value)
        end
        subject.setup_i18n_config
        Turnout.config.i18n = original
      end
    end

    context 'init_fallbacks' do
      let(:fake_fallbacks) {[double]}
      before(:each) do
        allow(subject.i18n_config).to receive(:delete).with(:fallbacks).and_return(fake_fallbacks)
      end

      it 'inits the fallbacks' do
        expect(subject).to receive(:init_fallbacks).with(fake_fallbacks)
        subject.setup_i18n_config
      end
    end

    context 'validate_fallbacks' do
      let(:fake_fallbacks) {[double]}
      before(:each) do
        allow(subject.i18n_config).to receive(:delete).with(:fallbacks).and_return(fake_fallbacks)
      end

      it 'inits the fallbacks' do
        expect(subject).to receive(:validate_fallbacks).with(fake_fallbacks)
        subject.setup_i18n_config
      end
    end

    context 'load_translations' do
      let(:fake_backend) {double}
      before(:each) do
        allow(I18n).to receive(:backend).and_return(fake_backend)
      end

      it 'inits the fallbacks' do
        expect(fake_backend).to receive(:load_translations).with(no_args)
        subject.setup_i18n_config
      end
    end

    context '#use_language_header' do
      let(:fake_parser) {double}

      context "config true" do
        before(:each) do
          allow(subject.i18n_config).to receive(:use_language_header).and_return(true)
        end

        it 'checks proper method calls' do
          expect(subject).to receive(:http_accept_language).with(no_args).and_return(fake_parser)
          expect(fake_parser).to receive(:compatible_language_from).with(I18n.available_locales).and_return("de")
          subject.setup_i18n_config
          expect(I18n.locale).to eq(:de)
        end

        it 'calls original' do
          expect(I18n.available_locales).to eq([:en])
          subject.setup_i18n_config
          expect(I18n.locale).to eq(:en)
        end

        it 'calls original using default' do
          I18n.available_locales = []
          subject.setup_i18n_config
          expect(I18n.locale).to eq(:en)
        end
      end

      context "config false" do
        before(:each) do
          allow(subject.i18n_config).to receive(:use_language_header).and_return(false)
        end

        it 'calls original using default' do
          expected = 'fake'
          allow(I18n).to receive(:default_locale).and_return(expected)
          subject.setup_i18n_config
          expect(I18n.locale).to eq(expected.to_sym)
        end

      end
    end

  end


  describe '#array_wrap' do
    it 'returns []' do
      result = subject.array_wrap(nil)
      expect(result).to eq([])
    end

    it 'returns array' do
      array = ['a', 'b', 'c']
      result = subject.array_wrap(array)
      expect(result).to eq(array)
    end

    it 'returns array from string' do
      string = "something"
      result = subject.array_wrap(string)
      expect(result).to eq([string])
    end

    it 'returns array from hash' do
      hash = {key: :value }
      result = subject.array_wrap(hash)
      expect(result).to eq([hash])
    end

    it 'use to_ary' do
      expected = "something"
      fake = double(to_ary: expected)
      result = subject.array_wrap(fake)
      expect(result).to eq(fake.to_ary)
    end
  end

  describe '#include_fallbacks_module' do

    it 'use to_ary' do
      expect(I18n.backend.class).to receive(:include).with(I18n::Backend::Fallbacks)
      subject.include_fallbacks_module
    end
  end

  describe '#init_fallbacks' do
    let(:fake_fallback) { double }
    let(:fake_fallbacks) {[fake_fallback]}

    it 'includes the default fallback' do
      expect(subject).to receive(:include_fallbacks_module).with(no_args).and_call_original
      subject.init_fallbacks(fake_fallback)
    end

    it 'wraps fallbacks if array' do
      expect(subject).to receive(:array_wrap).with(fake_fallbacks).and_call_original
      expect(I18n::Locale::Fallbacks).to receive(:new).with(fake_fallback).and_call_original
      subject.init_fallbacks(fake_fallbacks)
    end

    it 'wraps fallbacks if hash' do
      hash = {key: :value}
      expect(subject).to receive(:array_wrap).with(hash).and_call_original
      expect(I18n::Locale::Fallbacks).to receive(:new).with(hash).and_call_original
      subject.init_fallbacks(hash)
    end

    it 'uses ordered options' do
      hash = Turnout::OrderedOptions.new({ map: :value })
      expected = [*(hash[:defaults] || []) << hash[:map]].compact
      expect(I18n::Locale::Fallbacks).to receive(:new).with(*expected).and_call_original
      subject.init_fallbacks(hash)
      expect(I18n.fallbacks.defaults).to eq(expected)
    end
  end

  describe '#validate_fallbacks' do
    let(:fake_fallback) { double }
    let(:fake_fallbacks) {[fake_fallback]}

    it 'validates array' do
      result = subject.validate_fallbacks(fake_fallbacks)
      expect(result).to eq(true)
    end

    it 'validates hash' do
      hash = {key: :value}
      result = subject.validate_fallbacks(hash)
      expect(result).to eq(true)
    end

    it 'validates trueclass' do
      result= subject.validate_fallbacks(true)
      expect(result).to eq(true)
    end

    it 'uses ordered options' do
      hash = Turnout::OrderedOptions.new({ map: :value })
      expect(hash).to receive(:empty?).and_call_original
      subject.validate_fallbacks(hash)
    end

    it 'raises error if unknown' do
      data = nil
      expect { subject.validate_fallbacks(data) }.to raise_error(RuntimeError, "Unexpected fallback type #{data.inspect}")
    end
  end

end
