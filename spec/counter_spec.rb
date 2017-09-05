require 'metrics/core/counter'

RSpec.describe Metrics::Core::Counter do

  it 'starts at zero' do
    expect(subject.count).to eq 0
  end

    
  it 'incrementsByOne' do
    subject.inc

    expect(subject.count).to eq 1
  end

    
  it 'incrementsByAnArbitraryDelta' do
    subject.inc(12)

    expect(subject.count).to eq 12
  end

    
  it 'decrementsByOne' do
    subject.dec

    expect(subject.count).to eq -1
  end

    
  it 'decrementsByAnArbitraryDelta' do
    subject.dec(12)

    expect(subject.count).to eq -12
  end

    
  it 'incrementByNegativeDelta' do
    subject.inc(-12)

    expect(subject.count).to eq -12
  end

    
  it 'decrementByNegativeDelta' do
    subject.dec(-12)

    expect(subject.count).to eq 12
  end
end
