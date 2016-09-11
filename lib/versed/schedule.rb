require "versed/category"

module Versed
  class Schedule
    attr_reader :categories

    WEEKDAYS = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ]

    def initialize(schedule, log)
      @categories = {}

      # create categories
      category_ids(schedule).uniq.sort.each do |id|
        self.categories[id] = Versed::Category.new(id)
      end

      # add scheduled time
      7.times.each_with_index do |day_id|
        schedule_day = lookup_day(schedule, day_id)
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

      # add time spent
      log.each do |day, tasks|
        day_id = Date.parse(day).wday

        tasks.each do |log_task_name, time_spent|
          category = self.categories[log_task_name]
          next unless category # TODO: possibly handle tasks that are done out of the schedule here

          category.tasks[day_id].time_spent = time_spent
        end
      end
    end

    def to_hash
      hash = {
        "weekdays" => WEEKDAYS,
        "categories" => []
      }

      self.categories.each do |id, category|
        hash["categories"] << category.to_hash
      end

      hash
    end

    private

    def category_ids(schedule)
      category_ids = []
      schedule.each do |day, tasks|
        category_ids += tasks.keys
      end
      category_ids
    end

    def lookup_day(schedule, day_id)
      schedule[WEEKDAYS[day_id]]
    end
  end
end
