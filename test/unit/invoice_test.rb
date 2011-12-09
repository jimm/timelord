require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase

  test "money to string" do
    assert_equal "$0.00", Invoice.money_str(0)
    assert_equal "$0.03", Invoice.money_str(3)
    assert_equal "$0.23", Invoice.money_str(23)
    assert_equal "$1.23", Invoice.money_str(123)
    assert_equal "$1.03", Invoice.money_str(103)
    assert_equal "$1,234.56", Invoice.money_str(123456)
  end

  test "invoice number" do
    inv = Invoice.new(2011, 11)
    assert_equal 11, inv.invoice_number

    inv = Invoice.new(2012, 11)
    assert_equal 23, inv.invoice_number
  end

end
