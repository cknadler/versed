require "versed/task"

module Versed
  class Day
    attr_reader :id, :tasks, :date

    def initialize(id, date)
      @id = id
      @date = date
      @tasks = []
    end

    def active?
      @tasks.each { |t| return true if t.time_spent? }
      false
    end

    def time_on_schedule
      time = 0
      @tasks.each do |task|
        next unless task.time_spent? && task.time_scheduled?
        if task.time_scheduled < task.time_spent
          time += task.time_scheduled
        else
          time += task.time_spent
        end
      end
      time
    end

    def time_off_schedule
      time = 0
      @tasks.each do |task|
        next unless task.time_spent
        if !task.time_scheduled
          time += task.time_spent
        elsif task.time_scheduled < task.time_spent
          time += task.time_spent - task.time_scheduled
        end
      end
      time
    end

    def time_scheduled
      @tasks.collect { |t| t.time_scheduled? ? t.time_scheduled : 0 }.reduce(0, :+)
    end
  end
end
