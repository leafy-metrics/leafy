require 'leafy/core/console_reporter'

RSpec.describe Leafy::Core::ConsoleReporter do

  let(:output) { StringIO.new }
  let(:registry) { double(Leafy::Core::MetricRegistry) }

  let(:clock) do
    clock = double(Leafy::Core::Clock)
    allow(clock).to receive(:time).and_return(1363568676000)
    clock
  end

  let(:reporter) do
    Leafy::Core::ConsoleReporter::Builder
      .for_registry(registry)
      .output_to(output)
      .with_clock(clock)
      .build
  end
  
  it 'reportsGaugeValues' do
    gauge = Leafy::Core::Gauge.new { 1 }

    reporter.do_report({"gauge" => gauge},
                    {},
                    {},
                    {},
                    {})

    expect(output.string).to eq [
                        "1970-01-16 18:46:08 UTC ========================================================",
                        "",
                        "-- Gauges ----------------------------------------------------------------------",
                        "gauge",
                        "             value = 1",
                        "",
                        "",
                        ""
               ].join("\n")
  end


  it 'reportsCounterValues' do
    counter = double(Leafy::Core::Counter.class)
    allow(counter).to receive(:count).and_return(100)

    reporter.do_report({},
                    {"test.counter" => counter},
                    {},
                    {},
                    {})

    expect(output.string).to eq [
                        "1970-01-16 18:46:08 UTC ========================================================",
                        "",
                        "-- Counters --------------------------------------------------------------------",
                        "test.counter",
                        "             count = 100",
                        "",
                        "",
                        ""
               ].join("\n")
  end


  it 'reportsHistogramValues' do
    histogram = double(Leafy::Core::Histogram.class)
    allow(histogram).to receive(:count).and_return(1)

    snapshot = double(Leafy::Core::Snapshot.class)
    allow(snapshot).to receive(:max).and_return(2)
    allow(snapshot).to receive(:mean).and_return(3.0)
    allow(snapshot).to receive(:min).and_return(4)
    allow(snapshot).to receive(:std_dev).and_return(5.0)
    allow(snapshot).to receive(:median).and_return(6.0)
    allow(snapshot).to receive(:get_75th_percentile).and_return(7.0)
    allow(snapshot).to receive(:get_95th_percentile).and_return(8.0)
    allow(snapshot).to receive(:get_98th_percentile).and_return(9.0)
    allow(snapshot).to receive(:get_99th_percentile).and_return(10.0)
    allow(snapshot).to receive(:get_999th_percentile).and_return(11.0)

    allow(histogram).to receive(:snapshot).and_return(snapshot)

    reporter.do_report({},
                    {},
                    {"test.histogram" => histogram},
                    {},
                    {})

    expect(output.string).to eq [
                        "1970-01-16 18:46:08 UTC ========================================================",
                        "",
                        "-- Histograms ------------------------------------------------------------------",
                        "test.histogram",
                        "             count = 1",
                        "               min = 4",
                        "               max = 2",
                        "              mean = 3.00",
                        "            stddev = 5.00",
                        "            median = 6.00",
                        "              75% <= 7.00",
                        "              95% <= 8.00",
                        "              98% <= 9.00",
                        "              99% <= 10.00",
                        "            99.9% <= 11.00",
                        "",
                        "",
                        ""
               ].join("\n")
  end


  it 'reportsMeterValues' do
    meter = double(Leafy::Core::Meter.class)
    allow(meter).to receive(:count).and_return(1)
    allow(meter).to receive(:mean_rate).and_return(2.0)
    allow(meter).to receive(:one_minute_rate).and_return(3.0)
    allow(meter).to receive(:five_minute_rate).and_return(4.0)
    allow(meter).to receive(:fifteen_minute_rate).and_return(5.0)

    reporter.do_report({},
                    {},
                    {},
                    {"test.meter" => meter},
                    {})

    expect(output.string).to eq [
                        "1970-01-16 18:46:08 UTC ========================================================",
                        "",
                        "-- Meters ----------------------------------------------------------------------",
                        "test.meter",
                        "             count = 1",
                        "         mean rate = 2.00 events/second",
                        "     1-minute rate = 3.00 events/second",
                        "     5-minute rate = 4.00 events/second",
                        "    15-minute rate = 5.00 events/second",
                        "",
                        "",
                        ""
               ].join("\n")
  end


  it 'reportsTimerValues' do
    timer = double(Leafy::Core::Timer.class)
    allow(timer).to receive(:count).and_return(1)
    allow(timer).to receive(:mean_rate).and_return(2.0)
    allow(timer).to receive(:one_minute_rate).and_return(3.0)
    allow(timer).to receive(:five_minute_rate).and_return(4.0)
    allow(timer).to receive(:fifteen_minute_rate).and_return(5.0)

    snapshot = double(Leafy::Core::Snapshot.class)
    allow(snapshot).to receive(:max).and_return(100000000)
    allow(snapshot).to receive(:mean).and_return(200000000.0)
    allow(snapshot).to receive(:min).and_return(300000000.0)
    allow(snapshot).to receive(:std_dev).and_return(400000000.0)
    allow(snapshot).to receive(:median).and_return(500000000.0)
    allow(snapshot).to receive(:get_75th_percentile).and_return(600000000.0)
    allow(snapshot).to receive(:get_95th_percentile).and_return(700000000.0)
    allow(snapshot).to receive(:get_98th_percentile).and_return(800000000.0)
    allow(snapshot).to receive(:get_99th_percentile).and_return(900000000.0)
    allow(snapshot).to receive(:get_999th_percentile).and_return(1000000000.0)

    allow(timer).to receive(:snapshot).and_return(snapshot)

    reporter.do_report({},
                    {},
                    {},
                    {},
                    {"test.another.timer" => timer})

    expect(output.string).to eq [
                        "1970-01-16 18:46:08 UTC ========================================================",
                        "",
                        "-- Timers ----------------------------------------------------------------------",
                        "test.another.timer",
                        "             count = 1",
                        "         mean rate = 2.00 calls/second",
                        "     1-minute rate = 3.00 calls/second",
                        "     5-minute rate = 4.00 calls/second",
                        "    15-minute rate = 5.00 calls/second",
                        "               min = 300.00 milliseconds",
                        "               max = 100.00 milliseconds",
                        "              mean = 200.00 milliseconds",
                        "            stddev = 400.00 milliseconds",
                        "            median = 500.00 milliseconds",
                        "              75% <= 600.00 milliseconds",
                        "              95% <= 700.00 milliseconds",
                        "              98% <= 800.00 milliseconds",
                        "              99% <= 900.00 milliseconds",
                        "            99.9% <= 1000.00 milliseconds",
                        "",
                        "",
                        ""
               ].join("\n")
  end


    # it 'reportMeterWithDisabledAttributes' do
    #     Set<MetricAttribute> disabledMetricAttributes = EnumSet.of(MetricAttribute.M15_RATE, MetricAttribute.M5_RATE, MetricAttribute.COUNT)

    #     final ConsoleReporter customReporter = ConsoleReporter.forRegistry(registry)
    #             .outputTo(output)
    #             .formattedFor(locale)
    #             .withClock(clock)
    #             .formattedFor(timeZone)
    #             .convertRatesTo(TimeUnit.SECONDS)
    #             .convertDurationsTo(TimeUnit.MILLISECONDS)
    #             .filter(MetricFilter.ALL)
    #             .disabledMetricAttributes(disabledMetricAttributes)
    #             .build()

    #     final Meter meter = double(Meter.class)
    #     when(meter).to receive(:Count()).and_return(1L)
    #     when(meter).to receive(:MeanRate()).and_return(2.0)
    #     when(meter).to receive(:OneMinuteRate()).and_return(3.0)
    #     when(meter).to receive(:FiveMinuteRate()).and_return(4.0)
    #     when(meter).to receive(:FifteenMinuteRate()).and_return(5.0)

    #     customReporter.report({},
    #             {},
    #             {},
    #             {"test.meter" => meter),
    #             {})

    #     expect(output.string).to eq
    #            [
    #                     "3/17/13 6:04:36 PM =============================================================",
    #                     "",
    #                     "-- Meters ----------------------------------------------------------------------",
    #                     "test.meter",
    #                     "         mean rate = 2.00 events/second",
    #                     "     1-minute rate = 3.00 events/second",
    #                     "",
    #                     ""
    #            ].join("\n")
    # }


    # it 'reportTimerWithDisabledAttributes' do
    #     Set<MetricAttribute> disabledMetricAttributes = EnumSet.of(MetricAttribute.P50, MetricAttribute.P999, MetricAttribute.M5_RATE, MetricAttribute.MAX)

    #     final ConsoleReporter customReporter = ConsoleReporter.forRegistry(registry)
    #             .outputTo(output)
    #             .formattedFor(locale)
    #             .withClock(clock)
    #             .formattedFor(timeZone)
    #             .convertRatesTo(TimeUnit.SECONDS)
    #             .convertDurationsTo(TimeUnit.MILLISECONDS)
    #             .filter(MetricFilter.ALL)
    #             .disabledMetricAttributes(disabledMetricAttributes)
    #             .build()

    #     final Timer timer = double(Timer.class)
    #     when(timer).to receive(:Count()).and_return(1L)
    #     when(timer).to receive(:MeanRate()).and_return(2.0)
    #     when(timer).to receive(:OneMinuteRate()).and_return(3.0)
    #     when(timer).to receive(:FiveMinuteRate()).and_return(4.0)
    #     when(timer).to receive(:FifteenMinuteRate()).and_return(5.0)

    #     final Snapshot snapshot = double(Snapshot.class)
    #     when(snapshot).to receive(:Max()).and_return(TimeUnit.MILLISECONDS.toNanos(100))
    #     when(snapshot).to receive(:Mean()).and_return((double) TimeUnit.MILLISECONDS.toNanos(200))
    #     when(snapshot).to receive(:Min()).and_return(TimeUnit.MILLISECONDS.toNanos(300))
    #     when(snapshot).to receive(:StdDev()).and_return((double) TimeUnit.MILLISECONDS.toNanos(400))
    #     when(snapshot).to receive(:Median()).and_return((double) TimeUnit.MILLISECONDS.toNanos(500))
    #     when(snapshot).to receive(:75thPercentile()).and_return((double) TimeUnit.MILLISECONDS.toNanos(600))
    #     when(snapshot).to receive(:95thPercentile()).and_return((double) TimeUnit.MILLISECONDS.toNanos(700))
    #     when(snapshot).to receive(:98thPercentile()).and_return((double) TimeUnit.MILLISECONDS.toNanos(800))
    #     when(snapshot).to receive(:99thPercentile()).and_return((double) TimeUnit.MILLISECONDS.toNanos(900))
    #     when(snapshot).to receive(:999thPercentile()).and_return((double) TimeUnit.MILLISECONDS
    #             .toNanos(1000))

    #     when(timer).to receive(:Snapshot()).and_return(snapshot)

    #     customReporter.report({},
    #             {},
    #             {},
    #             {},
    #             {"test.another.timer" => timer})

    #     expect(output.string).to eq
    #            [
    #                     "3/17/13 6:04:36 PM =============================================================",
    #                     "",
    #                     "-- Timers ----------------------------------------------------------------------",
    #                     "test.another.timer",
    #                     "             count = 1",
    #                     "         mean rate = 2.00 calls/second",
    #                     "     1-minute rate = 3.00 calls/second",
    #                     "    15-minute rate = 5.00 calls/second",
    #                     "               min = 300.00 milliseconds",
    #                     "              mean = 200.00 milliseconds",
    #                     "            stddev = 400.00 milliseconds",
    #                     "              75% <= 600.00 milliseconds",
    #                     "              95% <= 700.00 milliseconds",
    #                     "              98% <= 800.00 milliseconds",
    #                     "              99% <= 900.00 milliseconds",
    #                     "",
    #                     ""
    #            ].join("\n")
    # }


    # it 'reportHistogramWithDisabledAttributes' do
    #     Set<MetricAttribute> disabledMetricAttributes = EnumSet.of(MetricAttribute.MIN, MetricAttribute.MAX, MetricAttribute.STDDEV, MetricAttribute.P95)

    #     final ConsoleReporter customReporter = ConsoleReporter.forRegistry(registry)
    #             .outputTo(output)
    #             .formattedFor(locale)
    #             .withClock(clock)
    #             .formattedFor(timeZone)
    #             .convertRatesTo(TimeUnit.SECONDS)
    #             .convertDurationsTo(TimeUnit.MILLISECONDS)
    #             .filter(MetricFilter.ALL)
    #             .disabledMetricAttributes(disabledMetricAttributes)
    #             .build()

    #     final Histogram histogram = double(Histogram.class)
    #     when(histogram).to receive(:Count()).and_return(1L)

    #     final Snapshot snapshot = double(Snapshot.class)
    #     when(snapshot).to receive(:Max()).and_return(2L)
    #     when(snapshot).to receive(:Mean()).and_return(3.0)
    #     when(snapshot).to receive(:Min()).and_return(4L)
    #     when(snapshot).to receive(:StdDev()).and_return(5.0)
    #     when(snapshot).to receive(:Median()).and_return(6.0)
    #     when(snapshot).to receive(:75thPercentile()).and_return(7.0)
    #     when(snapshot).to receive(:95thPercentile()).and_return(8.0)
    #     when(snapshot).to receive(:98thPercentile()).and_return(9.0)
    #     when(snapshot).to receive(:99thPercentile()).and_return(10.0)
    #     when(snapshot).to receive(:999thPercentile()).and_return(11.0)

    #     when(histogram).to receive(:Snapshot()).and_return(snapshot)

    #     customReporter.report({},
    #             {},
    #             {"test.histogram" => histogram},
    #             {},
    #             {})

    #     expect(output.string).to eq
    #            [
    #                     "3/17/13 6:04:36 PM =============================================================",
    #                     "",
    #                     "-- Histograms ------------------------------------------------------------------",
    #                     "test.histogram",
    #                     "             count = 1",
    #                     "              mean = 3.00",
    #                     "            median = 6.00",
    #                     "              75% <= 7.00",
    #                     "              98% <= 9.00",
    #                     "              99% <= 10.00",
    #                     "            99.9% <= 11.00",
    #                     "",
    #                     ""
    #            ].join("\n")
    # }


end
