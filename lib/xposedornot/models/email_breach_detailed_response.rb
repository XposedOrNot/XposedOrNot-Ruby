# frozen_string_literal: true

module XposedOrNot
  module Models
    # Response from the Plus API detailed email breach check endpoint.
    class EmailBreachDetailedResponse
      # @return [String] status from the API
      attr_reader :status

      # @return [String] the queried email address
      attr_reader :email

      # @return [Array<Breach>] detailed breach records
      attr_reader :breaches

      # @param data [Hash] raw response data from the Plus API
      def initialize(data)
        @status = data["status"]
        @email = data["email"]
        raw_breaches = data["breaches"] || []
        @breaches = raw_breaches.map { |b| Breach.new(b) }
      end

      # @return [Boolean] true if the email was found in any breaches
      def breached?
        !@breaches.empty?
      end

      # @return [Integer] number of breaches found
      def count
        @breaches.length
      end

      # @return [Hash] hash representation
      def to_h
        {
          status: @status,
          email: @email,
          breaches: @breaches.map(&:to_h),
          breached: breached?,
          count: count
        }
      end
    end
  end
end
