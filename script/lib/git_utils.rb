
def git_blame(file, line_number)
  `git blame -l -L #{line_number} #{file} | head -n 1`
end
