# frozen_string_literal: true

module Bardo
  module Journey
    class ReturnToMenu < StandardError; end

    class Engine
      attr_reader :player, :prompt, :colors

      def initialize
        @player = Player.new
        @prompt = TTY::Prompt.new
        @colors = UI::Colors.new
      end

      def start
        show_welcome
        main_loop
      end

      def show_status
        puts ''
        puts colors.title('=' * 50)
        puts colors.title('         A JORNADA DO BARDO')
        puts colors.title('=' * 50)
        puts ''
        puts "  Nivel: #{colors.level_name(player.level.name)}     XP: #{colors.xp(player.xp.to_s)}"

        unless player.level.max_level?
          next_lvl = player.level.next_level
          puts "  #{colors.progress_bar(player.xp - player.level.xp_required,
                                        next_lvl.xp_required - player.level.xp_required)}"
          puts "  Proximo nivel: #{next_lvl.name} (#{next_lvl.xp_required} XP)"
        end

        puts ''
        puts "  Licoes completas: #{player.completed_lessons.length}/#{Lesson.all.length}"
        puts "  Precisao: #{player.accuracy}% (#{player.total_correct}/#{player.total_answered})"
        puts "  Streak atual: #{player.streak}"
        puts ''

        next_lesson = player.next_lesson
        if next_lesson
          puts "  Proxima licao: #{colors.subtitle(next_lesson.title)}"
        else
          puts colors.success('  Parabens! Voce completou todas as licoes!')
        end
        puts colors.title('=' * 50)
        puts ''
      end

      private

      def show_welcome
        puts ''
        puts colors.title('  ____                  _       ')
        puts colors.title(' |  _ \                | |      ')
        puts colors.title(' | |_) | __ _ _ __ ___| | ___  ')
        puts colors.title(" |  _ < / _` | '__/ __| |/ _ \\ ")
        puts colors.title(' | |_) | (_| | | | (__| | (_) |')
        puts colors.title(' |____/ \__,_|_|  \___|_|\___/ ')
        puts ''
        puts '  Bem-vindo a Jornada do Bardo!'
        puts '  Aprenda teoria musical no seu ritmo.'
        puts ''
      end

      def main_loop
        loop do
          show_status
          choice = prompt.select('O que deseja fazer?', cycle: true) do |menu|
            next_lesson = player.next_lesson
            menu.choice "Continuar jornada (#{next_lesson&.title || 'Completo!'})", :continue if next_lesson
            menu.choice 'Ver licoes disponiveis', :lessons
            menu.choice 'Sair', :quit
          end

          case choice
          when :continue
            run_lesson(player.next_lesson)
          when :lessons
            choose_lesson
          when :quit
            puts colors.muted("\nAte a proxima, Bardo! Continue praticando.\n")
            break
          end
        end
      end

      def choose_lesson
        available = Lesson.all.select { |l| l.level_index <= player.level.index }
        choices = available.map do |lesson|
          status = player.lesson_completed?(lesson.id) ? '[OK]' : '[  ]'
          { name: "#{status} #{lesson.id} - #{lesson.title}", value: lesson }
        end
        choices << { name: 'Voltar', value: nil }

        chosen = prompt.select('Escolha uma licao:', choices, cycle: true, per_page: 15)
        run_lesson(chosen) if chosen
      end

      def run_lesson(lesson)
        return unless lesson

        puts ''
        puts colors.title('=' * 55)
        puts colors.title("  Licao #{lesson.id}: #{lesson.title}")
        puts colors.title('=' * 55)
        puts ''
        puts lesson.content
        puts ''

        action = prompt.select(colors.muted('Pronto?'), cycle: true) do |menu|
          menu.choice 'Comecar exercicios', :start
          menu.choice 'Voltar ao menu', :back
        end
        return if action == :back

        puts ''

        correct = 0
        total_attempted = 0

        begin
          lesson.exercises.each_with_index do |exercise, i|
            puts colors.subtitle("Exercicio #{i + 1}/#{lesson.exercises.length}")
            result = run_exercise(exercise)
            total_attempted += 1
            correct += 1 if result
            puts ''
          end
        rescue ReturnToMenu
          puts ''
          puts colors.muted('  Saindo da licao...')
        end

        show_lesson_result(lesson, correct, total_attempted)
      end

      def show_lesson_result(lesson, correct, total_attempted)
        puts colors.title('-' * 40)

        if total_attempted.zero?
          puts colors.muted('  Nenhum exercicio respondido.')
          puts ''
          return
        end

        puts "  Resultado: #{correct}/#{lesson.exercises.length}"

        if total_attempted < lesson.exercises.length
          puts colors.muted("  (#{total_attempted} de #{lesson.exercises.length} exercicios respondidos)")
        end

        if correct >= (lesson.exercises.length * 0.7).ceil
          result = player.complete_lesson!(lesson.id)
          puts colors.success("  Licao completa! +#{result[:xp_gained]} XP")
          if result[:level_bonus].positive?
            puts colors.xp("  LEVEL UP! +#{result[:level_bonus]} XP bonus!")
            puts colors.level_name("  Novo nivel: #{result[:new_level].name}!")
          end
        else
          remaining = (lesson.exercises.length * 0.7).ceil - correct
          puts colors.warning('  Voce precisa de 70% para completar a licao.')
          puts colors.muted("  Faltam #{remaining} acerto(s). Tente novamente!")
        end

        puts ''
        prompt.keypress(colors.muted('Pressione qualquer tecla para voltar ao menu...'))
      end

      def run_exercise(exercise)
        case exercise[:type]
        when :multiple_choice
          run_multiple_choice(exercise)
        when :tom_semitom
          run_tom_semitom(exercise)
        when :fill_in
          run_fill_in(exercise)
        when :scale_build
          run_scale_build(exercise)
        when :chord_notes
          run_chord_notes(exercise)
        when :interval
          run_interval(exercise)
        else
          puts "Tipo de exercicio desconhecido: #{exercise[:type]}"
          false
        end
      end

      def run_multiple_choice(exercise)
        choices = exercise[:options] + [colors.muted('>> Voltar ao menu')]
        answer = prompt.select(exercise[:question], choices, cycle: true)
        raise ReturnToMenu if answer == choices.last

        check_answer(answer, exercise[:answer])
      end

      def run_tom_semitom(exercise)
        choices = %w[Tom Semitom] + [colors.muted('>> Voltar ao menu')]
        answer = prompt.select(exercise[:question], choices, cycle: true)
        raise ReturnToMenu if answer == choices.last

        check_answer(answer, exercise[:answer])
      end

      def run_fill_in(exercise)
        answer = prompt_with_quit(exercise[:question])
        check_answer(answer.strip, exercise[:answer])
      end

      def run_scale_build(exercise)
        scale = Theory::Scale.new(exercise[:root], exercise[:scale_type])
        expected = scale.note_names

        puts exercise[:question]
        puts colors.muted('(Digite as notas separadas por espaco, ex: C D E F G A B)')
        puts colors.muted("(Digite 'q' para voltar ao menu)")
        answer = prompt_with_quit('>')

        given = answer.strip.split(/[\s,]+/).map do |n|
          Theory::Note.new(n).to_s
        rescue StandardError
          n
        end

        if notes_match?(given, expected)
          result = player.answer_correct!
          show_correct(result)
          true
        else
          player.answer_wrong!
          puts colors.error('  Incorreto!')
          puts "  Resposta certa: #{expected.join(' ')}"
          false
        end
      end

      def run_chord_notes(exercise)
        chord = Theory::Chord.new(exercise[:chord])
        expected = chord.note_names

        puts exercise[:question]
        puts colors.muted('(Digite as notas separadas por espaco)')
        puts colors.muted("(Digite 'q' para voltar ao menu)")
        answer = prompt_with_quit('>')

        given = answer.strip.split(/[\s,]+/).map do |n|
          Theory::Note.new(n).to_s
        rescue StandardError
          n
        end

        if notes_match?(given, expected)
          result = player.answer_correct!
          show_correct(result)
          true
        else
          player.answer_wrong!
          puts colors.error('  Incorreto!')
          puts "  Resposta certa: #{expected.join(' ')}"
          false
        end
      end

      def run_interval(exercise)
        puts exercise[:question]
        puts colors.muted("(Digite 'q' para voltar ao menu)")
        answer = prompt_with_quit('>')

        if answer.strip.to_i == exercise[:answer]
          result = player.answer_correct!
          show_correct(result)
          interval = Theory::Interval.new(exercise[:answer])
          puts colors.muted("  #{interval.name} - #{interval.song_example}")
          true
        else
          player.answer_wrong!
          puts colors.error('  Incorreto!')
          puts "  Resposta: #{exercise[:answer]} semitons (#{Theory::Interval.new(exercise[:answer]).name})"
          false
        end
      end

      def prompt_with_quit(question)
        answer = prompt.ask(question) do |q|
          q.required true
        end
        raise ReturnToMenu if %w[q quit voltar].include?(answer.strip.downcase)

        answer
      end

      def notes_match?(given, expected)
        given.length == expected.length && given.each_with_index.all? do |n, i|
          Theory::Note.new(n) == Theory::Note.new(expected[i])
        rescue StandardError
          false
        end
      end

      def check_answer(given, expected)
        if given.to_s.strip.downcase == expected.to_s.strip.downcase
          result = player.answer_correct!
          show_correct(result)
          true
        else
          player.answer_wrong!
          puts colors.error('  Incorreto!')
          puts "  Resposta certa: #{expected}"
          false
        end
      end

      def show_correct(result)
        msg = colors.success("  Correto! +#{result[:xp_gained]} XP")
        msg += colors.xp("  Streak bonus! +#{result[:streak_bonus]} XP") if result[:streak_bonus].positive?
        msg += "  (streak: #{result[:streak]})" if result[:streak] > 1
        puts msg
      end
    end
  end
end
