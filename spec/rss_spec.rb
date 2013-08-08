require 'spec_helper'

describe SecretService do

  it "can create a session" do
    SecretService.new.class.should_not be nil
  end

  it "has a default collection" do
    SecretService.new.collection.should_not be nil
  end

  it "can create and read back objects" do
    name = SecureRandom.hex(8).to_s
    secret = SecureRandom.hex(8).to_s
    ss = SecretService.new
    ss.collection.create_item("rspec_test_#{name}", secret).should_not be nil
    ss.collection.get_secret("rspec_test_#{name}").should eq secret
  end
  
  it "can create locked objects" do
    ss = SecretService.new
    coll = ss.collection
  end

end
