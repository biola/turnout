require 'spec_helper'

describe Turnout::RedisClient do

  let(:config) { Turnout::MaintenanceConfig.default }
  subject { Turnout::RedisClient }

  describe "with redis" do
    before(:each) do
      allow(subject).to receive(:client).and_return(Redis.new)
    end

    it 'checks if maintenance mode is off with redis installed but key not set' do
      subject.client.del("turnout:maintenance")
      expect(subject.maintenance? config).to be false
    end

    it 'checks if maintenance mode is on with redis installed with key set' do
      subject.client.set("turnout:maintenance", "key")
      expect(Turnout::RedisClient.maintenance? config).to be true
    end

    it 'checks if redis key sets reason correctly' do
      subject.client.set("turnout:maintenance", "reason message")
      expect(Turnout::RedisClient.maintenance? config).to be true
      expect(config.reason).to eq("reason message")
    end

    it 'checks if redis key sets default reason if value is default' do
      subject.client.set("turnout:maintenance", "default")
      expect(Turnout::RedisClient.maintenance? config).to be true
      expect(config.reason).to eq("The site is temporarily down for maintenance.\nPlease check back soon.")
    end

    it 'is not in maintenance mode if redis unreachable' do
      allow(subject.client).to receive(:get).and_raise(Redis::CannotConnectError)
      expect(Turnout::RedisClient.maintenance? config).to be false
    end
  end

  describe "without redis" do
    it 'checks if maintenance mode is off with redis uninstalled' do
      expect(Turnout::RedisClient.maintenance? config).to be false
    end
  end
end
