require 'test_helper'

class CodeTest < ActiveSupport::TestCase

  test "used true if used" do
    assert codes(:loc1code1).used?
  end

  test "used false if not used" do
    assert !codes(:loc1code2).used?
  end
end
