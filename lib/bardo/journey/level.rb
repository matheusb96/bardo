# frozen_string_literal: true

module Bardo
  module Journey
    class Level
      LEVELS = [
        { name: 'Aprendiz', xp_required: 0, description: 'Começando a jornada musical' },
        { name: 'Trovador', xp_required: 100, description: 'Dominando o básico da teoria' },
        { name: 'Menestrel', xp_required: 300, description: 'Entendendo harmonia e intervalos' },
        { name: 'Bardo', xp_required: 600, description: 'Improvisando com consciência' },
        { name: 'Mestre Bardo', xp_required: 1000, description: 'Domínio completo da teoria' }
      ].freeze

      attr_reader :index

      def initialize(index = 0)
        @index = [index, LEVELS.length - 1].min
      end

      def name
        LEVELS[index][:name]
      end

      def description
        LEVELS[index][:description]
      end

      def xp_required
        LEVELS[index][:xp_required]
      end

      def next_level
        return nil if index >= LEVELS.length - 1

        self.class.new(index + 1)
      end

      def xp_for_next
        nxt = next_level
        return nil unless nxt

        nxt.xp_required
      end

      def max_level?
        index >= LEVELS.length - 1
      end

      def to_s
        name
      end

      def self.for_xp(xp)
        level_index = LEVELS.rindex { |l| xp >= l[:xp_required] } || 0
        new(level_index)
      end

      def self.all
        LEVELS.each_with_index.map { |_, i| new(i) }
      end
    end
  end
end
