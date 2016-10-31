require 'test_helper'

class CategoricalDistributionTest < Minitest::Test
  def test_create_empty_distribution
    r = CategoricalDistribution.new
    assert_equal({}, r.probabilities)
  end

  def test_create_distribution_with_empty_array
    r = CategoricalDistribution.new([])
    assert_equal({}, r.probabilities)
  end

  def test_create_distribution_with_negatives
    assert_raises ArgumentError do
      r = CategoricalDistribution.new([-1])
    end
  end

  def test_create_distribution_with_int_array
    r = CategoricalDistribution.new([2, 4])
    assert_equal({ 0 => Rational(1, 3), 1 => Rational(2, 3) }, r.probabilities)
  end

  def test_create_distribution_with_float_array
    r = CategoricalDistribution.new([0.25, 0.75])
    assert_equal({ 0 => Rational(1, 4), 1 => Rational(3, 4) }, r.probabilities)
  end

  def test_create_distribution_with_rational_array
    r = CategoricalDistribution.new([Rational(1, 3), Rational(2, 3)])
    assert_equal({ 0 => Rational(1, 3), 1 => Rational(2, 3) }, r.probabilities)
  end

  def test_create_distribution_with_empty_hash
    r = CategoricalDistribution.new({})
    assert_equal({}, r.probabilities)
  end

  def test_create_distribution_with_int_hash
    r = CategoricalDistribution.new({ a: 2, b: 4 })
    assert_equal({ a: Rational(1, 3), b: Rational(2, 3)}, r.probabilities)
  end

  def test_create_distribution_with_empty_values_array
    r = CategoricalDistribution.new([], [])
    assert_equal({}, r.probabilities)
  end

  def test_create_distribution_with_values_array
    r = CategoricalDistribution.new([1, 2], [:a, :b])
    assert_equal({ a: Rational(1, 3), b: Rational(2, 3) }, r.probabilities)
  end

  def test_empty_distribution_rand_returns_nil
    r = CategoricalDistribution.new
    assert_nil r.rand
  end

  def test_distribution_rand_returns_something
    r = CategoricalDistribution.new([1])
    assert_equal(0, r.rand)
  end

  # TODO: make sure the random behavior actually works as intended

  def test_empty_distribution_each_returns_nil
    r = CategoricalDistribution.new
    assert_raises(StopIteration) { r.each.next }
  end

  def test_distribution_each_returns_something
    r = CategoricalDistribution.new([1])
    assert_equal(0, r.each.next)
    assert_equal(0, r.each.next)
    assert_equal(0, r.each.next)
  end

  def test_empty_distribution_equal
    r = CategoricalDistribution.new
    s = CategoricalDistribution.new
    assert_equal(r, s)
  end

  def test_distribution_equal
    r = CategoricalDistribution.new({ a: 1, b: 2, c: 3})
    s = CategoricalDistribution.new({ a: 1, b: 2, c: 3})
    assert_equal(r, s)
    assert_equal(r, r)
  end

  def test_distribution_not_equal
    r = CategoricalDistribution.new({ a: 1, b: 2, c: 3})
    s = CategoricalDistribution.new({ a: 2, b: 2, c: 3})
    refute_equal(r, s)
  end

  def test_empty_distribution_empty
    r = CategoricalDistribution.new
    assert(r.empty?)
  end

  def test_distribution_not_empty
    r = CategoricalDistribution.new([1])
    refute(r.empty?)
  end

  def test_empty_distribution_length
    r = CategoricalDistribution.new
    assert_equal(0, r.length)
    assert_equal(0, r.size)
  end

  def test_distribution_length
    r = CategoricalDistribution.new([1, 2])
    assert_equal(2, r.length)
    assert_equal(2, r.size)
  end
end
