require 'leafy/core/meter'

RSpec.describe Leafy::Core::Meter do

  let(:clock) do
    clock = Leafy::Core::Clock.new
    def clock.tick      
      @ticks ||= [0, 0] + [10000000000] * 10
      @ticks.shift
    end
    clock
  end

  let(:meter) {  Leafy::Core::Meter.new(clock) }

  it 'starts out with no rates or count' do
    expect(meter.count).to eq 0

    expect(meter.mean_rate).to eq 0

    expect(meter.one_minute_rate).to eq 0

    expect(meter.five_minute_rate).to eq 0

    expect(meter.fifteen_minute_rate).to eq 0
  end

  it 'marksEventsAndUpdatesRatesAndCount' do
    meter.mark
    meter.mark(2)

    expect(meter.mean_rate).to eq 0.3

    expect(Number[meter.one_minute_rate]).to eql Number[0.1840, 0.1]

    expect(Number[meter.five_minute_rate]).to eql Number[0.1966, 0.1]

    expect(Number[meter.fifteen_minute_rate]).to eql Number[0.1988, 0.1]
  end
end
