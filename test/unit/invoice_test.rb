require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase

  def setup
    @user = users(:normal)
    @inv = Invoice.new(@user, 2011, 12)
  end

  test "invoice number" do
    assert_equal "#{@user.id}-12", @inv.invoice_number

    inv = Invoice.new(@user, 2012, 11)
    assert_equal "#{@user.id}-23", inv.invoice_number
  end

  test "total minutes in month" do
    @inv.generate
    assert_equal 30+60+90, @inv.total_minutes_in_month
  end

  test "total minutes in code" do
    @inv.generate
    assert_equal 60+90, @inv.total_minutes_for_code(codes(:loc2code2))
  end

  test "generate hourly" do
    @inv.generate
    @inv.work_entries.each { |we|
      assert_equal 10000, we.rate_cents
      assert_equal 10000 * we.minutes / 60, we.fee_cents
    }
    assert_equal 30000, @inv.total
  end

  test "generate yearly" do
    @user.rate_type = 'yearly'
    @user.rate_amount_cents = 3600_00
    hourly_rate_for_180_mins = @user.hourly_rate_cents(180)
    # $300/month divided by 3 hours == $100/hour
    assert_equal 100_00, hourly_rate_for_180_mins

    @inv.generate
    @inv.work_entries.each { |we|
      assert_equal hourly_rate_for_180_mins, we.rate_cents
      assert_equal hourly_rate_for_180_mins * we.minutes / 60, we.fee_cents
    }
    assert_equal 3600_00 / 12, @inv.total
  end
end
