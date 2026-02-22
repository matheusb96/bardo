# frozen_string_literal: true

RSpec.describe Bardo::Improv::Guide do
  let(:colors) { Bardo::UI::Colors.new }

  describe '.new' do
    it 'creates a guide for a major key' do
      guide = described_class.new('C', :major, colors: colors)
      expect(guide.root.name).to eq('C')
      expect(guide.mode).to eq(:major)
    end

    it 'creates a guide for a minor key' do
      guide = described_class.new('A', :minor, colors: colors)
      expect(guide.mode).to eq(:minor)
    end
  end

  describe '#mode_name' do
    it 'returns Maior for major' do
      guide = described_class.new('C', :major, colors: colors)
      expect(guide.mode_name).to eq('Maior')
    end

    it 'returns Menor for minor' do
      guide = described_class.new('A', :minor, colors: colors)
      expect(guide.mode_name).to eq('Menor')
    end
  end

  describe '#cheat_sheet' do
    let(:guide) { described_class.new('C', :major, colors: colors) }

    it 'returns a non-empty string' do
      output = guide.cheat_sheet
      expect(output).to be_a(String)
      expect(output).not_to be_empty
    end

    it 'includes the key name' do
      output = guide.cheat_sheet
      expect(output).to include('C Maior')
    end

    it 'includes harmonic field section' do
      output = guide.cheat_sheet
      expect(output).to include('CAMPO HARMONICO')
    end

    it 'includes scales per chord section' do
      output = guide.cheat_sheet
      expect(output).to include('ESCALAS POR ACORDE')
    end

    it 'includes safe choices section' do
      output = guide.cheat_sheet
      expect(output).to include('SAFE CHOICES')
    end

    it 'includes progressions section' do
      output = guide.cheat_sheet
      expect(output).to include('PROGRESSOES COMUNS')
    end

    it 'includes fretboard section' do
      output = guide.cheat_sheet
      expect(output).to include('FRETBOARD')
    end

    it 'includes voicings section' do
      output = guide.cheat_sheet
      expect(output).to include('VOICINGS')
    end
  end

  describe '#harmonic_field_section' do
    it 'shows triads and tetrads for C major' do
      guide = described_class.new('C', :major, colors: colors)
      output = guide.harmonic_field_section
      expect(output).to include('C')
      expect(output).to include('Dm')
      expect(output).to include('G')
    end
  end

  describe '#scales_per_chord_section' do
    it 'shows mode for each chord' do
      guide = described_class.new('C', :major, colors: colors)
      output = guide.scales_per_chord_section
      expect(output).to include('Ionian')
      expect(output).to include('Dorian')
      expect(output).to include('Mixolydian')
    end

    it 'includes the helpful tip' do
      guide = described_class.new('C', :major, colors: colors)
      output = guide.scales_per_chord_section
      expect(output).to include('MESMAS notas')
    end
  end

  describe '#safe_choices_section' do
    it 'suggests pentatonic major for major keys' do
      guide = described_class.new('A', :major, colors: colors)
      output = guide.safe_choices_section
      expect(output).to include('Pentatonica maior')
    end

    it 'suggests pentatonic minor for minor keys' do
      guide = described_class.new('A', :minor, colors: colors)
      output = guide.safe_choices_section
      expect(output).to include('Pentatonica menor')
    end

    it 'suggests blues scale for minor keys' do
      guide = described_class.new('A', :minor, colors: colors)
      output = guide.safe_choices_section
      expect(output).to include('Blues')
    end

    it 'suggests relative pentatonic' do
      guide = described_class.new('C', :major, colors: colors)
      output = guide.safe_choices_section
      expect(output).to include('relativa')
    end
  end

  describe '#common_progressions_section' do
    it 'shows common major progressions' do
      guide = described_class.new('C', :major, colors: colors)
      output = guide.common_progressions_section
      # I - IV - V in C should show C - F - G
      expect(output).to include('C')
      expect(output).to include('F')
      expect(output).to include('G')
    end

    it 'shows common minor progressions' do
      guide = described_class.new('A', :minor, colors: colors)
      output = guide.common_progressions_section
      expect(output).to include('Am')
    end
  end

  describe 'different keys' do
    it 'works for all 12 major keys' do
      %w[C D E F G A B].each do |root|
        guide = described_class.new(root, :major, colors: colors)
        expect { guide.cheat_sheet }.not_to raise_error
      end
    end

    it 'works for sharp/flat keys' do
      %w[F# Bb Eb Ab].each do |root|
        guide = described_class.new(root, :major, colors: colors)
        expect { guide.cheat_sheet }.not_to raise_error
      end
    end

    it 'works for minor keys' do
      %w[A E D B F#].each do |root|
        guide = described_class.new(root, :minor, colors: colors)
        expect { guide.cheat_sheet }.not_to raise_error
      end
    end
  end
end
