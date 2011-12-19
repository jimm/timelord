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

  test "minutes as duration instance method calls class method" do
    assert_equal '1:15', work_entries(:one).minutes_as_duration
    assert_equal '1:30', work_entries(:two).minutes_as_duration
    assert_equal '2:00', work_entries(:older).minutes_as_duration
  end

  test "duration as minutes" do
    assert_equal WorkEntry.duration_as_minutes(''), 0
    assert_equal WorkEntry.duration_as_minutes('0'), 0
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

  test "scope in_month" do
    user = users(:one)
    assert_equal 0, WorkEntry.in_month(user.id, 2011, 10).count
    assert_equal 1, WorkEntry.in_month(user.id, 2011, 11).count
    assert_equal 2, WorkEntry.in_month(user.id, 2011, 12).count
  end

end
