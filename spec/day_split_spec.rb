# frozen_string_literal: true

require 'date'
require 'datapoint_mock.rb'
require_relative '../processing.rb'

RSpec.describe "split_into_days" do
  def date
    DateTime.new(2001, 2, 3)
  end

  it "splits full dataset into separate days" do
    year = 2001
    month = 2
    first_datapoint  = DatapointMock.new(DateTime.new(year, month, 3), DateTime.new(year, month, 3, 12, 19), 10)
    second_datapoint = DatapointMock.new(DateTime.new(year, month, 4), DateTime.new(year, month, 4, 12, 19), 10)
    third_datapoint  = DatapointMock.new(DateTime.new(year, month, 5), DateTime.new(year, month, 5, 12, 19), 1000)
    fourth_datapoint = DatapointMock.new(DateTime.new(year, month, 5), DateTime.new(year, month, 5, 12, 29), 1)
    dataset = [first_datapoint, second_datapoint, third_datapoint, fourth_datapoint]
    end_date = dataset[-1].timestamp
    split = split_into_days(dataset, end_date)
    expect(split).to eq [[first_datapoint], [second_datapoint], [third_datapoint, fourth_datapoint]]
  end

  it "creates empty arrays for days without entries between dates with existing entries" do
    year = 2101
    month = 12
    first_datapoint  = DatapointMock.new(DateTime.new(year, month, 3), DateTime.new(year, month, 3, 12, 19), 10)
    second_datapoint = DatapointMock.new(DateTime.new(year, month, 4), DateTime.new(year, month, 4, 12, 19), 10)
    third_datapoint  = DatapointMock.new(DateTime.new(year, month, 7), DateTime.new(year, month, 5, 12, 19), 1000)
    fourth_datapoint = DatapointMock.new(DateTime.new(year, month, 7), DateTime.new(year, month, 5, 12, 29), 1)
    dataset = [first_datapoint, second_datapoint, third_datapoint, fourth_datapoint]
    end_date = dataset[-1].timestamp
    split = split_into_days(dataset, end_date)
    expect(split).to eq [[first_datapoint], [second_datapoint], [], [], [third_datapoint, fourth_datapoint]]
  end

  it "creates empty arrays for days without entries between date with existing entry and end date, including end date" do
    year = 1991
    month = 10
    first_datapoint  = DatapointMock.new(DateTime.new(year, month, 3), DateTime.new(year, month, 3, 12, 19), 10)
    second_datapoint = DatapointMock.new(DateTime.new(year, month, 4), DateTime.new(year, month, 4, 12, 19), 10)
    third_datapoint  = DatapointMock.new(DateTime.new(year, month, 5), DateTime.new(year, month, 5, 12, 19), 1000)
    fourth_datapoint = DatapointMock.new(DateTime.new(year, month, 5), DateTime.new(year, month, 5, 12, 29), 1)
    dataset = [first_datapoint, second_datapoint, third_datapoint, fourth_datapoint]
    end_date = DateTime.new(year, month, 10)
    split = split_into_days(dataset, end_date)
    expect(split).to eq [[first_datapoint], [second_datapoint], [third_datapoint, fourth_datapoint], [], [], [], [], []]
  end
end
