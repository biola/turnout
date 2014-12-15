require 'spec_helper'

describe Turnout::MaintenancePage::JSON do
  describe 'class methods' do
    subject { Turnout::MaintenancePage::JSON }

    its(:media_types) { should eql %w{application/json text/json application/x-javascript text/javascript text/x-javascript text/x-json} }
    its('new.media_types') { should eql %w{application/json text/json application/x-javascript text/javascript text/x-javascript text/x-json} }
    its(:extension) { should eql 'json' }
    its('new.extension') { should eql 'json' }
  end

  describe 'instance methods' do
    let(:reason) { nil }
    let(:instance) { Turnout::MaintenancePage::JSON.new(*[reason].compact) }
    subject { instance }

    describe '#reason' do
      context 'without a reason' do
        its(:reason) { should eql '""' }
      end

      context 'with a reason' do
        let(:reason) { "Just because.\nOkay!" }

        its(:reason) { should eql '"Just because.\nOkay!"' }
      end
    end

    describe '#rack_response' do
      let(:reason) { 'Oops!' }
      let(:code) { nil }
      let(:retry_after) { nil }
      let(:raw_response) { instance.rack_response(code, retry_after) }
      subject { Rack::MockResponse.new(*raw_response) }

      before do
        def subject.json() JSON.parse(body) end
        def subject.message() json['message'] end
      end

      context 'without code and retry_after' do
        it { expect(raw_response).to be_an Array }
        its(:status) { should eql 503 }
        its(:headers) { should be_a Hash }
        its(:headers) { should have_key 'Content-Type' }
        its(:headers) { should have_key 'Content-Length' }
        its(:headers) { should_not have_key 'Retry-After' }
        its(:content_type) { should eql 'application/json' }
        it { expect(raw_response).to be_an Array }
        its(:json) { should be_a Hash }
        its(:json) { should have_key 'error' }
        its(:json) { should have_key 'message' }
        its(:message) { should eql 'Oops!' }
      end

      context 'with a code' do
        let(:code) { 418 }
        its(:status) { should eql 418 }
      end

      context 'with retry_after' do
        let(:retry_after) { 3600 }
        its(:headers) { should include('Retry-After' => 3600) }
      end
    end
  end
end