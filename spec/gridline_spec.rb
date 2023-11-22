require 'spec_helper'

describe Squid::Gridline do
  let(:height) { 100 }
  let(:steps) { 4 }
  let(:skip_baseline) { false }

  describe '.for' do
    subject(:gridlines) { Squid::Gridline.for(height: height, skip_baseline: skip_baseline, steps: steps) }

    it 'returns +count+ instances, with vertically distributed y between 0 and height' do
      expect(gridlines.map &:y).to eq [100.0, 75.0, 50.0, 25.0, 0.0]
    end

    describe 'given skip_baseline: true' do
      let(:skip_baseline) { true }
      it 'skips the last line' do
        expect(gridlines.map &:y).to eq [100.0, 75.0, 50.0, 25.0]
      end
    end

    describe "With verbatim steps" do
      let(:steps) { [90, 4, 3] }
      it "uses given steps" do
        expect(gridlines.map(&:y)).to eq([100.0, 1.1494252873563218, 0.0])
      end
    end
  end
end
