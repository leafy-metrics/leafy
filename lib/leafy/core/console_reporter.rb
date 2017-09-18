require_relative 'scheduled_reporter'
require_relative 'clock'
module Leafy
  module Core
    class ConsoleReporter < ScheduledReporter

      class Builder
        def self.for_registry(registry)
          new(registry)
        end

        def initialize(registry)
          @registry = registry
        end

        def shutdown_executor_on_stop(value)
          @shutdown_executor_on_stop = value
        end

        def output_to(output)
          @output = output
          self
        end

        def with_clock(clock)
          @clock = clock
          self
        end

        def schedule_on(executor)
          @executor = executor
        end

        def build
          ConsoleReporter.new(@registry,
                    #locale,
                    #timeZone,
                    #rateUnit,
                    #durationUnit,
                    #filter,
                    @executor,
                    @shutdown_executor_on_stop,
                    clock: @clock, output: @output)
                    #disabledMetricAttributes
        end
      end

      CONSOLE_WIDTH = 80
      attr_reader :output, :clock
      def initialize(registry, executor = nil, shutdownExecutorOnStop = true, output: nil, clock: nil)
        super(registry, 'console-reporter', executor, shutdownExecutorOnStop)
        @output = output || STDOUT
        @clock = clock || Clock.default_clock
      end

      def print_report(metric, name, print_method)
        unless metric.empty?
          printWithBanner("-- #{name}", '-')
          metric.each do |k,v|
            output.puts(k)
            print_method.call(v)
          end
          output.puts
        end
      end
      private :print_report

      def do_report(gauges,
                    counters,
                    histograms,
                    meters,
                    timers)
        dateTime = Time.at(@clock.time / 1000000.0).utc
        printWithBanner(dateTime.to_s, '=');
        output.puts

        print_report(gauges, 'Gauges', method(:printGauge))
        print_report(counters, 'Counters', method(:printCounter))
        print_report(histograms, 'Histograms', method(:printHistogram))
        print_report(meters, 'Meters', method(:printMeter))
        print_report(timers, 'Timers', method(:printTimer))

        output.puts
        output.flush
      end

      def printMeter(meter)
        output.printf("             count = %d\n", meter.count)
        output.printf("         mean rate = %2.2f events/%s\n", convert_rate(meter.mean_rate), rate_unit)
        output.printf("     1-minute rate = %2.2f events/%s\n", convert_rate(meter.one_minute_rate), rate_unit)
        output.printf("     5-minute rate = %2.2f events/%s\n", convert_rate(meter.five_minute_rate), rate_unit)
        output.printf("    15-minute rate = %2.2f events/%s\n", convert_rate(meter.fifteen_minute_rate), rate_unit)
      end
      private :printMeter

      def printCounter(counter)
        output.printf("             count = %d\n", counter.count)
      end
      private :printCounter

      def printGauge(gauge)
        output.printf("             value = %s\n", gauge.value)
      end
      private :printGauge

      def printHistogram(histogram)
        output.printf("             count = %d\n", histogram.count)
        snapshot = histogram.snapshot
        output.printf("               min = %d\n", snapshot.min)
        output.printf("               max = %d\n", snapshot.max)
        output.printf("              mean = %2.2f\n", snapshot.mean)
        output.printf("            stddev = %2.2f\n", snapshot.std_dev)
        output.printf("            median = %2.2f\n", snapshot.median)
        output.printf("              75%% <= %2.2f\n", snapshot.get_75th_percentile)
        output.printf("              95%% <= %2.2f\n", snapshot.get_95th_percentile)
        output.printf("              98%% <= %2.2f\n", snapshot.get_98th_percentile)
        output.printf("              99%% <= %2.2f\n", snapshot.get_99th_percentile)
        output.printf("            99.9%% <= %2.2f\n", snapshot.get_999th_percentile)
      end
      private :printHistogram

      def printTimer(timer)
        snapshot = timer.snapshot
        output.printf("             count = %d\n", timer.count)
        output.printf("         mean rate = %2.2f calls/%s\n", convert_rate(timer.mean_rate), rate_unit)
        output.printf("     1-minute rate = %2.2f calls/%s\n", convert_rate(timer.one_minute_rate), rate_unit)
        output.printf("     5-minute rate = %2.2f calls/%s\n", convert_rate(timer.five_minute_rate), rate_unit)
        output.printf("    15-minute rate = %2.2f calls/%s\n", convert_rate(timer.fifteen_minute_rate), rate_unit)

        output.printf("               min = %2.2f %s\n", convert_duration(snapshot.min), duration_unit)
        output.printf("               max = %2.2f %s\n", convert_duration(snapshot.max), duration_unit)
        output.printf("              mean = %2.2f %s\n", convert_duration(snapshot.mean), duration_unit)
        output.printf("            stddev = %2.2f %s\n", convert_duration(snapshot.std_dev), duration_unit)
        output.printf("            median = %2.2f %s\n", convert_duration(snapshot.median), duration_unit)
        output.printf("              75%% <= %2.2f %s\n", convert_duration(snapshot.get_75th_percentile), duration_unit)
        output.printf("              95%% <= %2.2f %s\n", convert_duration(snapshot.get_95th_percentile), duration_unit)
        output.printf("              98%% <= %2.2f %s\n", convert_duration(snapshot.get_98th_percentile), duration_unit)
        output.printf("              99%% <= %2.2f %s\n", convert_duration(snapshot.get_99th_percentile), duration_unit)
        output.printf("            99.9%% <= %2.2f %s\n", convert_duration(snapshot.get_999th_percentile), duration_unit)
      end
      private :printTimer

      def printWithBanner(string, char)
        output.print(string)
        output.print(' ')
        (CONSOLE_WIDTH - string.size - 1).times { output.print(char) }
        output.puts
      end
    end
  end
end
