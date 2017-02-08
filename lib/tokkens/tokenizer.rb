require_relative 'tokens'

module Tokkens
  # Converts a string to a list of token numbers.
  #
  # Useful for computing with text, like machine learning.
  # Before using the tokenizer, you're expected to have pre-processed
  # the textdepending on application. For example, converting to lowercase,
  # removing non-word characters, transliterating accented characters.
  #
  # This class then splits the string into tokens by whitespace, and
  # removes tokens not passing the selection criteria.
  #
  class Tokenizer

    # default minimum token length
    MIN_LENGTH = 2

    # no default stop words to ignore
    STOP_WORDS = []

    # @!attribute [r] tokens
    #   @return [Tokens] object to use for obtaining tokens
    # @!attribute [r] stop_words
    #   @return [Array<String>] stop words to ignore
    # @!attribute [r] min_length
    #   @return [Fixnum] Minimum length for tokens
    attr_reader :tokens, :stop_words, :min_length

    # Create a new tokenizer
    #
    # @param tokens [Tokens] object to use for obtaining token numbers
    # @param min_length [Fixnum] minimum length for tokens
    # @param stop_words [Array<String>] stop words to ignore
    def initialize(tokens = nil, min_length: MIN_LENGTH, stop_words: STOP_WORDS)
      @tokens = tokens || Tokens.new
      @stop_words = stop_words
      @min_length = min_length
    end

    # @return [Array<Fixnum>] array of token numbers
    def get(s, **kwargs)
      return [] if !s || s.strip == ''
      tokenize(s).map {|token| @tokens.get(token, **kwargs) }.compact
    end

    private

    def tokenize(s)
      s.split.select(&method(:include?))
    end

    def include?(s)
      s.length >= @min_length && !@stop_words.include?(s)
    end
  end
end
