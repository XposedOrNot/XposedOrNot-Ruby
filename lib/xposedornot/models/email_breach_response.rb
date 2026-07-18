# frozen_string_literal: true

module XposedOrNot
  module Models
    # Response from the free email breach check endpoint.
    class EmailBreachResponse
      # @return [Array<String>] list of breach names
      attr_reader :breaches

      # @return [String] the email address that was checked
      attr_reader :email

      # @return [String] response status ("success" or "error")
      attr_reader :status

      # @param data [Hash] raw response data from the API
      def initialize(data)
        raw = data["breaches"]
        @breaches = if raw.is_a?(Array) && raw.first.is_a?(Array)
                      raw.flatten
                    elsif raw.is_a?(Array)
                      raw
                    else
                      []
                    end
        @email = data["email"] || ""
        @status = data["status"] || ""
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
        { breaches: @breaches, breached: breached?, count: count, email: @email, status: @status }
      end
    end
  end
end
