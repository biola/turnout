require 'spec_helper'

describe Turnout::MaintenancePage do
  describe '.all' do
    its(:all) { should_not include Turnout::MaintenancePage::Base }
    its(:all) { should eql [Turnout::MaintenancePage::HTML, Turnout::MaintenancePage::JSON] }
  end

  describe '.best_for' do
    let(:env) { Rack::MockRequest.env_for('/', 'HTTP_ACCEPT' => content_type) }
    subject { Turnout::MaintenancePage.best_for(env) }

    context 'with "*/*" accept header' do
      let(:content_type) { '*/*' }

      it { should eql Turnout::MaintenancePage::HTML }
    end

    context 'with "text/html" accept header' do
      let(:content_type) { 'text/html' }

      it { should eql Turnout::MaintenancePage::HTML }
    end

    context 'with "text/json" accept header' do
      let(:content_type) { 'text/json' }

      it { should eql Turnout::MaintenancePage::JSON }
    end

    context 'with "image/gif" accept header' do
      let(:content_type) { 'image/gif' }

      it { should eql Turnout::MaintenancePage::HTML }
    end
  end
end