# Generate values from a categorical probability distribution in constant time.
# Uses Vose's Alias Method to construct a table of probabilities and aliases.
# To generate a value, we pick an entry in the distribution at random, and then pick
# either the value or the alias, using a biased coin flip.
#
# Table construction is O(n), index generation is O(1).
# 
# See http://www.keithschwarz.com/darts-dice-coins for a detailed explanation.

class CategoricalDistribution
  include Enumerable

  # :call-seq:
  #   CategoricalDistribution.new(p={})
  #   CategoricalDistribution.new(p=[])
  #   CategoricalDistribution.new(p=[], values=[])
  #
  # Constructs a categorical random distribution from a set of probabilities
  # and, optionally, values. 
  #
  # These can be passed as an array of probabilities and an array of values,
  # or as a hash of values to probabilities.
  #
  # If necessary, probabilities will be normalized so that they sum to one.
  # If no values are provided, they will default to the respective indices of
  # each probability.
  #
  # Raises an +ArgumentError+ if any probability is negative.
  #
  #   CategoricalDistribution.new                                    
  #     #=> {}
  #
  #   CategoricalDistribution.new([Rational(1, 5), Rational(4, 5)])
  #     #=> {0 => (1/5), 1 => (4/5)}
  #
  #   CategoricalDistribution.new([1, 1, 1])
  #     #=> {0 => (1/3), 1 => (1/3), 2 => (1/3)}
  #
  #   CategoricalDistribution.new([1, 1, 1], [:a, :b, :c])
  #     #=> {:a => (1/3), :b => (1/3), :c => (1/3)}
  #
  #   CategoricalDistribution.new({a: 1, b: 2, c: 3})
  #     #=> {:a => (1/6), :b => (1/3), :c => (1/2)}

  def initialize(p={}, values=nil)
    if p.respond_to?(:keys) && p.respond_to?(:values)
      values, p = p.keys, p.values 
    end

    @size = p.size
    @values = values

    raise ArgumentError, 'probabilities must be positive' if p.any? { |value| value < 0 }

    sum = p.reduce(:+)
    p.map! { |value| Rational(value, sum) } unless sum == 1

    @prob = Array.new(size, Rational(1))
    @alias = Array.new(size)

    p.map! { |value| value * size }

    small, large = p.each_index.partition { |i| p[i] < 1 }

    until small.empty?
      l = small.pop
      g = large.pop

      @prob[l] = p[l]
      @alias[l] = g

      p[g] -= 1 - p[l]
      (p[g] < 1 ? small : large) << g
    end
  end


  # :call-seq:
  #   distribution.rand              -> obj or nil
  #   distribution.rand(random: rng) -> obj or nil
  #
  # Return a value from the probability distribution, or +nil+ if it is empty.
  #
  # The optional rng argument will be used as the random number generator.
  #
  #   distribution = CategoricalDistribution.new({a: 1, b: 2, c: 3})
  #   distribution.rand      #=> :b
  #   distribution.rand      #=> :c
  #   distribution.rand      #=> :c

  def rand(random: Random)
    return if empty?

    i = random.rand(size)
    index = random.rand <= @prob[i] ? i : @alias[i]
    @values.nil? ? index : @values[index]
  end


  # :call-seq:
  #   distribution.each { |item| block }  -> nil
  #   distribution.each                   -> Enumerator
  #
  # Calls the given block infinitely many times, passing a value from the
  # distribution as a parameter.
  #
  # An Enumerator is returned if no block is given.
  #
  #   distribution = CategoricalDistribution.new([1, 2, 3])
  #   distribution.each { |x| print x, " -- " }
  #
  # produces:
  #
  #  1 -- 2 -- 2 -- 0 -- 1 -- ... 
  
  def each(random: Random)
    return enum_for(:each) unless block_given?

    loop { yield rand } unless empty?
  end


  # Returns the distribution's values and their probabilities, as a hash of
  # objects to Rationals which sum to one, or an empty hash if the distribution is empty.
  # This operation is expensive, in exchange for memory efficiency.
  #
  #   CategoricalDistribution.new([1, 1, 1]).probabilities   
  #     #=> {0 => (1/3), 1 => (1/3), 2 => (1/3)}
  #
  #   CategoricalDistribution.new.probabilities
  #     #=> {}

  def probabilities
    p = @prob.clone
    @alias.each_with_index { |a, i| p[a] += 1 - @prob[i] unless a.nil? }
    p.map! { |prob| prob / size }
    Hash[[@values || size.times.to_a, p].transpose]
  end


  # :call_seq:
  #   distribution == other_distribution    ->    bool
  #
  # Equality --- Two probability distributions are equal if they contain the
  # same values and if each value has the same probability as the corresponding
  # value in other_distribution.
  #
  #   CategoricalDistribution.new([1, 2])            == CategoricalDistribution.new([1, 2, 3])
  #     #=> false
  #
  #   CategoricalDistribution.new([1, 2, 3])         == CategoricalDistribution.new([1, 2, 3])
  #     #=> true
  #
  #   CategoricalDistribution.new([1, 2, 3])         == CategoricalDistribution.new([1, 1, 1])
  #     #=> false
  #
  #   CategoricalDistribution.new([1, 2], [:a, :b])  == CategoricalDistribution.new([1, 2], [:a, :c])
  #     #=> false

  def ==(other)
    self.prob     == other.prob &&
      self.alias  == other.alias &&
      self.values == other.values
  end


  # :call_seq:
  #   distribution.eql?(other)  -> true or false
  #
  # Returns true if self and other are the same object, or are both probability
  # distributions with the same values and probabilities.

  def eql?(other)
    self.equal?(other) || 
      (self.class   == other.class &&
       self.prob    == other.prob &&
       self.alias   == other.alias &&
       self.values  == other.values)
  end


  # :call_seq:
  #   distribution.hash    -> fixnum
  #
  # Compute a hash-code for this probability distribution.
  #
  # Two distributions with the same values and probabilities will have the same
  # hash code (and will compare using #eql?).

  def hash
    hash = 17
    hash = 37 * hash + @prob.hash
    hash = 37 * hash + @alias.hash
    hash = 37 * hash + @values.hash
    hash
  end


  def to_s
    probabilities.to_s
  end


  # :call_seq:
  #   distribution.empty?    -> true or false
  #
  # Returns true if self contains no values.
  #
  #   distribution = CategoricalDistribution.new
  #   distribution.empty?   #=> true

  def empty?
    size.zero?
  end

  ##
  # :method: length
  # :call_seq:
  #   distribution.length  -> int
  #
  # Returns the number of values in self. May be zero.
  #
  #   CategoricalDistribution.new([1, 2, 3, 4]).length    #=> 4
  #   CategoricalDistribution.new.length                  #=> 0
  
  attr_reader :size
  alias length size

  protected
    attr_reader :prob, :alias, :values
end
