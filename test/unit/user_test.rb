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
      :address => 'Bikini Bottom',
      :rate_type => 'hourly',
      :rate_amount_cents => '10000'
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

  test "money to cents conversion" do
    assert_equal 0, User.money_to_cents('')
    assert_equal 0, User.money_to_cents('0')
    assert_equal 50, User.money_to_cents('50')
    assert_equal 50, User.money_to_cents('$.50')
    assert_equal 50, User.money_to_cents('$0.50')
    assert_equal 150, User.money_to_cents('$1.50')
    assert_equal 1203, User.money_to_cents('$12.03')
    assert_equal 12345, User.money_to_cents('$123.45')
    assert_equal 1234500, User.money_to_cents('$12,345.00')
  end

  test "hourly rate in cents" do
    assert_equal 10000, @user.hourly_rate_cents(nil)
    assert_equal 10000, @user.hourly_rate_cents(234)
  end

  test "hourly rate in cents for yearly amount" do
    @user.rate_type = 'yearly'
    @user.rate_amount_cents = 1200_00
    assert_equal 100_00, @user.hourly_rate_cents(60)
    assert_equal 50_00, @user.hourly_rate_cents(120)
  end

end
