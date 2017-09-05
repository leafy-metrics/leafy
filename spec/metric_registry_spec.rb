require 'metrics/core/metric_registry'

RSpec.describe Metrics::Core::MetricRegistry do

  class MetricMock

    def initialize(klass)
      @klass = klass
    end
    def is_a?(klass)
      @klass == klass
    end
  end

  let(:registry) { subject }

  let(:gauge) { }
  let(:counter) { MetricMock.new(Metrics::Core::Counter) }
  let(:timer) { MetricMock.new(Metrics::Core::Timer) }
  let(:histogram) { MetricMock.new(Metrics::Core::Histogram) }
  let(:meter) { MetricMock.new(Metrics::Core::Meter) }

  # it 'registeringAGaugeTriggersANotification' do
  #   expect(registry.register("thing", gauge)).to eq gauge

  #   #     verify(listener).onGaugeAdded("thing", gauge);
  # end

  
  # it 'removingAGaugeTriggersANotification' do
  #   registry.register("thing", gauge);

  #   expect(registry.remove("thing")).to eq true

  #   #      verify(listener).onGaugeRemoved("thing");
  # end

  
  it 'registeringACounterTriggersANotification' do
    expect(registry.register("thing", counter)).to eq counter

    #       verify(listener).onCounterAdded("thing", counter);
  end

  
  it 'accessingACounterRegistersAndReusesTheCounter' do
    counter1 = registry.counter("thing");
    counter2 = registry.counter("thing");

    expect(counter1).to equal counter2

    #        verify(listener).onCounterAdded("thing", counter1);
  end


  
  it 'removingACounterTriggersANotification' do
    registry.register("thing", counter);

    expect(registry.remove("thing")).to eq true

    #      verify(listener).onCounterRemoved("thing");
  end

  
  it 'registeringAHistogramTriggersANotification' do
    expect(registry.register("thing", histogram)).to eq histogram

    #       verify(listener).onHistogramAdded("thing", histogram);
  end

  
  it 'accessingAHistogramRegistersAndReusesIt' do
    histogram1 = registry.histogram("thing");
    histogram2 = registry.histogram("thing");

    expect(histogram1).to be histogram2

    #        verify(listener).onHistogramAdded("thing", histogram1);
  end

  
  it 'removingAHistogramTriggersANotification' do
    registry.register("thing", histogram);

    expect(registry.remove("thing")).to eq true

    #      verify(listener).onHistogramRemoved("thing");
  end

  
  it 'registeringAMeterTriggersANotification' do
    expect(registry.register("thing", meter)).to eq meter

    #       verify(listener).onMeterAdded("thing", meter);
  end

  
  it 'accessingAMeterRegistersAndReusesIt' do
    meter1 = registry.meter("thing");
    meter2 = registry.meter("thing");

    expect(meter1).to be meter2

    #        verify(listener).onMeterAdded("thing", meter1);
  end

  
  it 'removingAMeterTriggersANotification' do
    registry.register("thing", meter);

    expect(registry.remove("thing")).to eq true

    #     verify(listener).onMeterRemoved("thing");
  end

  
  it 'registeringATimerTriggersANotification' do
    expect(registry.register("thing", timer)).to eq timer

    #      verify(listener).onTimerAdded("thing", timer);
  end

  
  it 'accessingATimerRegistersAndReusesIt' do
    timer1 = registry.timer("thing");
    timer2 = registry.timer("thing");

    expect(timer1).to be timer2

    #       verify(listener).onTimerAdded("thing", timer1);
  end

  

  
  it 'removingATimerTriggersANotification' do
    registry.register("thing", timer);

    expect(registry.remove("thing")).to eq true

    #        verify(listener).onTimerRemoved("thing");
  end



  
  # it 'hasAMapOfRegisteredGauges' do
  #     registry.register("gauge", gauge);

  #     expect(registry.gauges['gauge']).to eq gauge
  # end

  
  it 'hasAMapOfRegisteredCounters' do
    registry.register("counter", counter);

    expect(registry.counters['counter']).to eq counter
  end

  
  it 'hasAMapOfRegisteredHistograms' do
    registry.register("histogram", histogram);

    expect(registry.histograms['histogram']).to eq histogram
  end

  
  it 'hasAMapOfRegisteredMeters' do
    registry.register("meter", meter);

    expect(registry.meters['meter']).to eq meter
  end

  
  it 'hasAMapOfRegisteredTimers' do
    registry.register("timer", timer);

    expect(registry.timers['timer']).to eq timer
  end

  
  it 'hasASetOfRegisteredMetricNames' do
    registry.register("gauge", gauge);
    registry.register("counter", counter);
    registry.register("histogram", histogram);
    registry.register("meter", meter);
    registry.register("timer", timer);

    expect(registry.names).to match_array ["gauge", "counter", "histogram", "meter", "timer"]
  end

end
