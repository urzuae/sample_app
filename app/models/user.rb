class User < ActiveRecord::Base
  include AASM
  
  aasm_column :state
  
  aasm_initial_state :created
  
  aasm_state :created
  aasm_state :registered
  aasm_state :activated
  
  aasm_event :processing do
    transitions :to => :registered, :from => [:created]
  end
  
  aasm_event :confirm do
    transitions :to => :activated, :from => [:registered]
  end
  
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation
  
  EmailRegex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/
  validates_presence_of :name, :email
  validates_length_of :name, :maximum => 50
  validates_format_of :email, :with => EmailRegex
  validates_uniqueness_of :email, :case_sensitive => false
  validates_confirmation_of :password
  validates_presence_of :password
  validates_length_of :password, :within => 6..40
  
  before_save :encrypt_password
  
  has_many :microposts, :dependent => :destroy
  has_many :relationships, :foreign_key => "follower_id", :dependent => :destroy
  has_many :following, :through => :relationships, :source => :followed
  has_many :reverse_relationships, :foreign_key => "followed_id", :class_name => "Relationship", :dependent => :destroy
  has_many :followers, :through => :reverse_relationships, :source => :follower
  
  named_scope :admin, :conditions => { :admin => true }
  
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end
  
  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil if user.nil?
    return user if user.has_password?(submitted_password) && (user.active?)
    nil
  end
  
  def following?(followed)
    relationships.find_by_followed_id(followed)
  end
  
  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end
  
  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end
  
  def remember_me!
    self.remember_token = encrypt("#{salt}--#{id}--#{Time.now.utc}")
    save_without_validation
  end

  def registered
    self.confirmation_token = encrypt("#{id}--#{Time.now.utc}")
    self.processing!
  end

  def feed
    Micropost.from_users_followed_by(self)
  end
  
  def active?
    confirmation_token.nil?
  end
  
  def confirmation
    self.confirmation_token = nil
    self.confirm!
  end
  
  private
  
  def encrypt_password
    unless password.nil?
      self.salt = make_salt
      self.encrypted_password = encrypt(password)
    end
  end
  
  def encrypt(string)
    secure_hash("#{salt}#{string}")
  end
  
  def make_salt
    secure_hash("#{Time.now.utc}#{password}")
  end
  
  def secure_hash(string)
    Digest::SHA2.hexdigest(string)
  end
  
end
