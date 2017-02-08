# Tokkens

[![Build Status](https://travis-ci.org/q-m/tokkens-ruby.svg?branch=master)](https://travis-ci.org/q-m/tokkens-ruby)
[![Documentation](https://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/github/q-m/tokkens-ruby/master)

`Tokkens` makes it easy to apply a [vector space model](https://en.wikipedia.org/wiki/Vector_space_model)
to text documents, targeted towards with machine learning. It provides a mapping
between numbers and tokens (strings).

Read more about [installation](#installation),  [usage](#usage) or skip to an [example](#example).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tokkens'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tokkens

Note that you'll need [Ruby](http://ruby-lang.org/) 2+.

## Usage

### Tokens

#### `get` and `find`

`Tokens` is a store for mapping strings (tokens) to numbers. Each string gets
its own unique number. First instantiate a new instance.

```ruby
require 'tokkens'
@tokens = Tokkens::Tokens.new
```

Then `get` a number for some tokens. You'll notice that each distinct token
gets its own number.

```ruby
puts @tokens.get('foo')
# => 1
puts @tokens.get('bar')
# => 2
puts @tokens.get('foo')
# => 1
```

The reverse operation is `find` (code is optimized for `get`).

```ruby
puts @tokens.find(2)
# => "bar"
```

The `prefix` option can be used to add a prefix to the token.

```ruby
puts @tokens.get('blup', prefix: 'DESC:')
# => 3
puts @tokens.find(3)
# => "DESC:blup"
puts @tokens.find(3, prefix: 'DESC:')
# => "blup"
```

#### `load` and `save`

To persist tokens across runs, one can load and save the list of tokens. At the
moment, this is a plain text file, with one line containing number, occurence and token.

```ruby
@tokens.save('foo.tokens')
# ---- some time later
@tokens = Tokkens::Tokens.new
@tokens.load('foo.tokens')
```

#### `limit!`

One common operation is reducing the number of words, to retain only those that are
most relevant. This is called feature selection or
[dimensionality reduction](https://en.wikipedia.org/wiki/Dimensionality_reduction).
You can select by maximum `max_size` (most occuring words are kept).

```ruby
@tokens = Tokkens::Tokens.new
@tokens.get('foo')
@tokens.get('bar')
@tokens.get('baz')
@tokens.indexes
# => [1, 2, 3]
@tokens.limit!(max_size: 2)
@tokens.indexes
# => [1, 2]
```

Or you can reduce by minimum `occurence`.

```ruby
@tokens.get('zab')
# => 4
@tokens.get('bar')
# => 2
@tokens.indexes
# => [1, 2, 4]
@tokens.limit!(occurence: 2)
@tokens.indexes
# => [2]
```

Note that this limits only the tokens store, if you reference the tokens removed
elsewhere, you may still need to remove those.

#### `freeze!` and `thaw!`

`Tokens` may be used to train a model from a training dataset, and then use it to
predict based on the model. In this case, new tokens need to be added during the
training stage, but it doesn't make sense to generate new tokens during prediction.

By default, `Tokens` makes new tokens when an unrecognized token is passed to `get`.
But when it has been `frozen?` by `freeze!`, new tokens will return `nil` instead.
If for some reason, you'd like to add new tokens again, use `thaw!`.

```ruby
@tokens.freeze!
@tokens.get('hithere')
# => 4
@tokens.get('blahblah')
# => nil
@tokens.thaw!
@tokens.get('blahblah')
# => 5
```

Note that after `load`ing, the state may be frozen.

### Tokenizer

When processing sentences or other text bodies, `Tokenizer` provides a way to map
this to an array of numbers (using `Token`).

```ruby
@tokenizer = Tokkens::Tokenizer.new
@tokenizer.get('hi from example')
# => [1, 2, 3]
@tokenizer.tokens.find(3)
# => "example"
```

The `prefix` keyword argument also works here.

```ruby
@tokenizer.get('from example', prefix: 'X:')
# => [4, 5]
@tokenizer.tokens.find(5)
# => "X:example"
```

One can specify a minimum length (default 2) and stop words for tokenizing.

```ruby
@tokenizer = Tokkens::Tokenizer.new(min_length: 3, stop_words: %w(and the))
@tokenizer.get('the cat and a bird').map {|i| @tokenizer.tokens.find(i)}
# => ["cat", "bird"]
```

### Example

A basic text classification example using [liblinear](https://www.csie.ntu.edu.tw/~cjlin/liblinear/)
can be found in [examples/classify.rb](examples/classify.rb). Run it as follows:

```
$ gem install liblinear-ruby
$ ruby examples/classify.rb
How many students are in for the exams today? -> students exams -> school
The forest has large trees, while the field has its flowers. -> trees field flowers -> nature
Can we park our cars inside that building to go shopping? -> cars building shopping -> city
```

The classifier was trained using three training sentences for each class.
The output shows a prediction for three test sentences. Each test sentence is
printed, followed by the tokens, followed by the predicted class.

## [MIT license](LICENSE.md)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/tokkens/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Make sure the tests are green (`rspec`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
