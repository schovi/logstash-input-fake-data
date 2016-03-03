require 'faker'

I18n.reload!

class FakerGenerator
  FAKER_MATCHER = /%\{.*?\}/i
  FAKER_INNER_MATCHER = /\{(.*?)\}/
  FAKER_REPEAT_MATCHER = /%\{repeat\s+(\d+)\}/i

  class << self

    def locale=(locale)
      Faker::Config.locale = locale
    end

    def make(object)
      string_to_lambda(string(object))
    end

    def string_to_lambda(string)
      eval(string)
    end

    def string(object)
      result = ""

      result << "lambda do"
      result << build_faker_element(object)
      result << "end"
      result
    end

    def build_faker_element(element)
      case element
      when Hash
        build_faker_hash(element)
      when Array
        build_faker_array(element)
      when String
        build_faker_string(element)
      else
        element
      end
    end

    def build_faker_hash(element)
      result = ""
      result << "{"

      result << element.map do |key, value|
        "\"#{key.to_s}\" => #{build_faker_element(value)}"
      end.join(",")

      result << "}"

      result
    end

    def build_faker_array(element)
      element.map do |value|
        build_faker_element(value)
      end.join(",")
    end

    def build_faker_string(element)
       result = element.gsub(FAKER_MATCHER) do |faker_placer|
         match = faker_placer.match(FAKER_INNER_MATCHER)
         split = match[1].split(".")
         klass = get_faker_class(split[0])

         faker_call = [klass, split.slice(1,split.length)].join(".")

         # TODO validate method on klass

         "\#\{#{faker_call}\}"
       end

       "\"#{result}\""
    end

    def get_faker_class string
      parts = string.split("::")

      parts.unshift("Faker") if parts.length == 1

      klass = parts.map {|s| camelize(s)}.join("::")

      eval(klass)
    rescue NameError => ex
      raise "Can't resolve class '#{klass}', reason #{ex.message}"
    end

    def camelize(str)
      str.split('_').map {|w| w.capitalize}.join
    end
  end
end
