# An abstraction for how time passes. It is passed to {@link Timer} to track timing.
module Metrics
  module Core
    class Clock 
      # Returns the current time tick.
      #
      # @return time tick in nanoseconds
      def tick
        (Time.now.to_f * 1000000000).to_i
      end

      # Returns the current time in milliseconds.
      #
      # @return time in milliseconds
      def time
        (Time.now.to_f * 1000000).to_i
      end

      # The default clock to use.
      #
      # @return the default {@link Clock} instance
      def self.default_clock
        DEFAULT
      end

      DEFAULT = Clock.new
    end
  end
end
