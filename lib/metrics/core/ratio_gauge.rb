require_relative 'gauge'

# A gauge which measures the ratio of one value to another.
#
# If the denominator is zero, not a number, or infinite, the resulting ratio is not a number.
module Metrics
  module Core
    class RatioGauge < Gauge

      # A ratio of one quantity to another.
      class Ratio
        
        # Creates a new ratio with the given numerator and denominator.
        #
        # @param numerator   the numerator of the ratio
        # @param denominator the denominator of the ratio
        # @return {@code numerator:denominator}
        def self.of(numerator, denominator)
          Ratio.new(numerator, denominator)
        end

        def initialize(numerator, denominator)
          @numerator = numerator
          @denominator = denominator
        end
        
        # Returns the ratio, which is either a {@code double} between 0 and 1 (inclusive) or
        # {@code NaN}.
        #
        # @return the ratio
        def value
          if !(@denominator.is_a?(Float)) || @denominator.infinite? || @denominator.nan? || @denominator == 0
            return Float::NAN
          end
          @numerator.to_f / @denominator.to_f
        end

        def to_s
          "#{@numerator.to_f}:#{@denominator.to_f}"
        end
      end
    
      # Returns the {@link Ratio} which is the gauge's current value.
      #
      # @return the {@link Ratio} which is the gauge's current value
      def ratio
        @block.call
      end
      protected :ratio

      def value
        ratio.value
      end
    end
  end
end
