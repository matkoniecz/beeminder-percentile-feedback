# frozen_string_literal: true

require 'date'
require 'datapoint_mock.rb'
require_relative '../run.rb'

RSpec.describe "full program behavior except calling API" do
  it "generates graph from data" do
    data = [DatapointMock.new(DateTime.new(2018, 12, 5), DateTime.new(2018, 12, 5, 12, 19), 1000)]
    process_data_and_generate_graph(data)
  end
end