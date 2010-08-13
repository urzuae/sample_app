require 'resque_mailer'
class UserMailer < ActionMailer::Base
  include Resque::Mailer
  
  def signup_notification(user_id)
    user = User.find(user_id)
    @recipients = "#{user.email}"
    @from = "noreply@sampleapp.com"
    @subject = "Confirm you Sample App account"
    @body = "Activate your account. Click in the following link, #{activate_url(:confirmation_token => user.confirmation_token)}"
  end
  
  def message_notification(user, sender)
    setup_mail(user)
    @subject = "You receive a message from #{sender.name}"
    @body = "#{sender.name} send you a message. Check your inbox now. #{signin_url}"
  end
  
  def follower_notification(user_id, sender_id)
    user = User.find(user_id)
    sender = User.find(sender_id)
    
    @recipients = "#{user.email}"
    @from = "no-reply@sampleapp.com"
    @subject = "#{sender.name} is now following you."
    @body = "#{sender.name} is now following you. Do you want to follow #{sender.name}.\nGo now! #{signin_url}"
  end
  
  def setup_mail(user)
    @recipients = "#{user.email}"
    @from = "no-reply@sampleapp.com"
  end
end
