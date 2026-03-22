# frozen_string_literal: true

module XposedOrNot
  module Endpoints
    # Password exposure check endpoint.
    module Password
      # Check if a password has been exposed in data breaches.
      #
      # The password is hashed locally using Keccak-512 and only the first
      # 10 hex characters of the digest are sent to the API for an anonymous
      # lookup.
      #
      # @param password [String] the plaintext password to check
      # @return [Models::PasswordCheckResponse]
      # @raise [ValidationError] if the password is blank
      def check_password(password)
        Utils.validate_password(password)

        hash_prefix = Utils.keccak_hash_prefix(password)
        begin
          response = request(:get, "v1/pass/anon/#{hash_prefix}", base: :passwords)
          Models::PasswordCheckResponse.new(response)
        rescue NotFoundError
          # 404 means password hash prefix not found — password is not exposed
          Models::PasswordCheckResponse.not_found(hash_prefix)
        end
      end
    end
  end
end
