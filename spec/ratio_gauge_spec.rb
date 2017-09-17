require 'leafy/core/ratio_gauge'

RSpec.describe Leafy::Core::RatioGauge do

  
    it 'ratiosAreHumanReadable' do
      ratio = Leafy::Core::RatioGauge::Ratio.of(100, 200);

      expect(ratio.to_s).to eq "100.0:200.0"
    end

    
    it 'calculatesTheRatioOfTheNumeratorToTheDenominator' do
        regular = Leafy::Core::RatioGauge.new do
          Leafy::Core::RatioGauge::Ratio.of(2.0, 4.0)
        end

        expect(regular.value).to eq 0.5
    end

    
    it 'handlesDivideByZeroIssues' do
        divByZero = Leafy::Core::RatioGauge.new do
          Leafy::Core::RatioGauge::Ratio.of(100, 0)
        end
        
        expect(divByZero.value.nan?).to eq true
    end

    
    it 'handlesInfiniteDenominators' do
      infinite = Leafy::Core::RatioGauge.new do
        Leafy::Core::RatioGauge::Ratio.of(10, Float::INFINITY)
      end

      expect(infinite.value.nan?).to eq true
    end

    
    it 'handlesNaNDenominators' do
      nan = Leafy::Core::RatioGauge.new do
        Leafy::Core::RatioGauge::Ratio.of(10, Float::NAN)
      end

      expect(nan.value.nan?).to eq true
    end
end
