# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PuzzleSolver::WhenVectorSolveableRule do
  describe '#apply!' do
    let(:board) { PuzzleBoard.build }
    let(:clues) { Array.new(16, 0) }

    subject { described_class.new(board, clues).apply! }

    context 'when column partially complete' do
      it 'populates the missing cells' do
        board[0, 2] = 1
        board[1, 2] = nil
        board[2, 2] = nil
        board[3, 2] = 3
        clues[2] = 2
        clues[9] = 2
        subject
        expect(board[1, 2]).to eql(4)
        expect(board[2, 2]).to eql(2)
      end
    end

    context 'when row partially complete' do
      it 'populates the missing cells' do
        board[2, 0] = nil
        board[2, 1] = 2
        board[2, 2] = 4
        board[2, 3] = nil
        clues[6] = 2
        clues[13] = 3
        subject
        expect(board[2, 1]).to eql(2)
        expect(board[2, 2]).to eql(4)
      end
    end
  end
end
