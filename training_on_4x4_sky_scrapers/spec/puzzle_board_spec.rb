# frozen_string_literal: true

require 'spec_helper'
require './app/puzzle_board'

RSpec.describe PuzzleBoard do
  describe '#update_vector_at_clue_index' do
    let(:puzzle_board) { PuzzleBoard.build(4) }

    context 'when index is 0..3' do
      before do
        puzzle_board.update_vector_at_clue_index(1, 1, 2, 3, 4)
      end
      it 'updates the row in the same order' do
        expect(puzzle_board[0, 1]).to eql(1)
        expect(puzzle_board[1, 1]).to eql(2)
        expect(puzzle_board[2, 1]).to eql(3)
        expect(puzzle_board[3, 1]).to eql(4)
      end
    end

    context 'when index is 4..7' do
      before do
        puzzle_board.update_vector_at_clue_index(5, 1, 2, 3, 4)
      end

      it 'updates the row in reverse order' do
        expect(puzzle_board[1, 0]).to eql(4)
        expect(puzzle_board[1, 1]).to eql(3)
        expect(puzzle_board[1, 2]).to eql(2)
        expect(puzzle_board[1, 3]).to eql(1)
      end
    end

    context 'when index is 8..11' do
      before do
        puzzle_board.update_vector_at_clue_index(9, 1, 2, 3, 4)
      end

      it 'updates the row in the same order' do
        expect(puzzle_board[3, 2]).to eql(1)
        expect(puzzle_board[2, 2]).to eql(2)
        expect(puzzle_board[1, 2]).to eql(3)
        expect(puzzle_board[0, 2]).to eql(4)
      end
    end

    context 'when index is 12..15' do
      before do
        puzzle_board.update_vector_at_clue_index(15, 1, 2, 3, 4)
      end

      it 'updates the row in the same order' do
        expect(puzzle_board[0, 0]).to eql(1)
        expect(puzzle_board[0, 1]).to eql(2)
        expect(puzzle_board[0, 2]).to eql(3)
        expect(puzzle_board[0, 3]).to eql(4)
      end
    end
  end
end
