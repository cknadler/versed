require "versed/task"

module Versed
  class Category
    attr_reader :id, :tasks

    def initialize(id)
      @id = id
      @tasks = Array.new(7) { Task.new(id) }
    end

    def to_hash
      hash = {
        "id" => self.id,
        "tasks" => []
      }

      self.tasks.each do |task|
        hash["tasks"] << task.to_hash
      end

      hash
    end

    def incomplete?
      total_min_incomplete > 0
    end

    def total_min_scheduled
      scheduled = 0
      @tasks.each do |task|
        next unless task.time_scheduled
        scheduled += task.time_scheduled
      end
      scheduled
    end

    def total_min_logged
      logged = 0
      @tasks.each do |task|
        next unless task.time_spent
        logged += task.time_spent
      end
      logged
    end

    def total_min_incomplete
      incomplete = total_min_scheduled - total_min_logged
      incomplete >= 0 ? incomplete : 0
    end

    def percent_incomplete
      ((total_min_incomplete / total_min_scheduled.to_f) * 100).round(1)
    end
  end
end
