# frozen_string_literal: true

RSpec.describe Bardo::Fretboard::Renderer do
  let(:tuning) { Bardo::Fretboard::Tuning.new(:standard) }
  let(:colors) { Bardo::UI::Colors.new }
  let(:renderer) { described_class.new(tuning: tuning, colors: colors) }

  describe '#render' do
    it 'renders without errors' do
      notes = Bardo::Theory::Scale.new('A', :pentatonic_minor).notes
      output = renderer.render(notes)
      expect(output).to be_a(String)
      expect(output).not_to be_empty
    end

    it 'includes all 6 strings' do
      notes = Bardo::Theory::Scale.new('C', :major).notes
      output = renderer.render(notes)
      lines = output.split("\n").select { |l| l.include?('|') }
      expect(lines.length).to eq(6)
    end

    it 'includes fret numbers' do
      notes = [Bardo::Theory::Note.new('A')]
      output = renderer.render(notes)
      expect(output).to include('0')
      expect(output).to include('12')
    end

    it 'includes legend' do
      notes = Bardo::Theory::Scale.new('A', :pentatonic_minor).notes
      output = renderer.render(notes)
      expect(output).to include('Tonica')
    end

    it 'respects custom fret count' do
      notes = [Bardo::Theory::Note.new('E')]
      output = renderer.render(notes, frets: 5)
      # Should not include high fret numbers
      expect(output).not_to include('  12  ')
    end
  end
end

RSpec.describe Bardo::Fretboard::Tuning do
  describe '.new' do
    it 'creates standard tuning' do
      tuning = described_class.new(:standard)
      expect(tuning.strings).to eq(%w[E B G D A E])
    end

    it 'creates drop D tuning' do
      tuning = described_class.new(:drop_d)
      expect(tuning.strings.last).to eq('D')
    end

    it 'raises error for unknown tuning' do
      expect { described_class.new(:unknown) }.to raise_error(ArgumentError)
    end
  end

  describe '#string_notes' do
    it 'returns Note objects' do
      tuning = described_class.new(:standard)
      expect(tuning.string_notes).to all(be_a(Bardo::Theory::Note))
    end
  end

  describe '.available' do
    it 'returns available tuning names' do
      expect(described_class.available).to include(:standard, :drop_d)
    end
  end
end
