require 'test_helper'

class UserTest < ActiveSupport::TestCase

  attr_reader :create_params

  def setup
    @create_params = {
      :login => 'spongebob',
      :hashed_password => 'squarepants', # hashed on save
      :role => 'user',
      :name => 'Spongebob Squarepants',
      :email => 'spongebob@example.com',
      :address => 'Bikini Bottom'
    }
    @user = User.create(@create_params)
  end

  test "password hashed on save" do
    assert @user.hashed_password != @create_params[:hashed_password]
    assert_match /[a-zA-Z0-9]{16}:[a-fA-F0-9]+$/, @user.hashed_password
  end

  test "password re-hashed on update" do
    old_hashed_value = @user.hashed_password
    @user.hashed_password = 'foobar'
    @user.save
    assert !@user.hashed_password.blank?
    assert old_hashed_value != @user.hashed_password
  end

  test "password not re-hashed if not changed" do
    old_hashed_value = @user.hashed_password
    @user.hashed_password = ''
    @user.save
    assert !@user.hashed_password.blank?, "user hashed_password should not be blank after save"
    assert_equal old_hashed_value, @user.hashed_password
  end
end
