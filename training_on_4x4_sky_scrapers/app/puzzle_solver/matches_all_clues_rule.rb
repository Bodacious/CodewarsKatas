class PuzzleSolver
  class MatchesAllCluesRule < Rule
    using VectorExtension

    def apply!
      puzzle_board.vectors.each_with_index do |vector, index|
        clues = clue_pair_at_index(index)
        next if vector.incomplete?
        next if clues.all?(&:zero?)
        next if vector_matches_clues?(vector, clues)

        throw(:backtrack)
      end
      super
    end

    private

    def vector_matches_clues?(vector, clues)
      (clues[0].zero? || vector.visible_peaks == clues[0]) &&
        (clues[1].zero? || vector.reverse.visible_peaks == clues[1])
    end
  end
end