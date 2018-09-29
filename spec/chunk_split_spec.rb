require 'date'
require 'datapoint_mock.rb'
require_relative '../processing.rb'

RSpec.describe "split_into_singular_chunks" do
  def date()
    DateTime.new(2001, 2, 3)
  end

  def run_and_convert_to_mock(input)
    processed = split_into_singular_chunks(input)
    converted = []
    processed.each do |entry|
      converted << DatapointMock.new(entry.timestamp, entry.updated_at, entry.value)
    end
    return converted
  end

  it "raises exception if data is not from a single day" do
    year = 2018
    month = 1
    expect {
      entry_from_first_day = DatapointMock.new(DateTime.new(year, month, 3), DateTime.new(year, month, 3), 1)
      entry_from_second_day = DatapointMock.new(DateTime.new(year, month, 4), DateTime.new(year, month, 4), 1)
      split_into_singular_chunks([entry_from_first_day, split_into_singular_chunks])
    }.to raise_error(InvalidData)
  end

  xit "splits each point into chunks, each with singular value" do
    split_into_singular_chunks(dataset_for_a_day)
  end

  it "throws exception on encountering numbers that are not integers" do
    expect {
      split_into_singular_chunks([DatapointMock.new(date(), date(), 1.5)])
    }.to raise_error(InvalidData)
  end

  it "throws exception on encountering negative integer values" do
    expect {
      split_into_singular_chunks([DatapointMock.new(date(), date(), -1)])
    }.to raise_error(InvalidData)
  end

  it "is not changing dataset with logging minute-by-minute with sufficient gaps" do
    year = 2019
    month = 2
    day = 28
    a = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 12, 20), 1)
    b = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 12, 30), 1)
    c = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 12, 32), 1)
    dataset_for_a_day = [a, b, c]
    comparable = run_and_convert_to_mock(input)
    expect(comparable).to eq [c, b, a]
  end

  it "reorder form earliest to latest entry" do
    year = 2019
    month = 2
    day = 28
    a = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 12, 32), 1)
    b = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 12, 30), 1)
    c = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 12, 20), 1)
    comparable = run_and_convert_to_mock([a, b, c])
    expect(comparable).to eq [c, b, a]
  end

  it "is pushing apart entries in logging minute-by-minute if values are closer than one minute to each other" do
    year = 2019
    month = 2
    day = 28
    a = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 12, 32), 1)
    b = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 12, 32), 1)
    c = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 12, 20), 1)
    dataset_for_a_day = [a, b, c]

    expected_a = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 12, 20), 1)
    expected_b = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 12, 31), 1)
    expected_c = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 12, 32), 1)
    expected_dataset_for_a_day = [expected_a, expected_b, expected_c]
    comparable = run_and_convert_to_mock(dataset_for_a_day)
    expect(comparable).to eq expected_dataset_for_a_day
  end

  it "splits datapoint with value larger than 1" do
    year = 2020
    month = 7
    day = 30
    a = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 1, 0), 4)
    dataset_for_a_day = [a]

    expected_a = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 0, 57), 1)
    expected_b = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 0, 58), 1)
    expected_c = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 0, 59), 1)
    expected_d = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 1,  0), 1)
    expected_dataset_for_a_day = [expected_a, expected_b, expected_c, expected_d]
    comparable = run_and_convert_to_mock(dataset_for_a_day)
    expect(comparable).to eq expected_dataset_for_a_day
  end

  it "handles single value datapoint added or modified after the day by moving it to the last moment before midnight" do
    year = 2020
    month = 7
    day = 20
    a = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day+1, 1, 0), 1)
    dataset_for_a_day = [a]

    expected_a = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 23, 59), 1)

    expected_dataset_for_a_day = [expected_a]

    comparable = run_and_convert_to_mock(dataset_for_a_day)
    expect(comparable).to eq expected_dataset_for_a_day
  end

  it "handles large value datapoint added or modified after the day by moving it to the midnight and splitting" do
    year = 2020
    month = 12
    day = 31

    later_year = 2021
    later_month = 3
    later_day = 1
    a = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(later_year, later_month, later_day, 1, 0), 3)
    dataset_for_a_day = [a]

    expected_a = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 0, 58), 1)
    expected_b = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 0, 59), 1)
    expected_c = DatapointMock.new(DateTime.new(year, month, day), DateTime.new(year, month, day, 1,  0), 1)
    expected_dataset_for_a_day = [expected_a, expected_b, expected_c]

    comparable = run_and_convert_to_mock(dataset_for_a_day)
    expect(comparable).to eq expected_dataset_for_a_day
  end
end
