require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

  test "money to string" do
    assert_equal "$0.00", money_str(0)
    assert_equal "$0.03", money_str(3)
    assert_equal "$0.23", money_str(23)
    assert_equal "$1.23", money_str(123)
    assert_equal "$1.03", money_str(103)
    assert_equal "$1,234.56", money_str(123456)
  end
end
