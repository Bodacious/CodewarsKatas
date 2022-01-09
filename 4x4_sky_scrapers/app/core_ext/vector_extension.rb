# frozen_string_literal: true

module VectorExtension
  require_relative 'array_extension'

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
