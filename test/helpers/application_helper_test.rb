# frozen_string_literal: true

require "test_helper"

SimpleCov.command_name "test:helpers"

# Assure that date and time methods work as expected.
class ApplicationHelperTest < ActionView::TestCase
  test "should show date" do
    date = Time.zone.today + 5.days
    date = date.change(year: Time.zone.today.year)
    assert_equal date.strftime("%b %-d"), simple_date(date)
  end

  test "should show date today" do
    date = Time.zone.today
    assert_equal "Today", simple_date(date)
  end

  test "should show date yesterday" do
    date = Time.zone.today - 1.day
    assert_equal "Yesterday", simple_date(date)
  end

  test "should show date tomorrow" do
    date = Time.zone.today + 1.day
    assert_equal "Tomorrow", simple_date(date)
  end

  test "should show full date from last year" do
    date = Time.zone.today - 1.year
    assert_equal date.strftime("%b %-d, %Y"), simple_date(date)
  end

  test "should show time" do
    time = Time.zone.now
    assert_equal time.strftime("Today at %-I:%M %p"), simple_time(time)
  end

  test "should show full time from yesterday" do
    time = Time.zone.now - 1.day
    time += 2.days if time.year != Time.zone.now.year # Test would fail if run on Jan 1st otherwise
    assert_equal time.strftime("on %b %-d at %-I:%M %p"), simple_time(time)
  end

  test "should show full time from last year" do
    time = Time.zone.now - 1.year
    assert_equal time.strftime("on %b %-d, %Y at %-I:%M %p"), simple_time(time)
  end
end
