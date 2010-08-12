class MessagesController < ApplicationController
  def index
    @user = current_user
    @messages = @user.messages
  end
  def create
    user = Message.split_user(params[:content])
    @user = User.find_by_name(user)
    @message = @user.messages.build(:content => params[:content], :sender_id => current_user.id)
    if @message.save
      if @user.mail_option?
        Resque.enqueue(Mailer, UserMailer.deliver_message_notification)
      end
      flash[:success] = "Your message has been sent already to #{@user.name}"
      redirect_to root_path
    else
      redirect_back
    end
  end
  
  def sent_messages
    @user = current_user
    @messages = @user.sent
  end
  
  def destroy
  end
end
