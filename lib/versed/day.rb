require "versed/task"

module Versed
  class Day
    attr_reader :id, :tasks

    def initialize(id)
      @id = id
      @tasks = []
    end
  end
end
