require 'concurrent/thread_safe/util/volatile'
require_relative 'adder'

# An exponentially-weighted moving average.
#
# @see <a href="http://www.teamquest.com/pdfs/whitepaper/ldavg1.pdf">UNIX Load Average Part 1: How
# It Works</a>
# @see <a href="http://www.teamquest.com/pdfs/whitepaper/ldavg2.pdf">UNIX Load Average Part 2: Not
# Your Average Average</a>
# @see <a href="http://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average">EMA</a>
module Leafy
  module Core
    class EWMA
      extend Concurrent::ThreadSafe::Util::Volatile
      
      private

      INTERVAL = 5 # 5 nanos
      FIVE_NANOS = INTERVAL * 1000000000.0 # 5 nanos
      ONE_NANOS = 1000000000.0 # 1 nanos
      SECONDS_PER_MINUTE = 60.0
      ONE_MINUTE = 1
      FIVE_MINUTES = 5
      FIFTEEN_MINUTES = 15
      M1_ALPHA = 1 - Math.exp(-INTERVAL / SECONDS_PER_MINUTE / ONE_MINUTE);
      M5_ALPHA = 1 - Math.exp(-INTERVAL / SECONDS_PER_MINUTE / FIVE_MINUTES);
      M15_ALPHA = 1 - Math.exp(-INTERVAL / SECONDS_PER_MINUTE / FIFTEEN_MINUTES);

      public

      # Creates a new EWMA which is equivalent to the UNIX one minute load average and which expects
      # to be ticked every 5 seconds.
      #
      # @return a one-minute EWMA
      def self.oneMinuteEWMA
        EWMA.new(M1_ALPHA);
      end

      # Creates a new EWMA which is equivalent to the UNIX five minute load average and which expects
      # to be ticked every 5 seconds.
      #
      # @return a five-minute EWMA
      def self.fiveMinuteEWMA
        EWMA.new(M5_ALPHA);
      end

      # Creates a new EWMA which is equivalent to the UNIX fifteen minute load average and which
      # expects to be ticked every 5 seconds.
      #
      # @return a fifteen-minute EWMA
      def self.fifteenMinuteEWMA
        EWMA.new(M15_ALPHA);
      end

      attr_volatile :initialized, :rate

      # Create a new EWMA with a specific smoothing constant.
      #
      # @param alpha        the smoothing constant
      # @param interval     the expected tick interval
      # @param intervalUnit the time unit of the tick interval
      def initialize(alpha)
        @alpha = alpha;
        @initialized = false # volatile
        @rate = 0.0 # volatile
        @uncounted = Adder.new
      end

      # Update the moving average with a new value.
      #
      # @param n the new value
      def update(n)
        @uncounted.add(n)
      end

      # Mark the passage of time and decay the current rate accordingly.
      def tick
        count = @uncounted.sum_then_reset# @uncounted = 0 # uncounted.sumThenReset();
        instantRate = count / FIVE_NANOS;
        if @initialized
          oldRate = @rate
          @rate = oldRate + (@alpha * (instantRate - oldRate))
        else 
          @rate = instantRate
          @initialized = true
        end
        self
      end

      # Returns the rate in the given units of time.
      #
      # @param rateUnit the unit of time
      # @return the rate
      def rate
        @rate * ONE_NANOS
      end
    end
  end
end
