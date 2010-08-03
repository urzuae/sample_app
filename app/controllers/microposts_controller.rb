class MicropostsController < ApplicationController
  before_filter :authenticate, :only => [:create, :destroy, :index]
  def index
    @user = current_user
    @microposts = current_user.microposts
  end
  def create
    @micropost = current_user.microposts.build(params[:micropost])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_path
    else
      @feed_items = []
      render 'pages/home'
    end
  end
  def destroy
  end
end
