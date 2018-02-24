require 'fileutils'
require_relative 'read_version'

# Download & install local version of Sourcery
def install_sourcery(sourcery_version = nil)
  sourcery_version = read_version("sourcery") if sourcery_version.nil? || sourcery_version.empty?
  sourcery_dir = "bin/sourcery"
  puts ""
  puts " → Donwloading Sourcery version '#{sourcery_version}' ..."
  filename = "Sourcery-#{sourcery_version}.zip"
  `curl --progress-bar -L -O https://github.com/krzysztofzablocki/Sourcery/releases/download/#{sourcery_version}/#{filename}`
  FileUtils.rm_rf(sourcery_dir) if File.exist?(sourcery_dir)
  FileUtils.mkdir(sourcery_dir)
  `unzip -d #{sourcery_dir} #{filename}`
  FileUtils.rm_rf(filename)
  sourcery_installed_version = `bin/sourcery/bin/sourcery --version`.strip
  if sourcery_version == sourcery_installed_version
    puts " ✔ Sourcery version '#{sourcery_version}' successfully installed"
  else
    puts "Error: Sourcery could not be installed"
    exit 1
  end
end

if __FILE__== $0
  install_sourcery(ARGV[0])
end
