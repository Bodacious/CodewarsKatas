# frozen_string_literal: true

require 'timeout'
require_relative 'puzzle_board'
require_relative 'puzzle_solver/when_clue_four_rule'
require_relative 'puzzle_solver/when_clue_one_rule'
require_relative 'puzzle_solver/when_vector_missing_one_rule'
require_relative 'puzzle_solver/when_vector_solvable_rule'
require_relative 'puzzle_solver/when_vector_unsolvable_rule'
require_relative 'puzzle_solver/matches_all_clues_rule'

class PuzzleSolver
  CLUE_COUNT = 16
  DEFAULT_CLUE = 0

  attr_accessor :puzzle_board, :saved_puzzle_board
  attr_reader :clues

  def initialize(puzzle_board, *clues)
    @puzzle_board = puzzle_board
    @clues = (clues + Array.new(CLUE_COUNT, DEFAULT_CLUE)).take(CLUE_COUNT)
  end

  def solve
    Timeout.timeout(5) do
      apply_first_pass_rules
      apply_backtrackable_rules
    end
  end

  private

  def apply_first_pass_rules
    WhenClueOneRule.new(puzzle_board, clues).apply!
    WhenClueFourRule.new(puzzle_board, clues).apply!
  end

  def apply_backtrackable_rules
    self.saved_puzzle_board = puzzle_board.dup
    catch(:backtrack) do
      until puzzle_board.solved?
        WhenVectorMissingOneRule.new(puzzle_board, clues).apply!
        WhenVectorSolveableRule.new(puzzle_board, clues).apply!
        WhenVectorUnsolveableRule.new(puzzle_board, clues).apply!
        MatchesAllCluesRule.new(puzzle_board, clues).apply!
        puts puzzle_board
        throw(:backtrack) if puzzle_board.invalid?
      end
      return puzzle_board
    end
    self.puzzle_board = saved_puzzle_board
    apply_backtrackable_rules
  end
end
