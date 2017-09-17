require 'leafy/core/scheduled_reporter'
require 'concurrent/atomic/atomic_fixnum'


RSpec.describe Leafy::Core::ScheduledReporter do

  class MetricMock

    def initialize(klass)
      @klass = klass
    end
    def is_a?(klass)
      @klass == klass
    end
  end

  class Leafy::Core::DummyReporter < Leafy::Core::ScheduledReporter

    attr_reader :execution_count, :args
    def initialize(registry, name, *)#executor = nil, shutdownExecutorOnStop = false)
      super
      @execution_count = Concurrent::AtomicFixnum.new
      @args = []
    end

    def do_report(*args)
      @args << args
      @execution_count.increment
    end
  end

  let(:gauge) { MetricMock.new(Leafy::Core::Gauge) }
  let(:counter) { MetricMock.new(Leafy::Core::Counter) }
  let(:timer) { MetricMock.new(Leafy::Core::Timer) }
  let(:histogram) { MetricMock.new(Leafy::Core::Histogram) }
  let(:meter) { MetricMock.new(Leafy::Core::Meter) }
  let(:registry) do
    registry = Leafy::Core::MetricRegistry.new
    registry.register("gauge", gauge)
    registry.register("counter", counter)
    registry.register("histogram", histogram)
    registry.register("meter", meter)
    registry.register("timer", timer)
    registry
  end

  let(:custom_executor) { Concurrent::SingleThreadExecutor.new }
  let(:external_executor) { Concurrent::SingleThreadExecutor.new }
  let(:reporter) { Leafy::Core::DummyReporter.new(registry, 'example') }
  let(:reporter_with_custom_executor) { Leafy::Core::DummyReporter.new(registry, 'example', custom_executor) }
  let(:reporter_with_externally_managed_executor) { Leafy::Core::DummyReporter.new(registry, 'example', external_executor, false) }
  let(:reporters) { [reporter, reporter_with_custom_executor,
                     reporter_with_externally_managed_executor] }

  after :each do
    reporter.stop
    custom_executor.shutdown
    external_executor.shutdown
  end

  it 'pollsPeriodically' do
    reporter.start(0.1)

    sleep(0.55)
    expect(reporter.execution_count.value).to eq 5
    expect(reporter.args.size).to eq 5
    reporter.args.each do |arg|
      expect(arg[0]['gauge']).to eq gauge
      expect(arg[1]['counter']).to eq counter
      expect(arg[2]['histogram']).to eq histogram
      expect(arg[3]['meter']).to eq meter
      expect(arg[4]['timer']).to eq timer
    end
  end

  it 'shouldDisallowToStartReportingMultiple' do
    expect { reporter.start(0.2) }.not_to raise_error
    expect { reporter.start(0.2) }.to raise_error ArgumentError
  end

  it 'shouldDisallowToStartReportingMultipleTimesOnCustomExecutor' do
    expect { reporter_with_custom_executor.start(0.2) }.not_to raise_error
    expect { reporter_with_custom_executor.start(0.2) }.to raise_error ArgumentError
  end

  it 'shouldDisallowToStartReportingMultipleTimesOnExternallyManagedExecutor' do
    expect { reporter_with_externally_managed_executor.start(0.2) }.not_to raise_error
    expect { reporter_with_externally_managed_executor.start(0.2) }.to raise_error ArgumentError
  end
    
  it 'shouldNotFailOnStopIfReporterWasNotStared' do
    reporters.each do |reporter|
      expect { reporter.stop }.not_to raise_error
    end
  end

  it 'shouldNotFailWhenStoppingMultipleTimes' do
    reporters[2..2].each do |reporter|
      reporter.start(0.2)
      reporter.stop
      reporter.stop
      reporter.stop
    end
  end

  it 'shouldShutdownExecutorOnStopByDefault' do
    reporter_with_custom_executor.start(0.2)
    reporter_with_custom_executor.stop
    expect(custom_executor.shutdown?).to eq true
  end

  it 'shouldNotShutdownExternallyManagedExecutorOnStop' do
    reporter_with_externally_managed_executor.start(0.2)
    reporter_with_externally_managed_executor.stop
    expect(external_executor.shutdown?).to eq false
  end

    
  it 'shouldCancelScheduledFutureWhenStoppingWithExternallyManagedExecutor' do
    # configure very frequency rate of execution
    reporter_with_externally_managed_executor.start(0.001)
    reporter_with_externally_managed_executor.stop
    sleep(0.1)

    # executionCount should not increase when scheduled future is canceled properly
    execution_count = reporter_with_externally_managed_executor.execution_count.value
    sleep(0.5)
    expect(execution_count).to eq reporter_with_externally_managed_executor.execution_count.value
  end

    
  it 'shouldConvertDurationToMillisecondsPrecisely' do
    expect(2.0E-5).to eq reporter.send(:convert_duration, 20)
  end
end
