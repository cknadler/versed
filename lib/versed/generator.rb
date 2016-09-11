require "versed/parser"
require "versed/reader"

module Versed
  module Generator

    # The CLI entry point for the Versed program. Parses the input files, parses
    # the content into task objects, generates the visualization HTML and
    # converts the HTML to a PDF.
    def self.run(schedule_path, log_path)
      schedule = Versed::Reader.read(schedule_path)
      log = Versed::Reader.read(log_path)

      puts "Schedule"
      puts schedule

      puts "Log"
      puts log
    end
  end
end
