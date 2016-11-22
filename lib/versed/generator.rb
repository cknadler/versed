require "mustache"
require "pdfkit"
require "versed/reader"
require "versed/schedule"
require "versed/schedule_view"

module Versed
  module Generator

    # The CLI entry point for the Versed program. Parses the input files, parses
    # the content into task objects, generates the visualization HTML and
    # converts the HTML to a PDF.
    def self.run(schedule_path, log_path, output_path)
      # read in input
      raw_schedule = Versed::Reader.read(schedule_path)
      raw_log = Versed::Reader.read(log_path)

      # determine date range
      start_date = Date.parse(raw_log.keys[0])
      start_date = start_date.prev_day(start_date.wday)
      date_range = start_date..start_date.next_day(6)
      validate_log(raw_log, date_range)

      # map model and view model
      schedule = Versed::Schedule.new(raw_schedule, raw_log, date_range)
      schedule_view = Versed::ScheduleView.new(schedule)

      # make HTML page
      templates_path = File.expand_path(File.join(__FILE__, "../../../templates"))
      Mustache.template_path = templates_path
      main_template_path = File.join(templates_path, "page.mustache")
      html = Mustache.render(IO.read(main_template_path), schedule_view.to_hash)

      # make the PDF
      output_path = Dir.pwd unless output_path
      output_path = File.expand_path(output_path)

      if File.directory?(output_path)
        first_date = schedule.days[0].date
        output_path = File.join(output_path, "#{first_date}-routine-analysis.pdf")
      end

      kit = PDFKit.new(html, :page_size => 'Letter')
      kit.to_file(output_path)
    end

    private

    def self.validate_log(raw_log, date_range)
      raw_log.keys.each do |raw_day|
        day = Date.parse(raw_day)
        unless date_range.include?(day)
          puts "Days from multiple weeks present."
          puts "#{day} not present in #{date_range}"
          puts "Ensure log only contains days from one calendar week (Sun-Sat)."
          exit 1
        end
      end
    end
  end
end
