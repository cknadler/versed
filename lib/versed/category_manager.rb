require "versed/category"

module Versed
  class CategoryManager

    def initialize(schedule, log)
      @categories = {}

      (category_ids(schedule) + category_ids(log)).uniq.sort.each do |id|
        @categories[id] = Versed::Category.new(id)
      end
    end

    # Returns an array of incomplete tasks. This array is sorted first by
    # percentage incomplete, then by total number of minutes incomplete.
    def incomplete_tasks
      # TODO: refactor with reject
      incomplete = []
      self.categories.each { |c| incomplete << c if c.incomplete? }
      incomplete.sort_by { |c| [-c.percent_incomplete, -c.total_min_incomplete] }
    end

    # Finds the category object for the given category id
    # @param id [String] A category id
    # @return [Category] The category object matching the id
    def lookup(id)
      category = @categories[id]
      unless category
        puts "Unrecognized category id: #{id}"
        exit 1
      end
      category
    end

    # @return [Array] An array of all categories
    def categories
      @categories.values
    end

    private

    # Finds all unique category ids in a log or a schedule
    # @param entries [Hash] A parsed log or schedule
    # @return [Array, String] Unique category ids
    def category_ids(entries)
      category_ids = []
      entries.each do |day, tasks|
        category_ids += tasks.keys
      end
      category_ids.uniq
    end
  end
end
