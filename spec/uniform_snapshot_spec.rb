require 'metrics/core/sliding_window_reservoir'

RSpec.describe Metrics::Core::UniformSnapshot do

  let(:snapshot) {  Metrics::Core::UniformSnapshot.new(5, 1, 2, 3, 4) }
  let(:empty_snapshot) { subject }
  
  it 'smallQuantilesAreTheFirstValue' do
    expect(Number[snapshot.value(0.0)]).to eql Number[1, 0.1]
  end

  
  it 'bigQuantilesAreTheLastValue' do
    expect(Number[snapshot.value(1.0)]).to eql Number[5, 0.1]
  end

  it 'disallowsNotANumberQuantile' do
    expect { snapshot.value('asd') }.to raise_error ArgumentError 
  end

  it 'disallowsNegativeQuantile' do
    expect { snapshot.value(-0.5) }.to raise_error ArgumentError 
  end

  it 'disallowsQuantileOverOne' do
    expect { snapshot.value(1.5) }.to raise_error ArgumentError 
  end

  
  it 'hasAMedian' do
    expect(Number[snapshot.median]).to eql Number[3, 0.1]
  end

  
  it 'hasAp75' do
    expect(Number[snapshot.get_75th_percentile]).to eql Number[4.5, 0.1]
  end

  
  it 'hasAp95' do
    expect(Number[snapshot.get_95th_percentile]).to eql Number[5.0, 0.1]
  end

  
  it 'hasAp98' do
    expect(Number[snapshot.get_98th_percentile]).to eql Number[5.0, 0.1]
  end

  
  it 'hasAp99' do
    expect(Number[snapshot.get_99th_percentile]).to eql Number[5.0, 0.1]
  end

  
  it 'hasAp999' do
    expect(Number[snapshot.get_999th_percentile]).to eql Number[5.0, 0.1]
  end

  
  it 'hasValues' do
    expect(snapshot.values).to match_array [1,2,3,4,5]
  end

  
  it 'hasASize' do
    expect(snapshot.size).to eq 5
  end


  
  it 'dumpsToAStream' do
    output = StringIO.new
    
    snapshot.dump(output);

    expect(output.string).to eq "1\n2\n3\n4\n5\n"
  end

  
  it 'calculatesTheMinimumValue' do
    expect(snapshot.min).to eq 1
  end

  
  it 'calculatesTheMaximumValue' do
    expect(snapshot.max).to eq 5
  end

  
  it 'calculatesTheMeanValue' do
    expect(snapshot.mean).to eq 3.0
  end

  
  it 'calculatesTheStdDev' do
    expect(Number[snapshot.std_dev]).to eql Number[1.5811, 0.01]
  end

  
  it 'calculatesAMinOfZeroForAnEmptySnapshot' do
    expect(empty_snapshot.min).to eq 0.0
  end

  
  it 'calculatesAMaxOfZeroForAnEmptySnapshot' do
    expect(empty_snapshot.max).to eq 0.0
  end

  
  it 'calculatesAMeanOfZeroForAnEmptySnapshot' do
    expect(empty_snapshot.mean).to eq 0.0
  end

  
  it 'calculatesAStdDevOfZeroForAnEmptySnapshot' do
    expect(empty_snapshot.std_dev).to eq 0.0
  end

  
  it 'calculatesAStdDevOfZeroForASingletonSnapshot' do
    singleItemSnapshot = Metrics::Core::UniformSnapshot.new(1)

    expect(singleItemSnapshot.std_dev).to eq 0.0
  end

end
