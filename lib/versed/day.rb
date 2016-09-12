require "versed/task"

module Versed
  class Day
    attr_reader :id, :tasks, :date

    def initialize(id, date)
      @id = id
      @date = date
      @tasks = []
    end
  end
end
