require 'yaml'

module Versed
  module Reader

    # Reads YAML from a file
    # @param path [String] The path to the file
    # @return [Hash] The parsed YAML file
    def self.read(path)
      begin
        return YAML.load(IO.read(path))
      rescue YAML::Error => e
        puts "Encountered an error reading YAML from #{path}"
        puts e.message
        exit 1
      rescue StandardError => e
        puts e.message
        exit 1
      end
    end
  end
end
