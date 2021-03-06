[![Gem Version](https://badge.fury.io/rb/secret_sharing.svg)](http://badge.fury.io/rb/secret_sharing)
[![Build Status](https://travis-ci.org/duse-io/secret_sharing_ruby.svg?branch=master)](https://travis-ci.org/duse-io/secret_sharing_ruby)
[![Test Coverage](https://codeclimate.com/github/duse-io/secret_sharing_ruby/badges/coverage.svg)](https://codeclimate.com/github/duse-io/secret_sharing_ruby/coverage)
[![Code Climate](https://codeclimate.com/github/duse-io/secret_sharing_ruby/badges/gpa.svg)](https://codeclimate.com/github/duse-io/secret_sharing_ruby)
[![Inline docs](http://inch-ci.org/github/duse-io/secret_sharing_ruby.svg?branch=master)](http://inch-ci.org/github/duse-io/secret_sharing_ruby)

# secret_sharing

> **Warning:** This implementation has not been tested in production nor has it
> been examined by a security audit. All uses are your own responsibility.

A ruby implementation of [Shamir's Secret
Sharing](http://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing).

## Installation

Add this line to your application's Gemfile:

    gem 'secret_sharing'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install secret_sharing

## Implementation details

This implementation of Shamir's Secret Sharing has initially been developed to
be used in [duse](http://duse.io/), however, it is designed to be used in any
other context just as well.

The representation of a share is simply a pair of integers represented as a
`Point`. We chose to be unopionated in terms of a string representation of a
share, mainly to make it easier for this library to become compatible with
other implementations.

When generating a random polynomial, we make sure the coefficients are random,
but never zero. If we would allow the coefficients to be zero, it could result
in a lower threshold than intended. For example, if the threshold is three,
then the degree of the polynomial would be two so in the form of `f(x)=a0 +
a1*x + a2*x^2`. If `a2` would be zero than the polynomial would be of dergree
one, which would result in a real threshold of two rather than three.

## Usage

	require "secret_sharing"
	shares = SecretSharing.split("my secret", 2, 3)
	# => [<SecretSharing::Point @x=1, @y=5098750880207642474240885>, <SecretSharing::Point @x=2, @y=10197493837875874270610422>, <SecretSharing::Point @x=3, @y=15296236795544106066979959>]
	secret = SecretSharing.combine(shares[0..1]) # two shares are enough to reconstruct!
	# => "my secret"

[Further documentation on
rubydoc](http://www.rubydoc.info/github/duse-io/secret_sharing_ruby/master/SecretSharing).

## Rubies

Tested on

* Ruby MRI
* JRuby

## Contributing

1. Fork it ( https://github.com/duse-io/secret_sharing_ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
