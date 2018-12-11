# frozen_string_literal: true

require 'date'
require 'datapoint_mock.rb'
require_relative '../run.rb'

RSpec.describe "full program behavior except calling API" do
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
    required = 50
    returned = []
    while required > 0
      points = Random.rand(required) + 1
      required -= points
      returned << get_datapoint(date, points)
    end
    return returned
  end
  it "generates graph from data" do
    today = Time.now
    data = []
    (-100..0).each do |offset|
      data += get_data_for_a_day(today.next_day(offset))
      puts(data[-1])
    end
    process_data_and_generate_graph(data)
  end
end
