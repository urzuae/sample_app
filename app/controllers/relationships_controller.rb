class RelationshipsController < ApplicationController
  before_filter :authenticate
  before_filter :get_followed_user
  
  def create
    current_user.follow!(@user)
    respond_to do |format|
      format.html do
        UserMailer.deliver_follower_notification(@user, current_user) if @user.mail_option?
        redirect_to @user
      end
      format.js do
        UserMailer.deliver_follower_notification(@user, current_user) if @user.mail_option?
      end
    end
  end
  
  def destroy
    current_user.unfollow!(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
  
  private
  
  def get_followed_user
    @user = User.find(params[:relationship][:followed_id])
  end
end
