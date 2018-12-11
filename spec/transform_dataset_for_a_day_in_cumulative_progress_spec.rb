# frozen_string_literal: true

require 'date'
require 'datapoint_mock.rb'
require_relative '../run.rb'

RSpec.describe "full program behavior except calling API" do
  it "correctly processes into single-day resolution" do
    data = [DatapointMock.new(DateTime.new(2010, 1, 12), DateTime.new(2010, 1, 12, 8, 12), 1)]
    transformed = transform_dataset_for_a_day_in_cumulative_progress(data, 24*60)
    expect(transformed).to eq [1]
  end

  it "correctly processes into half-day resolution" do
    data = [DatapointMock.new(DateTime.new(2010, 1, 12), DateTime.new(2010, 1, 12, 8, 12), 1)]
    transformed = transform_dataset_for_a_day_in_cumulative_progress(data, 12*60)
    expect(transformed).to eq [1, 1]
  end

  it "correctly processes into 8 hours resolution" do
    data = [DatapointMock.new(DateTime.new(2010, 1, 12), DateTime.new(2010, 1, 12, 8, 12), 1)]
    transformed = transform_dataset_for_a_day_in_cumulative_progress(data, 8*60)
    expect(transformed).to eq [0, 1, 1]
  end
end
