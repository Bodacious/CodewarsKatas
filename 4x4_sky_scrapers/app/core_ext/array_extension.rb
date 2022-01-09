# frozen_string_literal: true

module ArrayExtension
  refine Array do
    def to_vector
      Vector[*self]
    end
  end
end
