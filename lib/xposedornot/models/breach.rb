# frozen_string_literal: true

module XposedOrNot
  module Models
    # Represents a single data breach record.
    class Breach
      # @return [String] unique breach identifier
      attr_reader :breach_id

      # @return [String] date the breach occurred
      attr_reader :breached_date

      # @return [String] domain affected by the breach
      attr_reader :domain

      # @return [String] industry of the breached organization
      attr_reader :industry

      # @return [String] types of data exposed
      attr_reader :exposed_data

      # @return [Integer] number of records exposed
      attr_reader :exposed_records

      # @return [Boolean] whether the breach is verified
      attr_reader :verified

      # @return [String, nil] URL of the breach logo
      attr_reader :logo

      # @return [String, nil] risk level of password exposure
      attr_reader :password_risk

      # @return [Boolean, nil] whether the breach is searchable
      attr_reader :searchable

      # @return [String, nil] description of the exposure
      attr_reader :xposure_desc

      # @param data [Hash] raw breach data from the API
      def initialize(data)
        @breach_id = data["breachID"] || data["breach_id"]
        @breached_date = data["breachedDate"] || data["breached_date"]
        @domain = data["domain"]
        @industry = data["industry"]
        @exposed_data = data["exposedData"] || data["xposed_data"]
        @exposed_records = data["exposedRecords"] || data["xposed_records"]
        @verified = data["verified"]
        @logo = data["logo"]
        @password_risk = data["password_risk"]
        @searchable = data["searchable"]
        @xposure_desc = data["xposure_desc"]
      end

      # @return [Hash] hash representation of the breach
      def to_h
        {
          breach_id: @breach_id,
          breached_date: @breached_date,
          domain: @domain,
          industry: @industry,
          exposed_data: @exposed_data,
          exposed_records: @exposed_records,
          verified: @verified,
          logo: @logo,
          password_risk: @password_risk,
          searchable: @searchable,
          xposure_desc: @xposure_desc
        }.compact
      end
    end
  end
end
