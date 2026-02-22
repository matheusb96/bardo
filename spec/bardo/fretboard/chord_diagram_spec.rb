# frozen_string_literal: true

RSpec.describe Bardo::Fretboard::ChordDiagram do
  let(:colors) { Bardo::UI::Colors.new }

  describe '#voicings' do
    it 'returns 5 CAGED voicings for a major chord' do
      diagram = described_class.new('C', colors: colors)
      voicings = diagram.voicings
      expect(voicings.length).to eq(5)
    end

    it 'returns 5 CAGED voicings for a minor chord' do
      diagram = described_class.new('Am', colors: colors)
      voicings = diagram.voicings
      expect(voicings.length).to eq(5)
    end

    it 'returns voicings sorted by position on neck' do
      diagram = described_class.new('C', colors: colors)
      min_frets = diagram.voicings.map { |v| v[:min_fret] }
      expect(min_frets).to eq(min_frets.sort)
    end

    it 'each voicing has required keys' do
      diagram = described_class.new('G', colors: colors)
      diagram.voicings.each do |v|
        expect(v).to have_key(:shape)
        expect(v).to have_key(:frets)
        expect(v).to have_key(:barre_fret)
        expect(v).to have_key(:root_strings)
        expect(v).to have_key(:quality)
      end
    end

    it 'calculates correct frets for E shape of F major (barre 1)' do
      diagram = described_class.new('F', colors: colors)
      e_shape = diagram.voicings.find { |v| v[:shape] == :E }
      expect(e_shape).not_to be_nil
      expect(e_shape[:frets]).to eq([1, 3, 3, 2, 1, 1])
    end

    it 'calculates correct frets for A shape of B major (barre 2)' do
      diagram = described_class.new('B', colors: colors)
      a_shape = diagram.voicings.find { |v| v[:shape] == :A }
      expect(a_shape).not_to be_nil
      expect(a_shape[:frets]).to eq([nil, 2, 4, 4, 4, 2])
    end

    it 'identifies open chords correctly' do
      diagram = described_class.new('E', colors: colors)
      e_shape = diagram.voicings.find { |v| v[:shape] == :E }
      expect(e_shape[:is_open]).to be true
    end

    it 'uses minor shapes for minor chords' do
      diagram = described_class.new('Am', colors: colors)
      diagram.voicings.each do |v|
        expect(v[:quality]).to eq(:minor)
      end
    end

    it 'uses major shapes for major chords' do
      diagram = described_class.new('C', colors: colors)
      diagram.voicings.each do |v|
        expect(v[:quality]).to eq(:major)
      end
    end

    it 'uses major shapes for dominant chords' do
      diagram = described_class.new('G7', colors: colors)
      diagram.voicings.each do |v|
        expect(v[:quality]).to eq(:major)
      end
    end
  end

  describe '#voicings_near' do
    it 'returns voicings near a specific fret' do
      diagram = described_class.new('C', colors: colors)
      near_5 = diagram.voicings_near(5, range: 2)
      expect(near_5).not_to be_empty
      near_5.each do |v|
        min = v[:frets].compact.reject(&:zero?).min || 0
        expect((min - 5).abs).to be <= 2
      end
    end

    it 'returns empty array when no voicings nearby' do
      diagram = described_class.new('C', colors: colors)
      near_20 = diagram.voicings_near(20, range: 1)
      expect(near_20).to be_empty
    end
  end

  describe '#render_voicing' do
    it 'renders a diagram as string' do
      diagram = described_class.new('C', colors: colors)
      voicing = diagram.voicings.first
      output = diagram.render_voicing(voicing)
      expect(output).to be_a(String)
      expect(output).not_to be_empty
    end

    it 'includes string labels' do
      diagram = described_class.new('A', colors: colors)
      voicing = diagram.voicings.first
      output = diagram.render_voicing(voicing)
      expect(output).to include('E A D G B e')
    end

    it 'shows nut for open chords' do
      diagram = described_class.new('E', colors: colors)
      e_shape = diagram.voicings.find { |v| v[:shape] == :E }
      output = diagram.render_voicing(e_shape)
      # Open chord should have nut symbol
      expect(output).to include('╒')
    end

    it 'shows fret number for barre chords' do
      diagram = described_class.new('F', colors: colors)
      e_shape = diagram.voicings.find { |v| v[:shape] == :E }
      output = diagram.render_voicing(e_shape)
      expect(output).to include('fr')
    end
  end

  describe '#render_all' do
    it 'renders all voicings' do
      diagram = described_class.new('G', colors: colors)
      output = diagram.render_all
      expect(output).to be_a(String)
      expect(output).not_to be_empty
    end

    it 'includes shape labels' do
      diagram = described_class.new('A', colors: colors)
      output = diagram.render_all
      expect(output).to include('E shape')
    end
  end

  describe 'CAGED correctness' do
    # Verify the E shape for common chords
    {
      'E' => { shape: :E, expected: [0, 2, 2, 1, 0, 0] },
      'G' => { shape: :E, expected: [3, 5, 5, 4, 3, 3] },
      'A' => { shape: :E, expected: [5, 7, 7, 6, 5, 5] }
    }.each do |chord_name, data|
      it "E shape of #{chord_name} has correct frets" do
        diagram = described_class.new(chord_name, colors: colors)
        voicing = diagram.voicings.find { |v| v[:shape] == data[:shape] }
        expect(voicing[:frets]).to eq(data[:expected])
      end
    end

    # Verify the A shape for common chords
    {
      'A' => { shape: :A, expected: [nil, 0, 2, 2, 2, 0] },
      'C' => { shape: :A, expected: [nil, 3, 5, 5, 5, 3] },
      'D' => { shape: :A, expected: [nil, 5, 7, 7, 7, 5] }
    }.each do |chord_name, data|
      it "A shape of #{chord_name} has correct frets" do
        diagram = described_class.new(chord_name, colors: colors)
        voicing = diagram.voicings.find { |v| v[:shape] == data[:shape] }
        expect(voicing[:frets]).to eq(data[:expected])
      end
    end

    # Verify E minor shapes
    {
      'Em' => { shape: :E, expected: [0, 2, 2, 0, 0, 0] },
      'Fm' => { shape: :E, expected: [1, 3, 3, 1, 1, 1] },
      'Am' => { shape: :E, expected: [5, 7, 7, 5, 5, 5] }
    }.each do |chord_name, data|
      it "Em shape of #{chord_name} has correct frets" do
        diagram = described_class.new(chord_name, colors: colors)
        voicing = diagram.voicings.find { |v| v[:shape] == data[:shape] }
        expect(voicing[:frets]).to eq(data[:expected])
      end
    end

    # Verify Am shapes
    {
      'Am' => { shape: :A, expected: [nil, 0, 2, 2, 1, 0] },
      'Bm' => { shape: :A, expected: [nil, 2, 4, 4, 3, 2] },
      'Cm' => { shape: :A, expected: [nil, 3, 5, 5, 4, 3] }
    }.each do |chord_name, data|
      it "Am shape of #{chord_name} has correct frets" do
        diagram = described_class.new(chord_name, colors: colors)
        voicing = diagram.voicings.find { |v| v[:shape] == data[:shape] }
        expect(voicing[:frets]).to eq(data[:expected])
      end
    end
  end
end
