# frozen_string_literal: true

require "digest/keccak"

module XposedOrNot
  # Utility methods for the XposedOrNot client.
  module Utils
    EMAIL_REGEX = /\A[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}\z/

    module_function

    # Validates that the given string is a plausible email address.
    #
    # @param email [String] the email address to validate
    # @raise [ValidationError] if the email is invalid
    # @return [void]
    def validate_email(email)
      raise ValidationError, "Email must be a non-empty string" if email.nil? || email.strip.empty?
      raise ValidationError, "Invalid email format: #{email}" unless email.match?(EMAIL_REGEX)
    end

    # Validates that the given string is a non-empty password.
    #
    # @param password [String] the password to validate
    # @raise [ValidationError] if the password is blank
    # @return [void]
    def validate_password(password)
      raise ValidationError, "Password must be a non-empty string" if password.nil? || password.empty?
    end

    # Hashes a password with original Keccak-512 and returns the first 10 hex
    # characters of the digest (the "anonymous prefix").
    #
    # @param password [String] the plaintext password
    # @return [String] first 10 hex characters of the Keccak-512 digest
    def keccak_hash_prefix(password)
      digest = Digest::Keccak.new(512)
      full_hash = digest.hexdigest(password)
      full_hash[0, 10]
    end
  end
end
