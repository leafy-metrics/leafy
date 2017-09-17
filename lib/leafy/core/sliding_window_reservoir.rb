require_relative 'uniform_snapshot'
require 'concurrent/thread_safe/util/cheap_lockable'

# A {@link Reservoir} implementation backed by a sliding window that stores the last {@code N}
# measurements.
module Leafy
  module Core
    class SlidingWindowReservoir
      include Concurrent::ThreadSafe::Util::CheapLockable
   
      # Creates a new {@link SlidingWindowReservoir} which stores the last {@code size} measurements.
      #
      # @param size the number of measurements to store
      def initialize(size)
        super() # for cheap_lockable
        @measurements = Array.new size
        @count = 0
      end

      def size
        cheap_synchronize do
          [@count, @measurements.size].min
        end
      end

      def update(value)
        cheap_synchronize do
          @measurements[(@count % @measurements.size)] = value;
          @count += 1
        end
      end

      def snapshot
        values = nil
        cheap_synchronize do
          values = @measurements.dup
        end
        UniformSnapshot.new(*values)
      end
    end
  end
end
