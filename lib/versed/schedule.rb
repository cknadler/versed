require "versed/category"
require "versed/day"

module Versed
  class Schedule
    attr_reader :days, :categories

    def initialize(raw_schedule, raw_log, date_range)
      @date_range = date_range
      map_categories(raw_schedule, raw_log)
      map_days
      map_time_scheduled(raw_schedule)
      map_time_spent(raw_log)
    end

    def categories
      @categories.values
    end

    # Returns an array of incomplete tasks. This array is sorted first by
    # percentage incomplete, then by total number of minutes incomplete.
    def incomplete_tasks
      # TODO: refactor with reject
      incomplete = []
      categories.each { |c| incomplete << c if c.incomplete? }
      incomplete.sort_by { |c| [-c.percent_incomplete, -c.total_min_incomplete] }
    end

    private

    def map_categories(raw_schedule, raw_log)
      @categories = {}
      (category_ids(raw_schedule) + category_ids(raw_log)).uniq.sort.each do |id|
        @categories[id] = Versed::Category.new(id, @date_range)
      end
    end

    def map_days
      @days = []
      @date_range.each { |d| @days << Day.new(d) }

      # map category tasks to days
      categories.each do |category|
        category.tasks.each_with_index do |task, index|
          @days[index].tasks << task
        end
      end
    end

    def map_time_scheduled(raw_schedule)
      @days.each_with_index do |day, day_id|
        schedule_day = raw_schedule[Date::DAYNAMES[day.date.wday]]
        next unless schedule_day

        schedule_day.each do |scheduled_task_name, time_scheduled|
          category = lookup_category(scheduled_task_name)
          category.tasks[day_id].time_scheduled = time_scheduled
        end
      end
    end

    def map_time_spent(raw_log)
      raw_log.each do |day, tasks|
        day_id = Date.parse(day).mday - 1

        tasks.each do |log_task_name, time_spent|
          category = lookup_category(log_task_name)
          assert(category, "Any category here should have been in the log or schedule.")
          category.tasks[day_id].time_spent = time_spent
        end
      end
    end

    # Finds the category object for the given category id
    # @param id [String] A category id
    # @return [Category] The category object matching the id
    def lookup_category(id)
      category = @categories[id]
      unless category
        puts "Unrecognized category id: #{id}"
        exit 1
      end
      category
    end


    # Finds all unique category ids in a log or a schedule
    # @param entries [Hash] A parsed log or schedule
    # @return [Array, String] Unique category ids
    def category_ids(entries)
      category_ids = []
      entries.each do |day, tasks|
        category_ids += tasks.keys
      end
      category_ids.uniq
    end
  end
end
