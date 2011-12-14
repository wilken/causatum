require 'digest/md5'
class User 
  include Mongoid::Document
  has_many :events

  SALT = "salt"
  before_save :encrypt_password
  
  def valid_password?(pwd)
    self.password == Digest::MD5.hexdigest(pwd + SALT)
  end
  
  def encrypt_password
    self.password = Digest::MD5.hexdigest(self.password + SALT) if self.password_changed?
  end

  field :login, type: String
  field :password, type: String
  field :email, type: String
  field :name, type: String
  
end