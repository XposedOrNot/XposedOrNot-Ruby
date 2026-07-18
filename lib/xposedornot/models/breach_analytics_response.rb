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

      # @return [Array<String>] names of breaches the email was found in
      attr_reader :breach_names

      # @return [Integer] number of breaches the email was found in
      attr_reader :breaches_count

      # @return [Integer] total number of exposures
      attr_reader :exposures_count

      # @return [String] date of first breach
      attr_reader :first_breach

      # @return [Integer] number of pastes the email was found in
      attr_reader :pastes_count

      # @param data [Hash] raw response data from the API
      def initialize(data)
        exposed = data["ExposedBreaches"] || {}
        details = exposed["breaches_details"] || []
        @breaches_details = details.map { |b| Breach.new(b) }
        @breaches_summary = data["BreachesSummary"] || {}
        @breach_metrics = data["BreachMetrics"] || {}
        @pastes_summary = data["PastesSummary"] || {}
        @exposed_pastes = data["ExposedPastes"] || []

        site = @breaches_summary["site"]
        if site.is_a?(String)
          @breach_names = site.split(";").reject(&:empty?)
          @breaches_count = @breach_names.length
        else
          @breach_names = []
          @breaches_count = site || 0
        end

        @exposures_count = @breaches_summary["exposures"] || @breaches_details.length
        @first_breach = @breaches_summary["first_breach"] || ""
        @pastes_count = @pastes_summary["cnt"] || 0
      end

      # @return [Hash] hash representation
      def to_h
        {
          breaches_details: @breaches_details.map(&:to_h),
          breaches_summary: @breaches_summary,
          breach_metrics: @breach_metrics,
          pastes_summary: @pastes_summary,
          exposed_pastes: @exposed_pastes,
          breach_names: @breach_names,
          breaches_count: @breaches_count,
          exposures_count: @exposures_count,
          first_breach: @first_breach,
          pastes_count: @pastes_count
        }
      end
    end
  end
end
