# frozen_string_literal: true

module XposedOrNot
  module Models
    # Response from the password exposure check endpoint.
    class PasswordCheckResponse
      # @return [String] the anonymous hash prefix used for the search
      attr_reader :anon

      # @return [String] character composition breakdown (e.g. "D:3;A:8;S:0;L:11")
      attr_reader :char

      # @return [Integer] number of times the password was seen in breaches
      attr_reader :count

      # @param data [Hash] raw response data from the API
      def initialize(data)
        search = data["SearchPassAnon"] || {}
        @anon = search["anon"]
        @char = search["char"]
        @count = (search["count"] || "0").to_i
      end

      # Build a not-found response (password is clean).
      # @param hash_prefix [String]
      # @return [PasswordCheckResponse]
      def self.not_found(hash_prefix)
        new({"SearchPassAnon" => {"anon" => hash_prefix, "char" => "", "count" => "0"}})
      end

      # @return [Boolean] true if the password has been exposed
      def exposed?
        @count.positive?
      end

      # @return [Hash] hash representation
      def to_h
        { anon: @anon, char: @char, count: @count, exposed: exposed? }
      end
    end
  end
end
