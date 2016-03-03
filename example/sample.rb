dir = File.dirname(__FILE__)
require File.join("./", dir, '../lib/logstash/inputs/faker')

s = FakerGenerator.string({
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

p s

fun = FakerGenerator.string_to_lambda(s)

10.times do
  p fun.()
end
