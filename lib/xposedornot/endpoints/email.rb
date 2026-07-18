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
      # @param include_details [Boolean] request detailed breach information from the
      #   free API; ignored when an API key is set (the Plus API is always queried
      #   with detailed results)
      # @return [Models::EmailBreachResponse, Models::EmailBreachDetailedResponse]
      # @raise [ValidationError] if the email is invalid
      # @raise [NotFoundError] if the Plus API reports the email as not found
      def check_email(email, include_details: false)
        Utils.validate_email(email)

        if @config.plus_api?
          check_email_detailed(email)
        else
          check_email_free(email, include_details: include_details)
        end
      end

      # Get breach analytics for an email address.
      #
      # @param email [String] the email address to analyze
      # @param token [String, nil] optional token for accessing sensitive breach data
      # @return [Models::BreachAnalyticsResponse]
      # @raise [ValidationError] if the email is invalid
      def breach_analytics(email, token: nil)
        Utils.validate_email(email)

        params = { email: email }
        params[:token] = token if token

        response = request(:get, "/v1/breach-analytics", base: :free, params: params)
        Models::BreachAnalyticsResponse.new(response)
      end

      private

      # @param email [String]
      # @param include_details [Boolean]
      # @return [Models::EmailBreachResponse]
      def check_email_free(email, include_details: false)
        params = include_details ? { include_details: "true" } : {}
        response = request(:get, "/v1/check-email/#{URI.encode_www_form_component(email)}", base: :free,
                                                                                            params: params)
        Models::EmailBreachResponse.new(response)
      rescue NotFoundError
        # 404 means email not found in any breaches — valid result
        Models::EmailBreachResponse.new({})
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
