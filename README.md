# CategoricalDistribution

This gem provides an implementation of a [categorical distribution](https://en.wikipedia.org/wiki/Categorical_distribution) using [Vose's Alias Method](https://en.wikipedia.org/wiki/Allas_method). More details on the implementation can be found [here](http://www.keithschwarz.com/darts-dice-coins).
The algorithm chooses a random item, with a weighted probability given on initialization, in constant time, after an O(n) initialization step.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'categorical_distribution'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install categorical_distribution

## Usage

r = CategoricalDistribution.new({ a: 1, b: 2, c: 3 })
r.rand    #=> :a
r.rand    #=> :b
r.rand    #=> :c
r.rand    #=> :c
r.rand    #=> :b

r = CategoricalDistribution.new([1, 1, 1])
r.take(5) #=> [1, 2, 1, 1, 2]

r = CategoricalDistribution.new([1, 3], ['heads', 'tails'])
r.rand    #=> "tails"
r.rand    #=> "tails"
r.rand    #=> "tails"
r.rand    #=> "tails"
r.rand    #=> "heads"

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zanecodes/categorical_distribution.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

