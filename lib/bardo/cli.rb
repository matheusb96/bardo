# frozen_string_literal: true

require 'thor'
require 'tty-prompt'
require 'tty-table'
require 'pastel'

module Bardo
  class CLI < Thor
    package_name 'bardo'

    def self.exit_on_failure?
      true
    end

    desc 'field TOM', 'Mostra o campo harmonico de um tom (ex: bardo field C, bardo field Am)'
    option :tetrads, type: :boolean, aliases: '-t', desc: 'Mostrar tetrades (acordes com 7a)'
    def field(key)
      root, mode = parse_key(key)
      hf = Theory::HarmonicField.new(root, mode)
      colors = UI::Colors.new

      puts ''
      puts colors.title(hf.to_s)
      puts ''

      header = %w[Grau Acorde Notas]
      header.insert(2, 'Tetrade') if options[:tetrads]
      header << 'Funcao'

      rows = hf.chords_data.map do |data|
        chord = data[:triad]
        row = [
          data[:numeral],
          colorize_chord(chord, colors),
          chord.note_names.join(' - ')
        ]

        if options[:tetrads]
          tetrad = data[:tetrad]
          row.insert(2, colorize_chord(tetrad, colors))
        end

        row << data[:function]
        row
      end

      table = TTY::Table.new(header: header, rows: rows)
      puts table.render(:unicode, padding: [0, 1])

      puts ''
      puts colors.muted("Escala: #{hf.scale.note_names.join(' - ')}")
      puts colors.muted("Formula: #{hf.scale.step_pattern}") if hf.scale.step_pattern
      puts ''
    end

    desc 'scale NOTA TIPO', 'Mostra uma escala (ex: bardo scale C major, bardo scale A pentatonic_minor)'
    option :fretboard, type: :boolean, aliases: '-f', desc: 'Mostrar no braco da guitarra'
    option :tuning, type: :string, default: 'standard', desc: 'Afinacao (standard, drop_d, etc)'
    def scale(root, type = 'major')
      s = Theory::Scale.new(root, type)
      colors = UI::Colors.new

      puts ''
      puts colors.title("#{root.upcase} #{s.description}")
      puts ''

      # Notes with degrees
      degrees = s.notes.each_with_index.map { |_, i| (i + 1).to_s }
      intervals = s.intervals.map(&:short_name)

      table = TTY::Table.new(
        header: ['Grau'] + degrees,
        rows: [
          ['Nota'] + s.note_names,
          ['Intervalo'] + intervals
        ]
      )
      puts table.render(:unicode, padding: [0, 1])

      puts ''
      puts colors.muted("Formula: #{s.step_pattern}") if s.step_pattern
      puts ''

      return unless options[:fretboard]

      renderer = Fretboard::Renderer.new(
        tuning: Fretboard::Tuning.new(options[:tuning]),
        colors: colors
      )
      puts colors.subtitle('Braco da guitarra:')
      puts ''
      puts renderer.render(s.notes, root: s.root)
      puts ''
    end

    desc 'chord ACORDE', 'Mostra detalhes de um acorde (ex: bardo chord Am7, bardo chord Cmaj7)'
    option :scales, type: :boolean, aliases: '-s', desc: 'Sugerir escalas para solar'
    option :fretboard, type: :boolean, aliases: '-f', desc: 'Mostrar notas no braco'
    option :voicings, type: :boolean, aliases: '-v', desc: 'Mostrar voicings CAGED'
    option :tuning, type: :string, default: 'standard', desc: 'Afinacao'
    def chord(symbol)
      c = Theory::Chord.new(symbol)
      colors = UI::Colors.new

      puts ''
      puts colors.title("#{c.symbol} - #{c.description}")
      puts ''
      puts "  Notas:      #{c.note_names.join(' - ')}"
      puts "  Intervalos:  #{c.interval_names.join(' - ')}"
      puts ''

      if options[:scales]
        suggestions = c.suggested_scales
        unless suggestions.empty?
          puts colors.subtitle('Escalas sugeridas para solar:')
          suggestions.each do |s|
            puts "  * #{s.root} #{s.description}"
            puts "    #{colors.muted(s.note_names.join(' - '))}"
          end
          puts ''
        end
      end

      if options[:voicings]
        diagram = Fretboard::ChordDiagram.new(c, colors: colors)
        puts colors.subtitle("Voicings CAGED de #{c.symbol}:")
        puts ''
        puts diagram.render_all
        puts ''
      end

      return unless options[:fretboard]

      renderer = Fretboard::Renderer.new(
        tuning: Fretboard::Tuning.new(options[:tuning]),
        colors: colors
      )
      puts colors.subtitle('Notas no braco:')
      puts ''
      puts renderer.render(c.notes, root: c.root)
      puts ''
    end

    desc 'suggest ACORDE1 ACORDE2 ...', 'Sugere escalas para uma progressao de acordes'
    def suggest(*chord_symbols)
      if chord_symbols.empty?
        puts 'Use: bardo suggest Am F C G'
        return
      end

      colors = UI::Colors.new
      chords = chord_symbols.map { |s| Theory::Chord.new(s) }

      puts ''
      puts colors.title("Progressao: #{chords.map(&:symbol).join(' -> ')}")
      puts ''

      # Identify key
      candidates = Theory::HarmonicField.identify_key(chord_symbols)
      top = candidates.first(3)

      unless top.empty?
        puts colors.subtitle('Tom provavel:')
        top.each_with_index do |c, i|
          marker = i.zero? ? '>>>' : '   '
          puts "  #{marker} #{c[:key]} (#{c[:matches]}/#{chords.length} acordes encaixam)"
        end
        puts ''
      end

      puts colors.subtitle('Escalas sugeridas por acorde:')
      puts ''

      chords.each do |chord|
        puts "  #{colors.highlight(chord.symbol)} (#{chord.note_names.join(' - ')}):"
        suggestions = chord.suggested_scales.first(3)
        suggestions.each do |s|
          puts "    * #{s.root} #{s.type} - #{s.note_names.join(' ')}"
        end
        puts ''
      end

      # Overall safe suggestions
      return unless top.any?

      best = top.first
      puts colors.subtitle('Safe choices para toda a progressao:')
      root = best[:root]
      puts "  * #{root} Pentatonica menor - #{Theory::Scale.new(root, :pentatonic_minor).note_names.join(' ')}"

      # Find relative minor/major
      if best[:mode] == :major
        relative = Theory::Scale.new(root, :major).degree(6)
        puts "  * #{relative} Pentatonica menor (relativa) - #{Theory::Scale.new(relative,
                                                                                 :pentatonic_minor).note_names.join(' ')}"
      end
      puts ''
    end

    desc 'fretboard NOTA ESCALA', 'Mostra escala no braco da guitarra (ex: bardo fretboard A pentatonic_minor)'
    option :tuning, type: :string, default: 'standard', desc: 'Afinacao'
    option :frets, type: :numeric, default: 15, desc: 'Numero de casas'
    def fretboard(root, type = 'pentatonic_minor')
      s = Theory::Scale.new(root, type)
      colors = UI::Colors.new
      renderer = Fretboard::Renderer.new(
        tuning: Fretboard::Tuning.new(options[:tuning]),
        colors: colors
      )

      puts ''
      puts colors.title("#{s.root} #{s.description}")
      puts colors.muted("Notas: #{s.note_names.join(' - ')}   Afinacao: #{renderer.tuning}")
      puts ''
      puts renderer.render(s.notes, root: s.root, frets: options[:frets])
      puts ''
    end

    desc 'improv TOM', 'Guia de improvisacao completo (ex: bardo improv A, bardo improv Am)'
    option :interactive, type: :boolean, aliases: '-i', desc: 'Modo interativo com menu de navegacao'
    def improv(key)
      root, mode = parse_key(key)
      guide = Improv::Guide.new(root, mode)

      if options[:interactive]
        guide.interactive
      else
        puts guide.cheat_sheet
      end
    end

    desc 'voicings ACORDE', 'Mostra diagramas de acorde CAGED (ex: bardo voicings C, bardo voicings Am)'
    option :near, type: :numeric, aliases: '-n', desc: 'Filtrar voicings perto de uma casa especifica'
    def voicings(symbol)
      colors = UI::Colors.new
      diagram = Fretboard::ChordDiagram.new(symbol, colors: colors)

      puts ''
      puts colors.title("Voicings CAGED de #{symbol}")
      puts ''

      if options[:near]
        near = diagram.voicings_near(options[:near])
        if near.empty?
          puts colors.muted("  Nenhum voicing encontrado perto da casa #{options[:near]}")
        else
          rendered = near.map { |v| diagram.render_voicing(v) }
          puts rendered.join("\n\n")
        end
      else
        puts diagram.render_all
      end
      puts ''
    end

    desc 'journey', 'Inicia a Jornada do Bardo - aprenda teoria musical passo a passo'
    def journey
      engine = Journey::Engine.new
      engine.start
    end

    desc 'scales', 'Lista todas as escalas disponiveis'
    def scales
      colors = UI::Colors.new
      puts ''
      puts colors.title('Escalas disponiveis:')
      puts ''

      Theory::Scale::DESCRIPTIONS.each do |type, desc|
        formula = Theory::Scale::FORMULAS[type]
        puts "  #{colors.highlight(type.to_s.ljust(18))} #{desc}"
        puts "  #{colors.muted(' ' * 18 + "Intervalos: #{formula.join(' ')}")}"
        puts ''
      end
    end

    desc 'version', 'Mostra a versao do Bardo'
    def version
      puts "Bardo v#{VERSION}"
    end

    private

    def parse_key(key)
      if key.end_with?('m') && !key.end_with?('dim')
        root = key.chomp('m')
        [root, :minor]
      else
        [key, :major]
      end
    end

    def colorize_chord(chord, colors)
      if chord.diminished?
        colors.chord_dim(chord.symbol)
      elsif chord.minor?
        colors.chord_minor(chord.symbol)
      elsif chord.dominant?
        colors.chord_dom(chord.symbol)
      else
        colors.chord_major(chord.symbol)
      end
    end
  end
end
