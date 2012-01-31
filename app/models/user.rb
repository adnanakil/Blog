require 'digest'

class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation
  
  has_many :microposts, :dependent => :destroy
  
  has_many :relationships, :foreign_key => "follower_id", 
      :dependent => :destroy
  has_many :following, :through => :relationships, :source => :followed
  
  has_many :reverse_relationships, :foreign_key => "followed_id",
    :class_name => "Relationship", :dependent => :destroy
  has_many :followers, :through => :reverse_relationships, :source => :follower
  
  email_regex = /\A[a-z\d_+.-]+@[a-z\d.-]+\.[a-z]{2,4}\z/i
  
  validates :name, :presence => true,
    :length => { :maximum => 20 }
  validates :email, :presence => true,
    :format => { :with => email_regex },
    :uniqueness => { :case_sensitive => false }
  validates :password, :presence => true,
    :confirmation => true,
    :length => { :within => 6..20 }
  
  before_save :encrypt_password
  
  def valid_password?(submitted_password)
    self.encrypted_password == encrypt(submitted_password)
  end
  
  def self.authenticate(email, submitted_password)
    user = User.find_by_email(email)
    user && user.valid_password?(submitted_password) ? user : nil
  end
  
  def self.authenticate_with_salt(id, cookie_salt)
    user = User.find_by_id(id)
    user && user.salt == cookie_salt ? user : nil
  end
  
  def feed
    # Micropost.where("user_id = ?", id)
    Micropost.from_users_followed_by(self)
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
  
  private
    def encrypt_password
      self.salt = make_salt if self.new_record?
      self.encrypted_password = encrypt(self.password)
    end
    
    def encrypt(string)
      secure_hash "#{salt}--#{string}"
    end
    
    def make_salt
      secure_hash "#{Time.now.utc}--#{self.password}"
    end
    
    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end
