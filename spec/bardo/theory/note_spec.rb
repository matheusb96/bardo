# frozen_string_literal: true

RSpec.describe Bardo::Theory::Note do
  describe '.new' do
    it 'creates a note from a valid name' do
      note = described_class.new('C')
      expect(note.name).to eq('C')
    end

    it 'normalizes lowercase input' do
      note = described_class.new('c#')
      expect(note.name).to eq('C#')
    end

    it 'accepts flats' do
      note = described_class.new('Bb')
      expect(note.name).to eq('Bb')
    end

    it 'raises error for invalid note' do
      expect { described_class.new('X') }.to raise_error(ArgumentError, /Nota inválida/)
    end

    it 'raises error for empty string' do
      expect { described_class.new('') }.to raise_error(ArgumentError)
    end
  end

  describe '#semitones_from_c' do
    it 'returns 0 for C' do
      expect(described_class.new('C').semitones_from_c).to eq(0)
    end

    it 'returns 7 for G' do
      expect(described_class.new('G').semitones_from_c).to eq(7)
    end

    it 'returns same value for enharmonic equivalents' do
      expect(described_class.new('C#').semitones_from_c).to eq(described_class.new('Db').semitones_from_c)
    end
  end

  describe '#+' do
    it 'adds semitones to get next note' do
      note = described_class.new('C') + 4
      expect(note.name).to eq('E')
    end

    it 'wraps around after B' do
      note = described_class.new('A') + 3
      expect(note.name).to eq('C')
    end

    it 'handles sharps' do
      note = described_class.new('C') + 1
      expect(note.name).to eq('C#')
    end
  end

  describe '#-' do
    it 'subtracts semitones' do
      note = described_class.new('E') - 4
      expect(note.name).to eq('C')
    end

    it 'calculates distance between notes' do
      c = described_class.new('C')
      e = described_class.new('E')
      expect(e - c).to eq(4)
    end
  end

  describe '#distance_to' do
    it 'calculates ascending distance' do
      c = described_class.new('C')
      expect(c.distance_to('E')).to eq(4)
    end

    it 'wraps around correctly' do
      a = described_class.new('A')
      expect(a.distance_to('C')).to eq(3)
    end

    it 'returns 0 for same note' do
      c = described_class.new('C')
      expect(c.distance_to('C')).to eq(0)
    end
  end

  describe '#==' do
    it 'considers enharmonic equivalents as equal' do
      expect(described_class.new('C#')).to eq(described_class.new('Db'))
    end

    it 'considers same notes as equal' do
      expect(described_class.new('A')).to eq(described_class.new('A'))
    end

    it 'considers different notes as not equal' do
      expect(described_class.new('C')).not_to eq(described_class.new('D'))
    end
  end

  describe '#natural?' do
    it 'returns true for natural notes' do
      expect(described_class.new('C').natural?).to be true
    end

    it 'returns false for sharps' do
      expect(described_class.new('C#').natural?).to be false
    end
  end

  describe '#enharmonic' do
    it 'returns enharmonic equivalent' do
      expect(described_class.new('C#').enharmonic.name).to eq('Db')
    end

    it 'returns self for natural notes' do
      note = described_class.new('C')
      expect(note.enharmonic).to eq(note)
    end
  end

  describe '.all' do
    it 'returns 12 notes with sharps' do
      notes = described_class.all(representation: :sharps)
      expect(notes.length).to eq(12)
      expect(notes.first.name).to eq('C')
    end

    it 'returns 12 notes with flats' do
      notes = described_class.all(representation: :flats)
      expect(notes.length).to eq(12)
      expect(notes[1].name).to eq('Db')
    end
  end
end
