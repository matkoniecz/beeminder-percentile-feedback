# frozen_string_literal: true

require_relative 'processing.rb'
require 'gruff'
require 'logger'

def main
  data = download_data
  data.reverse_each do |entry|
    print_datapoint(entry, Logger::INFO)
    $logger.info ""
  end
  process_data_and_generate_graph(data)
end

def process_data_and_generate_graph(data)
  split = split_into_days(data)
  step = 15
  now = Time.now
  outliers = get_outliers(split, current_date: now.to_date, percent_to_remove: 10)
  data_for_graph = []
  # first day is guaranted to have 0 datapoint added by beeminder, so [0][0] is safe
  # -1 is done to counteract first incrementation in a loop
  # incrementation is at the beginning of loop to allow for breaks in alter part
  processed_date = split[0][0].timestamp.to_date.next_day(-1)
  split.each do |dataset_for_a_day|
    processed_date = processed_date.next_day(1)
    progress = get_data_series_for_graph(dataset_for_a_day, processed_date, now, step)

    total_value = progress[-1].to_i
    location_in_outliers = outliers.index(total_value)
    if !location_in_outliers.nil? && processed_date != now.to_date
      # current day is not discarded, even if it is an outlier
      outliers.delete_at location_in_outliers
      $logger.info "IGNORED AS OUTLIER (#{total_value})"
    else
      $logger.debug progress.inspect
      data_for_graph << progress
    end
  end

  if outliers.length > 0
    $logger.warn "NOT REMOVED OUTLIERS: #{outliers}"
  end
  generate_graph(data_for_graph, split)
end

def get_special_color_for_today(days_count)
  colors = []
  (1..(days_count-1)).each do |_|
    colors << '#bbbbbb'
  end
  colors << 'black'
end

def get_outliers(dataset_split_into_days, current_date, percent_to_remove: 10)
  processed_date = dataset_split_into_days[0][0].timestamp.to_date.next_day(-1)
  day_counts = []
  dataset_split_into_days.each do |dataset_for_a_day|
    processed_date = processed_date.next_day(1)
    day_count = 0
    if processed_date == current_date
      # do not discard current date even if it is an outlier
      next
    end
    dataset_for_a_day.each do |datapoint|
      if datapoint.timestamp.to_date == datapoint.updated_at.to_date
        day_count += datapoint.value
      end
    end
    day_counts << day_count.to_i
  end

  day_counts.sort!
  lower_outliers = day_counts[0..day_counts.length * percent_to_remove / 100 / 2]
  upper_outliers = day_counts[-(day_counts.length * percent_to_remove / 100 / 2)..day_counts.length - 1]
  return lower_outliers + upper_outliers
end

def print_datapoint(entry, importance)
  $logger.add(importance) { entry.timestamp } # last second of the affected day
  $logger.add(importance) { entry.updated_at } # time of posting/updating entry (may be on a later date)
  $logger.add(importance) { entry.value } # datapoint value
end

def get_initialized_graph(displayed_lines)
  size = 2000
  g = Gruff::Line.new(size)
  g.hide_legend = true
  g.hide_dots = true
  g.line_width = 1
  g.theme = {
    colors: get_special_color_for_today(displayed_lines),
    marker_color: 'grey',
    font_color: 'black',
    background_colors: 'white'
  }
  return g
end

def get_data_series_for_graph(dataset_for_a_day, day_date, current_time, resolution_in_minutes)
  progress = transform_dataset_for_a_day_in_cumulative_progress(dataset_for_a_day, resolution_in_minutes)
  if day_date.to_date == current_time.to_date
    # do not paint line of what has yet to happen
    # especially as it would be a flat demotivating one
    wanted_minutes = current_time.hour * 60 + current_time.min
    wanted_steps = wanted_minutes / resolution_in_minutes + 1 #+1 because we want also current that started but is not yet finished
    return progress[0, wanted_steps]
  end
  return progress
end

def generate_graph(processed_data_for_graph, data_split_into_days)
  g = get_initialized_graph(processed_data_for_graph.length)
  processed_data_for_graph.each do |data_for_day|
    g.data :day, data_for_day
  end

  $logger.info "GENERATING"

  # https://github.com/topfunky/gruff
  # https://makandracards.com/makandra/8745-plot-graphs-in-ruby
  # probably I should switch to https://plot.ly/python/
  g.title = "percentile #{percentile_of_day_compared_to_other(data_split_into_days)} for #{goal_name()}"
  g.write('percentile_feedback.png')
  pid = Process.fork
  if pid.nil? then
    # In child
    `eog percentile_feedback.png`
    exit
  else
    # In parent
    Process.detach(pid)
  end
end

$logger = Logger.new(STDOUT)
$logger.formatter = proc do |severity, datetime, _progname, msg|
  "#{severity} [#{datetime.strftime('%Y-%m-%d %H:%M:%S.%6N')} ##{Process.pid}]: #{msg}\n"
end
$logger.level = Logger::WARN

if __FILE__ == $0
  $logger.level = Logger::INFO
  main
end
