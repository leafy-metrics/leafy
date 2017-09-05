require 'metrics/core/sliding_window_reservoir'

RSpec.describe Metrics::Core::SlidingWindowReservoir do

  let(:reservoir) {  Metrics::Core::SlidingWindowReservoir.new(3) }

  it 'handles small data streams' do
    reservoir.update(1)
    reservoir.update(2)

    expect(reservoir.snapshot.values).to eq [1,2]
  end

  it 'onlyKeepsTheMostRecentFromBigDataStreams' do
    reservoir.update(1)
    reservoir.update(2)
    reservoir.update(3)
    reservoir.update(4)
    
    expect(reservoir.snapshot.values).to eq [2, 3, 4]
  end
end
