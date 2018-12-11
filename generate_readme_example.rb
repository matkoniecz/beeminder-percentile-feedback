# frozen_string_literal: true

require 'date'
require_relative 'spec/datapoint_mock.rb'
require_relative 'run.rb'

def get_datapoint(date, points)
  year = date.year
  month = date.month
  day = date.day
  hour = Random.rand(24)
  minute = Random.rand(60)
  if Random.rand(2) == 0
    hour = 23
    if Random.rand(2) == 0
      minute = Random.rand(30) + 30
    end
  end
  return DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, hour, minute), points)
end

def get_data_for_a_day(date)
  required = 200
  returned = []
  while required > 0
    points = Random.rand(required) + 1
    if Random.rand(2) == 0
      points /= 2
      points += 1
    end
    if Random.rand(2) == 0
      points /= 3
      points += 1
    end
    required -= points
    returned << get_datapoint(date, points)
  end
  return returned
end

today = Time.now
data = []
(-100..0).each do |offset|
  data += get_data_for_a_day(today.next_day(offset))
  puts(data[-1])
end
process_data_and_generate_graph(data)
