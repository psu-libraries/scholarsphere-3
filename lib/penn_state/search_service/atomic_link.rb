# frozen_string_literal: true

module PennState::SearchService
  class AtomicLink < OpenStruct
    def to_s
      href
    end
  end
end
