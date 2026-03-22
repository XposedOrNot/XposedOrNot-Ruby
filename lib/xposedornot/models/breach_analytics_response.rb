# frozen_string_literal: true

module XposedOrNot
  module Models
    # Response from the breach analytics endpoint.
    class BreachAnalyticsResponse
      # @return [Array<Breach>] detailed breach records
      attr_reader :breaches_details

      # @return [Hash] summary of breaches
      attr_reader :breaches_summary

      # @return [Hash] breach metrics
      attr_reader :breach_metrics

      # @return [Hash] pastes summary
      attr_reader :pastes_summary

      # @return [Array<Hash>] exposed pastes
      attr_reader :exposed_pastes

      # @param data [Hash] raw response data from the API
      def initialize(data)
        exposed = data["ExposedBreaches"] || {}
        details = exposed["breaches_details"] || []
        @breaches_details = details.map { |b| Breach.new(b) }
        @breaches_summary = data["BreachesSummary"] || {}
        @breach_metrics = data["BreachMetrics"] || {}
        @pastes_summary = data["PastesSummary"] || {}
        @exposed_pastes = data["ExposedPastes"] || []
      end

      # @return [Hash] hash representation
      def to_h
        {
          breaches_details: @breaches_details.map(&:to_h),
          breaches_summary: @breaches_summary,
          breach_metrics: @breach_metrics,
          pastes_summary: @pastes_summary,
          exposed_pastes: @exposed_pastes
        }
      end
    end
  end
end
