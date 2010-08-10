class Micropost < ActiveRecord::Base
  attr_accessible :content
  belongs_to :user
  
  validates_presence_of :content, :user_id
  validates_length_of :content, :maximum => 140
  
  default_scope :order => 'created_at DESC'
  
  named_scope :from_users_followed_by, lambda { |user| followed_by(user) }
  
  def self.followed_by(user)
    followed_ids = %(SELECT followed_id FROM relationships WHERE follower_id = :user_id)
    { :conditions => ["user_id IN (#{followed_ids}) OR user_id = :user_id", { :user_id => user }] }
  end
  
  def self.search(search, page)
    paginate :per_page => 10, :page => page, :conditions => ['content like ?', "%#{search}%"], :order => 'created_at'
  end
  
  def self.is_message?(content)
    message = /\A@(\w+)(.+)/
    to_message = content.match(message)
    if to_message.nil?
      return false
    else
      user = Message.split_user(content)
      user = User.find_by_username(user)
      if user.nil?
        return false
      else
        return true
      end
    end
  end
end

