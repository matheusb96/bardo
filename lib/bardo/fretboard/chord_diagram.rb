# frozen_string_literal: true

module Bardo
  module Fretboard
    class ChordDiagram
      # Standard tuning semitone values per string (6=low E, 1=high e)
      OPEN_STRING_VALUES = [4, 9, 2, 7, 11, 4].freeze # E A D G B E

      # CAGED shapes: open_frets relative to nut (nil = muted string)
      # Strings ordered: [6, 5, 4, 3, 2, 1] = [low E, A, D, G, B, high e]
      # root_string: which string carries the root (6=low E, 5=A, 4=D)
      # root_offset: fret of the root in the open chord shape
      CAGED_SHAPES = {
        E: {
          major: { open_frets: [0, 2, 2, 1, 0, 0], root_string: 6, root_offset: 0 },
          minor: { open_frets: [0, 2, 2, 0, 0, 0], root_string: 6, root_offset: 0 }
        },
        A: {
          major: { open_frets: [nil, 0, 2, 2, 2, 0], root_string: 5, root_offset: 0 },
          minor: { open_frets: [nil, 0, 2, 2, 1, 0], root_string: 5, root_offset: 0 }
        },
        G: {
          major: { open_frets: [3, 2, 0, 0, 0, 3], root_string: 6, root_offset: 3 },
          minor: { open_frets: [3, 1, 0, 0, 3, 3], root_string: 6, root_offset: 3 }
        },
        C: {
          major: { open_frets: [nil, 3, 2, 0, 1, 0], root_string: 5, root_offset: 3 },
          minor: { open_frets: [nil, 3, 1, 0, 1, 3], root_string: 5, root_offset: 3 }
        },
        D: {
          major: { open_frets: [nil, nil, 0, 2, 3, 2], root_string: 4, root_offset: 0 },
          minor: { open_frets: [nil, nil, 0, 2, 3, 1], root_string: 4, root_offset: 0 }
        }
      }.freeze

      # Order of CAGED shapes ascending on the neck
      CAGED_ORDER = %i[C A G E D].freeze

      attr_reader :chord, :colors

      def initialize(chord, colors: UI::Colors.new)
        @chord = chord.is_a?(Theory::Chord) ? chord : Theory::Chord.new(chord)
        @colors = colors
      end

      # Returns all CAGED voicings for this chord, sorted by position
      def voicings
        quality = chord.major? || chord.dominant? ? :major : :minor
        root_value = chord.root.semitones_from_c

        results = CAGED_SHAPES.map do |shape_name, shapes|
          shape = shapes[quality]
          next unless shape

          barre = calculate_barre(root_value, shape)
          frets = calculate_frets(shape[:open_frets], barre)
          min_fret = frets.compact.reject(&:zero?).min || 0
          is_open = barre.zero?

          {
            shape: shape_name,
            frets: frets,
            barre_fret: barre,
            min_fret: min_fret,
            is_open: is_open,
            root_strings: find_root_strings(frets, root_value),
            quality: quality
          }
        end.compact

        results.sort_by { |v| v[:min_fret] }
      end

      # Render a single voicing as vertical chord diagram
      def render_voicing(voicing, label: nil)
        frets = voicing[:frets]
        min_fret = frets.compact.reject(&:zero?).min || 0
        frets.compact.max || 0
        is_open = voicing[:is_open] || min_fret.zero?

        start_fret = is_open ? 0 : min_fret
        display_frets = 4

        lines = []

        # Title
        title = label || "#{chord.symbol} (#{voicing[:shape]} shape)"
        lines << title.center(17)
        lines << ''

        # Open/muted string indicators
        top_line = frets.map.with_index do |f, _i|
          if f.nil?
            'X'
          elsif f.zero? || (is_open && f == start_fret)
            'O'
          else
            ' '
          end
        end
        lines << " #{top_line.join('  ')}"

        # Nut or fret indicator
        lines << if is_open
                   ' ╒═╤═╤═╤═╤═╕'
                 else
                   "#{start_fret.to_s.rjust(2)}fr"
                 end

        # Fret rows
        display_frets.times do |row|
          current_fret = start_fret + row + (is_open ? 1 : 0)

          # Check if this row has a barre (all non-nil strings at this fret)
          barre_strings = []
          cells = frets.map.with_index do |f, string_idx|
            if f == current_fret && f && !f.zero?
              is_root = voicing[:root_strings].include?(string_idx)
              barre_strings << string_idx
              is_root ? :root : :finger
            else
              :empty
            end
          end

          line = render_fret_row(cells, row == display_frets - 1)
          lines << " #{line}"

          # Fret separator
          lines << if row < display_frets - 1
                     ' ├─┼─┼─┼─┼─┤'
                   else
                     ' └─┴─┴─┴─┴─┘'
                   end
        end

        # String labels
        lines << ' E A D G B e'

        lines.join("\n")
      end

      # Render all voicings side by side
      def render_all(max_per_row: 3)
        all_voicings = voicings
        return 'Nenhum voicing encontrado.' if all_voicings.empty?

        sections = []
        all_voicings.each_slice(max_per_row) do |group|
          rendered = group.map { |v| render_voicing(v) }
          sections << side_by_side(rendered, spacing: 4)
        end

        sections.join("\n\n")
      end

      # Voicings near a specific fret region
      def voicings_near(fret, range: 3)
        voicings.select do |v|
          min = v[:frets].compact.reject(&:zero?).min || 0
          (min - fret).abs <= range
        end
      end

      private

      def calculate_barre(root_value, shape)
        root_string_idx = 6 - shape[:root_string] # Convert string number to array index
        open_string_value = OPEN_STRING_VALUES[root_string_idx]
        (root_value - open_string_value - shape[:root_offset]) % 12
      end

      def calculate_frets(open_frets, barre)
        open_frets.map { |f| f.nil? ? nil : f + barre }
      end

      def find_root_strings(frets, root_value)
        frets.each_with_index.select do |f, i|
          next false if f.nil?

          (OPEN_STRING_VALUES[i] + f) % 12 == root_value
        end.map(&:last)
      end

      def render_fret_row(cells, _is_last)
        cells.map do |cell|
          case cell
          when :root
            colors.root_note('◉')
          when :finger
            '●'
          else
            '│'
          end
        end.join('─')
      end

      def side_by_side(rendered_diagrams, spacing: 4)
        split = rendered_diagrams.map { |d| d.split("\n") }
        max_lines = split.map(&:length).max
        max_width = split.map { |lines| lines.map(&:length).max || 0 }.max

        spacer = ' ' * spacing

        (0...max_lines).map do |line_idx|
          split.map do |lines|
            line = lines[line_idx] || ''
            # Strip ANSI codes for padding calculation
            visible_length = line.gsub(/\e\[[0-9;]*m/, '').length
            padding = max_width - visible_length
            line + (' ' * [padding, 0].max)
          end.join(spacer)
        end.join("\n")
      end
    end
  end
end
