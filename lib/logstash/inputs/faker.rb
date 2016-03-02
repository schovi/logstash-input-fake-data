# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"
require "socket" # for Socket.gethostname
require File.join(File.dirname(__FILE__), "../../faker/generator")

# Generate a repeating message.
#
# This plugin is intented only as an example.
class LogStash::Inputs::Faker < LogStash::Inputs::Base
  config_name "faker"

  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, "plain"

  config :message, validate: :hash,
                   default: {
                     user_name: "%f(Internet.user_name)"
                   }

  # Set how frequently messages should be sent.
  #
  # The default, `1`, means send a message every second.
  config :interval, validate: :number, default: 1
  config :interval_range, validate: :array
  config :count, validate: :number
  config :locale, validate: :string, default: 'en'

  public

  def register
    @host = Socket.gethostname
    FakerGenerator.locale = locale
    @generator = FakerGenerator.make(message)
  end # def register

  def run(queue)
    counter = 0
    # we can abort the loop if stop? becomes true
    while !stop?
      event = LogStash::Event.new(@generator.())
      event["@host"] = @host
      decorate(event)
      queue << event

      counter += 1

      if count and counter >= count
        p "Successfully generated #{@counter} messages"
        break
      else
        # because the sleep interval can be big, when shutdown happens
        # we want to be able to abort the sleep
        # Stud.stoppable_sleep will frequently evaluate the given block
        # and abort the sleep(@interval) if the return value is true
        Stud.stoppable_sleep(get_interval) { stop? }
      end # if
    end # loop
  end # def run

  def stop
    # nothing to do in this case so it is not necessary to define stop
    # examples of common "stop" tasks:
    #  * close sockets (unblocking blocking reads/accepts)
    #  * cleanup temporary files
    #  * terminate spawned threads
  end

  private

  def get_interval
    if interval_range
      rand(interval_range[0]..interval_range[1])
    else
      interval
    end
  end
end # class LogStash::Inputs::Faker
