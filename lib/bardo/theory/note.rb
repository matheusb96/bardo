# frozen_string_literal: true

module Bardo
  module Theory
    class Note
      SHARPS = %w[C C# D D# E F F# G G# A A# B].freeze
      FLATS  = %w[C Db D Eb E F Gb G Ab A Bb B].freeze

      ENHARMONIC = {
        'C#' => 'Db', 'Db' => 'C#',
        'D#' => 'Eb', 'Eb' => 'D#',
        'F#' => 'Gb', 'Gb' => 'F#',
        'G#' => 'Ab', 'Ab' => 'G#',
        'A#' => 'Bb', 'Bb' => 'A#'
      }.freeze

      # Keys that conventionally use flats
      FLAT_KEYS = %w[F Bb Eb Ab Db Gb Dm Gm Cm Fm Bbm Ebm].freeze

      attr_reader :name

      def initialize(name)
        normalized = normalize(name)
        raise ArgumentError, "Nota inválida: #{name}" unless valid?(normalized)

        @name = normalized
      end

      def semitones_from_c
        index_in(SHARPS) || index_in(FLATS)
      end

      def +(other)
        idx = (semitones_from_c + other) % 12
        self.class.new(SHARPS[idx])
      end

      def -(other)
        case other
        when Integer
          self + (-other)
        when Note
          (semitones_from_c - other.semitones_from_c) % 12
        else
          raise ArgumentError, "Esperado Integer ou Note, recebido #{other.class}"
        end
      end

      def distance_to(other)
        other = self.class.new(other) if other.is_a?(String)
        (other.semitones_from_c - semitones_from_c) % 12
      end

      def enharmonic
        ENHARMONIC[name] ? self.class.new(ENHARMONIC[name]) : self
      end

      def natural?
        name.length == 1
      end

      def sharp?
        name.include?('#')
      end

      def flat?
        name.include?('b')
      end

      def to_s
        name
      end

      def ==(other)
        return false unless other.is_a?(Note)

        semitones_from_c == other.semitones_from_c
      end

      def eql?(other)
        self == other
      end

      def hash
        semitones_from_c.hash
      end

      # Display name using flats or sharps based on key context
      def display_name(use_flats: false)
        if use_flats
          FLATS[semitones_from_c]
        else
          SHARPS[semitones_from_c]
        end
      end

      def self.all(representation: :sharps)
        (representation == :flats ? FLATS : SHARPS).map { |n| new(n) }
      end

      def self.parse(name)
        new(name)
      end

      private

      def normalize(name)
        return name if name.nil? || name.empty?

        # Capitalize first letter, keep rest as-is
        name = name.strip
        name[0].upcase + name[1..].to_s
      end

      def valid?(name)
        SHARPS.include?(name) || FLATS.include?(name)
      end

      def index_in(notes)
        notes.index(name) || notes.index(ENHARMONIC[name])
      end
    end
  end
end
