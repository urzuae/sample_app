class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_mail(user)
    @subject = "Confirm you Sample App account"
    @body = "Activate your account. Click in the following link, http://radiant-flower-29.heroku.com/activate/#{user.confirmation_token}"
  end
  
  def message_notification(user, sender)
    setup_mail(user)
    @subject = "You receive a message from #{sender.name}"
    @body = "#{sender.name} send you a message. Check your inbox now. #{signin_url}"
  end
  
  def follower_notification(user, sender)
    setup_mail(user)
    @subject = "#{sender.name} is now following you."
    @body = "#{sender.name} is now following you. Do you want to follow #{sender.name}.\nGo now! #{signin_url}"
  end
  
  def setup_mail(user)
    @recipients = "#{user.email}"
    @from = "no-reply@sampleapp.com"
  end
end
