require 'spec_helper'

describe User do
  before(:each) do
    @attributes = { 
      :name => "user",
      :username => "username",
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
  
  it "should require a username" do
    user_username = User.new(@attributes.merge(:username => ""))
    user_username.should_not be_valid
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
  
  it "should reject usernames that are too long" do
    long_username = "a" * 41
    user_username = User.new(@attributes.merge(:username => long_username))
    user_username.should_not be_valid
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
  
  it "should reject duplicate email addresses" do
    User.create!(@attributes.merge(:email => "user@name.com"))
    user_duplicate = User.new(@attributes.merge(:email => "user@name.com"))
    user_duplicate.should_not be_valid
  end
  
  it "should reject duplicate username" do
    User.create!(@attributes.merge(:username => "user_name"))
    user_duplicate = User.new(@attributes.merge(:username => "user_name"))
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
  
  describe "remember me" do
    
    before(:each) do
      @user = User.create!(@attributes)
    end
    
    it "should have a remember token" do
      @user.should respond_to(:remember_token)
    end
    
    it "should have a remember_me! method" do
      @user.should respond_to(:remember_me!)
    end
    
    it "should set the remember token" do
      @user.remember_me!
      @user.remember_token.should_not be_nil
    end
    
  end
  
  describe "admin attribute" do
    
    before(:each) do
      @user = User.create!(@attributes)
    end
    
    it "should respond to admin" do
      @user.should respond_to(:admin)
    end
    
    it "should not be an admin by default" do
      @user.should_not be_admin
    end
    
    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
    
  end
  
  describe "micropost associations" do
    before(:each) do
      @user = User.create(@attributes)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end

    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end
    it "should have the right microposts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end
    it "should destroy associated microposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end
    
    describe "status feed" do

      it "should have a feed" do
        @user.should respond_to(:feed)
      end
      it "should include the user's microposts" do
        @user.feed.include?(@mp1).should be_true
        @user.feed.include?(@mp2).should be_true
      end
      it "should not include a different user's microposts" do
        mp3 = Factory(:micropost, :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.include?(mp3).should be_false
      end
      it "should include the microposts of followed users" do
        followed = Factory(:user, :email => Factory.next(:email))
        mp3 = Factory(:micropost, :user => followed)
        @user.follow!(followed)
        @user.feed.include?(mp3).should be_true
      end
    end
  end
  
  describe "relationships" do
    before(:each) do
      @user = User.create!(@attributes)
      @followed = Factory(:user)
    end
    it "should have a relationships method" do
      @user.should respond_to(:relationships)
    end
    it "should have a following method" do
      @user.should respond_to(:following)
    end
    it "should have a following? method" do
      @user.should respond_to(:following?)
    end
    it "should have a follow! method" do
      @user.should respond_to(:follow!)
    end
    it "should follow another user" do
      @user.follow!(@followed)
      @user.following.include?(@followed).should be_true
    end
    it "should have an unfollow! method" do
      @user.should respond_to(:unfollow!)
    end
    it "should unfollow a user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end
    it "should have a reverse_relationships method" do
      @user.should respond_to(:reverse_relationships)
    end
    it "should have a followers method" do
      @user.should respond_to(:followers)
    end
    it "should include the follower in the followers array" do
      @user.follow!(@followed)
      @followed.followers.include?(@user).should be_true
    end
  end
  
  describe "act as state machine" do
    
    describe "states" do
      before(:each) do
        @user = User.create!(@attributes)
      end
      it "should respond to state method" do
        @user.should respond_to(:state)
      end
      it "should respont to created when a user is created" do
        @user.created?.should be_true
      end
      it "should respond to a processing method" do
        @user.should respond_to(:processing)
      end
      it "should transition from created to registered" do
        @user.processing
        @user.registered?.should be_true
      end
      it "should respond to a confirm method" do
        @user.should respond_to(:confirm)
      end
      it "should transition from registered to activated" do
        @user.processing
        @user.confirm
        @user.activated?.should be_true
      end
    end
  end
  
  describe "registration process" do
    before(:each) do
      @user = User.create(@attributes)
    end
    it "should respond to a register method" do
      @user.should respond_to(:register)
    end
    it "should change user state" do
      @user.register
      @user.state.should == "registered"
    end
    it "should respond to a confirmation method" do
      @user.should respond_to(:confirmation)
    end
    it "should change user state" do
      @user.register
      @user.confirmation
      @user.state.should == "activated"
    end
  end
  
end
