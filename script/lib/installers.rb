require_relative 'read_version'
require_relative 'carthage'

def carthage_bootstrap
  puts ""
  puts " → Installing dependencies using Carthage ..."
  required_version = read_version("carthage")
  safe_exec("carthage", "bootstrap --platform ios",
    check_args: "version",
    enforce_version: required_version) do |command_exists, version_matches, installed_version|
      if command_exists && !version_matches
        puts ""
        puts "\tAn incompatible version of 'carthage' is already installed."
        puts "\t\tInstalled version: '#{installed_version}'"
        puts "\t\tRequired version:  '#{required_version}'"
        if install_required_carthage_version?(required_version)
          puts "\t * Uninstalling carthage version '#{installed_version}'. sudo privilages may be required ..."
          uninstall_carthage
          puts "\t * Installing 'carthage' version '#{required_version}' from GitHub release ..."
          install_carthage(required_version)
        end
      else
        puts "\t * Command 'carthage' is not available"
        puts "\t * Installing 'carthage' version '#{required_version}' from GitHub release ..."
        install_carthage(required_version)
      end
    end
end

def pip_install(egg_name)
  puts ""
  puts " → Installing '#{egg_name}' using 'pip' ..."
  safe_exec("pip", "install proselint", check_args: "-V") do
    puts "\t * Command 'pip' is not available"
    puts "\t * Installing 'pip' using 'easy_install' ..."
    execute_command("sudo easy_install pip", prefix: "easy_install: ")
  end
end

def bundle_install
  puts ""
  puts " → Installing gems using bundler ..."
  safe_exec("bundle", "install") do
    puts "\t * Command 'bundle' is not available"
    puts "\t * Installing 'bundle' using 'gem install' ..."
    execute_command("gem install bundler", prefix: "gem: ")
  end
end

def safe_exec(command, command_args, check_args: "-v", enforce_version: nil)
  execute_command = ->() do
    puts ""
    puts "\t * Executing command: #{command} #{command_args}"
    pretty_print(`#{command} #{command_args}`, prefix: "#{command}: ")
  end
  output = `#{command} #{check_args} 2> /dev/null`.strip
  command_exists = $?.exitstatus == 0
  version_matches = enforce_version.nil? || output == enforce_version
  if command_exists && version_matches
    execute_command.call()
  elsif block_given?
    if yield command_exists, version_matches, output
      execute_command.call()
    else
      puts "Error: '#{command}' could not be installed."
      exit 1
    end
  else
    puts "Error: command '#{command}' is not available"
    exit 1
  end
end

def execute_command(command, prefix: "")
  output = `#{command}`
  exit_code = $?.exitstatus
  pretty_print(output, prefix: prefix)
  exit_code == 0
end

def pretty_print(message, prefix: "")
  puts message.split("\n").map { |line| "\t#{prefix}#{line}" }.join("\n")
end
