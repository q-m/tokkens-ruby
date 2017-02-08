module Tokkens
  # Converts a string token to a uniquely identifying sequential number.
  #
  # Useful for working with a {https://en.wikipedia.org/wiki/Vector_space_model vector space model}
  # for text.
  class Tokens

    # @!attribute [r] offset
    #   @return [Fixnum] Number of first token.
    attr_accessor :offset

    def initialize(offset: 1)
      # liblinear can't use offset 0, libsvm doesn't mind to start at one
      @tokens = {}
      @offset = offset
      @next_number = offset
      @frozen = false
    end

    # Stop assigning new numbers to token.
    # @see #frozen?
    # @see #thaw!
    def freeze!
      @frozen = true
    end

    # Allow new tokens to be created.
    # @see #freeze!
    # @see #frozen?
    def thaw!
      @frozen = false
    end

    # @return [Boolean] Whether the tokens are frozen or not.
    # @see #freeze!
    # @see #thaw!
    def frozen?
      @frozen
    end

    # Limit the number of tokens.
    #
    # @param max_size [Fixnum] Maximum number of tokens to retain
    # @param occurence [Fixnum] Keep only tokens seen at least this many times
    # @return [Fixnum] Number of tokens left
    def limit!(max_size: nil, occurence: nil)
      # @todo raise if frozen
      if occurence
        @tokens.delete_if {|name, data| data[1] < occurence }
      end
      if max_size
        @tokens = Hash[@tokens.to_a.sort_by {|a| -a[1][1] }[0..(max_size-1)]]
      end
      @tokens.length
    end

    # Return a number for a new or existing token.
    #
    # When the token was seen before, the same number is returned. If the token
    # is first seen and this class isn't {#frozen?}, a new number is returned;
    # else +nil+ is returned.
    #
    # @param s [String] token to return number for
    # @option kwargs [String] :prefix optional string to prepend to the token
    # @return [Fixnum, NilClass] number for given token
    def get(s, **kwargs)
      return if !s || s.strip == ''
      @frozen ? retrieve(s, **kwargs) : upsert(s, **kwargs)
    end

    # Return an token by number.
    #
    # This class is optimized for retrieving by token, not by number.
    #
    # @param i [String] number to return token for
    # @param prefix [String] optional string to remove from beginning of token
    # @return [String, NilClass] given token, or +nil+ when not found
    def find(i, prefix: nil)
      @tokens.each do |s, data|
        if data[0] == i
          return (prefix && s.start_with?(prefix)) ? s[prefix.length..-1] : s
        end
      end
      nil
    end

    # Return indexes for all of the current tokens.
    #
    # @return [Array<Fixnum>] All current token numbers.
    # @see #limit!
    def indexes
      @tokens.values.map(&:first)
    end

    # Load tokens from file.
    #
    # The tokens are frozen by default.
    # All previously existing tokens are removed.
    #
    # @param filename [String] Filename
    def load(filename)
      File.open(filename) do |f|
        @tokens = {}
        f.each_line do |line|
          id, count, name = line.rstrip.split(/\s+/, 3)
          @tokens[name.strip] = [id.to_i, count]
        end
      end
      # safer
      freeze!
    end

    # Save tokens to file.
    #
    # @param filename [String] Filename
    def save(filename)
      File.open(filename, 'w') do |f|
        @tokens.each do |token, (index, count)|
          f.puts "#{index} #{count} #{token}"
        end
      end
    end

    private

    def retrieve(s, prefix: '')
      data = @tokens[prefix + s]
      data[0] if data
    end

    # return token number, update next_number; always returns a number
    def upsert(s, prefix: '')
      unless data = @tokens[prefix + s]
        @tokens[prefix + s] = data = [@next_number, 0]
        @next_number += 1
      end
      data[1] += 1
      data[0]
    end
  end
end
