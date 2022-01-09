# frozen_string_literal: true

class PuzzleSolver
  class Rule
    attr_reader :clues, :puzzle_board

    def initialize(puzzle_board, clues)
      @puzzle_board = puzzle_board
      @clues = clues
    end

    def clue_pair_at_index(index)
      case index
      when 0..3 then [clues[index], clues[11 - index]]
      when 4..7 then [clues[19 - index], clues[index]]
      else
        raise StandardError, "Cannot return clue pair outside of range 0..7 (was: #{index})"
      end
    end

    def apply!
      puzzle_board
    end
  end
end
