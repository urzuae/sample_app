require 'spec_helper'

describe UsersController do
  integrate_views

  #Delete these examples and add some real ones
  it "should use UsersController" do
    controller.should be_an_instance_of(UsersController)
  end

  describe "GET 'index'" do
    
    describe "for non-sign-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i 
      end
    end
    
    describe "for sign-in users" do
      
      before(:each) do
        @user = test_sign_in(Factory(:user))
        second = Factory(:user, :username => "second", :email => "another@example.com")
        third = Factory(:user, :username => "third", :email => "another@example.net")
        
        @users = [@user, second, third]
        30.times do
          @users << Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
        end
      end
      
      it "should be successful" do
        get :index, :search => ""
        response.should be_success
      end
      
      it "should have the right title" do
        get :index
        response.should have_tag("title", /find people/i)
      end
      
    end
    
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
    
    it "should have a name field" do
      get :new
      response.should have_tag("input[name=?][type=?]", "user[name]", "text")
    end
    
    it "should have an email field" do
      get :new
      response.should have_tag("input[name=?][type=?]", "user[email]", "text")
    end
    
    it "should have a password field" do
      get :new
      response.should have_tag("input[name=?][type=?]", "user[password]", "password")
    end
    
    it "should have a password confirmation field" do
      get :new
      response.should have_tag("input[name=?][type=?]", "user[password_confirmation]", "password")
    end
    
  end
  
  it "should have the right title" do
    get 'new'
    response.should have_tag("title", /Sign up/)
  end
  
  describe "GET 'show'" do
    
    before(:each) do
      @user = Factory(:user)
      User.stub!(:find, @user.id).and_return(@user)
    end
    
    it "should be succesful" do
      get :show, :id => @user
      response.should be_success
    end
    it "should have the right title" do
      get :show, :id => @user
      response.should have_tag("title", /#{@user.name}/)
    end
    it "should include the user's name" do
      get :show, :id => @user
      response.should have_tag("h2", /#{@user.name}/)
    end
    it "should have a profile image" do
      get :show, :id => @user
      response.should have_tag("h2>img", :class => "gravatar")
    end
    it "should show the user's microposts" do
      mp1 = Factory(:micropost, :user => @user, :content => "Foo bar")
      mp2 = Factory(:micropost, :user => @user, :content => "Lorem Ipsum")
      get :show, :id => @user
      response.should have_tag("span.content", mp1.content)
      response.should have_tag("span.content", mp2.content)
    end
  end
  
  describe "POST 'create'" do
    
    describe "failure" do
      
      before(:each) do
        @attributes = {
          :name => "",
          :email => "",
          :password => "",
          :password_confirmation => ""
        }
        @user = Factory.build(:user, @attributes)
        User.stub!(:new).and_return(@user)
        @user.should_receive(:save).and_return(false)
      end
      
      it "should have the right title" do
        post :create, :user => @attributes
        response.should have_tag("title", /sign up/i)
      end
      
      it "should render the 'new' page" do
        post :create, :user => @attributes
        response.should render_template('new')
      end
      
    end
    
    describe "success" do
      
      before(:each) do
        @attributes = {
          :name => "New User",
          :username => "newuser",
          :email => "user@example.com",
          :password => "foobar",
          :password_confirmation => "foobar"
        }
        @user = Factory(:user, @attributes)
        User.stub!(:new).and_return(@user)
      end
      
      it "should redirect to the home page" do
        post :create, :user => @attributes
        response.should redirect_to(root_path)
      end
      
      it "should have a welcome message" do
        post :create, :user => @attributes
        flash[:success].should =~ /thanks for registering/i
      end
      
      it "should not sign the user in" do
        post :create, :user => @attributes
        controller.should_not be_signed_in
      end
      
      it "should create a confirmation_token" do
        post :create, :user => @attributes
        @user.confirmation_token.should_not be_nil
      end
      
      it "should change state of user" do
        post :create, :user => @attributes
        @user.registered?.should be_true
      end
      
    end
  end
  
  describe "activation of user" do
    before(:each) do
      @attributes = {
        :name => "New User",
        :username => "newuser",
        :email => "user@example.com",
        :password => "foobar",
        :password_confirmation => "foobar"
      }
      @user = Factory(:user, @attributes)
      User.stub!(:new).and_return(@user)
      post :create, :user => @attributes
    end
      
    describe "failure" do
      it "should redirect to home page when confirmation_token is blank" do
        get :activate
        response.should redirect_to(root_path)
      end
    end
      
    describe "success" do
      before(:each) do
        get :activate, :confirmation_token =>  @user.confirmation_token
        @user.confirmation
      end
      it "should redirect to user page" do
        response.should redirect_to(user_path(@user))
      end
      it "should change state of user" do
        @user.activated?.should be_true
      end
      
      it "should delete confirmation_token" do
        @user.confirmation_token.should be_nil
      end
      
    end
  end
  
  describe "GET 'edit'" do
    
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    it "should be succesful" do
      get :edit, :id => @user
      response.should be_success
    end
    
    it "should have the right title" do
      get :edit, :id => @user
      response.should have_tag("title", /edit user/i)
    end
    
    it "should have a link to change the gravatar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_tag("a[href=?]", gravatar_url, /change/i)
    end
    
  end
  
  describe "PUT 'update'" do
    
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
      User.should_receive(:find).with(@user).and_return(@user)
    end
    
    describe "failure" do
      
      before(:each) do
        @invalids = { :email => "", :password => "" }
        @user.should_receive(:update_attributes).and_return(false)
      end
      
      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @invalids
        response.should render_template('edit')
      end
      
      it "should have the right title" do
        put :update, :id => @user, :user => @invalids
        response.should have_tag("title", /edit user/i)
      end
      
    end
    
    describe "success" do
      
      before(:each) do
        @attributes = { :name => "New Name", :username => "new username", :email => "user@example.org", :password => "barbaz", :password_confirmation => "barbaz" }
        @user.should_receive(:update_attributes).and_return(true)
      end
      
      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attributes
        response.should redirect_to user_path(@user)
      end
      
      it "should have a flash message" do
        put :update, :id => @user, :user => @attributes
        flash[:success].should =~ /updated/
      end
      
    end
    
  end

  describe "authentication of edit/update pages" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "for non-signed-in users" do
      
      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to signin_path
      end
      
      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to signin_path
      end
      
    end
    
    describe "for signed-in users" do
      
      before(:each) do
        wrong_user = Factory(:user, :username => "othername", :email => "use@example.net")
        test_sign_in(wrong_user)
      end
      
      it "should require matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end
      
      it "should require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
      
    end
    
  end
  
  describe "DELETE 'destroy'" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "as a non-admin user" do
      it "should protect the page" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end
    
    describe "as an admin user" do
      before(:each) do
        admin = Factory(:user, :username => Factory.next(:username), :email => "admin@example.com", :admin => true)
        test_sign_in(admin)
        User.should_receive(:find).with(@user).and_return(@user)
        @user.should_receive(:destroy).and_return(@user)
      end
      it "should destroy the user" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
    end
    
  end
  
  describe "follow pages" do
    describe "when not signed in" do
      it "should protect 'following'" do
        get :following
        response.should redirect_to(signin_path)
      end
      it "should protect 'followers'" do
        get :followers
        response.should redirect_to(signin_path)
      end
    end
    describe "when signed in" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @other_user = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
        @user.follow!(@other_user)
      end
      it "should show user following" do
        get :following, :id => @user
        response.should have_tag("a[href=?]", user_path(@other_user), @other_user.name)
      end
      it "should show user followers" do
        get :followers, :id => @other_user
        response.should have_tag("a[href=?]", user_path(@user), @user.name)
      end
    end
  end
  
end
