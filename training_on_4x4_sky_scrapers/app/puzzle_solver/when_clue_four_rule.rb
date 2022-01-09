# frozen_string_literal: true

require_relative 'rule'
class PuzzleSolver
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
end
