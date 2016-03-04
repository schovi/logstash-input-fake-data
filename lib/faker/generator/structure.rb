class FakerGenerator
  class Structure
    FAKER_MATCHER = /%\{.*?\}/i
    FAKER_INNER_MATCHER = /\{(.*?)\}/
    FAKER_REPEAT_MATCHER = /%\{repeat.*?(\d+).*?\}/i

    class << self
      # Makes lambda from object
      def object_to_lambda(object)
        source_to_lambda(
          object_to_source(
            object
          )
        )
      end

      # For debug
      def source_to_lambda(string)
        eval(string)
      end

      # For debug
      def object_to_source(object)
        result = ""

        result << "lambda do"
        result << build_faker_element(object)
        result << "end"

        result
      end

      private

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
        keys = element.keys

        result = ""

        if keys.length == 1 && match = keys.first.match(FAKER_REPEAT_MATCHER)
          repeats = match[1].to_i

          result << "["

          result << repeats.times.map do
            build_faker_element(element[keys.first])
          end.join(",")

          result << "]"
        else
          result << "{"

          result << element.map do |key, value|
            "\"#{key.to_s}\" => #{build_faker_element(value)}"
          end.join(",")

          result << "}"
        end

        result
      end

      def build_faker_array(element)
        result = ""

        result << "["

        result << element.map do |value|
          build_faker_element(value)
        end.join(",")

        result << "]"

        result
      end

      def build_faker_string(element)
        # TODO: when there is only Faker call dont wrap it into "#{...}", but call it directly
        result = element.gsub(FAKER_MATCHER) do |faker_placer|
          match = faker_placer.match(FAKER_INNER_MATCHER)
          "\#\{#{FakerGenerator::Call.new(match[1])}\}"
        end

        "\"#{result}\""
      end
    end
  end
end
