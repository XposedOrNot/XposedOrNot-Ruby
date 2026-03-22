# frozen_string_literal: true

module XposedOrNot
  module Endpoints
    # Breaches listing endpoint.
    module Breaches
      # Get a list of all known breaches, optionally filtered by domain.
      #
      # @param domain [String, nil] optional domain to filter results
      # @return [Array<Models::Breach>] list of breach records
      def get_breaches(domain: nil)
        params = {}
        params[:domain] = domain if domain

        response = request(:get, "/v1/breaches", base: :free, params: params)
        raw = response["exposedBreaches"] || []
        raw.map { |b| Models::Breach.new(b) }
      end
    end
  end
end
