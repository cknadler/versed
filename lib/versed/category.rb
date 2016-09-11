require "versed/task"

module Versed
  class Category
    attr_reader :id, :tasks

    def initialize(id)
      @id = id
      @tasks = Array.new(7) { Task.new }
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
  end
end
