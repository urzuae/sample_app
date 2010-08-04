class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_mail(user)
  end
  
  def setup_mail(user)
    @recipients = "#{user.email}"
    @from = "no-reply@localhost.com"
    @subject = "Confirm you Sample App account"
    @body = "Activate your account. Click in the following link http://radiant-flower-29.heroku.com/activate/#{user.confirmation_token}"
  end
end
