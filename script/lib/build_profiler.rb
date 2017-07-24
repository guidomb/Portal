require 'ostruct'

class BuildProfiler

  attr_reader :log_file

  def initialize(log_file)
    @log_file = log_file
  end

  def build_times
    @build_times ||= begin
      regexp = /^[0-9]+\.[0-9]+ms.*\.swift.*$/
      File.readlines(log_file)
        .select { |line| regexp === line }
        .map { |line| parse_line(line) }
        .sort { |a, b| b.time <=> a.time }
    end
  end

  def most_expensive(amount: nil, build_time_threshold: 50)
    result = build_times
    result = result.select { |profile| profile.time > build_time_threshold} if build_time_threshold
    result = result.take(amount) if amount
    result
  end

  private

    def parse_line(line)
      parts = line.split("\t")
      location = parts[1].split(":")
      OpenStruct.new({
        time: parts[0].gsub("ms", "").to_f,
        file_path: location[0],
        line_number: location[1].to_i,
        column_number: location[2].to_i,
        function_signature: parts[2].strip
      })
    end

end

if __FILE__==$0
  puts BuildProfiler.new(ARGV[0]).most_expensive(amount: 10)
end
