class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :sender, :foreign_key => "sender_id", :class_name => "User"
  
  def self.split_user(content)
    message = /\A@(\w+)(.+)/
    return to_user = content.match(message)[1]
  end
end
