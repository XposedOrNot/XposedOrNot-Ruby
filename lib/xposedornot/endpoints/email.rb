# frozen_string_literal: true

require "uri"

module XposedOrNot
  module Endpoints
    # Email-related API endpoints.
    module Email
      # Check if an email has been exposed in data breaches.
      #
      # When an API key is configured, uses the Plus API for detailed results.
      # Otherwise, uses the free API.
      #
      # @param email [String] the email address to check
      # @return [Models::EmailBreachResponse, Models::EmailBreachDetailedResponse]
      # @raise [ValidationError] if the email is invalid
      # @raise [NotFoundError] if the email is not found in any breaches
      def check_email(email)
        Utils.validate_email(email)

        if @config.plus_api?
          check_email_detailed(email)
        else
          check_email_free(email)
        end
      end

      # Get breach analytics for an email address.
      #
      # @param email [String] the email address to analyze
      # @return [Models::BreachAnalyticsResponse]
      # @raise [ValidationError] if the email is invalid
      def breach_analytics(email)
        Utils.validate_email(email)

        response = request(:get, "/v1/breach-analytics", base: :free, params: { email: email })
        Models::BreachAnalyticsResponse.new(response)
      end

      private

      # @param email [String]
      # @return [Models::EmailBreachResponse]
      def check_email_free(email)
        response = request(:get, "/v1/check-email/#{URI.encode_www_form_component(email)}", base: :free)
        Models::EmailBreachResponse.new(response)
      end

      # @param email [String]
      # @return [Models::EmailBreachDetailedResponse]
      def check_email_detailed(email)
        response = request(:get, "/v3/check-email/#{URI.encode_www_form_component(email)}", base: :plus, params: { detailed: true })
        Models::EmailBreachDetailedResponse.new(response)
      end
    end
  end
end
