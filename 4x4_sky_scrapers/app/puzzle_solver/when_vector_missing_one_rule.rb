# frozen_string_literal: true

require_relative 'rule'
require './app/core_ext/vector_extension'

class PuzzleSolver
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
end
