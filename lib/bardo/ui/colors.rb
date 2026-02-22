# frozen_string_literal: true

module Bardo
  module UI
    class Colors
      def initialize
        @pastel = Pastel.new
      end

      def title(text)
        @pastel.bold.cyan(text)
      end

      def subtitle(text)
        @pastel.yellow(text)
      end

      def success(text)
        @pastel.green(text)
      end

      def error(text)
        @pastel.red(text)
      end

      def warning(text)
        @pastel.yellow(text)
      end

      def muted(text)
        @pastel.dim(text)
      end

      def highlight(text)
        @pastel.bold.white(text)
      end

      def root_note(text)
        @pastel.bold.red(text)
      end

      def note(text)
        @pastel.bold.white(text)
      end

      def chord_major(text)
        @pastel.bold.green(text)
      end

      def chord_minor(text)
        @pastel.bold.blue(text)
      end

      def chord_dim(text)
        @pastel.bold.red(text)
      end

      def chord_dom(text)
        @pastel.bold.yellow(text)
      end

      def xp(text)
        @pastel.bold.magenta(text)
      end

      def level_name(text)
        @pastel.bold.cyan(text)
      end

      def progress_bar(current, total, width: 20)
        filled = [(current.to_f / total * width).round, width].min
        empty = width - filled
        bar = @pastel.green('#' * filled) + @pastel.dim('.' * empty)
        "#{bar} #{current}/#{total}"
      end
    end
  end
end
