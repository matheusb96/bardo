# frozen_string_literal: true

module Bardo
  module Theory
    class HarmonicField
      TRIAD_TYPES = {
        major: %i[major minor minor major major minor dim],
        minor: %i[minor dim major minor minor major major]
      }.freeze

      TETRAD_TYPES = {
        major: %i[maj7 min7 min7 maj7 dom7 min7 min7b5],
        minor: %i[min7 min7b5 maj7 min7 min7 maj7 dom7]
      }.freeze

      ROMAN_NUMERALS = %w[I II III IV V VI VII].freeze

      FUNCTIONS = {
        major: ['Tônica', 'Subdominante', 'Tônica (mediante)', 'Subdominante', 'Dominante', 'Tônica relativa',
                'Dominante'],
        minor: ['Tônica', 'Subdominante', 'Tônica relativa', 'Subdominante', 'Dominante', 'Subdominante (submed.)',
                'Dominante (subtônica)']
      }.freeze

      MODES_BY_DEGREE = {
        major: %i[ionian dorian phrygian lydian mixolydian aeolian locrian],
        minor: %i[aeolian locrian ionian dorian phrygian lydian mixolydian]
      }.freeze

      attr_reader :root, :mode

      def initialize(root, mode = :major)
        @root = root.is_a?(Note) ? root : Note.new(root)
        @mode = mode.to_sym
        raise ArgumentError, 'Modo deve ser :major ou :minor' unless %i[major minor].include?(@mode)
      end

      def scale
        @scale ||= Scale.new(root, mode == :major ? :major : :minor)
      end

      def triads
        scale.notes.each_with_index.map do |note, i|
          Chord.new(note, TRIAD_TYPES[mode][i])
        end
      end

      def tetrads
        scale.notes.each_with_index.map do |note, i|
          Chord.new(note, TETRAD_TYPES[mode][i])
        end
      end

      def degree(n)
        raise ArgumentError, 'Grau deve ser entre 1 e 7' unless n.between?(1, 7)

        {
          degree: n,
          numeral: roman_numeral(n),
          triad: triads[n - 1],
          tetrad: tetrads[n - 1],
          function: FUNCTIONS[mode][n - 1],
          scale_note: scale.degree(n),
          mode: mode_for_degree(n)
        }
      end

      def mode_for_degree(n)
        raise ArgumentError, 'Grau deve ser entre 1 e 7' unless n.between?(1, 7)

        mode_type = MODES_BY_DEGREE[mode][n - 1]
        Scale.new(scale.degree(n), mode_type)
      end

      def chords_data
        (1..7).map { |n| degree(n) }
      end

      def roman_numeral(n)
        chord_type = TRIAD_TYPES[mode][n - 1]
        numeral = ROMAN_NUMERALS[n - 1]

        case chord_type
        when :minor, :min7, :min7b5
          numeral.downcase
        when :dim
          "#{numeral.downcase}°"
        else
          numeral
        end
      end

      # Given a progression of chords, try to identify the key
      def self.identify_key(chord_symbols)
        chords = chord_symbols.map { |s| Chord.new(s) }
        candidates = []

        Note.all.each do |root|
          %i[major minor].each do |m|
            field = new(root, m)
            field_chords = field.triads + field.tetrads
            field_notes = field_chords.map { |c| [c.root.semitones_from_c, c.type] }

            match_count = chords.count do |chord|
              field_notes.include?([chord.root.semitones_from_c, chord.type])
            end

            if match_count.positive?
              candidates << { key: "#{root} #{m == :major ? 'Maior' : 'Menor'}", root: root, mode: m,
                              matches: match_count, field: field }
            end
          end
        end

        candidates.sort_by { |c| -c[:matches] }
      end

      def to_s
        mode_name = mode == :major ? 'Maior' : 'Menor'
        "Campo Harmônico de #{root} #{mode_name}"
      end
    end
  end
end
