# frozen_string_literal: true

RSpec.describe Bardo::Theory::Scale do
  describe '.new' do
    it 'creates a scale from root and type' do
      scale = described_class.new('C', :major)
      expect(scale.root.name).to eq('C')
      expect(scale.type).to eq(:major)
    end

    it 'accepts string type' do
      scale = described_class.new('A', 'minor')
      expect(scale.type).to eq(:minor)
    end

    it 'raises error for unknown scale type' do
      expect { described_class.new('C', :unknown) }.to raise_error(ArgumentError, /Escala desconhecida/)
    end
  end

  describe '#notes / #note_names' do
    it 'returns correct notes for C major' do
      scale = described_class.new('C', :major)
      expect(scale.note_names).to eq(%w[C D E F G A B])
    end

    it 'returns correct notes for G major' do
      scale = described_class.new('G', :major)
      expect(scale.note_names).to eq(%w[G A B C D E F#])
    end

    it 'returns correct notes for A minor' do
      scale = described_class.new('A', :minor)
      expect(scale.note_names).to eq(%w[A B C D E F G])
    end

    it 'returns correct notes for A pentatonic minor' do
      scale = described_class.new('A', :pentatonic_minor)
      expect(scale.note_names).to eq(%w[A C D E G])
    end

    it 'returns correct notes for C pentatonic major' do
      scale = described_class.new('C', :pentatonic_major)
      expect(scale.note_names).to eq(%w[C D E G A])
    end

    it 'returns correct notes for A blues' do
      scale = described_class.new('A', :blues)
      expect(scale.note_names).to eq(%w[A C D D# E G])
    end

    it 'returns correct notes for D dorian' do
      scale = described_class.new('D', :dorian)
      expect(scale.note_names).to eq(%w[D E F G A B C])
    end

    it 'returns correct notes for E phrygian' do
      scale = described_class.new('E', :phrygian)
      expect(scale.note_names).to eq(%w[E F G A B C D])
    end

    it 'returns correct notes for F lydian' do
      scale = described_class.new('F', :lydian)
      expect(scale.note_names).to eq(%w[F G A B C D E])
    end

    it 'returns correct notes for G mixolydian' do
      scale = described_class.new('G', :mixolydian)
      expect(scale.note_names).to eq(%w[G A B C D E F])
    end

    it 'uses flats for flat keys' do
      scale = described_class.new('F', :major)
      expect(scale.note_names).to include('Bb')
    end
  end

  describe '#degree' do
    it 'returns the nth degree note' do
      scale = described_class.new('C', :major)
      expect(scale.degree(5).name).to eq('G')
    end

    it 'raises error for out-of-range degree' do
      scale = described_class.new('C', :major)
      expect { scale.degree(0) }.to raise_error(ArgumentError)
      expect { scale.degree(8) }.to raise_error(ArgumentError)
    end
  end

  describe '#includes?' do
    let(:scale) { described_class.new('C', :major) }

    it 'returns true for notes in the scale' do
      expect(scale.includes?('E')).to be true
    end

    it 'returns false for notes not in the scale' do
      expect(scale.includes?('F#')).to be false
    end

    it 'accepts Note objects' do
      note = Bardo::Theory::Note.new('G')
      expect(scale.includes?(note)).to be true
    end
  end

  describe '#description' do
    it 'returns a description for each scale type' do
      described_class.available_types.each do |type|
        scale = described_class.new('C', type)
        expect(scale.description).to be_a(String)
        expect(scale.description).not_to be_empty
      end
    end
  end

  describe '#intervals' do
    it 'returns Interval objects' do
      scale = described_class.new('C', :major)
      expect(scale.intervals).to all(be_a(Bardo::Theory::Interval))
    end
  end

  describe '.find_matching' do
    it 'finds scales containing given notes' do
      results = described_class.find_matching(%w[C E G])
      expect(results).not_to be_empty
      expect(results.map(&:type)).to include(:major)
    end

    it 'filters by root when specified' do
      results = described_class.find_matching(%w[C E G], root: 'C')
      expect(results).to all(have_attributes(root: have_attributes(name: 'C')))
    end
  end

  describe '.available_types' do
    it 'returns all scale types' do
      types = described_class.available_types
      expect(types).to include(:major, :minor, :pentatonic_minor, :blues, :dorian, :mixolydian)
    end
  end

  describe 'relative minor/major relationship' do
    it 'A minor has the same notes as C major' do
      c_major = described_class.new('C', :major)
      a_minor = described_class.new('A', :minor)

      c_notes = c_major.notes.map(&:semitones_from_c).sort
      a_notes = a_minor.notes.map(&:semitones_from_c).sort

      expect(c_notes).to eq(a_notes)
    end

    it 'A pentatonic minor has the same notes as C pentatonic major' do
      c_pent_maj = described_class.new('C', :pentatonic_major)
      a_pent_min = described_class.new('A', :pentatonic_minor)

      c_notes = c_pent_maj.notes.map(&:semitones_from_c).sort
      a_notes = a_pent_min.notes.map(&:semitones_from_c).sort

      expect(c_notes).to eq(a_notes)
    end
  end

  describe 'modes share notes with parent major scale' do
    it 'D dorian has same notes as C major' do
      c_major = described_class.new('C', :major)
      d_dorian = described_class.new('D', :dorian)

      c_notes = c_major.notes.map(&:semitones_from_c).sort
      d_notes = d_dorian.notes.map(&:semitones_from_c).sort

      expect(c_notes).to eq(d_notes)
    end

    it 'G mixolydian has same notes as C major' do
      c_major = described_class.new('C', :major)
      g_mixo = described_class.new('G', :mixolydian)

      c_notes = c_major.notes.map(&:semitones_from_c).sort
      g_notes = g_mixo.notes.map(&:semitones_from_c).sort

      expect(c_notes).to eq(g_notes)
    end
  end
end
