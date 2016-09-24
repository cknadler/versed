def run(schedule, log)
  system("bundle exec versed #{schedule} #{log}")
end

desc "run with examples"
task :examples do
  run("examples/schedule.yaml", "examples/log.yaml")
end

task :default => :examples
