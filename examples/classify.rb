# Document classification example using tokkens and linear SVM
require 'tokkens'   # `rake install` or `gem install tokkens`
require 'liblinear' # `gem install liblinear-ruby`

# define the training data
TRAINING_DATA = [
  ['school', 'The teacher writes a formula on the blackboard, while students are studying for their exams.'],
  ['school', 'Students play soccer during the break after class, while a teacher watches over them.'],
  ['school', 'All the students are studying hard for the final exams.'],
  ['nature', 'The fox is running around the trees, while flowers bloom in the field.'],
  ['nature', 'Where are the rabbits hiding today? Their holes below the trees are empty.'],
  ['nature', 'The dark sky is bringing rain. The fox hides, rabbits find their holes, but the flowers surrender.'],
  ['city',   'Cars are passing by swiftly, until the traffic lights become red.'],
  ['city',   'Look at the high building, with so many windows. Who would live there?'],
  ['city',   'The shopping centre building is over there, you will find everything you need to buy.'],
]

# after training, these test sentences will receive a predicted classification
TEST_DATA = [
  'How many students are in for the exams today?',
  'The forest has large trees, while the field has its flowers.',
  'Can we park our cars inside that building to go shopping?',
]

# stop words don't carry meaning, we better ignore them
STOP_WORDS = %w(
  the a on to at so today all many some
  are is will would their you them their our everyone everything who there
  while during over for below by with after in around until where
)

def preprocess(s)
  s.downcase.gsub(/[^a-z\s]/, '')
end

@labels = Tokkens::Tokens.new
@tokenizer = Tokkens::Tokenizer.new(stop_words: STOP_WORDS)

# train
training_labels = []
training_samples = []
TRAINING_DATA.each do |(label, sentence)|
  training_labels  << @labels.get(label)
  tokens = @tokenizer.get(preprocess(sentence)).uniq
  training_samples << Hash[tokens.zip([1] * tokens.length)]
end
#tokenizer.tokens.limit!(occurence: 2) # limit number of tokens - doesn't affect training though!
@model = Liblinear.train({}, training_labels, training_samples)

# predict
@tokenizer.tokens.freeze!
TEST_DATA.each do |sentence|
  tokens = @tokenizer.get(preprocess(sentence))
  label_number = Liblinear.predict(@model, Hash[tokens.zip([1] * tokens.length)])
  puts "#{sentence} -> #{tokens.map{|i| @tokenizer.tokens.find(i)}.join(' ')} -> #{@labels.find(label_number)}"
end

# you might want to persist data for prediction at a later time
#model.save('test.model')
#labels.save('test.labels')
#tokenizer.tokens.save('test.tokens')
