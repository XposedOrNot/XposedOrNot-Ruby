# frozen_string_literal: true

module XposedOrNot
  module Endpoints
    # Breaches listing endpoint.
    module Breaches
      # Get a list of all known breaches, optionally filtered by domain or breach ID.
      #
      # @param domain [String, nil] optional domain to filter results
      # @param breach_id [String, nil] optional breach ID to fetch a specific breach
      # @return [Array<Models::Breach>] list of breach records
      def get_breaches(domain: nil, breach_id: nil)
        params = {}
        params[:domain] = domain if domain
        params[:breach_id] = breach_id if breach_id

        response = request(:get, "/v1/breaches", base: :free, params: params)
        raw = response["exposedBreaches"] || []
        raw.map { |b| Models::Breach.new(b) }
      end

      # Get breach information for domains verified against the API key.
      #
      # Requires an API key with verified domains configured at
      # console.xposedornot.com.
      #
      # @return [Models::DomainBreachesResponse] metrics and exposed email records
      # @raise [AuthenticationError] if no API key is configured or the key is invalid
      def get_domain_breaches
        unless @config.plus_api?
          raise AuthenticationError,
                "An API key is required for domain breach monitoring. " \
                "Get one at console.xposedornot.com"
        end

        response = request(:post, "/v1/domain-breaches", base: :free)
        Models::DomainBreachesResponse.new(response)
      end
    end
  end
end
