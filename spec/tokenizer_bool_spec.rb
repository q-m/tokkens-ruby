require_relative 'spec_helper'

describe TokenizerBool do
  let(:tokenizer) { described_class.new }
  let(:offset) { 1 } # default token offset

  describe '#get' do
    it 'does tokenization' do
      expect(tokenizer.get('foo bar')).to eq ([offset, offset + 1])
    end

    it 'ignores too short tokens' do
      t = described_class.new(min_length: 2)
      expect(t.get('x')).to eq []
    end

    it 'ignores stop words' do
      t = described_class.new(stop_words: ['xyz'])
      expect(t.get('xyz foo')).to eq [offset]
    end
  end

  describe '#tokens' do
    it 'returns a tokens object by default' do
      expect(tokenizer.tokens).to be_a Tokens
    end

    it 'can be overridden' do
      tokens = Tokens.new
      t = described_class.new(tokens)
      expect(t.tokens).to be tokens
    end
  end
end
