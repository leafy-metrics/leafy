require_relative 'snapshot'

# A statistical snapshot of a {@link UniformSnapshot}. 
module Leafy
  module Core
    class UniformSnapshot < Snapshot

      # Create a new {@link Snapshot} with the given values.
      #
      # @param values an unordered set of values in the reservoir that can be used by this class directly
      def initialize(*values)
        @values = values.dup.compact.sort
      end

      # Returns the value at the given quantile.
      #
      # @param quantile a given quantile, in {@code [0..1]}
      # @return the value in the distribution at {@code quantile}
      def value(quantile)
        if quantile < 0.0 || quantile > 1.0 || !quantile.is_a?(Float)
            raise ArgumentError.new("#{quantile} is not in [0..1]")
        end

        return 0.0 if @values.empty?
        
        pos = quantile * (values.size + 1)
        index = pos.to_i

        return @values[0] if index < 1
        
        return @values.last if index >= @values.size

        lower = @values[index - 1]
        upper = @values[index]
        lower + (pos - pos.floor) * (upper - lower)
      end

      # Returns the number of values in the snapshot.
      #
      # @return the number of values
      def size
        @values.size
      end

      # Returns the entire set of values in the snapshot.
      #
      # @return the entire set of values
      def values
        @values.dup
      end

      # Returns the highest value in the snapshot.
      #
      # @return the highest value
      #/
      @Override
      def max
        return 0 if @values.empty?
        @values.last
      end

      # Returns the lowest value in the snapshot.
      #
      # @return the lowest value
      def min
        return 0 if @values.empty?
        @values.first
      end

      # Returns the arithmetic mean of the values in the snapshot.
      #
      # @return the arithmetic mean
      def mean
        return 0 if @values.empty?
 

        sum = 0;
        @values.each do |value|
          sum += value
        end
        sum / @values.size
      end

      # Returns the standard deviation of the values in the snapshot.
      #
      # @return the standard deviation value
      def std_dev
        # two-pass algorithm for variance, avoids numeric overflow

        return 0.0 if @values.size <= 1
        
        mean = self.mean
        sum = 0.0

        @values.each do |value|
          diff = value - mean
          sum += diff * diff
        end

        variance = sum / (@values.size - 1)
        Math.sqrt(variance)
      end

      # Writes the values of the snapshot to the given stream.
      #
      # @param output an output stream
      def dump(out)
        @values.each do |value|
          out.printf("%d\n", value)
        end
      end
    end
  end
end

