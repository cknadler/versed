require "versed/constants"
require "versed/schedule"

module Versed
  class ScheduleView

    def initialize(schedule)
      @schedule = schedule
    end

    def to_hash
      hash = {
        "weekdays" => Versed::Constants::WEEKDAYS,
        "categories" => [],
        "metadata" => metadata,
        "incomplete_tasks" => incomplete_tasks,
        "first_date" => @schedule.days[0].date
      }

      @schedule.categories.each do |category|
        hash["categories"] << category.to_hash
      end

      hash
    end

    private

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
      percent(days_active, 7)
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
      divide(total_min_logged, 7)
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
