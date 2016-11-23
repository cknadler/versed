require "versed/schedule"

module Versed
  class ScheduleView

    DAYS_PER_ROW = 8

    def initialize(schedule)
      @schedule = schedule
    end

    def to_hash
      hash = {
        "sections" => [],
        "metadata" => metadata,
        "incomplete_tasks" => incomplete_tasks
      }

      # fill in days
      section = nil
      @schedule.days.each_with_index do |day, day_id|
        if day_id % DAYS_PER_ROW == 0
          section = {
            "days" => [],
            "categories" => []
          }
          hash["sections"] << section
        end

        section["days"] << day.date.strftime("%m.%d")
      end

      # determine row date ranges
      day_ranges = []
      day_max = @schedule.days.size - 1
      start_date = 0
      while start_date <= day_max
        end_date = [start_date + DAYS_PER_ROW - 1, day_max].min
        day_ranges << (start_date..end_date)
        start_date = end_date + 1
      end

      # fill in categories and tasks
      @schedule.categories.each do |category|
        day_ranges.each_with_index do |range, section_index|
          hash["sections"][section_index]["categories"] << category_hash(category, range)
        end
      end

      # create header
      origin = @schedule.days.first.date
      hash["header"] = "#{Date::MONTHNAMES[origin.month]} #{origin.year}"

      hash
    end

    private

    ###
    # model hashes
    ###

    def category_hash(category, day_range)
      hash = {
        "id" => category.id,
        "tasks" => []
      }

      category.tasks[day_range].each do |task|
        hash["tasks"] << task.to_hash
      end

      hash
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
      @schedule.days.count { |d| d.active? }
    end

    def days_active_percent
      percent(days_active, @schedule.days.size)
    end

    def total_min_logged
      total_min_logged_on_schedule + total_min_logged_off_schedule
    end

    def total_min_logged_on_schedule
      @schedule.days.collect { |d| d.time_on_schedule }.reduce(0, :+)
    end

    def total_min_logged_off_schedule
      @schedule.days.collect { |d| d.time_off_schedule }.reduce(0, :+)
    end

    def total_hr_logged
      divide(total_min_logged, 60)
    end

    def min_logged_per_day
      divide(total_min_logged, @schedule.days.size)
    end

    def hr_logged_per_day
      divide(min_logged_per_day, 60)
    end

    def total_min_scheduled
      @schedule.days.collect { |d| d.time_scheduled }.reduce(0, :+)
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
      @schedule.incomplete_tasks.each do |category|
        hash = {}
        hash["id"] = category.id
        hash["value"] = "#{category.total_min_logged} / #{category.total_min_scheduled} (-#{category.percent_incomplete}%)"
        top_tasks << hash
      end
      top_tasks
    end

    ###
    # General
    ###

    def percent(a, b)
      ((a / b.to_f) * 100).round(1)
    end

    def divide(a, b)
      (a / b.to_f).round(1)
    end
  end
end
