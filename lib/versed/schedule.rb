require "versed/day_manager"

module Versed
  class Schedule
    attr_reader :days, :date_range

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
      map_categories(raw_schedule, raw_log)

      @days = []

      start_date = Date.parse(raw_log.keys[0])
      start_date = start_date.prev_day(start_date.wday)
      @date_range = start_date..start_date.next_day(6)

      validate_log(raw_log)

      # create days
      @date_range.each { |d| @days << Day.new(d) }

      # map category tasks to days so tasks can be looked up by day or category
      categories.each do |category|
        category.tasks.each_with_index do |task, index|
          @days[index].tasks << task
        end
      end

      map_time_scheduled(raw_schedule)
      map_time_spent(raw_log)
    end

    # Returns an array of incomplete tasks. This array is sorted first by
    # percentage incomplete, then by total number of minutes incomplete.
    def incomplete_tasks
      # TODO: refactor with reject
      incomplete = []
      categories.each { |c| incomplete << c if c.incomplete? }
      incomplete.sort_by { |c| [-c.percent_incomplete, -c.total_min_incomplete] }
    end

    def categories
      @categories.values
    end

    private

    ###
    # Validation
    ###

    def validate_log(raw_log)
      raw_log.keys.each do |raw_day|
        day = Date.parse(raw_day)
        unless @date_range.include?(day)
          puts "Days from multiple weeks present."
          puts "#{day} not present in #{@date_range}"
          puts "Ensure log only contains days from one calendar week (Sun-Sat)."
          exit 1
        end
      end
    end

    ###
    # Parsing and Model Creation
    ###

    def map_categories(raw_schedule, raw_log)
      @categories = {}
      (category_ids(raw_schedule) + category_ids(raw_log)).uniq.sort.each do |id|
        @categories[id] = Versed::Category.new(id)
      end
    end

    def map_time_scheduled(raw_schedule)
      7.times.each_with_index do |day_id|
        schedule_day = raw_schedule[WEEKDAYS[day_id]]
        next unless day_id

        schedule_day.each do |scheduled_task_name, time_scheduled|
          category = lookup_category(scheduled_task_name)
          category.tasks[day_id].time_scheduled = time_scheduled
        end
      end
    end

    def map_time_spent(raw_log)
      raw_log.each do |day, tasks|
        day_id = Date.parse(day).wday

        tasks.each do |log_task_name, time_spent|
          category = lookup_category(log_task_name)
          next unless category # TODO: possibly handle tasks that are done out of the schedule here

          category.tasks[day_id].time_spent = time_spent
        end
      end
    end

    ###
    # Categories
    ###

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

    ###
    # Days
    ###

    ###
    # General
    ###
  end
end
