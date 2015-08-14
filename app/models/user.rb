require 'digest/sha1'

class User < ActiveRecord::Base

  ROLE_USER = 'user'
  ROLE_ADMIN = 'admin'

  has_many :work_entries

  validates_uniqueness_of :login, :on => :create

  # Don't validate presence of password, because that will prevent
  # crypt_unless_empty from being called due to the validation violation.
  validates_presence_of :login, :role, :name, :email, :address, :invoice_recipient

  before_create :crypt_password
  before_update :crypt_unless_empty

  # Authenticate a user.
  #
  # Example:
  #   @user = User.authenticate('bob', 'bobpass')
  #
  def self.authenticate(login, pass)
    user = find_by(login: login)
    (user && user.password_matches?(pass)) ? user : nil
  end

  def self.all_roles
    %w(user admin)
  end

  def self.all_rate_types
    %w(hourly yearly)
  end

  # Turns a string like '$1,234.56' into an integer number of cents.
  def self.money_to_cents(str)
    return 0 if (str == nil || str == '')
    str.gsub(/\D/, '').to_i
  end

  # Given the number of minutes worked in a month, return the hourly rate
  # for that month. If the user's rate type is hourly, that will be
  # returned. If it's yearly, we figure out how much to charge per hour
  # based on the number of minutes worked.
  def hourly_rate_cents(minutes_worked_in_month)
    case self.rate_type
    when 'hourly'
      self.rate_amount_cents
    when 'yearly'
      if minutes_worked_in_month == 0
        0
      else
        monthly_amount = self.rate_amount_cents.to_f / 12.0
        hours_worked_in_month = minutes_worked_in_month.to_f / 60.0
        (monthly_amount / hours_worked_in_month).to_i
      end
    else
      raise 'illegal rate type'
    end
  end

  def admin?
    self.role == ROLE_ADMIN
  end

  def password_matches?(pass)
    salt, _ = password.split(/:/)
    self.password == self.class.sha1(salt, pass)
  end

  protected

  # Apply SHA1 encryption to the supplied password. We will additionally
  # surround the password with a salt for additional security.
  def self.sha1(salt, pass)
    salt + ':' + Digest::SHA1.hexdigest("#{salt}--#{pass}--")
  end

  def self.generate_salt
    chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    (0..16).collect { |i| chars[rand(chars.length)] }.join
  end

  # Before saving the record to database we will crypt the password using
  # SHA1. We never store the actual password in the DB.
  def crypt_password
    write_attribute "password", self.class.sha1(self.class.generate_salt, password)
    @password = nil
  end

  # If the record is updated we will check if the password is empty. If its
  # empty we assume that the user didn't want to change his password and
  # just reset it to the old value.
  def crypt_unless_empty
    if self.password.empty?
      user = self.class.find(self.id)
      self.password = user.password
    else
      write_attribute "password", self.class.sha1(self.class.generate_salt, password)
    end
  end
end
