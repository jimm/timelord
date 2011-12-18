require 'digest/sha1'

class User < ActiveRecord::Base

  ROLE_USER = 'user'
  ROLE_ADMIN = 'admin'

  has_many :work_entries

  validates_uniqueness_of :login, :on => :create

  # Don't validate presence of hashed_password, because that will prevent
  # crypt_unless_empty from being called due to the validation violation.
  validates_presence_of :login, :role, :name, :email, :address

  before_create :crypt_password
  before_update :crypt_unless_empty

  # Authenticate a user.
  #
  # Example:
  #   @user = User.authenticate('bob', 'bobpass')
  #
  def self.authenticate(login, pass)
    user = find(:first, :conditions => ["login = ?", login])
    user.password_matches(pass) ? user : nil
  end

  def admin?
    self.role == ROLE_ADMIN
  end

  protected

  # Apply SHA1 encryption to the supplied password.
  # We will additionally surround the password with a salt
  # for additional security.
  def self.sha1(salt, pass)
    salt + ':' + Digest::SHA1.hexdigest("#{salt}--#{pass}--")
  end

  def self.generate_salt
    chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    (0..16).collect { |i| chars[rand(chars.length)] }.join
  end

  def password_matches(pass)
    salt, hash = pass.split(/:/)
    self.hashed_password == self.class.sha1(salt, pass)
  end

  # Before saving the record to database we will crypt the password
  # using SHA1.
  # We never store the actual password in the DB.
  def crypt_password
    write_attribute "hashed_password", self.class.sha1(self.class.generate_salt, hashed_password)
    @password = nil
  end

  # If the record is updated we will check if the password is empty.
  # If its empty we assume that the user didn't want to change his
  # password and just reset it to the old value.
  def crypt_unless_empty
    $stderr.puts "crypt_unless_empty" # DEBUG
    if self.hashed_password.empty?
      user = self.class.find(self.id)
      $stderr.puts "crypt_unless_empty re-read user hashed_password = #{hashed_password}" # DEBUG
      self.hashed_password = user.hashed_password
    else
      write_attribute "hashed_password", self.class.sha1(self.class.generate_salt, hashed_password)
    end
  end
end
