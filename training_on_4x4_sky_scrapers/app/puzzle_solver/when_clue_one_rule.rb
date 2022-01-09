# frozen_string_literal: true

require_relative 'rule'
class PuzzleSolver
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
end
