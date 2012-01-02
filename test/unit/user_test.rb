require 'test_helper'

class UserTest < ActiveSupport::TestCase

  attr_reader :create_params

  def setup
    @create_params = {
      :login => 'spongebob',
      :password => 'squarepants', # hashed on save
      :role => 'user',
      :name => 'Spongebob Squarepants',
      :email => 'spongebob@example.com',
      :address => 'Bikini Bottom'
    }
    @user = User.create(@create_params)
  end

  test "password hashed on save" do
    assert @user.password != @create_params[:password]
    assert_match /[a-zA-Z0-9]{16}:[a-fA-F0-9]+$/, @user.password
  end

  test "authenticate finds user" do
    assert_equal @user, User.authenticate(@create_params[:login], @create_params[:password])
  end

  test "authenticate with bad password does not return user" do
    assert_nil User.authenticate(@create_params[:login], 'bogus')
  end

  test "password matches" do
    assert users(:admin).password_matches?('password'), "password matcher is busted"
    assert @user.password_matches?(@create_params[:password]), "password matcher is busted"
  end

  test "password re-hashed on update" do
    old_hashed_value = @user.password
    @user.password = 'foobar'
    @user.save
    assert !@user.password.blank?
    assert old_hashed_value != @user.password
  end

  test "password not re-hashed if not changed" do
    old_hashed_value = @user.password
    @user.password = ''
    @user.save
    assert !@user.password.blank?, "user password should not be blank after save"
    assert_equal old_hashed_value, @user.password
  end
end
