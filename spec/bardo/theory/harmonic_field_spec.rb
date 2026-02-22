# frozen_string_literal: true

RSpec.describe Bardo::Theory::HarmonicField do
  describe '.new' do
    it 'creates a major harmonic field' do
      hf = described_class.new('C', :major)
      expect(hf.root.name).to eq('C')
      expect(hf.mode).to eq(:major)
    end

    it 'creates a minor harmonic field' do
      hf = described_class.new('A', :minor)
      expect(hf.mode).to eq(:minor)
    end

    it 'raises error for invalid mode' do
      expect { described_class.new('C', :blues) }.to raise_error(ArgumentError)
    end
  end

  describe '#triads' do
    it 'returns correct triads for C major' do
      hf = described_class.new('C', :major)
      symbols = hf.triads.map(&:symbol)
      expect(symbols).to eq(%w[C Dm Em F G Am Bdim])
    end

    it 'returns correct triads for G major' do
      hf = described_class.new('G', :major)
      symbols = hf.triads.map(&:symbol)
      expect(symbols).to eq(%w[G Am Bm C D Em F#dim])
    end

    it 'returns correct triads for A minor' do
      hf = described_class.new('A', :minor)
      symbols = hf.triads.map(&:symbol)
      expect(symbols).to eq(%w[Am Bdim C Dm Em F G])
    end
  end

  describe '#tetrads' do
    it 'returns correct tetrads for C major' do
      hf = described_class.new('C', :major)
      symbols = hf.tetrads.map(&:symbol)
      expect(symbols).to eq(%w[Cmaj7 Dm7 Em7 Fmaj7 G7 Am7 Bm7b5])
    end

    it 'returns correct tetrads for A minor' do
      hf = described_class.new('A', :minor)
      symbols = hf.tetrads.map(&:symbol)
      expect(symbols).to eq(%w[Am7 Bm7b5 Cmaj7 Dm7 Em7 Fmaj7 G7])
    end
  end

  describe '#degree' do
    let(:hf) { described_class.new('C', :major) }

    it 'returns correct info for degree I' do
      info = hf.degree(1)
      expect(info[:triad].symbol).to eq('C')
      expect(info[:tetrad].symbol).to eq('Cmaj7')
      expect(info[:function]).to include('Tônica')
    end

    it 'returns correct info for degree V' do
      info = hf.degree(5)
      expect(info[:triad].symbol).to eq('G')
      expect(info[:tetrad].symbol).to eq('G7')
      expect(info[:function]).to include('Dominante')
    end

    it 'returns correct info for degree VII' do
      info = hf.degree(7)
      expect(info[:triad].symbol).to eq('Bdim')
      expect(info[:function]).to include('Dominante')
    end

    it 'raises error for invalid degree' do
      expect { hf.degree(0) }.to raise_error(ArgumentError)
      expect { hf.degree(8) }.to raise_error(ArgumentError)
    end
  end

  describe '#roman_numeral' do
    let(:hf) { described_class.new('C', :major) }

    it 'uses uppercase for major chords' do
      expect(hf.roman_numeral(1)).to eq('I')
      expect(hf.roman_numeral(4)).to eq('IV')
      expect(hf.roman_numeral(5)).to eq('V')
    end

    it 'uses lowercase for minor chords' do
      expect(hf.roman_numeral(2)).to eq('ii')
      expect(hf.roman_numeral(3)).to eq('iii')
      expect(hf.roman_numeral(6)).to eq('vi')
    end

    it 'adds degree symbol for diminished' do
      expect(hf.roman_numeral(7)).to eq('vii°')
    end
  end

  describe '#chords_data' do
    it 'returns 7 degrees' do
      hf = described_class.new('C', :major)
      expect(hf.chords_data.length).to eq(7)
    end

    it 'includes all necessary keys' do
      hf = described_class.new('C', :major)
      data = hf.chords_data.first
      expect(data).to have_key(:degree)
      expect(data).to have_key(:numeral)
      expect(data).to have_key(:triad)
      expect(data).to have_key(:tetrad)
      expect(data).to have_key(:function)
      expect(data).to have_key(:mode)
    end
  end

  describe '#mode_for_degree' do
    let(:hf) { described_class.new('C', :major) }

    it 'returns Ionian for degree I' do
      mode = hf.mode_for_degree(1)
      expect(mode.type).to eq(:ionian)
      expect(mode.root.name).to eq('C')
    end

    it 'returns Dorian for degree II' do
      mode = hf.mode_for_degree(2)
      expect(mode.type).to eq(:dorian)
      expect(mode.root.name).to eq('D')
    end

    it 'returns Phrygian for degree III' do
      mode = hf.mode_for_degree(3)
      expect(mode.type).to eq(:phrygian)
      expect(mode.root.name).to eq('E')
    end

    it 'returns Lydian for degree IV' do
      mode = hf.mode_for_degree(4)
      expect(mode.type).to eq(:lydian)
    end

    it 'returns Mixolydian for degree V' do
      mode = hf.mode_for_degree(5)
      expect(mode.type).to eq(:mixolydian)
      expect(mode.root.name).to eq('G')
    end

    it 'returns Aeolian for degree VI' do
      mode = hf.mode_for_degree(6)
      expect(mode.type).to eq(:aeolian)
      expect(mode.root.name).to eq('A')
    end

    it 'returns Locrian for degree VII' do
      mode = hf.mode_for_degree(7)
      expect(mode.type).to eq(:locrian)
      expect(mode.root.name).to eq('B')
    end

    it 'all modes share the same notes as the parent scale' do
      parent_notes = hf.scale.notes.map(&:semitones_from_c).sort

      (1..7).each do |n|
        mode = hf.mode_for_degree(n)
        mode_notes = mode.notes.map(&:semitones_from_c).sort
        expect(mode_notes).to eq(parent_notes), "Mode for degree #{n} (#{mode.type}) has different notes"
      end
    end

    it 'raises error for invalid degree' do
      expect { hf.mode_for_degree(0) }.to raise_error(ArgumentError)
      expect { hf.mode_for_degree(8) }.to raise_error(ArgumentError)
    end

    context 'with minor key' do
      let(:hf_minor) { described_class.new('A', :minor) }

      it 'returns Aeolian for degree I' do
        mode = hf_minor.mode_for_degree(1)
        expect(mode.type).to eq(:aeolian)
        expect(mode.root.name).to eq('A')
      end

      it 'returns Ionian for degree III' do
        mode = hf_minor.mode_for_degree(3)
        expect(mode.type).to eq(:ionian)
        expect(mode.root.name).to eq('C')
      end

      it 'returns Mixolydian for degree VII' do
        mode = hf_minor.mode_for_degree(7)
        expect(mode.type).to eq(:mixolydian)
        expect(mode.root.name).to eq('G')
      end
    end
  end

  describe '.identify_key' do
    it 'identifies C major or A minor from Am F C G' do
      candidates = described_class.identify_key(%w[Am F C G])
      keys = candidates.map { |c| c[:key] }
      # Both C Major and A Minor are valid (relative keys, same notes)
      expect(keys.first(2)).to include('C Maior').and include('A Menor')
    end

    it 'identifies C major from Dm7 G7 Cmaj7 (ii-V-I)' do
      candidates = described_class.identify_key(%w[Dm7 G7 Cmaj7])
      keys = candidates.map { |c| c[:key] }
      expect(keys).to include('C Maior')
    end

    it 'returns multiple candidates sorted by match count' do
      candidates = described_class.identify_key(%w[C G Am])
      expect(candidates.first[:matches]).to be >= candidates.last[:matches]
    end
  end

  describe '#to_s' do
    it 'returns readable description' do
      hf = described_class.new('C', :major)
      expect(hf.to_s).to eq('Campo Harmônico de C Maior')
    end

    it 'returns minor description' do
      hf = described_class.new('A', :minor)
      expect(hf.to_s).to eq('Campo Harmônico de A Menor')
    end
  end
end
