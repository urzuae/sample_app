require 'spec_helper'

describe User do
  before(:each) do
    @attributes = { 
      :name => "user",
      :email => "user@name.com",
      :password => "foobar",
      :password_confirmation => "foobar"
    }
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
  
  describe "password validations" do
    
    it "should require a password" do
      User.new(@attributes.merge(:password => "", :password_confirmation => "")).should_not be_valid
    end
    
    it "should require a matching password confirmation" do
      User.new(@attributes.merge(:password_confirmation => "invalid")).should_not be_valid
    end
    
    it "should reject short passwords" do
      short = "a" * 5
      hash = @attributes.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end
    
    it "should reject long passwords" do
      long = "a" * 41
      hash = @attributes.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end
  
  describe "password encryption" do
    before(:each) do
      @user = User.create!(@attributes)
    end
    
    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end
    
    describe "has_password? method" do
      
      it "should be true if the password match" do
        @user.has_password?(@attributes[:password]).should be_true
      end
      
      it "should be false if the password do not match" do
        @user.has_password?("failed").should be_false
      end
      
      describe "authenticate method" do
        
        it "should return nil on email/password mismatch" do
          user_wrong = User.authenticate(@attributes[:email], "wrongpass")
          user_wrong.should be_nil
        end
        
        it "should return nil for an email address with no user" do
          user_none = User.authenticate("bar@foo.com", @attributes[:password])
          user_none.should be_nil
        end
        
        it "should return the user on email/passwors match" do
          user_match = User.authenticate(@attributes[:email], @attributes[:password])
          user_match.should == @user
        end
        
      end
    end
  end
end
