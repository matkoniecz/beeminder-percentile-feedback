require_relative 'processing.rb'
require 'gruff'

def get_special_color_for_today(days_count)
  colors = []
  (1..days_count-1).each do |_|
    colors << 'gray'
  end
  colors << 'black'
end

data = download_data()
data.each do |entry|
  puts entry.timestamp # last second of the affected day
  puts entry.updated_at # time of posting/updating entry (may be on a later date)
  puts entry.value # datapoint value
  puts
end

split = split_into_days(data)



size = 2000
g = Gruff::Line.new(size)
g.hide_legend = true
g.hide_dots = true
g.theme = {
  :colors => get_special_color_for_today(split.length),
  :marker_color => 'grey',
  :font_color => 'black',
  :background_colors => 'white'
}
step = 15
minutes_in_day = 24 * 60
split.each do |dataset_for_a_day|
  minute_since_day_start = step
  dataset_index = 0
  progress = [0]
  while minute_since_day_start <= minutes_in_day
    progressed = 0
    while dataset_index < dataset_for_a_day.length
      update_time = dataset_for_a_day[dataset_index].updated_at
      minutes_into_day = update_time.hour * 60 + update_time.min
      if minutes_into_day <= minute_since_day_start
        progressed += dataset_for_a_day[dataset_index].value
        dataset_index += 1
      else
        break
      end
    end
    progress << progress[-1] + progressed
    minute_since_day_start += step
  end
  puts progress.inspect
  g.data :day, progress
end

puts "GENERATING"

# https://github.com/topfunky/gruff
# https://makandracards.com/makandra/8745-plot-graphs-in-ruby
# probably I should switch to https://plot.ly/python/
g.title = 'percentile X'
g.write('percentile_feedback.png')

