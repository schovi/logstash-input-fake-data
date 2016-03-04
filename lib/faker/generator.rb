require File.join(File.dirname(__FILE__), "./generator/structure")
require File.join(File.dirname(__FILE__), "./generator/call")

# This is required. In developement it is ok,
# but in production Faker throws error on missing locale
I18n.reload!

class FakerGenerator
  class << self
    def locale=(locale)
      Faker::Config.locale = locale
    end
  end

  def initialize object
    @object = object
  end

  def lambda
    @lambda ||= Structure.object_to_lambda(@object)
  end

  def call
    lambda.call
  end

  # For debug
  def source
    @source ||= Structure.object_to_source(@object)
  end
end
