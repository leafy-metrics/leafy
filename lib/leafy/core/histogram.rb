require 'concurrent/thread_safe/util/adder'

module Leafy
  module Core

    # A metric which calculates the distribution of a value.
    #
    # @see <a href="http://www.johndcook.com/standard_deviation.html">Accurately computing running
    # variance</a>
    class Histogram

      # Creates a new {@link Histogram} with the given reservoir.
      #
      # @param reservoir the reservoir to create a histogram from
      def initialize(reservoir)
        @reservoir = reservoir
        @count = Concurrent::ThreadSafe::Util::Adder.new
      end

      # Adds a recorded value.
      #
      # @param value the length of the value
      def update(value)
        @count.increment
        @reservoir.update(value)
      end

      # Returns the number of values recorded.
      #
      # @return the number of values recorded
      def count
        @count.sum
      end

      def snapshot
        @reservoir.snapshot
      end
    end
  end
end
