require 'fileutils'
require_relative 'read_version'

def brew(command, silence_output: true)
  command_str = "brew #{command}"
  command_str += " > /dev/null 2>&1" if silence_output
  system(command_str)
end

def carthage_installed_by_homebrew?
  brew "list --versions carthage"
end

def install_required_carthage_version?(required_version)
  return true unless ENV['NO_INTERACTIVE'].nil?
  puts ""
  puts "\tDo you want to install required carthage version (#{required_version})? [N/y]"
  gets.strip.downcase == "y"
end

def uninstall_carthage
  if homebrew_available? && carthage_installed_by_homebrew?
    brew "uninstall carthage"
  else
    `sudo rm -frd /Library/Frameworks/CarthageKit.framework`
    `sudo rm /usr/local/bin/carthage`
  end
end

def install_carthage(required_version)
  `curl --progress-bar -L -O https://github.com/Carthage/Carthage/releases/download/#{required_version}/Carthage.pkg`
  system("sudo installer -pkg Carthage.pkg -target / > /dev/null 2>&1")
  FileUtils.rm("Carthage.pkg")
end

def homebrew_available?
  command_available?("brew")
end

def command_available?(command)
  system("type #{command} > /dev/null 2>&1")
end

def installed_carthage_version
  `carthage version`.strip if command_available?("carthage")
end

if __FILE__== $0
  version = ARGV[1] || read_version("carthage")
  if ARGV.empty? || ARGV[0] == "install"
    installed_version = installed_carthage_version
    if installed_version && installed_version != version
      puts "There is an incompatible version of carthage already installed."
      puts "Installed: #{installed_version}"
      puts "Required: #{version}"
      exit 1
    else
      puts "Installing carthage version '#{version}' ..."
      install_carthage(version)
    end
  elsif ARGV[0] == "uninstall"
    puts "Uninstalling carthage ..."
    uninstall_carthage
  elsif ARGV[0] == "check"
    installed_version = installed_carthage_version
    if installed_version.nil?
      puts "carthage is not installed"
    else
      puts "installed version '#{installed_version}' does not match '#{version}'"
    end
  else
    puts "Error: Unsupported command #{ARGV[0]}"
    exit 1
  end
end
