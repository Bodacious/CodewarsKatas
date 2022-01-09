# frozen_string_literal: true

require 'spec_helper'
require 'puzzle_solver'
RSpec.describe PuzzleSolver do
  describe '#solve' do
    let(:puzzle_solver) { PuzzleSolver.new(board, *clues) }
    let(:board) { PuzzleBoard.build(4) }
    let(:clues) { Array.new(16) { 0 } }

    subject { puzzle_solver.solve }

    context 'when clues contain a 1' do
      it 'places 4 in the adjacent cell' do
        clues[0] = 1
        subject
        expect(board.entries.first).to eql(4)
      end
      it 'places 4 in the correct cell when vector inverted' do
        [2, 2, 1, 3,
         2, 2, 3, 1,
         1, 2, 2, 3,
         3, 2, 1, 3].each_with_index { |val, i| clues[i] = val }

        subject

        expect(board[0, 2]).to eql(4)
        expect(board[1, 0]).to eql(4)
        expect(board[3, 3]).to eql(4)
      end
    end
    context 'when clues contain a 4' do
      it 'places 1,2,3,4 in the correct vector' do
        clues[5] = 4
        subject
        expect(board.row(1)).to eql(Vector[4, 3, 2, 1])
      end
    end
    context 'when vector has three values' do
      it 'completes the vector' do
        board[0, 1] = 3
        board[1, 1] = 4
        board[2, 1] = nil
        board[3, 1] = 1
        subject
        expect(board[2, 1]).to eql(2)
      end
    end
    context 'when vector has 1 and two clues' do
      it 'completes the vector' do
        board[0, 1] = nil
        board[1, 1] = 2
        board[2, 1] = nil
        board[3, 1] = nil
        clues[1] = 2
        clues[10] = 2
        subject
        expect(board.column(1)).to eql(Vector[3, 2, 4, 1])
      end
    end

    context 'end-to-end' do
      context 'puzzle 1' do
        let(:clues) do
          [0, 0, 1, 2,
           0, 2, 0, 0,
           0, 3, 0, 0,
           0, 1, 0, 0]
        end
        it { is_expected.to be_solved }
      end

      context 'puzzle 2' do
        let(:clues) do
          [2, 2, 1, 3,
           2, 2, 3, 1,
           1, 2, 2, 3,
           3, 2, 1, 3]
        end

        clues = [2, 2, 1, 3,
          2, 2, 3, 1,
          1, 2, 2, 3,
          3, 2, 1, 3]

        it { is_expected.to eql(
          Matrix[
            [1, 3, 4, 2],
            [4, 2, 1, 3],
            [3, 4, 2, 1],
            [2, 1, 3, 4]
          ]) }

      #     2  2  1  3
      #  3 [3, 1, 4, 2], 2
      #  1 [4, 2, 1, 3], 2
      #  2 [2, 4, 3, 1], 3
      #  3 [1, 3, 2, 4]  1
      #     3  2  2  1
      end
    end
  end
end
