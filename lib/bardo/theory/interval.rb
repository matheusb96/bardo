# frozen_string_literal: true

module Bardo
  module Theory
    class Interval
      INTERVALS = {
        0 => { name: 'Uníssono', short: '1', type: :perfect },
        1 => { name: 'Segunda menor', short: 'b2', type: :minor },
        2 => { name: 'Segunda maior', short: '2', type: :major },
        3 => { name: 'Terça menor', short: 'b3', type: :minor },
        4 => { name: 'Terça maior', short: '3', type: :major },
        5 => { name: 'Quarta justa', short: '4', type: :perfect },
        6 => { name: 'Trítono', short: 'b5', type: :augmented },
        7 => { name: 'Quinta justa', short: '5', type: :perfect },
        8 => { name: 'Sexta menor', short: 'b6', type: :minor },
        9 => { name: 'Sexta maior', short: '6', type: :major },
        10 => { name: 'Sétima menor', short: 'b7', type: :minor },
        11 => { name: 'Sétima maior', short: '7', type: :major }
      }.freeze

      # Song examples for ear training - Brazilian and international references
      SONG_EXAMPLES = {
        0 => 'mesma nota repetida',
        1 => 'Tubarão (Jaws) - duas primeiras notas',
        2 => "Parabéns pra Você - 'Para' até 'béns'",
        3 => 'Smoke on the Water - início do riff',
        4 => 'Oh When the Saints - duas primeiras notas',
        5 => 'Marcha Nupcial (casamento) - primeiras notas',
        6 => "Os Simpsons - 'The Simp...'",
        7 => 'Star Wars - início do tema',
        8 => 'Love Story - tema principal',
        9 => "My Way - 'And now...'",
        10 => 'Tema de Star Trek - primeiras notas',
        11 => "Take On Me - 'Take on...' no refrão"
      }.freeze

      attr_reader :semitones

      def initialize(semitones)
        @semitones = semitones % 12
      end

      def name
        INTERVALS[semitones][:name]
      end

      def short_name
        INTERVALS[semitones][:short]
      end

      def type
        INTERVALS[semitones][:type]
      end

      def song_example
        SONG_EXAMPLES[semitones]
      end

      def consonant?
        [0, 3, 4, 5, 7, 8, 9].include?(semitones)
      end

      def dissonant?
        !consonant?
      end

      def tom_or_semitom
        case semitones
        when 1 then 'Semitom'
        when 2 then 'Tom'
        else "#{semitones} semitons"
        end
      end

      def to_s
        short_name
      end

      def ==(other)
        return false unless other.is_a?(Interval)

        semitones == other.semitones
      end

      def self.between(note1, note2)
        note1 = Note.new(note1) if note1.is_a?(String)
        note2 = Note.new(note2) if note2.is_a?(String)
        new(note1.distance_to(note2))
      end

      def self.from_short(short)
        found = INTERVALS.find { |_, v| v[:short] == short }
        raise ArgumentError, "Intervalo desconhecido: #{short}" unless found

        new(found[0])
      end

      def self.all
        INTERVALS.keys.map { |s| new(s) }
      end
    end
  end
end
