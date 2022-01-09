# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VectorExtension do
  using VectorExtension

  describe '#visible_peaks' do
    subject { vector.visible_peaks }

    context 'when vector starts with 4' do
      let(:vector) { Vector[4, 3, 2, 1] }

      it { is_expected.to eql(1) }
    end
    context 'when vector is 1,2,3,4' do
      let(:vector) { Vector[1, 2, 3, 4] }

      it { is_expected.to eql(4) }
    end
    context 'when vector is 2,1,3,4' do
      let(:vector) { Vector[2, 1, 3, 4] }

      it { is_expected.to eql(3) }
    end

    context 'when vector is incomplete' do
      let(:vector) { Vector[2, 1, 3, nil] }

      it { expect { subject }.to raise_error(StandardError) }
    end
  end

  describe '#possible_permutations' do
    context 'when complete' do
      it 'returns empty Array' do
        vector = Vector[1, 2, 3, 4]
        expect(vector.possible_permutations).to eql([])
      end
    end

    context 'when one missing value' do
      it 'returns one result' do
        vector = Vector[1, 2, 3, nil]
        expect(vector.possible_permutations).to eql([Vector[1, 2, 3, 4]])
      end
    end

    context 'when two missing values' do
      it 'returns two possible results' do
        vector = Vector[nil, 2, 3, nil]
        results = vector.possible_permutations
        expect(results.count).to eql(2)
        expect(results).to include(Vector[1, 2, 3, 4])
        expect(results).to include(Vector[4, 2, 3, 1])
      end
    end

    context 'when three missing values' do
      it 'returns nine possible results' do
        vector = Vector[nil, 2, nil, nil]
        results = vector.possible_permutations
        expect(results).to include(Vector[1, 2, 3, 4])
        expect(results).to include(Vector[1, 2, 4, 3])
        expect(results).to include(Vector[3, 2, 4, 1])
        expect(results).to include(Vector[3, 2, 1, 4])
        expect(results).to include(Vector[4, 2, 1, 3])
        expect(results).to include(Vector[4, 2, 3, 1])
        expect(results.count).to eql(6)
      end
    end
    context 'when has one clue' do
      it 'returns possible results' do
        vector = Vector[nil, 2, nil, nil]
        results = vector.possible_permutations(2)
        expect(results).to include(Vector[3, 2, 4, 1])
        expect(results).to include(Vector[3, 2, 1, 4])
        expect(results.count).to eql(2)
      end
      it 'returns one possible results' do
        vector = Vector[nil, 2, nil, nil]
        results = vector.possible_permutations(1)
        expect(results).to include(Vector[4, 2, 1, 3])
        expect(results).to include(Vector[4, 2, 3, 1])
        expect(results.count).to eql(2)
      end
      it 'ignores zero clues' do
        vector = Vector[nil, 2, nil, nil]
        results = vector.possible_permutations(0)
        expect(results).to include(Vector[1, 2, 3, 4])
        expect(results).to include(Vector[1, 2, 4, 3])
        expect(results).to include(Vector[1, 2, 4, 3])
        expect(results).to include(Vector[3, 2, 1, 4])
        expect(results).to include(Vector[4, 2, 1, 3])
        expect(results).to include(Vector[4, 2, 3, 1])
        expect(results.count).to eql(6)
      end
    end
    context 'when has two clues' do
      it 'returns possible results' do
        vector = Vector[nil, 2, nil, nil]
        results = vector.possible_permutations(2, 2)
        expect(results).to include(Vector[3, 2, 4, 1])
        expect(results.count).to eql(1)
      end
    end
  end
end
