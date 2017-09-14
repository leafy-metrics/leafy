require 'metrics/core/ratio_gauge'

RSpec.describe Metrics::Core::RatioGauge do

  
    it 'ratiosAreHumanReadable' do
      ratio = Metrics::Core::RatioGauge::Ratio.of(100, 200);

      expect(ratio.to_s).to eq "100.0:200.0"
    end

    
    it 'calculatesTheRatioOfTheNumeratorToTheDenominator' do
        regular = Metrics::Core::RatioGauge.new do
          Metrics::Core::RatioGauge::Ratio.of(2.0, 4.0)
        end

        expect(regular.value).to eq 0.5
    end

    
    it 'handlesDivideByZeroIssues' do
        divByZero = Metrics::Core::RatioGauge.new do
          Metrics::Core::RatioGauge::Ratio.of(100, 0)
        end
        
        expect(divByZero.value.nan?).to eq true
    end

    
    it 'handlesInfiniteDenominators' do
      infinite = Metrics::Core::RatioGauge.new do
        Metrics::Core::RatioGauge::Ratio.of(10, Float::INFINITY)
      end

      expect(infinite.value.nan?).to eq true
    end

    
    it 'handlesNaNDenominators' do
      nan = Metrics::Core::RatioGauge.new do
        Metrics::Core::RatioGauge::Ratio.of(10, Float::NAN)
      end

      expect(nan.value.nan?).to eq true
    end
end
