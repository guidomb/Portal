require 'fileutils'
require_relative 'read_version'

# Download & install local version of SwiftLint
def install_swiftlint(swiftlint_version = nil)
  swiftlint_version = read_version("swiftlint") if swiftlint_version.nil? || swiftlint_version.empty?
  swiftlint_dir = "bin/swiftlint"
  puts ""
  puts " → Donwloading SwiftLint version '#{swiftlint_version}' ..."
  `curl --progress-bar -L -O https://github.com/realm/SwiftLint/releases/download/#{swiftlint_version}/portable_swiftlint.zip`
  FileUtils.rm_rf(swiftlint_dir) if File.exist?(swiftlint_dir)
  FileUtils.mkdir(swiftlint_dir)
  `unzip -d bin/swiftlint portable_swiftlint.zip`
  FileUtils.rm_rf("portable_swiftlint.zip")
  swiftlint_installed_version = `bin/swiftlint/swiftlint version`.strip
  if swiftlint_version == swiftlint_installed_version
    puts " ✔ SwiftLint version '#{swiftlint_version}' successfully installed"
  else
    puts "Error: SwiftLint could not be installed"
    exit 1
  end
end

if __FILE__== $0
  install_swiftlint(ARGV[0])
end
