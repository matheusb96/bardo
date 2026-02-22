# frozen_string_literal: true

module Bardo
  module Improv
    class Guide
      COMMON_PROGRESSIONS = {
        major: [
          { name: 'I - IV - V', degrees: [1, 4, 5], style: 'rock, folk, blues' },
          { name: 'I - V - vi - IV', degrees: [1, 5, 6, 4], style: 'pop (a mais usada no mundo)' },
          { name: 'ii - V - I', degrees: [2, 5, 1], style: 'jazz (a mais importante do jazz)' },
          { name: 'I - vi - IV - V', degrees: [1, 6, 4, 5], style: 'anos 50, doo-wop' },
          { name: 'I - IV - vi - V', degrees: [1, 4, 6, 5], style: 'pop/rock' },
          { name: 'vi - IV - I - V', degrees: [6, 4, 1, 5], style: 'pop emotivo' }
        ],
        minor: [
          { name: 'i - iv - v', degrees: [1, 4, 5], style: 'rock menor' },
          { name: 'i - VI - III - VII', degrees: [1, 6, 3, 7], style: 'pop menor, andaluz' },
          { name: 'i - iv - VII - III', degrees: [1, 4, 7, 3], style: 'balada menor' },
          { name: 'i - VII - VI - VII', degrees: [1, 7, 6, 7], style: 'flamenco, metal' }
        ]
      }.freeze

      attr_reader :field, :colors

      def initialize(key, mode = :major, colors: UI::Colors.new)
        @field = Theory::HarmonicField.new(key, mode)
        @colors = colors
      end

      def root
        field.root
      end

      def mode
        field.mode
      end

      def mode_name
        mode == :major ? 'Maior' : 'Menor'
      end

      # === CHEAT SHEET (tudo de uma vez) ===

      def cheat_sheet
        lines = []
        lines << header
        lines << ''
        lines << harmonic_field_section
        lines << ''
        lines << scales_per_chord_section
        lines << ''
        lines << safe_choices_section
        lines << ''
        lines << common_progressions_section
        lines << ''
        lines << fretboard_section
        lines << ''
        lines << voicings_section
        lines.join("\n")
      end

      def header
        title = "GUIA DE IMPROVISACAO - #{root} #{mode_name}"
        [
          colors.title('=' * 56),
          colors.title("  #{title}"),
          colors.title('=' * 56)
        ].join("\n")
      end

      def harmonic_field_section
        data = field.chords_data
        numerals = data.map { |d| d[:numeral].center(8) }.join
        triads = data.map { |d| d[:triad].symbol.center(8) }.join
        tetrads = data.map { |d| d[:tetrad].symbol.center(8) }.join

        [
          colors.subtitle('  CAMPO HARMONICO'),
          "  #{numerals}",
          "  #{triads}",
          "  #{tetrads}"
        ].join("\n")
      end

      def scales_per_chord_section
        lines = [colors.subtitle('  ESCALAS POR ACORDE')]
        lines << ''

        field.chords_data.each do |data|
          triad = data[:triad]
          tetrad = data[:tetrad]
          mode_scale = data[:mode]

          chord_label = "#{triad.symbol} / #{tetrad.symbol}".ljust(14)
          mode_name = mode_scale.type.to_s.capitalize
          mode_notes = mode_scale.note_names.join(' ')

          lines << "  #{colors.highlight(chord_label)} #{mode_name} (#{mode_notes})"
        end

        lines << ''
        lines << colors.muted('  Dica: todas as escalas acima tem as MESMAS notas!')
        lines << colors.muted('  A diferenca eh a nota que voce ENFATIZA (centro de gravidade).')

        lines.join("\n")
      end

      def safe_choices_section
        lines = [colors.subtitle('  SAFE CHOICES (funciona sobre tudo)')]
        lines << ''

        if mode == :major
          pent_maj = Theory::Scale.new(root, :pentatonic_major)
          lines << "  * #{root} Pentatonica maior:  #{pent_maj.note_names.join(' ')}"

          relative_root = field.scale.degree(6)
          pent_min = Theory::Scale.new(relative_root, :pentatonic_minor)
          lines << "  * #{relative_root} Pentatonica menor:  #{pent_min.note_names.join(' ')}  (relativa)"
        else
          pent_min = Theory::Scale.new(root, :pentatonic_minor)
          lines << "  * #{root} Pentatonica menor:  #{pent_min.note_names.join(' ')}"

          blues = Theory::Scale.new(root, :blues)
          lines << "  * #{root} Blues:              #{blues.note_names.join(' ')}"

          relative_root = field.scale.degree(3)
          pent_maj = Theory::Scale.new(relative_root, :pentatonic_major)
          lines << "  * #{relative_root} Pentatonica maior:  #{pent_maj.note_names.join(' ')}  (relativa)"
        end

        lines.join("\n")
      end

      def common_progressions_section
        lines = [colors.subtitle('  PROGRESSOES COMUNS')]
        lines << ''

        progs = COMMON_PROGRESSIONS[mode] || []
        progs.first(4).each do |prog|
          chords = prog[:degrees].map { |d| field.triads[d - 1].symbol }
          label = prog[:name].ljust(20)
          chord_str = chords.join(' - ')
          lines << "  #{label} #{chord_str.ljust(22)} #{colors.muted(prog[:style])}"
        end

        lines.join("\n")
      end

      def fretboard_section
        scale_type = mode == :major ? :pentatonic_major : :pentatonic_minor
        scale = Theory::Scale.new(root, scale_type)
        renderer = Fretboard::Renderer.new(colors: colors)

        [
          colors.subtitle("  FRETBOARD - #{root} #{scale.description}"),
          '',
          renderer.render(scale.notes, root: scale.root)
        ].join("\n")
      end

      def voicings_section
        diagram = Fretboard::ChordDiagram.new(field.triads[0], colors: colors)

        [
          colors.subtitle("  VOICINGS DE #{root} (CAGED)"),
          '',
          diagram.render_all
        ].join("\n")
      end

      # === INTERACTIVE MODE ===

      def interactive
        prompt = TTY::Prompt.new

        loop do
          puts ''
          puts header
          puts ''

          choice = prompt.select("O que deseja explorar em #{root} #{mode_name}?", cycle: true) do |menu|
            menu.choice 'Ver campo harmonico completo', :field
            menu.choice 'Escalas por acorde', :scales
            menu.choice 'Escolher acorde (escala + voicing + braco)', :chord
            menu.choice 'Pentatonica no braco', :pentatonic
            menu.choice 'Progressoes comuns', :progressions
            menu.choice "Voicings CAGED do acorde I (#{field.triads[0].symbol})", :voicings
            menu.choice 'Voltar', :back
          end

          case choice
          when :field
            puts ''
            puts harmonic_field_section
            puts ''
          when :scales
            puts ''
            puts scales_per_chord_section
            puts ''
          when :chord
            explore_chord(prompt)
          when :pentatonic
            puts ''
            puts fretboard_section
            puts ''
          when :progressions
            puts ''
            puts common_progressions_section
            puts ''
          when :voicings
            puts ''
            puts voicings_section
            puts ''
          when :back
            break
          end

          prompt.keypress(colors.muted('Pressione qualquer tecla para continuar...'))
        end
      end

      private

      def explore_chord(prompt)
        chord_choices = field.chords_data.map do |data|
          {
            name: "#{data[:numeral].ljust(5)} #{data[:triad].symbol.ljust(8)} (#{data[:function]})",
            value: data
          }
        end
        chord_choices << { name: 'Voltar', value: nil }

        chosen = prompt.select('Escolha o acorde:', chord_choices, cycle: true)
        return unless chosen

        puts ''
        triad = chosen[:triad]
        tetrad = chosen[:tetrad]
        mode_scale = chosen[:mode]

        # Chord info
        puts colors.title("  #{triad.symbol} / #{tetrad.symbol} - #{chosen[:function]}")
        puts ''
        puts "  Notas (triade):  #{triad.note_names.join(' - ')}"
        puts "  Notas (tetrade): #{tetrad.note_names.join(' - ')}"
        puts ''

        # Recommended scale/mode
        puts colors.subtitle("  Escala recomendada: #{mode_scale.root} #{mode_scale.type.to_s.capitalize}")
        puts "  Notas: #{mode_scale.note_names.join(' - ')}"
        puts ''

        # Target notes tip
        puts colors.subtitle('  Notas-alvo nos tempos fortes:')
        puts "  Mire em #{colors.highlight(triad.note_names.join(', '))} nos tempos 1 e 3."
        puts '  Chegue nelas por cromatismo (semitom acima ou abaixo).'
        puts ''

        # Scale on fretboard
        renderer = Fretboard::Renderer.new(colors: colors)
        puts colors.subtitle("  #{mode_scale.root} #{mode_scale.type.to_s.capitalize} no braco:")
        puts ''
        puts renderer.render(mode_scale.notes, root: mode_scale.root)
        puts ''

        # Chord voicings
        diagram = Fretboard::ChordDiagram.new(triad, colors: colors)
        puts colors.subtitle("  Voicings de #{triad.symbol} (CAGED):")
        puts ''
        puts diagram.render_all
        puts ''
      end
    end
  end
end
