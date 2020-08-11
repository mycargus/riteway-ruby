# The RITEway Ruby gem

Simple, readable, helpful unit tests in Ruby. Inspired by Eric Elliott's
[RITEway].

- **R**eadable
- **I**solated/**I**ntegrated
- **T**horough
- **E**xplicit

RITEway forces you to write **R**eadable, **I**solated, and **E**xplicit tests,
because that's the only way you can use the API. It also makes it easier to be
**T**horough by making test assertions so simple that you'll want to write more
of them.

There are [5 questions every unit test must answer]. RITEway forces you to
answer them.

1. What is the unit under test (module, method, class, whatever)?
2. What should it do? (Prose description)
3. What was the actual output?
4. What was the expected output?
5. How do you reproduce the failure?

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'riteway'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install riteway

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to [rubygems.org].

## Contributing

Bug reports and pull requests are welcome on GitHub at
<https://github.com/mycargus/riteway-ruby>. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to adhere
to the [code of conduct].

## License

The gem is available as open source under the terms of the [MIT License].

## Code of Conduct

Everyone interacting in the Riteway project's codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of conduct].

[riteway]: https://github.com/ericelliott/riteway
[rubygems.org]: https://rubygems.org
[code of conduct]: https://github.com/mycargus/riteway-ruby/blob/master/CODE_OF_CONDUCT.md
[mit license]: https://github.com/mycargus/riteway-ruby/blob/master/LICENSE
[5 questions every unit test must answer]: https://medium.com/javascript-scene/what-every-unit-test-needs-f6cd34d9836d
