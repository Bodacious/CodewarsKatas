# frozen_string_literal: true

require 'matrix'
class PuzzleBoard < Matrix
  require './app/core_ext/vector_extension'

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
