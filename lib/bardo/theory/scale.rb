# frozen_string_literal: true

module Bardo
  module Theory
    class Scale
      FORMULAS = {
        major: [0, 2, 4, 5, 7, 9, 11],
        minor: [0, 2, 3, 5, 7, 8, 10],
        harmonic_minor: [0, 2, 3, 5, 7, 8, 11],
        melodic_minor: [0, 2, 3, 5, 7, 9, 11],
        pentatonic_major: [0, 2, 4, 7, 9],
        pentatonic_minor: [0, 3, 5, 7, 10],
        blues: [0, 3, 5, 6, 7, 10],
        # Modos gregos
        ionian: [0, 2, 4, 5, 7, 9, 11],
        dorian: [0, 2, 3, 5, 7, 9, 10],
        phrygian: [0, 1, 3, 5, 7, 8, 10],
        lydian: [0, 2, 4, 6, 7, 9, 11],
        mixolydian: [0, 2, 4, 5, 7, 9, 10],
        aeolian: [0, 2, 3, 5, 7, 8, 10],
        locrian: [0, 1, 3, 5, 6, 8, 10]
      }.freeze

      DESCRIPTIONS = {
        major: 'Escala Maior (Jônica) - alegre, brilhante',
        minor: 'Escala Menor Natural (Eólia) - triste, melancólica',
        harmonic_minor: 'Menor Harmônica - som árabe/clássico, V7 funciona',
        melodic_minor: 'Menor Melódica - jazz, suave',
        pentatonic_major: 'Pentatônica Maior - country, pop, safe choice',
        pentatonic_minor: 'Pentatônica Menor - rock, blues, a queridinha da improvisação',
        blues: 'Blues - pentatônica menor + blue note (b5)',
        ionian: 'Jônico (= Maior) - base de tudo, som alegre',
        dorian: 'Dórico - menor com 6a maior, som de Santana/jazz funk',
        phrygian: 'Frígio - som espanhol/flamenco, tensão',
        lydian: 'Lídio - maior com #4, som sonhador/etéreo',
        mixolydian: 'Mixolídio - maior com b7, som de blues/rock/dominante',
        aeolian: 'Eólio (= Menor Natural) - triste, melancólico',
        locrian: 'Lócrio - instável, usado sobre m7b5'
      }.freeze

      STEP_PATTERNS = {
        major: 'T T ST T T T ST',
        minor: 'T ST T T ST T T',
        harmonic_minor: 'T ST T T ST 1½T ST',
        melodic_minor: 'T ST T T T T ST',
        pentatonic_major: 'T T 1½T T 1½T',
        pentatonic_minor: '1½T T T 1½T T',
        blues: '1½T T ST ST 1½T T'
      }.freeze

      attr_reader :root, :type

      def initialize(root, type = :major)
        @root = root.is_a?(Note) ? root : Note.new(root)
        @type = type.to_sym
        raise ArgumentError, "Escala desconhecida: #{type}" unless FORMULAS.key?(@type)
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

      def description
        DESCRIPTIONS[type]
      end

      def step_pattern
        STEP_PATTERNS[type]
      end

      def degree(n)
        raise ArgumentError, "Grau deve ser entre 1 e #{notes.length}" unless n.between?(1, notes.length)

        notes[n - 1]
      end

      def includes?(note)
        note = Note.new(note) if note.is_a?(String)
        notes.any? { |n| n == note }
      end

      def intervals
        formula.map { |s| Interval.new(s) }
      end

      def to_s
        "#{root} #{type}: #{note_names.join(' - ')}"
      end

      # Find scales that contain all given notes
      def self.find_matching(notes, root: nil)
        notes = notes.map { |n| n.is_a?(Note) ? n : Note.new(n) }
        roots = if root
                  [root.is_a?(Note) ? root : Note.new(root)]
                else
                  Note.all
                end

        results = []
        roots.each do |r|
          FORMULAS.each_key do |type|
            scale = new(r, type)
            results << scale if notes.all? { |n| scale.includes?(n) }
          end
        end
        results
      end

      def self.available_types
        FORMULAS.keys
      end
    end
  end
end
