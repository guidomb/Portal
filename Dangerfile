# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = github.pr_title.include? "#trivial"

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

# Run SwiftLint
swiftlint.config_file = '.swiftlint.yml'
swiftlint.binary_path = 'bin/swiftlint/swiftlint'
swiftlint.lint_files

# Runs a linter with all styles, on modified and added markdown files in this PR
prose.lint_files

# Xcode summary
xcode_summary.report 'build/reports/errors.json'

# Profile Swift compilation time
require_relative 'script/lib/build_profiler'
warn_threshold = 100.0
fail_threshold = 500.0
build_log_file = "output/xcodebuild_build_raw.log"
fail("Build log file '#{build_log_file}' could not be found") unless File.exist?(build_log_file)

profiler = BuildProfiler.new(build_log_file)
outliers = profiler.most_expensive(build_time_threshold: warn_threshold)
over_threshold, within_threshold = outliers.reduce([0,0]) do |(over, within), outlier|
  if outlier.time >= fail_threshold
    [over + 1, within]
  else
    [over, within + 1]
  end
end
if over_threshold > 0
  fail("There are #{over_threshold} functions over #{fail_threshold}ms build time threshold")
end
if within_threshold > 0
  warn("There are #{within_threshold} functions within [#{warn_threshold}, #{fail_threshold}]ms build time threshold")
end

unless outliers.empty?
  table_header = <<EOS
## Compilation time outliers

Time | File | Line | Function |
-----|------|------|----------|
EOS
  table_body = outliers.map do |outlier|
    filename = File.basename(outlier.file_path)
    github_location =
    "#{outlier.time} | [#{filename}]() | #{outlier.line_number} | #{outlier.function_signature}"
  end
  markdown(table_header + table_body.join("\n"))
end
