require 'beeminder'
require 'active_support'

token = File.new("token.secret").read
goal_name = File.new("goal_name.secret").read

bee = Beeminder::User.new token

goal = bee.goal goal_name
# dp = Beeminder::Datapoint.new :value => 2, :comment => "from API"
# goal.add dp
data = goal.datapoints
data.each do |entry|
  puts entry.timestamp # last second of the affected day
  puts entry.updated_at # time of posting/updating entry (may be on a later date)
  puts entry.value # datapoint value
  puts
end