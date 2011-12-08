require 'test_helper'

class WorkEntryTest < ActiveSupport::TestCase

  MINS_PER_DAY = 60 * 24

  test "minutes as duration" do
    assert_equal '0:00', WorkEntry.minutes_as_duration(0)
    assert_equal '0:09', WorkEntry.minutes_as_duration(9)
    assert_equal '0:59', WorkEntry.minutes_as_duration(59)
    assert_equal '1:00', WorkEntry.minutes_as_duration(60)
    assert_equal '1:59', WorkEntry.minutes_as_duration(60+59)
    assert_equal '2:00', WorkEntry.minutes_as_duration(120)
    assert_equal '1:00:00', WorkEntry.minutes_as_duration(MINS_PER_DAY)
    assert_equal '1:00:59', WorkEntry.minutes_as_duration(MINS_PER_DAY + 59)
    assert_equal '1:02:02', WorkEntry.minutes_as_duration(MINS_PER_DAY + 122)
  end

  test "duration as minutes" do
    assert_equal WorkEntry.duration_as_minutes('0:00'), 0
    assert_equal WorkEntry.duration_as_minutes('0:09'), 9
    assert_equal WorkEntry.duration_as_minutes('0:59'), 59
    assert_equal WorkEntry.duration_as_minutes('1:00'), 60
    assert_equal WorkEntry.duration_as_minutes('1:59'), 60+59
    assert_equal WorkEntry.duration_as_minutes('2:00'), 120
    assert_equal WorkEntry.duration_as_minutes('1:00:00'), MINS_PER_DAY
    assert_equal WorkEntry.duration_as_minutes('1:00:59'), MINS_PER_DAY + 59
    assert_equal WorkEntry.duration_as_minutes('1:02:02'), MINS_PER_DAY + 122
  end

end
