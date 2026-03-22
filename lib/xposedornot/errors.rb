# frozen_string_literal: true

module XposedOrNot
  # Base error class for all XposedOrNot errors.
  class XposedOrNotError < StandardError; end

  # Raised when the API returns a 429 Too Many Requests response.
  class RateLimitError < XposedOrNotError; end

  # Raised when the requested resource is not found (404).
  class NotFoundError < XposedOrNotError; end

  # Raised when authentication fails (401/403).
  class AuthenticationError < XposedOrNotError; end

  # Raised when input validation fails before making a request.
  class ValidationError < XposedOrNotError; end

  # Raised when a network-level error occurs (timeouts, connection refused, etc.).
  class NetworkError < XposedOrNotError; end

  # Raised when the API returns an unexpected error response.
  class APIError < XposedOrNotError
    # @return [Integer, nil] the HTTP status code
    attr_reader :status

    # @param message [String] the error message
    # @param status [Integer, nil] the HTTP status code
    def initialize(message = nil, status: nil)
      @status = status
      super(message)
    end
  end
end
