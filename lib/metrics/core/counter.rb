require 'concurrent/thread_safe/util/adder'

# An incrementing and decrementing counter metric.
module Metrics
  module Core
    class Counter
       def initialize
         @count = Concurrent::ThreadSafe::Util::Adder.new
       end
  
       # Increment the counter by {@code n}, default by one.
       #
       # @param n the amount by which the counter will be increased
       def inc(n = 1)
         @count.add(n)
       end

       # Decrement the counter by {@code n}, default by one.
       #
       # @param n the amount by which the counter will be decreased
       def dec(n = 1)
         @count.add(-n)
       end

       # Returns the counter's current value.
       #
       # @return the counter's current value
       @Override
       def count
         @count.sum
       end
    end
  end
end
