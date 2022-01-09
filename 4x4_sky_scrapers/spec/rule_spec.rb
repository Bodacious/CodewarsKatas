# frozen_string_literal: true

require 'spec_helper'
require 'puzzle_solver/rule'
RSpec.describe PuzzleSolver::Rule do
  describe '#cell_pair_and_index' do
    let(:board) { PuzzleBoard.build(4) }
    let(:clues) { (1..16).to_a }
    it 'returns the correct pair' do
      expect(described_class.new(board, clues).clue_pair_at_index(0)).to eql([1, 12])
      expect(described_class.new(board, clues).clue_pair_at_index(1)).to eql([2, 11])
      expect(described_class.new(board, clues).clue_pair_at_index(2)).to eql([3, 10])
      expect(described_class.new(board, clues).clue_pair_at_index(3)).to eql([4, 9])

      expect(described_class.new(board, clues).clue_pair_at_index(4)).to eql([16, 5])
      expect(described_class.new(board, clues).clue_pair_at_index(5)).to eql([15, 6])
      expect(described_class.new(board, clues).clue_pair_at_index(6)).to eql([14, 7])
      expect(described_class.new(board, clues).clue_pair_at_index(7)).to eql([13, 8])
    end
  end
end
