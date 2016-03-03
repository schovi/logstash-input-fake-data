dir = File.dirname(__FILE__)
require File.join("./", dir, '../lib/logstash/inputs/faker')

begin
  FakerGenerator.make({error: "%{unknown_category.name}"}).call
rescue => ex
  p ex
end

begin
  FakerGenerator.make({error: "%{name.unknown_method}"}).call
rescue => ex
  p ex
end

begin
  FakerGenerator.make({error: "%{time.between}"}).call
rescue => ex
  p ex
end
