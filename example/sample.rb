dir = File.dirname(__FILE__)
require File.join("./", dir, '../lib/logstash/inputs/faker')

p "============="
p "single string"
p FakerGenerator.new("%{name.name}").call

p "============="
p "array structure"
p FakerGenerator.new({
  "%{repeat(2)}" => {
    name: "%{name.name}"
  }
}).call

p "============="
p "complex object with repeated call"
generator = FakerGenerator.new({
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
  p generator.call
end
