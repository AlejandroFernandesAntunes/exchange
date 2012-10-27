require 'spec_helper'

describe "Exchange::Configuration" do
  let(:subject) { Exchange::Configuration.new }
  it "should have a standard configuration" do
    subject.api.retries.should == 5
    subject.api.subclass.should == Exchange::ExternalAPI::XavierMedia
    subject.cache.subclass.should == Exchange::Cache::Memory
    subject.cache.host.should be_nil
    subject.cache.port.should be_nil
    subject.cache.expire.should == :daily
  end
  it "should respond to all configuration getters and setters" do
    [:api, :allow_mixed_operations, :cache].each do |k|
      subject.should be_respond_to(k)
      subject.should be_respond_to(:"#{k}=")
    end
  end
  it 'should respond to nested getters and setters for the api and the cache' do
    {:api => [:subclass, :retries], :cache => [:subclass, :host, :port, :expire]}.each do |k,m|
      m.each do |meth|
        subject.send(k).should be_respond_to(meth)
        subject.send(k).should be_respond_to(:"#{meth}=")
      end
    end
  end
  it "should allow to be defined with a block" do
    Exchange.configuration = Exchange::Configuration.new {|c|
      c.api = {
        :subclass => :xavier_media,
        :retries => 60
      }
      c.cache = {
        :subclass => :redis
      }
    }
    Exchange.configuration.api.subclass.should == Exchange::ExternalAPI::XavierMedia
    Exchange.configuration.api.retries.should == 60
    Exchange.configuration.cache.subclass.should == Exchange::Cache::Redis
  end
  it "should allow to be set directly" do
    subject.api = {
      :subclass => :ecb,
      :retries => 1
    }
    subject.api.subclass.should == Exchange::ExternalAPI::Ecb
    subject.api.retries.should == 1
  end
  describe "reset" do
    Exchange.configuration = Exchange::Configuration.new {|c|
      c.api = {
        :subclass => :currency_bot,
        :retries => 60,
        :app_id => '234u230482348023'
      }
      c.cache = {
        :subclass => :redis,
        :host => 'localhost',
        :port => 112211,
        :path => 'PATH'
      }
      c.allow_mixed_operations = false
    }
    it "should restore the defaults" do
      subject.reset
      subject.api.subclass.should == Exchange::ExternalAPI::XavierMedia
      subject.api.retries.should == 5
      subject.api.app_id.should be_nil
      subject.cache.subclass.should == Exchange::Cache::Memory
      subject.cache.host.should be_nil
      subject.cache.port.should be_nil
      subject.cache.path.should be_nil
      subject.allow_mixed_operations.should be_true
    end
  end
  after(:all) do
    Exchange.configuration.reset
  end  
end