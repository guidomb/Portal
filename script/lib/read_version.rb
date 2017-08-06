require 'yaml'

def read_version(program)
  versions = YAML.load_file(".versions.yml")
  versions[program]
end

if __FILE__== $0
  puts read_version(ARGV[0])
end
