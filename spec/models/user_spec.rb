require 'spec_helper'

describe User do
  before(:each) do
    @attributes = { :name => "user", :email => "user@name.com" }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attributes)
  end
  
  it "should require a name" do
    user_name = User.new(@attributes.merge(:name => ""))
    user_name.should_not be_valid
  end
  
  it "should require an email address" do
    user_email = User.new(@attributes.merge(:email => ""))
    user_email.should_not be_valid
  end
  
  it "should reject names that are too long" do
    long_name = "a" * 51
    user_name = User.new(@attributes.merge(:name => long_name))
    user_name.should_not be_valid
  end
  
  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      user_email = User.new(@attributes.merge(:email => address))
      user_email.should be_valid
    end
  end
  
  it "should reject invalid addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      user_email = User.new(@attributes.merge(:email => address))
      user_email.should_not be_valid
    end
  end
  
  it "should reject dupicate email addresses" do
    User.create!(@attributes)
    user_duplicate = User.new(@attributes)
    user_duplicate.should_not be_valid
  end
end
