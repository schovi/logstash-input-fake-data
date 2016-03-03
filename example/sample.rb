dir = File.dirname(__FILE__)
require File.join("./", dir, '../lib/logstash/inputs/faker')

p "============="
p "single string"
p FakerGenerator.make("%{name.name}").call

p "============="
p "array structure"
p FakerGenerator.make({
  "%{repeat(2)}" => {
    name: "%{name.name}"
  }
}).call

p "============="
p "complex object with repeated call"
fun = FakerGenerator.make({
  a: {
    "%{repeat 2}" => "%{name.name}"
  },
  b: ["%{name.name}", "%{name.name}"],
  c: {
    "%{repeat(2)}" => {
      name: "%{name.name}"
    }
  }
})

2.times do
  p fun.call
end
