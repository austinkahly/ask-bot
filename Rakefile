require "rake"
require "rake/clean"
require "rdoc/task"

require "./app"

Dir[File.dirname(__FILE__) + "/lib/tasks/*.rb"].sort.each do |path|
  require path
end