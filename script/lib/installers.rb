
def pip_install(egg_name)
  puts ""
  puts " → Installing '#{egg_name}' using 'pip' ..."
  safe_exec("pip", "install proselint", check_args: "-V") do
    puts "\t * Command 'pip' is not available"
    puts "\t * Installing 'pip' using 'easy_install' ..."
    execute_command("easy_install pip", prefix: "easy_install: ")
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

def safe_exec(command, command_args, check_args: "-v")
  execute_command = ->() { pretty_print(`#{command} #{command_args}`, "#{command}: ") }
  if system("#{command} #{check_args} > /dev/null 2>&1")
    execute_command.call()
  elsif block_given?
    if yield
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
