require 'test_helper'

class LocationTest < ActiveSupport::TestCase

  test "used true if used" do
    assert locations(:loc1).used?
    assert locations(:loc2).used?
  end

  test "used false if not used" do
    loc = Location.create(:name => 'newbie')
    assert !loc.used?
  end
end
