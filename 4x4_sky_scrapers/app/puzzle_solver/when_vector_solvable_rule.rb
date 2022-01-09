# frozen_string_literal: true

class PuzzleSolver
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
end
