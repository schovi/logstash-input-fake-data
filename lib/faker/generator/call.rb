require 'faker'

class FakerGenerator
  class Call
    METHOD_NAME_MATCHER = /([a-z_=\?]+)/i
    LEFT_BRACKET_MATCHER = /^\(/
    RIGHT_BRACKET_MATCHER = /\)$/
    ARGUMENT_SPLIT_MATCHER = /\s*,\s*/

    attr_reader :source

    def initialize source
      @source = source
    end

    def to_s
      process
    end

    def inspect
      process
    end

    def call
      process
    end

    private

    def process
      return @call if defined?(@call)

      # Get only klass name
      faker_category, method_with_args = source.split(".", 2)

      # Validate Faker class
      faker_klass = begin
        get_faker_klass(faker_category)
      rescue NameError => ex
        raise_custom NameError, "'#{faker_category}' is not valid Faker category"
      end

      # Validate presence of method call
      unless method_match = method_with_args.match(METHOD_NAME_MATCHER)
        raise_custom NoMethodError, "missing category or method"
      end

      method_name = method_match[1]

      # TODO better argument splitting
      raw_arguments = method_with_args.delete(method_name)
      arguments = raw_arguments.strip.
                    gsub(LEFT_BRACKET_MATCHER, '').
                    gsub(RIGHT_BRACKET_MATCHER, '').
                    split(ARGUMENT_SPLIT_MATCHER)

      call = "#{faker_klass}.#{method_name}(#{arguments.join(", ")})"

      # Validate faker method and arguments
      begin
        eval(call)
      rescue NoMethodError => ex
        raise_custom NoMethodError, "'#{method_name}' is not valid method for Faker category '#{faker_category}'"
      rescue ArgumentError => ex
        raise_custom ArgumentError, "'#{raw_arguments}' are not valid arguements for Faker '#{faker_category}.#{method_name}'"
      end

      # Compose whole faker call

      @call = call
    end

    def get_faker_klass string
      parts = string.split("::")
      parts.unshift("Faker") if parts.length == 1
      klass = parts.map {|s| camelize(s)}.join("::")
      eval(klass)
    end

    def camelize(str)
      str.split('_').map {|w| w.capitalize}.join
    end

    def raise_custom error, reason
      raise error, "FakerGenerator: can't parse '#{source}'. Reason: #{reason}. For usage see: https://github.com/stympy/faker"
    end
  end
end
