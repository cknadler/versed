require "date"
require "mustache"
require "versed/parser"
require "versed/reader"

module Versed
  module Generator

    # The CLI entry point for the Versed program. Parses the input files, parses
    # the content into task objects, generates the visualization HTML and
    # converts the HTML to a PDF.
    def self.run(schedule_path, log_path)
      schedule = Versed::Reader.read(schedule_path)
      raw_log = Versed::Reader.read(log_path)

      logs = []
      raw_log.each do |day, tasks|
        logs[Date.parse(day).wday] = tasks
      end

      ###
      # Getting row headers
      ###

      all_tasks = []
      schedule.each do |day, tasks|
        all_tasks += tasks.keys
      end
      all_tasks.uniq!
      all_tasks.sort!

      weekdays = [
        "sunday",
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday",
        "saturday"
      ]

      ###
      # constructing table
      ###

      table = {
        "headers" => weekdays,
        "rows" => []
      }

      all_tasks.each do |task_id|
        row = {}
        row["row_head"] = task_id
        row["values"] = []

        logs.each do |tasks|
          value = nil
          if tasks && tasks[task_id]
            value = tasks[task_id]
          end
          row["values"] << value
        end

        table["rows"] << row
      end

      path = File.expand_path(File.join(__FILE__, "../../../templates/table.mustache"))
      puts Mustache.render(IO.read(path), table)
    end
  end
end
