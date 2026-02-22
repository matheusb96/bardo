# frozen_string_literal: true

RSpec.describe Bardo::Theory::Interval do
  describe '.new' do
    it 'creates interval from semitones' do
      interval = described_class.new(4)
      expect(interval.semitones).to eq(4)
    end

    it 'wraps values greater than 11' do
      interval = described_class.new(14)
      expect(interval.semitones).to eq(2)
    end
  end

  describe '#name' do
    {
      0 => 'Uníssono',
      1 => 'Segunda menor',
      2 => 'Segunda maior',
      3 => 'Terça menor',
      4 => 'Terça maior',
      5 => 'Quarta justa',
      6 => 'Trítono',
      7 => 'Quinta justa',
      8 => 'Sexta menor',
      9 => 'Sexta maior',
      10 => 'Sétima menor',
      11 => 'Sétima maior'
    }.each do |semitones, expected_name|
      it "returns '#{expected_name}' for #{semitones} semitones" do
        expect(described_class.new(semitones).name).to eq(expected_name)
      end
    end
  end

  describe '#short_name' do
    it "returns '1' for unison" do
      expect(described_class.new(0).short_name).to eq('1')
    end

    it "returns 'b3' for minor third" do
      expect(described_class.new(3).short_name).to eq('b3')
    end

    it "returns '5' for perfect fifth" do
      expect(described_class.new(7).short_name).to eq('5')
    end
  end

  describe '#tom_or_semitom' do
    it 'returns Semitom for 1 semitone' do
      expect(described_class.new(1).tom_or_semitom).to eq('Semitom')
    end

    it 'returns Tom for 2 semitones' do
      expect(described_class.new(2).tom_or_semitom).to eq('Tom')
    end

    it 'returns description for other values' do
      expect(described_class.new(5).tom_or_semitom).to eq('5 semitons')
    end
  end

  describe '#consonant?' do
    it 'returns true for perfect fifth' do
      expect(described_class.new(7).consonant?).to be true
    end

    it 'returns false for tritone' do
      expect(described_class.new(6).consonant?).to be false
    end
  end

  describe '#song_example' do
    it 'returns a song reference for each interval' do
      described_class.all.each do |interval|
        expect(interval.song_example).to be_a(String)
        expect(interval.song_example).not_to be_empty
      end
    end
  end

  describe '.between' do
    it 'calculates interval between C and E' do
      interval = described_class.between('C', 'E')
      expect(interval.semitones).to eq(4)
      expect(interval.name).to eq('Terça maior')
    end

    it 'calculates interval between A and C' do
      interval = described_class.between('A', 'C')
      expect(interval.semitones).to eq(3)
      expect(interval.name).to eq('Terça menor')
    end

    it 'calculates interval between G and D' do
      interval = described_class.between('G', 'D')
      expect(interval.semitones).to eq(7)
      expect(interval.name).to eq('Quinta justa')
    end
  end

  describe '.from_short' do
    it 'creates interval from short name' do
      interval = described_class.from_short('b3')
      expect(interval.semitones).to eq(3)
    end

    it 'raises error for unknown short name' do
      expect { described_class.from_short('xyz') }.to raise_error(ArgumentError)
    end
  end

  describe '.all' do
    it 'returns 12 intervals' do
      expect(described_class.all.length).to eq(12)
    end
  end
end
