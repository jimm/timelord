require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase

  def setup
    @user = users(:admin)
  end

  test "invoice number" do
    inv = Invoice.new(@user, 2011, 11)
    assert_equal "#{@user.id}-11", inv.invoice_number

    inv = Invoice.new(@user, 2012, 11)
    assert_equal "#{@user.id}-23", inv.invoice_number
  end

end
