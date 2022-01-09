# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PuzzleSolver::WhenVectorMissingOneRule do
  describe '#apply!' do
    let(:board) { PuzzleBoard.build }
    let(:clues) { Array.new(16, 0) }

    subject { described_class.new(board, clues).apply! }

    context 'when column partially complete' do
      it 'populates the missing cell' do
        board[0, 2] = 1
        board[1, 2] = 2
        board[2, 2] = nil
        board[3, 2] = 3
        subject
        expect(board[2, 2]).to eql(4)
      end
    end

    context 'when row partially complete' do
      it 'populates the missing cell' do
        board[3, 0] = nil
        board[3, 1] = 4
        board[3, 2] = 1
        board[3, 3] = 3
        subject
        puts board
        expect(board[3, 0]).to eql(2)
      end
    end
  end
end
