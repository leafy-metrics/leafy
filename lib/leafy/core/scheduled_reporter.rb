require 'concurrent/thread_safe/util/cheap_lockable'
require 'concurrent'
require_relative 'metric_registry'

module Leafy
  module Core
    class ScheduledReporter
      include Concurrent::ThreadSafe::Util::CheapLockable

      def self.logger(logger = nil)
        @logger ||= logger || (require 'logger'; Logger.new(STDERR))
      end

      #FACTORY_ID = Concurrent::AtomicFixnum.new
      def self.createDefaultExecutor(name)
        Concurrent::SingleThreadExecutor.new
        #return Executors.newSingleThreadScheduledExecutor(new NamedThreadFactory(name + '-' + FACTORY_ID.incrementAndGet()));
      end

      def initialize(registry, name, executor = nil, shutdownExecutorOnStop = true)
        super() # for cheap_lockable
        @registry  = registry;
        @executor = executor.nil? ? self.class.createDefaultExecutor(name) : executor
        @shutdownExecutorOnStop = shutdownExecutorOnStop;
        @rateFactor = 1.0
        @durationFactor = 1000000.0
      end

      class ReportedTask

        def initialize(reporter, start, period)
          @reporter = reporter
          @start = start
          @period = period
        end

        def delay
          @period - (Concurrent.monotonic_time - @start) % @period
        end

        def call
          @reporter.report
        end

        def task(task = nil)
          @task ||= task
        end
      end


      # obserer callback from scheduled task used to trigger the task for the
      # next report
      def update(time, value, reason)
        return if reason.is_a? Concurrent::CancelledOperationError
        cheap_synchronize do
          raise ArgumentError.new("Reporter not started started") unless @scheduledFuture
          task = Concurrent::ScheduledTask.new(@scheduledFuture.delay, executor: @executor, &@scheduledFuture.method(:call))
          task.add_observer(self)
          task.execute
        end
      end

      # Starts the reporter polling at the given period.
      #
      # @param initialDelay the time to delay the first execution
      # @param period       the amount of time between polls
      # @param unit         the unit for {@code period}
      def start(initial_delay, period = initial_delay)
        cheap_synchronize do
          raise ArgumentError.new("Reporter already started") if @scheduledFuture
          start = Concurrent.monotonic_time + initial_delay

          @scheduledFuture = ReportedTask.new(self, start, period) 
          task = Concurrent::ScheduledTask.new(initial_delay, executor: @executor, &@scheduledFuture.method(:call))
          task.add_observer(self)
          @scheduledFuture.task(task)
          task.execute
        end
      end

      # Stops the reporter and if shutdownExecutorOnStop is true then shuts down its thread of execution.
      # <p>
      # Uses the shutdown pattern from http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/ExecutorService.html
      def stop
        if @shutdownExecutorOnStop
          @executor.shutdown # Disable new tasks from being submitted
          # Wait a while for existing tasks to terminate
          unless @executor.wait_for_termination(1)
            @executor.shutdown # Cancel currently executing tasks
            # Wait a while for tasks to respond to being cancelled
            unless @executor.wait_for_termination(1)
              puts "#{self.class.name}: ScheduledExecutorService did not terminate"
            end
          end
        else
          # The external manager(like JEE container) responsible for lifecycle of executor
          cheap_synchronize do
            return if @scheduledFuture.nil? # was never started
            return if @scheduledFuture.task.cancelled? # already cancelled
            # just cancel the scheduledFuture and exit
            @scheduledFuture.task.cancel
          end
        end
      end
    
      # Report the current values of all metrics in the registry.
      def report
        cheap_synchronize do
          do_report(@registry.gauges,
            @registry.counters,
            @registry.histograms,
            @registry.meters,
            @registry.timers)
        end
      rescue => ex
        self.class.logger.error("Exception thrown from #{self.class.name}#report. Exception was suppressed: #{ex.message}")
      end

      # Called periodically by the polling thread. Subclasses should report all the given metrics.
      #
      # @param gauges     all of the gauges in the registry
      # @param counters   all of the counters in the registry
      # @param histograms all of the histograms in the registry
      # @param meters     all of the meters in the registry
      # @param timers     all of the timers in tdhe registry
      def do_report(gauges,
                    counters,
                    histograms,
                    meters,
                    timers)
        raise 'not implemented'
      end
    

      def rate_unit
        'second'
      end
      protected :rate_unit
      
      def duration_unit
        'milliseconds'
      end
      protected :duration_unit

      def convert_duration(duration)
        duration / @durationFactor;
      end
      protected :convert_duration

      def convert_rate(rate)
        rate * @rateFactor
      end
      protected :convert_rate
    end
  end
end
