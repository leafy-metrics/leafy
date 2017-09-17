require 'leafy/core/ewma'

RSpec.describe Leafy::Core::EWMA do

  it 'a one minute EWMA with a value of three' do
    ewma = Leafy::Core::EWMA.oneMinuteEWMA
    ewma.update(3)
    ewma.tick

    expect(Number[ewma.rate]).to eql(Number[0.6, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.22072766, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.08120117, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.02987224, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.01098938, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.00404277, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.00148725, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.00054713, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.00020128, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.00007405, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.00002724, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.00001002, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.00000369, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.00000136, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.00000050, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.00000018, 0.000001])
  end

  it 'a five minute EWMA with a value of three' do
    ewma = Leafy::Core::EWMA.fiveMinuteEWMA
    ewma.update(3)
    ewma.tick

    expect(Number[ewma.rate]).to eql(Number[0.6, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.49123845, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.40219203, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.32928698, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.26959738, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.22072766, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.18071653, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.14795818, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.12113791, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.09917933, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.08120117, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.06648190, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.05443077, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.04456415, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.03648604, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.02987224, 0.000001])
  end

  it 'a fifteen minute EWMA with a value of three' do
    ewma = Leafy::Core::EWMA.fifteenMinuteEWMA
    ewma.update(3)
    ewma.tick

    expect(Number[ewma.rate]).to eql(Number[0.6, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.56130419, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.52510399, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.49123845, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.45955700, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.42991879, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.40219203, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.37625345, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.35198773, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.32928698, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.30805027, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.28818318, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.26959738, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.25221023, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.23594443, 0.000001])

    12.times { ewma.tick }

    expect(Number[ewma.rate]).to eql(Number[0.22072766, 0.000001])
  end
end
