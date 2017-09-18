module Leafy
  module Core

    # A statistical snapshot of a {@link Snapshot}.
    class Snapshot

      # Returns the value at the given quantile.
      #
      # @param quantile a given quantile, in {@code [0..1]}
      # @return the value in the distribution at {@code quantile}
      def value(_quantile)
        raise 'not implemented'
      end

      # Returns the median value in the distribution.
      #
      # @return the median value
      def median
        value(0.5)
      end

      # Returns the value at the 75th percentile in the distribution.
      #
      # @the value at the 75th percentile
      def get_75th_percentile
        value(0.75)
      end

      # Returns the value at the 95th percentile in the distribution.
      #
      # @the value at the 95th percentile
      def get_95th_percentile
        value(0.95)
      end

      # Returns the value at the 98th percentile in the distribution.
      #
      # @the value at the 98th percentile
      def get_98th_percentile
        value(0.98)
      end

      # Returns the value at the 99th percentile in the distribution.
      #
      # @the value at the 99th percentile
      def get_99th_percentile
        value(0.99)
      end

      # Returns the value at the 99.9th percentile in the distribution.
      #
      # @the value at the 99.9th percentile
      def get_999th_percentile
        value(0.999)
      end
    end
  end
end
