require_relative 'clock'
require_relative 'meter'
require_relative 'histogram'

module Leafy
  module Core

    # A timer metric which aggregates timing durations and provides duration statistics, plus
    # throughput statistics via {@link Meter}.
    class Timer

      # A timing context.
      #
      # @see Timer#context()
      class Context
        def initialize(timer, clock)
          @timer = timer
          @clock = clock
          @startTime = clock.tick
        end

         # Updates the timer with the difference between current and start time. Call to this method will
         # not reset the start time. Multiple calls result in multiple updates.
         #
         # @return the elapsed time in nanoseconds
        def stop
          elapsed = @clock.tick - @startTime
          @timer.update(elapsed / 1000000000.0)
          elapsed
        end
      end

      # Creates a new {@link Timer} that uses the given {@link Reservoir} and {@link Clock}.
      #
      # @param reservoir the {@link Reservoir} implementation the timer should use
      # @param clock     the {@link Clock} implementation the timer should use
      def initialize(reservoir = SlidingWindowReservoir, clock = Clock.default_clock)
        @meter = Meter.new(clock)
        @clock = clock
        @histogram = Histogram.new(reservoir)
      end

      # Adds a recorded duration.
      #
      # @param duration the length of the duration in seconds
      def update(duration)
        if duration >= 0
          @histogram.update(duration * 1000000000.0)
          @meter.mark
        end
      end

      # Times and records the duration of event.
      #
      # @param event a {@link Runnable} whose {@link Runnable#run()} method implements a process
      #              whose duration should be timed
      def time(&block)
        startTime = @clock.tick
        begin 
          block.call
        ensure
          update((@clock.tick - startTime) / 1000000000.0)
        end
      end

      # Returns a new {@link Context}.
      #
      # @return a new {@link Context}
      # @see Context
      def context(&block)
        ctx = Context.new(self, @clock)
        if block_given?
          block.call ctx
          ctx.stop
        else
          ctx
        end
      end

      def count
        @histogram.count
      end

      def fifteen_minute_rate
        @meter.fifteen_minute_rate
      end

      def five_minute_rate
        @meter.five_minute_rate
      end

      def one_minute_rate
        @meter.one_minute_rate
      end

      def mean_rate
        @meter.mean_rate
      end

      def snapshot
        @histogram.snapshot
      end
    end
  end
end
