def ws_root
  @ws_root ||= File.dirname(__FILE__)
end

def run(schedule, log)
  schedule_path = File.join(ws_root, schedule)
  log_path = File.join(ws_root, log)
  system("bundle exec versed #{schedule_path} #{log_path}")
end

desc "run with examples"
task :examples do
  run("examples/schedule.yaml", "examples/log.yaml")
end

task :clean do
  system("rm #{ws_root}/*.pdf")
end

task :default => :examples
