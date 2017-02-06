require_relative 'spec_helper'
require 'tempfile'

describe Tokens do
  let(:tokens) { described_class.new }
  let(:offset) { 1 } # default offset

  describe '#get' do
    it 'can new tokens' do
      expect(tokens.get('bar')).to eq offset
      expect(tokens.get('foo')).to eq (offset + 1)
    end

    it 'can get an existing token' do
      tokens.get('bar')
      expect(tokens.get('bar')).to eq offset
    end

    it 'can include a prefix' do
      tokens.get('bar', prefix: 'XyZ$')
      expect(tokens.get('XyZ$bar')).to eq offset
    end

    it 'can get an existing token when frozen' do
      tokens.get('blup')
      tokens.freeze!
      expect(tokens.get('blup')).to eq offset
    end

    it 'cannot get a new token when frozen' do
      tokens.get('blup')
      tokens.freeze!
      expect(tokens.get('blabla')).to be_nil
    end
  end

  describe '#find' do
    it 'can find an existing token' do
      tokens.get('blup')
      i = tokens.get('blah')
      expect(tokens.find(i)).to eq 'blah'
    end

    it 'returns nil for a non-existing token' do
      tokens.get('blup')
      expect(tokens.find(offset + 1)).to eq nil
    end
  end

  describe '#indexes' do
    it 'is empty without tokens' do
      expect(tokens.indexes).to eq []
    end

    it 'returns the expected indexes' do
      tokens.get('foo')
      tokens.get('blup')
      expect(tokens.indexes).to eq [offset, offset + 1]
    end
  end

  describe '#offset' do
    it 'has a default' do
      expect(described_class.new.offset).to eq offset
    end

    it 'can override the default' do
      expect(described_class.new(offset: 5).offset).to eq 5
    end

    it 'affects the first number' do
      tokens = described_class.new(offset: 12)
      expect(tokens.get('hi')).to eq 12
    end
  end

  describe '#frozen?' do
    it 'is not frozen by default' do
      expect(tokens.frozen?).to be false
    end

    it 'can be frozen' do
      tokens.freeze!
      expect(tokens.frozen?).to be true
    end

    it 'can be thawed' do
      tokens.freeze!
      tokens.thaw!
      expect(tokens.frozen?).to be false
    end
  end

  describe '#limit!' do
    it 'limits to most frequent tokens by count' do
      tokens.get('foo')
      tokens.get('blup')
      tokens.get('blup')
      tokens.limit!(count: 1)
      expect(tokens.indexes).to eq [offset + 1]
    end

    it 'limits by occurence' do
      tokens.get('foo')
      tokens.get('blup')
      tokens.get('foo')
      tokens.limit!(occurence: 2)
      expect(tokens.indexes).to eq [offset]
    end
  end

  describe '#load' do
    let(:file) { Tempfile.new('tokens') }
    after { file.unlink }

    it 'saves and loads tokens' do
      tokens.get('foo')
      tokens.get('bar')
      tokens.save(file.path)
      expect(File.exists?(file.path)).to be true
      expect(File.zero?(file.path)).to be false

      ntokens = described_class.new
      ntokens.load(file.path)
      expect(tokens.get('bar')).to eq (offset + 1)
    end
  end
end
