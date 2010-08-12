class MicropostsController < ApplicationController
  before_filter :authenticate, :only => [:create, :destroy]
  before_filter :authorized_user, :only => [:destroy]
  require 'resque'
  require 'job'
  
  def index
    @user = current_user
    @all_microposts = current_user.microposts
    unless params[:search].blank?
      @microposts = Micropost.search(params[:search], params[:page])
    end
  end
  
  def create
    if Micropost.is_message?(params[:micropost][:content])
      redirect_to send_message_path(:params => params[:micropost])
    else
      @micropost = current_user.microposts.build(params[:micropost])
      if @micropost.save
        Resque.enqueue(Job, params)
        flash[:success] = "Micropost created!"
        redirect_to root_path
      else
        @feed_items = []
        render 'pages/home'
      end
    end
  end
  def destroy
    @micropost.destroy
    redirect_back_or root_path
  end
  
  private
  
  def authorized_user
    @micropost = Micropost.find(params[:id])
    redirect_to root_path unless current_user?(@micropost.user)
  end
  
end
