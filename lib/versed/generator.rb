require "mustache"
require "pdfkit"
require "versed/reader"
require "versed/schedule"

module Versed
  module Generator

    # The CLI entry point for the Versed program. Parses the input files, parses
    # the content into task objects, generates the visualization HTML and
    # converts the HTML to a PDF.
    def self.run(schedule_path, log_path, output_path)
      raw_schedule = Versed::Reader.read(schedule_path)
      raw_log = Versed::Reader.read(log_path)
      schedule = Versed::Schedule.new(raw_schedule, raw_log)

      # make HTML page
      templates_path = File.expand_path(File.join(__FILE__, "../../../templates"))
      Mustache.template_path = templates_path
      main_template_path = File.join(templates_path, "page.mustache")
      html = Mustache.render(IO.read(main_template_path), schedule.to_hash)

      # make the PDF
      output_path = Dir.pwd unless output_path
      kit = PDFKit.new(html, :page_size => 'Letter')
      kit.to_file(File.join(File.expand_path(output_path), "test.pdf"))
    end
  end
end
