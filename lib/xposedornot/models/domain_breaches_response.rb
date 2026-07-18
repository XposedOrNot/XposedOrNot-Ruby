# frozen_string_literal: true

module XposedOrNot
  module Models
    # A single exposed email record from the domain-breaches endpoint.
    class DomainBreachDetail
      # @return [String] email address exposed in the breach
      attr_reader :email

      # @return [String] verified domain the email belongs to
      attr_reader :domain

      # @return [String] name of the breach the email was found in
      attr_reader :breach

      # @param data [Hash] raw record data from the API
      def initialize(data)
        @email = data["email"] || ""
        @domain = data["domain"] || ""
        @breach = data["breach"] || ""
      end

      # @return [Hash] hash representation
      def to_h
        { email: @email, domain: @domain, breach: @breach }
      end
    end

    # Response from the domain-breaches endpoint.
    #
    # Contains breach metrics and statistics for domains verified
    # against the API key.
    class DomainBreachesResponse
      # @return [String] response status ("success" or "error")
      attr_reader :status

      # @return [Array<DomainBreachDetail>] exposed email records across the verified domains
      attr_reader :breaches_details

      # @return [Hash] breach counts by year
      attr_reader :yearly_metrics

      # @return [Hash] summary of breaches by domain
      attr_reader :domain_summary

      # @return [Hash] summary of all breaches
      attr_reader :breach_summary

      # @return [Hash] top 10 largest breaches affecting the domains
      attr_reader :top10_breaches

      # @return [Hash] detailed information about each breach
      attr_reader :detailed_breach_info

      # @param data [Hash] raw response data from the API
      def initialize(data)
        metrics = data["metrics"] || {}
        @status = data["status"] || ""
        @breaches_details = (metrics["Breaches_Details"] || []).map { |b| DomainBreachDetail.new(b) }
        @yearly_metrics = metrics["Yearly_Metrics"] || {}
        @domain_summary = metrics["Domain_Summary"] || {}
        @breach_summary = metrics["Breach_Summary"] || {}
        @top10_breaches = metrics["Top10_Breaches"] || {}
        @detailed_breach_info = metrics["Detailed_Breach_Info"] || {}
      end

      # @return [Hash] hash representation
      def to_h
        {
          status: @status,
          breaches_details: @breaches_details.map(&:to_h),
          yearly_metrics: @yearly_metrics,
          domain_summary: @domain_summary,
          breach_summary: @breach_summary,
          top10_breaches: @top10_breaches,
          detailed_breach_info: @detailed_breach_info
        }
      end
    end
  end
end
