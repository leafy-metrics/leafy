require 'concurrent/map'
require_relative 'ratio_gauge'
require_relative 'counter'
require_relative 'meter'
require_relative 'histogram'
require_relative 'timer'

module Leafy
  module Core

    # A registry of metric instances.
    class MetricRegistry

      # Creates a new {@link MetricRegistry}.
      def initialize
        @metrics = build_map
      end

      # Creates a new {@link ConcurrentMap} implementation for use inside the registry. Override this
      # to create a {@link MetricRegistry} with space- or time-bounded metric lifecycles, for
      # example.
      #
      # @return a new {@link ConcurrentMap}
      def build_map
        Concurrent::Map.new
      end

      # Given a {@link Metric}, registers it under the given name.
      #
      # @param name   the name of the metric
      # @param metric the metric
      # @param <T>    the type of the metric
      # @return {@code metric}
      # @throws IllegalArgumentException if the name is already registered
      def register(name, metric)
        existing = @metrics.put_if_absent(name, metric)
        if existing
          raise ArgumentError.new("A metric named #{name} already exists")
        end
        metric
      end

      # Return the {@link Gauge} registered under this name or create and register
      # a new {@link Gauge} if none is registered.
      #
      # @param name the name of the metric
      # @param supplier a Builder that can be used to manufacture a Gauge
      # @return a new or pre-existing {@link Gauge}
      def gauge(name, builder)
        getOrAdd(name, builder)
      end

      # Return the {@link Counter} registered under this name or create and register
      # a new {@link Counter} if none is registered.
      #
      # @param name the name of the metric
      # @return a new or pre-existing {@link Counter}
      def counter(name)
        getOrAdd(name, Builder.counters)
      end

      # Return the {@link Histogram} registered under this name or create and register
      # a new {@link Histogram} if none is registered.
      #
      # @param name the name of the metric
      # @return a new or pre-existing {@link Histogram}
      def histogram(name)
        getOrAdd(name, Builder.histograms)
      end

      # Return the {@link Meter} registered under this name or create and register
      # a new {@link Meter} if none is registered.
      #
      # @param name the name of the metric
      # @return a new or pre-existing {@link Meter}
      def meter(name)
        getOrAdd(name, Builder.meters)
      end

      # Return the {@link Timer} registered under this name or create and register
      # a new {@link Timer} if none is registered.
      #
      # @param name the name of the metric
      # @return a new or pre-existing {@link Timer}
      def timer(name)
        getOrAdd(name, Builder.timers)
      end

      # Removes the metric with the given name.
      #
      # @param name the name of the metric
      # @return whether or not the metric was removed
      #/
      def remove(name)
        metric = @metrics.delete(name)
        metric != nil
      end

      # Returns a set of the names of all the metrics in the registry.
      #
      # @return the names of all the metrics
      def names
        @metrics.keys.dup.freeze
      end

      # Returns a map of all the gauges in the registry and their names.
      #
      # @return all the gauges in the registry
      def gauges
        metrics(Gauge)
      end

      # Returns a map of all the counters in the registry and their names.
      #
      # @return all the counters in the registry
      def counters
        metrics(Counter)
      end

      # Returns a map of all the histograms in the registry and their names.
      #
      # @return all the histograms in the registry
      def histograms
        metrics(Histogram)
      end

      # Returns a map of all the meters in the registry and their names.
      #
      # @return all the meters in the registry
      def meters 
        metrics(Meter)
      end

      # Returns a map of all the timers in the registry and their names.
      #
      # @return all the timers in the registry
      def timers
        metrics(Timer)
      end

      def metrics(klass = nil)
        if klass
          result = {}
          @metrics.each do |k,v|
            result[k] = v if v.is_a?(klass)
          end
          result.freeze
        else
          Hash[@metrics.keys.zip(@metrics.values)].freeze
        end
      end
      
      # A quick and easy way of capturing the notion of default metrics.
      class Builder
        def initialize(klass, &block)
          @klass = klass
          @block = (block || klass.method(:new))
        end

        def new_metric
          @block.call
        end

        def instance?(metric)
          metric.is_a?(@klass)
        end

        class << self

          def counters
            @counters ||= Builder.new(Counter)
          end
          
          def histograms
            @histograms ||= begin
                              builder = Builder.new(Histogram)
                              def builder.new_metric
                                Histogram.new(SlidingWindowReservoir.new(16))
                              end
                              builder
                            end
          end

          def meters
            @meters ||= Builder.new(Meter)
          end
      
          def timers
            @timers ||= Builder.new(Timer)
          end
        end
      end

      private
      def getOrAdd(name, builder)
        metric = @metrics[name]
        if builder.instance?(metric)
          return metric
        else if metric.nil?
          begin
            return register(name, builder.new_metric)
          rescue ArgumentError
            added = @metrics[name]
            if builder.instance?(added)
              return added
            end
          end
        end
        raise ArgumentError.new("#{name} is already used for a different type of metric")
      end

    end
  end
end
end
