# frozen_string_literal: true

RSpec.describe Bardo::Theory::Chord do
  describe '.new' do
    it 'creates chord from symbol string' do
      chord = described_class.new('Am')
      expect(chord.root.name).to eq('A')
      expect(chord.type).to eq(:minor)
    end

    it 'creates chord from root and type' do
      chord = described_class.new('C', :major)
      expect(chord.root.name).to eq('C')
      expect(chord.type).to eq(:major)
    end

    it 'parses major chords (no suffix)' do
      chord = described_class.new('C')
      expect(chord.type).to eq(:major)
    end

    it 'parses minor chords' do
      chord = described_class.new('Am')
      expect(chord.type).to eq(:minor)
    end

    it 'parses dominant 7th' do
      chord = described_class.new('G7')
      expect(chord.type).to eq(:dom7)
    end

    it 'parses major 7th' do
      chord = described_class.new('Cmaj7')
      expect(chord.type).to eq(:maj7)
    end

    it 'parses minor 7th' do
      chord = described_class.new('Dm7')
      expect(chord.type).to eq(:min7)
    end

    it 'parses diminished' do
      chord = described_class.new('Bdim')
      expect(chord.type).to eq(:dim)
    end

    it 'parses m7b5' do
      chord = described_class.new('Bm7b5')
      expect(chord.type).to eq(:min7b5)
    end

    it 'parses sharp root' do
      chord = described_class.new('F#m')
      expect(chord.root.name).to eq('F#')
      expect(chord.type).to eq(:minor)
    end

    it 'parses flat root' do
      chord = described_class.new('Bbmaj7')
      expect(chord.root.name).to eq('Bb')
      expect(chord.type).to eq(:maj7)
    end

    it 'parses sus4' do
      chord = described_class.new('Asus4')
      expect(chord.type).to eq(:sus4)
    end

    it 'raises error for invalid symbol' do
      expect { described_class.new('XYZ') }.to raise_error(ArgumentError)
    end
  end

  describe '#notes / #note_names' do
    it 'returns correct notes for C major' do
      chord = described_class.new('C')
      expect(chord.note_names).to eq(%w[C E G])
    end

    it 'returns correct notes for Am' do
      chord = described_class.new('Am')
      expect(chord.note_names).to eq(%w[A C E])
    end

    it 'returns correct notes for G7' do
      chord = described_class.new('G7')
      expect(chord.note_names).to eq(%w[G B D F])
    end

    it 'returns correct notes for Cmaj7' do
      chord = described_class.new('Cmaj7')
      expect(chord.note_names).to eq(%w[C E G B])
    end

    it 'returns correct notes for Dm7' do
      chord = described_class.new('Dm7')
      expect(chord.note_names).to eq(%w[D F A C])
    end

    it 'returns correct notes for Bdim' do
      chord = described_class.new('Bdim')
      expect(chord.note_names).to eq(%w[B D F])
    end
  end

  describe '#symbol' do
    it 'returns the chord symbol' do
      expect(described_class.new('C').symbol).to eq('C')
      expect(described_class.new('Am').symbol).to eq('Am')
      expect(described_class.new('G7').symbol).to eq('G7')
      expect(described_class.new('Cmaj7').symbol).to eq('Cmaj7')
      expect(described_class.new('Dm7').symbol).to eq('Dm7')
    end
  end

  describe '#triad? / #tetrad?' do
    it 'identifies triads' do
      expect(described_class.new('C').triad?).to be true
      expect(described_class.new('Am').triad?).to be true
    end

    it 'identifies tetrads' do
      expect(described_class.new('Cmaj7').tetrad?).to be true
      expect(described_class.new('G7').tetrad?).to be true
    end
  end

  describe '#major? / #minor? / #dominant? / #diminished?' do
    it 'identifies major chords' do
      expect(described_class.new('C').major?).to be true
      expect(described_class.new('Cmaj7').major?).to be true
    end

    it 'identifies minor chords' do
      expect(described_class.new('Am').minor?).to be true
      expect(described_class.new('Am7').minor?).to be true
    end

    it 'identifies dominant chords' do
      expect(described_class.new('G7').dominant?).to be true
    end

    it 'identifies diminished chords' do
      expect(described_class.new('Bdim').diminished?).to be true
    end
  end

  describe '#suggested_scales' do
    it 'suggests scales for major chords' do
      chord = described_class.new('C')
      scales = chord.suggested_scales
      expect(scales.map(&:type)).to include(:major, :pentatonic_major)
    end

    it 'suggests scales for minor chords' do
      chord = described_class.new('Am')
      scales = chord.suggested_scales
      expect(scales.map(&:type)).to include(:minor, :pentatonic_minor, :blues)
    end

    it 'suggests mixolydian for dominant chords' do
      chord = described_class.new('G7')
      scales = chord.suggested_scales
      expect(scales.map(&:type)).to include(:mixolydian)
    end
  end

  describe '#interval_names' do
    it 'returns interval short names' do
      chord = described_class.new('C')
      expect(chord.interval_names).to eq(%w[1 3 5])
    end

    it 'returns flat intervals for minor chords' do
      chord = described_class.new('Am')
      expect(chord.interval_names).to eq(%w[1 b3 5])
    end
  end
end
