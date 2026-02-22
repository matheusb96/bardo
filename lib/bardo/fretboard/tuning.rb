# frozen_string_literal: true

module Bardo
  module Fretboard
    class Tuning
      TUNINGS = {
        standard: %w[E B G D A E],
        drop_d: %w[E B G D A D],
        open_g: %w[D B G D G D],
        open_d: %w[D A F# D A D],
        dadgad: %w[D A G D A D],
        half_down: %w[Eb Bb Gb Db Ab Eb]
      }.freeze

      attr_reader :name, :strings

      def initialize(name = :standard)
        @name = name.to_sym
        @strings = TUNINGS.fetch(@name) do
          raise ArgumentError, "Afinação desconhecida: #{name}. Disponíveis: #{TUNINGS.keys.join(', ')}"
        end
      end

      def string_notes
        strings.map { |s| Theory::Note.new(s) }
      end

      def string_count
        strings.length
      end

      def to_s
        display = name.to_s.tr('_', ' ').capitalize
        "#{display} (#{strings.join(' ')})"
      end

      def self.available
        TUNINGS.keys
      end
    end
  end
end
