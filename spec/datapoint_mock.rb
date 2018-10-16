# frozen_string_literal: true

DatapointMock = Struct.new(:timestamp, :updated_at, :value) do
end

=begin
datapoints_array has accessible
  entry.timestamp # last second of the affected day
  entry.updated_at # time of posting/updating entry (may be on a later date)
  entry.value # datapoint value
=end
