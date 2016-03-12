# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"
require "socket" # for Socket.gethostname
require "fake_data"

# Generate a repeating message.
#
# This plugin is intented only as an example.
class LogStash::Inputs::FakeData < LogStash::Inputs::Base
  config_name "fake_data"

  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, "plain"

  # Set template of generated object
  #
  # message => {
  #   id => "%{number.number(10)}"
  #   user_name => "%{internet.user_name}"
  #   tags => {
  #     "%{repeat 5}" => "%{lorem.word}"
  #   }
  #   address => {
  #     country => "%{address.country}"
  #     city => "%{address.city}"
  #     street => "%{address.street_name} %{address.building_number}"
  #     zip => "%{address.zip}"
  #   }
  #   friends => {
  #     "%{repeat 3}" => {
  #       user_name => "%{internet.user_name}"
  #     }
  #   }
  # }
  config :message, default: {
                     user_name: "%f(Internet.user_name)"
                   }

  # Set how frequently messages should be sent.
  #
  # The default, `1`, means send a message every second.
  config :interval, validate: :number

  # Set random range, how frequently messages should be sent.
  #
  # Example: interval_range => [0.1, 1] means
  # random interval between 0.1s and 1s
  config :interval_range, validate: :array

  # Set to limit number of generated objects
  config :count, validate: :number

  # Set which locale should be used for generated data.
  #
  # Default value 'en' can be change to any supported https://github.com/stympy/faker/tree/master/lib/locales
  config :locale, validate: :string, default: 'en'

  public

  def register
    # TODO validate message (hash, array, string)
    @host = Socket.gethostname
    ::FakeData.locale = locale
    @generator = ::FakeData.generator(message)
  end # def register

  def run(queue)
    counter = 0
    # we can abort the loop if stop? becomes true
    while !stop?
      object = @generator.call
      messages = object.is_a?(Array) ? object : [object]
      process_messages(queue, messages)
      counter += 1

      if count and counter >= count
        p "Successfully generated #{@counter * messages.length} messages (#{@counter} iterations)"
        break
      else
        # because the sleep interval can be big, when shutdown happens
        # we want to be able to abort the sleep
        # Stud.stoppable_sleep will frequently evaluate the given block
        # and abort the sleep(@interval) if the return value is true
        if interval = get_interval
          Stud.stoppable_sleep(interval) { stop? }
        end
      end # if
    end # loop

    if @codec.respond_to?(:flush)
      @codec.flush do |event|
        queue_event(queue, event)
      end
    end

  end # def run

  def process_messages queue, messages
    messages.each do |message|
      if message.is_a?(Hash)
        queue_event(queue, LogStash::Event.new(message))
      else
        @codec.decode(message) do |event|
          queue_event(queue, event)
        end
      end
    end
  end # def process_messages

  def queue_event queue, event
    decorate(event)
    queue << event
  end # def queue_event

  def stop
    # nothing to do in this case so it is not necessary to define stop
    # examples of common "stop" tasks:
    #  * close sockets (unblocking blocking reads/accepts)
    #  * cleanup temporary files
    #  * terminate spawned threads
  end # def stop

  private

  def get_interval
    if interval_range
      rand(interval_range[0]..interval_range[1])
    elsif interval
      interval
    end
  end # def get_interval
end # class LogStash::Inputs::FakeData
