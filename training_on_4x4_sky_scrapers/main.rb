# frozen_string_literal: true

# Kata Training on 4 By 4 Skyscrapers:
# https://www.codewars.com/kata/5671d975d81d6c1c87000022/train/ruby

require 'matrix'
require 'timeout'

def solve_puzzle(clues)
  PuzzleSolver.new(PuzzleBoard.build(4), *clues).solve
end

module ArrayExtension
  refine Array do
    def to_vector
      Vector[*self]
    end
  end
end

module VectorExtension
  VALUES = (1..4).to_a
  ALL_PERMUTATIONS = VALUES.permutation(4)

  refine Vector do
    using ArrayExtension

    def invalid?
      return true if repeated_values?
      return true if illegal_values?

      false
    end

    def incomplete?
      nil_entries_count.positive?
    end

    def complete?
      !incomplete?
    end

    def possible_permutations(*clues)
      return [] if complete?
      return all_possible_permutations unless clues.any?(&:positive?)

      if clues.one? || (clues[1]).zero?
        return all_possible_permutations.select do |vector|
          vector.visible_peaks == clues[0]
        end
      end

      if (clues[0]).zero?
        return all_possible_permutations.select do |vector|
          vector.reverse.visible_peaks == clues[1]
        end
      end

      all_possible_permutations.select do |vector|
        vector.visible_peaks == clues[0] && vector.reverse.visible_peaks == clues[1]
      end
    end

    def visible_peaks
      raise StandardError, 'Cannot count peaks for incomplete Vector' if include?(nil)

      max = 0
      count { |i| i > max && max = i }
    end

    def reverse
      Vector[*to_a.reverse]
    end

    def values
      entries.compact
    end

    private

    def illegal_values?
      entries.detect { |val| !VALUES.include?(val) }
    end

    def repeated_values?
      VALUES.detect { |i| entries.count { |e| e == i } > 1 }
    end

    def all_possible_permutations
      ALL_PERMUTATIONS.select do |array|
        values_with_index.all? { |value, index| array[index] == value }
      end.map(&:to_vector)
    end

    def non_nil_values_count
      values.count
    end

    def values_with_index
      entries.map.with_index.reject { |val, _| val.nil? }
    end

    def nil_entries_count
      entries.count(&:nil?)
    end
  end
end
class PuzzleSolver
  CLUE_COUNT = 16
  DEFAULT_CLUE = 0

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

  class WhenClueFourRule < Rule
    def apply!
      if matching_clues.any?
        matching_clues.each do |(_matching_clue, index)|
          puzzle_board.update_vector_at_clue_index(index, 1, 2, 3, 4)
        end
      end
      super
    end

    private

    def matching_clues
      @matching_clues ||= clues.map.with_index.select { |a, _i| a == 4 }
    end
  end

  class WhenClueOneRule < Rule
    def apply!
      if matching_clues.any?
        matching_clues.each do |(_matching_clue, index)|
          puzzle_board.update_cell_at_clue_index(index, 4)
        end
      end
      super
    end

    private

    def matching_clues
      @matching_clues ||= clues.map.with_index.select { |a, _i| a == 1 }
    end
  end

  class WhenVectorMissingOneRule < Rule
    using VectorExtension
    def apply!
      puzzle_board.vectors.each_with_index do |vector, index|
        next unless vector.values.count == 3

        all_values = vector.possible_permutations.first
        puzzle_board.update_vector_at_index(index, *all_values)
      end
      super
    end
  end

  class WhenVectorSolveableRule < Rule
    using VectorExtension
    def apply!
      puzzle_board.vectors.each_with_index do |vector, index|
        perms = vector.possible_permutations(*clue_pair_at_index(index))
        next unless perms.one?

        all_values = perms.first.to_a
        puzzle_board.update_vector_at_index(index, *all_values)
      end
      throw(:backtrack) if puzzle_board.invalid?
      super
    end
  end

  class WhenVectorUnsolveableRule < Rule
    using VectorExtension

    def apply!
      return super() if incomplete_vectors.empty?

      vector, index = most_solvable_vectors.sample
      perms = vector.possible_permutations(*clue_pair_at_index(index))
      return super() if perms.empty?

      selected_perm = perms.sample
      puzzle_board.update_vector_at_index(index, *selected_perm)
      super()
    end

    private

    def incomplete_vectors
      puzzle_board.vectors.each_with_index.select do |vector, _index|
        vector.incomplete?
      end
    end

    def most_solvable_vectors
      incomplete_vectors.sort_by do |vector, index|
        vector.possible_permutations(*clue_pair_at_index(index)).count
      end
    end
  end

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
        throw(:backtrack) if puzzle_board.invalid?
      end
      return puzzle_board
    end
    self.puzzle_board = saved_puzzle_board
    apply_backtrackable_rules
  end
end

class PuzzleBoard < Matrix

  using VectorExtension

  SIZE = 4

  VALUES = (1..SIZE).to_a

  def self.build(rows = SIZE, cols = SIZE)
    super(rows, cols) {} # rubocop:disable Lint/EmptyBlock
  end

  def solved?
    values.sort == (VALUES * SIZE).sort
  end

  def invalid?
    vectors.detect(&:invalid?) || false
  end

  def vectors
    column_vectors + row_vectors
  end

  def update_vector_at_clue_index(clue_index, *values)
    vector = vector_at_clue_index(clue_index)
    vector.to_a.each_index do |index|
      coords = []
      case clue_index
      when 0..3
        coords = [index, clue_index]
      when 4..7
        coords = [clue_index - 4, 3 - index]
      when 8..11
        coords = [3 - index, 11 - clue_index]
      when 12..15
        coords = [15 - clue_index, index]
      end

      update_cell_at_coords(coords, values[index])
    end
  end

  def update_vector_at_index(vector_index, *values)
    if vector_index < SIZE
      coords = values.map.with_index do |value, index|
        coords = [index, vector_index]
        update_cell_at_coords(coords, value)
      end
    else
      values.each_with_index do |value, index|
        coords = [vector_index - SIZE, index]
        update_cell_at_coords(coords, value)
      end
    end
  end

  def update_cell_at_clue_index(clue_index, value)
    coords = cell_at_clue_index(clue_index)
    update_cell_at_coords(coords, value)
  end

  private

  def values
    entries.compact
  end

  def update_cell_at_coords(coords, value)
    self[*coords] ||= value
  end

  def vector_at_index(vector_index)
    vectors[vector_index]
  end

  def vector_at_clue_index(clue_index)
    case clue_index
    when 0..3   then column(clue_index)
    when 4..7   then row(clue_index - SIZE)
    when 8..11  then column(11 - clue_index)
    when 12..15 then row(15 - clue_index)
    else
      raise "Invalid clue index: #{clue_index}"
    end
  end

  def cell_at_clue_index(clue_index)
    case clue_index
    when 0..3 then [0, clue_index]
    when 4..7 then [(clue_index - column_count), column_count - 1]
    when 8..11 then [row_count - 1, 11 - clue_index]
    when 12..15 then [15 - clue_index, 0]
    end
  end
end



clues = [2, 2, 1, 3,
         2, 2, 3, 1,
         1, 2, 2, 3,
         3, 2, 1, 3]

expected = [[1, 3, 4, 2],
            [4, 2, 1, 3],
            [3, 4, 2, 1],
            [2, 1, 3, 4]]

puts solve_puzzle(clues)
