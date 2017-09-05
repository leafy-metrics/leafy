require 'metrics/core/timer'
require 'concurrent/atomic/atomic_boolean'

RSpec.describe Metrics::Core::Timer do

  let(:clock) do
    clock = Metrics::Core::Clock.new
    # a mock clock that increments its ticker by 50msec per call
    def clock.tick      
      @ticks = @ticks.to_i + 50000000
    end
    clock
  end

  let(:reservoir) { double('Reservoir') }

  let(:timer) {  Metrics::Core::Timer.new(reservoir, clock) }

  it 'hasRates' do
    expect(timer.count).to eq 0

    expect(timer.mean_rate).to eq 0

    expect(timer.one_minute_rate).to eq 0

    expect(timer.five_minute_rate).to eq 0

    expect(timer.fifteen_minute_rate).to eq 0
  end

  
  it 'updatesTheCountOnUpdates' do
    allow(reservoir).to receive(:update).with(2000000000)
    expect(timer.count).to eq 0

    timer.update(2)

    expect(timer.count).to eq 1
  end

  
  it 'timesCallableInstances' do
    allow(reservoir).to receive(:update).with(50000000)

    value = timer.time { "one" }

    expect(timer.count).to eq 1

    expect(value).to eq 'one'
  end

  
  it 'timesRunnableInstances' do
    allow(reservoir).to receive(:update).with(50000000)

    called = Concurrent::AtomicBoolean.new(false)
    timer.time { called.value = true }

    expect(timer.count).to eq 1

    expect(called.value).to eq true
  end

  
  it 'timesContexts' do
    allow(reservoir).to receive(:update).with(50000000)
    timer.context.stop

    expect(timer.count).to eq 1
  end

  
  it 'returnsTheSnapshotFromTheReservoir' do
    snapshot = Object.new
    allow(reservoir).to receive(:snapshot).and_return(snapshot)

    expect(timer.snapshot).to eq snapshot
  end

  
  it 'ignoresNegativeValues' do
    timer.update(-1)

    expect(timer.count).to eq 0
  end

  
  it 'tryWithResourcesWork' do
    allow(reservoir).to receive(:update).with(50000000)
    expect(timer.count).to eq 0
    
    dummy = 0
    timer.context do |context|
      #expect(context).isNotNull();
      dummy += 1
    end
    expect(dummy).to eq 1
    expect(timer.count).to eq 1
  end
end
