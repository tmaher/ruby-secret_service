require 'spec_helper'

describe SecretService do

  #it "aborts when it can't find dbus" do
    #state = hide_dbus_configs
    #SecretService.new
    #expect {SecretService.new}.to raise_error
    #restore_dbus_configs state
  #end
  
  it "can create a session" do
    SecretService.new.class.should_not be nil
  end

  it "has a default collection" do
    SecretService.new.collection.should_not be nil
  end

  it "can lock and unlock collections" do
    ss = SecretService.new
    ss.collection.lock!.should eq true
    ss.collection.locked?.should eq true
    ss.collection.unlock!.should eq true
    ss.collection.locked?.should eq false
  end
  
  it "can create and read back objects" do
    name = SecureRandom.hex(8).to_s
    secret = SecureRandom.hex(8).to_s
    ss = SecretService.new
    ss.collection.unlock!
    ss.collection.create_item("rspec_test_#{name}", secret).should_not be nil
    ss.collection.get_secret("rspec_test_#{name}").should eq secret
  end

  it "can create a new collection" do
    ss = SecretService.new
    coll_label = "rspec_test_collection_#{SecureRandom.hex(4)}"
    new_coll = ss.create_collection coll_label
    new_coll.should_not be nil
    new_coll.name.should eq coll_label
  end
  
  it "can create and lock objects" do
    name = SecureRandom.hex(8).to_s
    secret = SecureRandom.hex(8).to_s
    ss = SecretService.new
    item = ss.collection.create_item("rspec_test_#{name}", secret)
    item.lock!
    item.locked?.should eq true
  end

  it "can find objects" do
    ss = SecretService.new
    unlocked, locked = ss.search_items
    unlocked.kind_of?(Array).should eq true
    locked.kind_of?(Array).should eq true
    (locked + unlocked).each do |item|
      item.match(/^\/org\/freedesktop\/secrets\/collection/).nil?.should eq false
    end
  end

  it "can unlock objects" do
    ss = SecretService.new
    item_paths, prompt = ss.unlock(ss.search_items[1])
  end

  it "aborts on invalid prompt creation" do
    ss = SecretService.new
    expect {ss.prompt! "/"}.to raise_error SecretService::Prompt::NoPromptRequired
  end

  #it "can raise a prompt" do
    #ss = SecretService.new
    #item_paths, prompt = ss.unlock(ss.search_items[1])
    #ss.prompt!(prompt)
    #new_items, new_prompt = ss.unlock(ss.search_items[1])
    #new_prompt.should be_nil
    #puts "new_items: #{new_items}"
  #end
  
end
