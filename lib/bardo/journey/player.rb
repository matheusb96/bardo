# frozen_string_literal: true

module Bardo
  module Journey
    class Player
      XP_CORRECT = 10
      XP_STREAK_BONUS = 25
      XP_LESSON_COMPLETE = 50
      XP_LEVEL_COMPLETE = 100
      STREAK_THRESHOLD = 5

      attr_reader :xp, :streak, :completed_lessons, :total_correct, :total_answered

      def initialize
        @xp = 0
        @streak = 0
        @completed_lessons = []
        @total_correct = 0
        @total_answered = 0
      end

      def level
        Level.for_xp(xp)
      end

      def answer_correct!
        @total_correct += 1
        @total_answered += 1
        @streak += 1
        @xp += XP_CORRECT

        streak_bonus = 0
        if (@streak % STREAK_THRESHOLD).zero?
          @xp += XP_STREAK_BONUS
          streak_bonus = XP_STREAK_BONUS
        end

        { xp_gained: XP_CORRECT, streak_bonus: streak_bonus, streak: @streak }
      end

      def answer_wrong!
        @total_answered += 1
        @streak = 0
        { xp_gained: 0, streak_bonus: 0, streak: 0 }
      end

      def complete_lesson!(lesson_id)
        return if @completed_lessons.include?(lesson_id)

        old_level = level
        @completed_lessons << lesson_id
        @xp += XP_LESSON_COMPLETE

        level_bonus = 0
        if level.index > old_level.index
          @xp += XP_LEVEL_COMPLETE
          level_bonus = XP_LEVEL_COMPLETE
        end

        { xp_gained: XP_LESSON_COMPLETE, level_bonus: level_bonus, new_level: level }
      end

      def lesson_completed?(lesson_id)
        @completed_lessons.include?(lesson_id)
      end

      def next_lesson
        all_lessons = Lesson.all
        all_lessons.find { |l| !lesson_completed?(l.id) && l.level_index <= level.index }
      end

      def accuracy
        return 0.0 if total_answered.zero?

        (total_correct.to_f / total_answered * 100).round(1)
      end

      def progress_in_level
        current_xp = xp - level.xp_required
        next_lvl = level.next_level
        return 100.0 if next_lvl.nil?

        needed = next_lvl.xp_required - level.xp_required
        (current_xp.to_f / needed * 100).round(1)
      end
    end
  end
end
