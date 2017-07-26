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
require_relative 'script/lib/build_time_profiler'
require_relative 'script/lib/git_utils'
warn_threshold = 100.0
fail_threshold = 500.0
build_log_file = "output/xcodebuild_build_raw.log"
fail("Build log file '#{build_log_file}' could not be found") unless File.exist?(build_log_file)

pr_commits = Set.new(git.commits.map { |commit| commit.sha })
profiler = BuildTimeProfiler.new(
  outliers_deviation: 3,
  warn_threshold: 100.0,
  fail_threshold: 500.0,
  build_log_file: build_log_file) do |outlier|
    # We only show build time outliers introduced in this PR, previous
    # outliers are ignored. We do this by using git blame to get
    # the commit sha where the outlier was introduced.
    blame_output = git_blame(outlier.file_path, outlier.line_number)
    commit_sha = /^([0-9a-f]+)\w.*/.match(blame_output)[1]
    pr_commits.include?(commit_sha)
end
profiler_analysis = profiler.analysis_output(github.branch_for_head)
profiler_analysis.each { |type, message| send(type, message) }
