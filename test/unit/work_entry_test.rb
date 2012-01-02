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
    assert_equal '0:30', work_entries(:one).minutes_as_duration
    assert_equal '1:00', work_entries(:two).minutes_as_duration
    assert_equal '2:00', work_entries(:older).minutes_as_duration
  end

  test "duration as minutes" do
    assert_equal 0, WorkEntry.duration_as_minutes('')
    assert_equal 0, WorkEntry.duration_as_minutes('0')
    assert_equal 0, WorkEntry.duration_as_minutes('0:00')
    assert_equal 9, WorkEntry.duration_as_minutes('0:09')
    assert_equal 59, WorkEntry.duration_as_minutes('0:59')
    assert_equal 60, WorkEntry.duration_as_minutes('1:00')
    assert_equal 60+59, WorkEntry.duration_as_minutes('1:59')
    assert_equal 120, WorkEntry.duration_as_minutes('2:00')
    assert_equal MINS_PER_DAY, WorkEntry.duration_as_minutes('1:00:00')
    assert_equal MINS_PER_DAY + 59, WorkEntry.duration_as_minutes('1:00:59')
    assert_equal MINS_PER_DAY + 122, WorkEntry.duration_as_minutes('1:02:02')
  end

  test "duration as minutes without hour or colon" do
    assert_equal 15, WorkEntry.duration_as_minutes('15')
    assert_equal 15, WorkEntry.duration_as_minutes(':15')
    assert_equal 90, WorkEntry.duration_as_minutes('90')
    assert_equal 90, WorkEntry.duration_as_minutes(':90')
  end

  test "scope in_month" do
    user = users(:normal)
    assert_equal 0, WorkEntry.in_month(user.id, 2011, 10).count
    assert_equal 1, WorkEntry.in_month(user.id, 2011, 11).count
    assert_equal 3, WorkEntry.in_month(user.id, 2011, 12).count
  end

end
