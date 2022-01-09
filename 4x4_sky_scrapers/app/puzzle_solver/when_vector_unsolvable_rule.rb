# frozen_string_literal: true

require './app/core_ext/vector_extension'
class PuzzleSolver
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
end
