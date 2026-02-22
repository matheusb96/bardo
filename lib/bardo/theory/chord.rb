# frozen_string_literal: true

module Bardo
  module Theory
    class Chord
      FORMULAS = {
        major: [0, 4, 7],
        minor: [0, 3, 7],
        dim: [0, 3, 6],
        aug: [0, 4, 8],
        sus2: [0, 2, 7],
        sus4: [0, 5, 7],
        maj7: [0, 4, 7, 11],
        min7: [0, 3, 7, 10],
        dom7: [0, 4, 7, 10],
        dim7: [0, 3, 6, 9],
        min7b5: [0, 3, 6, 10],
        aug7: [0, 4, 8, 10],
        maj9: [0, 4, 7, 11, 14],
        min9: [0, 3, 7, 10, 14],
        dom9: [0, 4, 7, 10, 14]
      }.freeze

      SUFFIXES = {
        major: '',    minor: 'm', dim: 'dim', aug: 'aug',
        sus2: 'sus2', sus4: 'sus4',
        maj7: 'maj7', min7: 'm7', dom7: '7',
        dim7: 'dim7', min7b5: 'm7b5', aug7: 'aug7',
        maj9: 'maj9', min9: 'm9', dom9: '9'
      }.freeze

      DESCRIPTIONS = {
        major: 'Maior - som alegre, estável',
        minor: 'Menor - som triste, melancólico',
        dim: 'Diminuto - som tenso, instável',
        aug: 'Aumentado - som misterioso, suspense',
        sus2: 'Suspensa 2 - som aberto, nem maior nem menor',
        sus4: 'Suspensa 4 - tensão que quer resolver',
        maj7: 'Maior com 7a maior - sofisticado, jazz/bossa',
        min7: 'Menor com 7a menor - suave, jazz',
        dom7: 'Dominante (7) - tensão, quer resolver',
        dim7: 'Diminuto com 7a - muito tenso, simétrico',
        min7b5: 'Meio-diminuto - ii do campo menor, jazz',
        aug7: 'Aumentado com 7a - dominante alterado',
        maj9: 'Maior com 9a - sofisticado, neo-soul',
        min9: 'Menor com 9a - suave, R&B/jazz',
        dom9: 'Dominante com 9a - funky, groovy'
      }.freeze

      # Regex to parse chord symbols like Am7, C#maj7, Bbdim, G7, Fsus4
      CHORD_REGEX = /\A([A-G][#b]?)(m7b5|maj7|maj9|min7|min9|dim7|aug7|sus[24]|dom[79]|m7|m9|m|dim|aug|7|9)?\z/

      attr_reader :root, :type

      def initialize(root_or_symbol, type = nil)
        if type
          @root = root_or_symbol.is_a?(Note) ? root_or_symbol : Note.new(root_or_symbol)
          @type = type.to_sym
        else
          @root, @type = self.class.parse_symbol(root_or_symbol)
        end

        raise ArgumentError, "Tipo de acorde desconhecido: #{@type}" unless FORMULAS.key?(@type)
      end

      def notes
        use_flats = Note::FLAT_KEYS.include?(root.name) || root.flat?
        formula.map do |semitones|
          note = root + semitones
          Note.new(note.display_name(use_flats: use_flats))
        end
      end

      def note_names
        notes.map(&:to_s)
      end

      def formula
        FORMULAS[type]
      end

      def intervals
        formula.map { |s| Interval.new(s) }
      end

      def interval_names
        intervals.map(&:short_name)
      end

      def suffix
        SUFFIXES[type]
      end

      def symbol
        "#{root}#{suffix}"
      end

      def description
        DESCRIPTIONS[type]
      end

      def triad?
        formula.length == 3
      end

      def tetrad?
        formula.length == 4
      end

      def major?
        %i[major maj7 maj9].include?(type)
      end

      def minor?
        %i[minor min7 min9 min7b5].include?(type)
      end

      def dominant?
        %i[dom7 dom9].include?(type)
      end

      def diminished?
        %i[dim dim7].include?(type)
      end

      # Suggest scales that work well over this chord
      def suggested_scales
        suggestions = []

        case type
        when :major, :maj7, :maj9
          suggestions << Scale.new(root, :major)
          suggestions << Scale.new(root, :lydian)
          suggestions << Scale.new(root, :pentatonic_major)
          suggestions << Scale.new(root, :ionian)
        when :minor, :min7, :min9
          suggestions << Scale.new(root, :minor)
          suggestions << Scale.new(root, :dorian)
          suggestions << Scale.new(root, :pentatonic_minor)
          suggestions << Scale.new(root, :blues)
          suggestions << Scale.new(root, :aeolian)
        when :dom7, :dom9
          suggestions << Scale.new(root, :mixolydian)
          suggestions << Scale.new(root, :pentatonic_minor)
          suggestions << Scale.new(root, :blues)
        when :dim, :dim7
          suggestions << Scale.new(root, :locrian)
        when :min7b5
          suggestions << Scale.new(root, :locrian)
        when :sus4, :sus2
          suggestions << Scale.new(root, :mixolydian)
          suggestions << Scale.new(root, :pentatonic_major)
        when :aug, :aug7
          suggestions << Scale.new(root, :melodic_minor)
        end

        suggestions
      end

      def to_s
        symbol
      end

      def ==(other)
        return false unless other.is_a?(Chord)

        root == other.root && type == other.type
      end

      def self.parse_symbol(symbol)
        match = symbol.to_s.match(CHORD_REGEX)
        raise ArgumentError, "Símbolo de acorde inválido: #{symbol}" unless match

        root = Note.new(match[1])
        type = parse_type(match[2])
        [root, type]
      end

      def self.available_types
        FORMULAS.keys
      end

      def self.parse_type(suffix)
        return :major if suffix.nil? || suffix.empty?

        type_map = {
          'm' => :minor, 'm7' => :min7, 'm9' => :min9,
          '7' => :dom7, '9' => :dom9,
          'maj7' => :maj7, 'maj9' => :maj9,
          'min7' => :min7, 'min9' => :min9,
          'dim' => :dim, 'dim7' => :dim7,
          'aug' => :aug, 'aug7' => :aug7,
          'm7b5' => :min7b5,
          'sus2' => :sus2, 'sus4' => :sus4,
          'dom7' => :dom7, 'dom9' => :dom9
        }

        type_map[suffix] || raise(ArgumentError, "Sufixo de acorde desconhecido: #{suffix}")
      end

      private_class_method :parse_type
    end
  end
end
