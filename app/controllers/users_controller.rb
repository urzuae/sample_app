class UsersController < ApplicationController  
  before_filter :authenticate, :except => [:show, :new, :create, :activate]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user, :only => [:destroy]
  
  def index
    unless params[:search].blank?
      @users = User.search(params[:search], params[:page])
    end
    @title = "Find People"
  end
  
  def new
    @user = User.new
    @title = "Sign up"
  end
  
  def create
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      @user.register
      UserMailer.deliver_signup_notification(@user.id)
      flash[:success] = "Thanks for registering, you will receive an email to confirm your account."
      redirect_to root_path
    else
      @title = "Sign up"
      @user.password = @user.password_confirmation = ""
      render 'new'
    end
  end
  
  def activate
    user = User.find_by_confirmation_token(params[:confirmation_token]) unless params[:confirmation_token].blank?
    if user && !user.active?
      user.confirmation
      flash[:success] = "Welcome to the Sample App. Your account was succesfully confirmed"
      sign_in user
      redirect_to user_path(user)
    else
      flash[:error] = "Your account has not been validated, check your email."
      redirect_to root_path
    end
  end
  
  def edit
    @title = "Edit user"
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end
  
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = CGI.escapeHTML(@user.name)
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_path
  end
  
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
    render 'show_follow'
  end
  
  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render 'show_follow'
  end

  def feeds
    @microposts = current_user.feed
  end
  
  private
  
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end
  
  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end

end
