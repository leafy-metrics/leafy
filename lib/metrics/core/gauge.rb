# A gauge which measures the ratio of one value to another.
#
# If the denominator is zero, not a number, or infinite, the resulting ratio is not a number.
module Metrics
  module Core
    class Gauge
      
      def initialize(&block)
        @block = block || raise(AgumentError.new('missing block'))
      end

      def value
        @block.call
      end
    end
  end
end
