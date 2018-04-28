task :app do
  require "./app"
end

desc 'Open an irb session preloaded with this library'
task :console do
  sh 'irb -I lib -r ./app.rb'
end

Dir[File.dirname(__FILE__) + "/lib/tasks/*.rb"].sort.each do |path|
  require path
end