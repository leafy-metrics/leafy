require 'leafy/core/histogram'

RSpec.describe Leafy::Core::Histogram do

  let(:reservoir) do
    reservoir = double('Reservoir')
    allow(reservoir).to receive(:update).with(100)
    reservoir
  end

  let(:histogram) {  Leafy::Core::Histogram.new(reservoir) }

  it 'updatesTheCountOnUpdates' do
    expect(histogram.count).to eq 0

    histogram.update(100);

    expect(histogram.count).to eq 1
  end
end
