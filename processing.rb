# frozen_string_literal: true

require 'time'
require 'active_support'
require 'beeminder'

class InvalidData < StandardError
end

def download_data
  token = File.new("token.secret").read.strip
  goal_name = File.new("goal_name.secret").read.strip

  bee = Beeminder::User.new token

  goal = bee.goal goal_name
  # dp = Beeminder::Datapoint.new :value => 2, :comment => "from API"
  # goal.add dp
  return goal.datapoints
end

def split_into_days(dataset, end_date = Time.now)
  Date.new(1999, 1, 1)
  # start date is provided by beeminder but end date is not
  # end data is explicit to allow testing

  first_day = (dataset.min_by { |entry| entry.timestamp.to_date }).timestamp.to_date
  i = first_day
  by_day = {}
  while i <= end_date.to_date
    by_day[i] = []
    i = i.next_day(1)
  end

  dataset.each do |entry|
    day = entry.timestamp.to_date
    by_day[day] << entry
  end
  by_day = by_day.sort

  returned = []
  by_day.each do |day, datapoint_list|
    returned << datapoint_list.sort_by { |entry| entry.timestamp }
  end
  return returned
end

def percentile_of_day_compared_to_other(dataset_split_by_day, checked_datetime = Time.now, end_date = Time.now)
  # each day check until checked_datetime hour, minute, second
  # and record value into table
  # on attempting checked_datetime year, month and day record value
  # count how many are below
  current_day = dataset_split_by_day[0][0].timestamp.to_date
  values_for_each_day = []
  value_for_checked_day = nil
  dataset_split_by_day.each do |day|
    total_counted_for_a_day = 0
    if day != []
      day.each do |entry|
        if entry.updated_at.hour * 60 + entry.updated_at.min <= checked_datetime.hour * 60 + checked_datetime.min
           total_counted_for_a_day += entry.value
        end
      end
    end
    if checked_datetime.to_date == current_day
      value_for_checked_day = total_counted_for_a_day
    end
    values_for_each_day << total_counted_for_a_day
    current_day = current_day.next_day(1)
  end
  return get_percentile(value_for_checked_day, values_for_each_day)
end

def get_percentile(value, dataset)
  below_or_equal_to_value = 0
  dataset.each do |entry|
    below_or_equal_to_value += 1 if entry <= value
  end
  return (below_or_equal_to_value * 100 / dataset.length).to_i
end
