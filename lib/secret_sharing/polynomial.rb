require 'securerandom'

module SecretSharing
  # The polynomial is used to represent the required random polynomials used in
  # Shamir's Secret Sharing algorithm.
  class Polynomial
    # Create a new instance of a Polynomial with n coefficients, when having
    # the polynomial in standard polynomial form.
    #
    # Example
    #
    #   Polynomial.new [1, 2, 3]
    #   # => #<SecretSharing::Polynomial:0x0000000 @coefficients=[1, 2, 3]>
    #
    # @param coefficients [Array] an array of integers as the coefficients
    def initialize(coefficients)
      @coefficients = coefficients
    end

    # Generate points on the polynomial, that can be used to reconstruct the
    # polynomial with.
    #
    # Example
    #
    #   SecretSharing::Polynomial.new([1, 2, 3, 4]).points(3, 7)
    #   # => [#<Point: @x=1 @y=3>, #<Point: @x=2 @y=0>, #<Point: @x=3 @y=2>]
    #
    # @param num_points [Integer] number of points to generate
    # @param prime [Integer] prime for calculation in finite field
    # @return [Array] array of calculated points
    def points(num_points, prime)
      (1..num_points).map do |x|
        y = @coefficients[0]
        (1...@coefficients.length).each do |i|
          exponentiation = x**i % prime
          term = (@coefficients[i] * exponentiation) % prime
          y = (y + term) % prime
        end
        Point.new(x, y)
      end
    end

    # Generate a random polynomial with a specific degree, defined x=0 value
    # and an upper limit for the coefficients of the polynomial.
    #
    # Example
    #
    #   Polynomial.random(2, 3, 7)
    #   # => #<SecretSharing::Polynomial:0x0000000 @coefficients=[3, 0, 4]>
    #
    # @param degree [Integer] degree of the polynomial to generate
    # @param intercept [Integer] the y value for x=0
    # @param upper_bound [Integer] the highest value of a single coefficient
    def self.random(degree, intercept, upper_bound)
      fail ArgumentError, 'Degree must be a non-negative number' if degree < 0

      coefficients = (0...degree).reduce([intercept]) do |accumulator, _i|
        accumulator << SecureRandom.random_number(upper_bound)
      end
      Polynomial.new coefficients
    end

    # Generate points from a secret integer.
    #
    # Example
    #
    #   SecretSharing::Polynomial.points_from_secret(123, 2, 3)
    #   # => [#<Point: @x=1 @y=109>, #<Point: @x=2 @y=95>, #<Point: @x=3 @y=81>]
    #
    # @param secret_int [Integer] the secret to divide into points
    # @param point_threshold [Integer] number of points to reconstruct
    # @param num_points [Integer] number of points to generate
    # @return [Polynomial] the generated polynomial
    def self.points_from_secret(secret_int, point_threshold, num_points)
      prime = SecretSharing::Prime.large_enough_prime([secret_int, num_points])
      fail ArgumentError, 'Secret is too long' if prime.nil?
      fail ArgumentError, 'Threshold must be at least 2' if point_threshold < 2
      fail ArgumentError, 'Threshold must be less than the total number of points' if point_threshold > num_points

      polynomial = SecretSharing::Polynomial.random(point_threshold - 1,
                                                    secret_int,
                                                    prime)
      polynomial.points(num_points, prime)
    end

    # Modular lagrange interpolation
    def self.modular_lagrange_interpolation(points)
      y_values = Point.transpose(points)[1]
      prime = SecretSharing::Prime.large_enough_prime(y_values)
      points.reduce(0) do |f_x, point|
        numerator, denominator = lagrange_fraction(points, point, prime)
        lagrange_polynomial = numerator * mod_inverse(denominator, prime)
        (prime + f_x + (point.y * lagrange_polynomial)) % prime
      end
    end

    # part of the lagrange interpolation
    def self.lagrange_fraction(points, current, prime)
      numerator, denominator = 1, 1
      points.each do |point|
        if point != current
          numerator = (numerator * (0 - point.x)) % prime
          denominator = (denominator * (current.x - point.x)) % prime
        end
      end
      [numerator, denominator]
    end

    # inverse modulo
    def self.mod_inverse(k, prime)
      k = k % prime
      r = egcd(prime, k.abs)[2]
      (prime + r) % prime
    end

    # extended Euclidean algorithm
    def self.egcd(a, b)
      return [b, 0, 1] if a == 0
      g, y, x = egcd(b % a, a)
      [g, x - b.div(a) * y, y]
    end
  end
end
