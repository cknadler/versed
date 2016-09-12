require "versed/category"
require "versed/day"

module Versed
  class Schedule
    attr_reader :categories, :days

    WEEKDAYS = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ]

    def initialize(raw_schedule, raw_log)
      # TODO: refactor so this is an array, not a hash
      @categories = {}
      @days = Array.new(7)

      # create categories
      category_ids(raw_schedule).uniq.sort.each do |id|
        self.categories[id] = Versed::Category.new(id)
      end

      # find start date
      date = Date.parse(raw_log.keys[0])
      date = date.prev_day(date.wday)

      # TODO: add handle for exluding days that fall out of the selected week

      # create days
      7.times.each_with_index do |day_id|
        @days[day_id] = Day.new(day_id, date)
        date = date.next_day
      end

      # map category tasks to days so tasks can be looked up by day or category
      categories.each do |id, category|
        category.tasks.each_with_index do |task, index|
          days[index].tasks << task
        end
      end

      map_time_scheduled(raw_schedule)
      map_time_spent(raw_log)
    end

    def to_hash
      hash = {
        "weekdays" => WEEKDAYS,
        "categories" => [],
        "metadata" => metadata,
        "incomplete_tasks" => incomplete_tasks,
        "first_date" => @days[0].date
      }

      self.categories.each do |id, category|
        hash["categories"] << category.to_hash
      end

      hash
    end

    private

    def map_time_scheduled(raw_schedule)
      7.times.each_with_index do |day_id|
        schedule_day = lookup_day(raw_schedule, day_id)
        next unless day_id

        schedule_day.each do |scheduled_task_name, time_scheduled|
          category = self.categories[scheduled_task_name]
          unless category
            puts "Error, unrecognized category in schedule."
            exit 1
          end

          category.tasks[day_id].time_scheduled = time_scheduled
        end
      end
    end

    def map_time_spent(raw_log)
      raw_log.each do |day, tasks|
        day_id = Date.parse(day).wday

        tasks.each do |log_task_name, time_spent|
          category = self.categories[log_task_name]
          next unless category # TODO: possibly handle tasks that are done out of the schedule here

          category.tasks[day_id].time_spent = time_spent
        end
      end
    end

    def category_ids(raw_schedule)
      category_ids = []
      raw_schedule.each do |day, tasks|
        category_ids += tasks.keys
      end
      category_ids
    end

    def lookup_day(raw_schedule, day_id)
      raw_schedule[WEEKDAYS[day_id]]
    end

    ###
    # metadata
    ###

    def metadata
      [
        {
          "id" => "Days Active",
          "value" => "#{days_active} (#{days_active_percent}%)"
        },
        {
          "id" => "Time Logged",
          "value" => "#{total_min_logged} min (#{total_hr_logged} hr)"
        },
        {
          "id" => "Time Logged Per Day",
          "value" => "#{min_logged_per_day} min (#{hr_logged_per_day} hr)"
        },
        {
          "id" => "Completed",
          "value" => "#{total_min_logged_on_schedule} / #{total_min_scheduled} (#{completed_percent}%)"
        },
        {
          "id" => "Off Schedule",
          "value" => "#{total_min_logged_off_schedule} / #{total_min_logged} (#{off_schedule_percent}%)"
        }
      ]
    end

    def days_active
      @days.count { |d| d.active? }
    end

    def days_active_percent
      percent(days_active, 7)
    end

    def total_min_logged
      total_min_logged_on_schedule + total_min_logged_off_schedule
    end

    def total_min_logged_on_schedule
      time = 0
      @days.each do |day|
        day.tasks.each do |task|
          next unless task.time_spent && task.time_scheduled
          if task.time_scheduled < task.time_spent
            time += task.time_scheduled
          else
            time += task.time_spent
          end
        end
      end
      time
    end

    def total_min_logged_off_schedule
      time = 0
      @days.each do |day|
        day.tasks.each do |task|
          next unless task.time_spent

          if !task.time_scheduled
            time += task.time_spent
          elsif task.time_scheduled < task.time_spent
            time += task.time_spent - task.time_scheduled
          end
        end
      end
      time
    end

    def total_hr_logged
      divide(total_min_logged, 60)
    end

    def min_logged_per_day
      divide(total_min_logged, 7)
    end

    def hr_logged_per_day
      divide(min_logged_per_day, 60)
    end

    def total_min_scheduled
      time = 0
      @days.each do |day|
        day.tasks.each do |task|
          next unless task.time_scheduled?
          time += task.time_scheduled
        end
      end
      time
    end

    def completed_percent
      percent(total_min_logged_on_schedule, total_min_scheduled)
    end

    def off_schedule_percent
      percent(total_min_logged_off_schedule, total_min_logged)
    end

    ###
    # Incompmlete Tasks
    ###

    def incomplete_tasks
      top_tasks = []
      find_incomplete_tasks.each do |category|
        hash = {}
        hash["id"] = category.id
        hash["value"] = "#{category.total_min_logged} / #{category.total_min_scheduled} (#{category.percent_incomplete}%)"
        top_tasks << hash
      end
      top_tasks
    end

    def find_incomplete_tasks
      incomplete = []
      @categories.each do |id, category|
        if category.total_min_incomplete > 0
          incomplete << category
        end
      end

      incomplete.sort! do |x, y|
        y.total_min_incomplete <=> x.total_min_incomplete
      end

      incomplete
    end

    def percent(a, b)
      ((a / b.to_f) * 100).round(1)
    end

    def divide(a, b)
      (a / b.to_f).round(1)
    end
  end
end
