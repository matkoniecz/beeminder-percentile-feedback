require_relative 'processing.rb'
require 'gruff'

def get_special_color_for_today(days_count)
  colors = []
  (1..days_count-1).each do |_|
    colors << 'gray'
  end
  colors << 'black'
end

def get_outliers(dataset_split_into_days, percent_to_remove: 10)
  day_counts = []
  dataset_split_into_days.each do |dataset_for_a_day|
    day_count = 0
    dataset_for_a_day.each do |datapoint|
      if datapoint.timestamp.to_date == datapoint.updated_at.to_date
        day_count += datapoint.value
      end
    end
    day_counts << day_count.to_i
  end

  day_counts.sort!
  lower_outliers = day_counts[0..day_counts.length * percent_to_remove / 100 / 2]
  upper_outliers = day_counts[-(day_counts.length * percent_to_remove / 100 / 2)..day_counts.length-1]
  return lower_outliers + upper_outliers
end

def print_datapoint(entry)
    puts entry.timestamp # last second of the affected day
    puts entry.updated_at # time of posting/updating entry (may be on a later date)
    puts entry.value # datapoint value
end

def obtain_data_for_each_day()
  data = download_data()
  data.each do |entry|
    print_datapoint(entry)
    puts
  end

  return split_into_days(data)
end

def get_initialized_graph(displayed_lines)
  size = 2000
  g = Gruff::Line.new(size)
  g.hide_legend = true
  g.hide_dots = true
  g.line_width = 1
  g.theme = {
    :colors => get_special_color_for_today(displayed_lines),
    :marker_color => 'grey',
    :font_color => 'black',
    :background_colors => 'white'
  }
  return g
end

def get_data_series_for_graph(dataset_for_a_day, day_date, current_time, step)
  minutes_in_day = 24 * 60
  minute_since_day_start = step
  dataset_index = 0
  progress = [0]
  while minute_since_day_start <= minutes_in_day
    progressed = 0
    while dataset_index < dataset_for_a_day.length
      update_time = dataset_for_a_day[dataset_index].updated_at
      if update_time.hour * 60 + update_time.min > minute_since_day_start
        break
      end
      datapoint = dataset_for_a_day[dataset_index]
      if datapoint.timestamp.to_date == datapoint.updated_at.to_date
        progressed += datapoint.value
      end
      dataset_index += 1
    end
    if day_date.to_date == current_time.to_date
      if minute_since_day_start > current_time.hour * 60 + current_time.min
        break
      end
    end
    progress << progress[-1] + progressed
    minute_since_day_start += step
  end
  return progress
end


split = obtain_data_for_each_day()
outliers = get_outliers(split, percent_to_remove: 10)
g = get_initialized_graph(split.length - outliers.length)
step = 15
# first day is guaranted to have 0 datapoint added by beeminder, so [0][0] is safe
# -1 is done to counteract first incrementation in a loop
# incrementation is at the beginning of loop to allow for breaks in alter part
processed_date = split[0][0].timestamp.to_date.next_day(-1)
now = Time.now
split.each do |dataset_for_a_day|
  processed_date = processed_date.next_day(1)
  progress = get_data_series_for_graph(dataset_for_a_day, processed_date, now, step)

  total_value = progress[-1].to_i
  location_in_outliers = outliers.index(total_value)
  if location_in_outliers != nil
    outliers.delete_at location_in_outliers
    puts "IGNORED AS OUTLIER (#{total_value})"
  else
    #puts progress.inspect
    g.data :day, progress
  end
end

puts "GENERATING"

# https://github.com/topfunky/gruff
# https://makandracards.com/makandra/8745-plot-graphs-in-ruby
# probably I should switch to https://plot.ly/python/
g.title = 'percentile X'
g.write('percentile_feedback.png')

