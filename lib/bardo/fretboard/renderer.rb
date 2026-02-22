# frozen_string_literal: true

module Bardo
  module Fretboard
    class Renderer
      FRETS = 15
      FRET_WIDTH = 4

      attr_reader :tuning, :colors

      def initialize(tuning: Tuning.new, colors: UI::Colors.new)
        @tuning = tuning
        @colors = colors
      end

      def render(notes, root: nil, frets: FRETS)
        target_notes = notes.map { |n| n.is_a?(Theory::Note) ? n : Theory::Note.new(n) }
        root_note = if root.is_a?(Theory::Note)
                      root
                    else
                      (root ? Theory::Note.new(root) : target_notes.first)
                    end

        lines = []
        lines << fret_numbers_line(frets)
        lines << fret_dots_line(frets)

        tuning.string_notes.each do |open_string|
          lines << render_string(open_string, target_notes, root_note, frets)
        end

        lines << fret_dots_line(frets)
        lines << ''
        lines << legend(root_note, target_notes)
        lines.join("\n")
      end

      private

      def fret_numbers_line(frets)
        numbers = (0..frets).map { |f| f.to_s.center(FRET_WIDTH) }
        "    #{numbers.join}"
      end

      def fret_dots_line(frets)
        dots = (0..frets).map do |f|
          if f == 12
            ':'.center(FRET_WIDTH)
          elsif [3, 5, 7, 9, 15].include?(f)
            '.'.center(FRET_WIDTH)
          else
            ' ' * FRET_WIDTH
          end
        end
        "    #{dots.join}"
      end

      def render_string(open_note, target_notes, root_note, frets)
        label = open_note.to_s.ljust(2)
        cells = (0..frets).map do |fret|
          note_at_fret = open_note + fret
          render_fret(note_at_fret, target_notes, root_note, fret)
        end

        "#{label} |#{cells.join}|"
      end

      def render_fret(note, target_notes, root_note, fret)
        is_target = target_notes.any? { |t| t == note }

        if is_target
          display = note.display_name(use_flats: root_note.flat?).center(FRET_WIDTH)
          if note == root_note
            colors.root_note(display)
          else
            colors.note(display)
          end
        elsif fret.zero?
          '----'
        else
          '----|'[0, FRET_WIDTH]
        end
      end

      def legend(root_note, notes)
        root_display = colors.root_note(root_note.to_s)
        note_names = notes.map(&:to_s).join(' ')
        "#{root_display} = Tonica   Notas: #{note_names}"
      end
    end
  end
end
