# frozen_string_literal: true

RSpec.describe Bardo::Journey::Level do
  describe '.for_xp' do
    it 'returns Aprendiz for 0 XP' do
      level = described_class.for_xp(0)
      expect(level.name).to eq('Aprendiz')
    end

    it 'returns Trovador for 100 XP' do
      level = described_class.for_xp(100)
      expect(level.name).to eq('Trovador')
    end

    it 'returns Menestrel for 300 XP' do
      level = described_class.for_xp(300)
      expect(level.name).to eq('Menestrel')
    end

    it 'returns Bardo for 600 XP' do
      level = described_class.for_xp(600)
      expect(level.name).to eq('Bardo')
    end

    it 'returns Mestre Bardo for 1000 XP' do
      level = described_class.for_xp(1000)
      expect(level.name).to eq('Mestre Bardo')
    end

    it 'stays at max level for very high XP' do
      level = described_class.for_xp(9999)
      expect(level.name).to eq('Mestre Bardo')
    end
  end

  describe '#next_level' do
    it 'returns the next level' do
      level = described_class.new(0)
      expect(level.next_level.name).to eq('Trovador')
    end

    it 'returns nil for max level' do
      level = described_class.new(4)
      expect(level.next_level).to be_nil
    end
  end

  describe '#max_level?' do
    it 'returns false for non-max levels' do
      expect(described_class.new(0).max_level?).to be false
    end

    it 'returns true for max level' do
      expect(described_class.new(4).max_level?).to be true
    end
  end
end

RSpec.describe Bardo::Journey::Lesson do
  describe '.all' do
    it 'returns all lessons' do
      lessons = described_class.all
      expect(lessons).not_to be_empty
      expect(lessons.length).to be >= 10
    end

    it 'all lessons have required attributes' do
      described_class.all.each do |lesson|
        expect(lesson.id).not_to be_nil
        expect(lesson.title).not_to be_empty
        expect(lesson.content).not_to be_empty
        expect(lesson.exercises).not_to be_empty
      end
    end

    it 'covers all levels' do
      level_indices = described_class.all.map(&:level_index).uniq.sort
      expect(level_indices).to include(0, 1, 2, 3)
    end
  end

  describe '.for_level' do
    it 'returns lessons for a specific level' do
      lessons = described_class.for_level(0)
      expect(lessons).not_to be_empty
      expect(lessons).to all(have_attributes(level_index: 0))
    end
  end

  describe '.find' do
    it 'finds lesson by id' do
      lesson = described_class.find('1.1')
      expect(lesson).not_to be_nil
      expect(lesson.title).to eq('As 12 notas musicais')
    end

    it 'returns nil for unknown id' do
      expect(described_class.find('99.99')).to be_nil
    end
  end
end

RSpec.describe Bardo::Journey::Player do
  let(:player) { described_class.new }

  describe 'initial state' do
    it 'starts at 0 XP' do
      expect(player.xp).to eq(0)
    end

    it 'starts as Aprendiz' do
      expect(player.level.name).to eq('Aprendiz')
    end

    it 'starts with no completed lessons' do
      expect(player.completed_lessons).to be_empty
    end
  end

  describe '#answer_correct!' do
    it 'awards XP' do
      result = player.answer_correct!
      expect(result[:xp_gained]).to eq(10)
      expect(player.xp).to eq(10)
    end

    it 'increments streak' do
      3.times { player.answer_correct! }
      expect(player.streak).to eq(3)
    end

    it 'awards streak bonus at threshold' do
      4.times { player.answer_correct! }
      result = player.answer_correct!
      expect(result[:streak_bonus]).to eq(25)
    end

    it 'tracks total correct' do
      3.times { player.answer_correct! }
      expect(player.total_correct).to eq(3)
    end
  end

  describe '#answer_wrong!' do
    it 'resets streak' do
      3.times { player.answer_correct! }
      player.answer_wrong!
      expect(player.streak).to eq(0)
    end

    it 'does not award XP' do
      player.answer_wrong!
      expect(player.xp).to eq(0)
    end

    it 'tracks total answered' do
      player.answer_wrong!
      expect(player.total_answered).to eq(1)
    end
  end

  describe '#complete_lesson!' do
    it 'awards lesson XP' do
      result = player.complete_lesson!('1.1')
      expect(result[:xp_gained]).to eq(50)
    end

    it 'does not double-count completed lessons' do
      player.complete_lesson!('1.1')
      initial_xp = player.xp
      player.complete_lesson!('1.1')
      expect(player.xp).to eq(initial_xp)
    end

    it 'awards level bonus on level up' do
      # Get player to near level 2 (100 XP)
      player.instance_variable_set(:@xp, 90)
      result = player.complete_lesson!('1.3')
      expect(result[:level_bonus]).to eq(100)
    end
  end

  describe '#accuracy' do
    it 'returns 0 with no answers' do
      expect(player.accuracy).to eq(0.0)
    end

    it 'calculates correct percentage' do
      3.times { player.answer_correct! }
      player.answer_wrong!
      expect(player.accuracy).to eq(75.0)
    end
  end

  describe '#next_lesson' do
    it 'returns first lesson for new player' do
      lesson = player.next_lesson
      expect(lesson.id).to eq('1.1')
    end

    it 'returns next uncompleted lesson' do
      player.complete_lesson!('1.1')
      lesson = player.next_lesson
      expect(lesson.id).to eq('1.2')
    end

    it 'does not return lessons above current level' do
      # Player is level 0 (Aprendiz), should not get level 1 lessons
      Bardo::Journey::Lesson.for_level(0).each do |l|
        player.complete_lesson!(l.id)
      end
      # Without enough XP for level 1, next_lesson should be nil or level 0
      lesson = player.next_lesson
      # If player leveled up from XP, they can access level 1
      expect(lesson.level_index).to be <= player.level.index if lesson
    end
  end
end
