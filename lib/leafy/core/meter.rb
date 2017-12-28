require_relative 'clock'
require_relative 'ewma'
require 'concurrent/thread_safe/util/adder'
require 'concurrent/atomic/atomic_fixnum'

# A meter metric which measures mean throughput and one-, five-, and fifteen-minute
# exponentially-weighted moving average throughputs.
#
# @see EWMA
module Leafy
  module Core
    class Meter

      TICK_INTERVAL = 5 * 1000 * 1000 * 1000 # 5 Nano-Seconds

      # Creates a new {@link Meter}.
      # @param clock the clock to use for the meter ticks
      def initialize(clock = Clock.default_clock)
        @clock = clock;
        @startTime = clock.tick
        @lastTick = Concurrent::AtomicFixnum.new(@startTime)#AtomicLong.new(startTime)
        @count = Adder.new

        @m1Rate = EWMA.oneMinuteEWMA
        @m5Rate = EWMA.fiveMinuteEWMA
        @m15Rate = EWMA.fifteenMinuteEWMA
      end

      # Mark the occurrence of an event.
      def mark(n = 1)
        tickIfNecessary
        @count.add(n)
        @m1Rate.update(n)
        @m5Rate.update(n)
        @m15Rate.update(n)
        n
      end


      def count
        @count.sum
      end


      def fifteen_minute_rate
        tickIfNecessary
        @m15Rate.rate
      end


      def five_minute_rate
        tickIfNecessary
        @m5Rate.rate
      end


      def one_minute_rate
        tickIfNecessary
        @m1Rate.rate
      end


      def mean_rate
        if count == 0
          0.0
        else
          elapsed = @clock.tick - @startTime
          count * 1000000000.0 / elapsed
        end
      end

      private

      def tickIfNecessary
        oldTick = @lastTick.value #.get
        newTick = @clock.tick
        age = newTick - oldTick
        if age > TICK_INTERVAL
          newIntervalStartTick = newTick - age % TICK_INTERVAL
          if (@lastTick.compare_and_set(oldTick, newIntervalStartTick))
            requiredTicks = age / TICK_INTERVAL
            requiredTicks.to_i.times do
              @m1Rate.tick
              @m5Rate.tick
              @m15Rate.tick
            end
          end
        end
      end
    end
  end
end
