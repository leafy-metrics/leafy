# A gauge.
module Leafy
  module Core
    class Gauge
      include Concurrent::Synchronization::Volatile

      attr_volatile :val

      def initialize(&block)
        @block = block
      end

      def value=(v)
        self.val = v
      end

      def value
        if @block
          @block.call
        else
          self.val
        end
      end
    end
  end
end
