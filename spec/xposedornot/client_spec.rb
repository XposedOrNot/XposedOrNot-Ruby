# frozen_string_literal: true

require "spec_helper"

RSpec.describe XposedOrNot::Client do
  subject(:client) { described_class.new }

  describe "#initialize" do
    it "creates a client with default configuration" do
      expect(client.config).to be_a(XposedOrNot::Configuration)
      expect(client.config.base_url).to eq("https://api.xposedornot.com")
      expect(client.config.api_key).to be_nil
    end

    it "accepts an API key" do
      client = described_class.new(api_key: "test-key")
      expect(client.config.api_key).to eq("test-key")
      expect(client.config.plus_api?).to be true
    end

    it "accepts custom configuration options" do
      client = described_class.new(
        timeout: 10,
        max_retries: 5,
        custom_headers: { "X-Custom" => "value" }
      )
      expect(client.config.timeout).to eq(10)
      expect(client.config.max_retries).to eq(5)
      expect(client.config.custom_headers).to eq({ "X-Custom" => "value" })
    end
  end

  describe "error handling" do
    it "raises AuthenticationError on 401" do
      stub_request(:get, "https://api.xposedornot.com/v1/breaches")
        .to_return(status: 401, body: "Unauthorized")

      expect { client.get_breaches }.to raise_error(XposedOrNot::AuthenticationError)
    end

    it "raises AuthenticationError on 403" do
      stub_request(:get, "https://api.xposedornot.com/v1/breaches")
        .to_return(status: 403, body: "Forbidden")

      expect { client.get_breaches }.to raise_error(XposedOrNot::AuthenticationError)
    end

    it "raises NotFoundError on 404" do
      stub_request(:get, "https://api.xposedornot.com/v1/check-email/notfound%40example.com")
        .to_return(status: 404, body: "Not Found")

      expect { client.check_email("notfound@example.com") }.to raise_error(XposedOrNot::NotFoundError)
    end

    it "raises APIError on 500" do
      stub_request(:get, "https://api.xposedornot.com/v1/breaches")
        .to_return(status: 500, body: "Internal Server Error")

      expect { client.get_breaches }.to raise_error(XposedOrNot::APIError) do |error|
        expect(error.status).to eq(500)
      end
    end

    it "raises APIError on invalid JSON response" do
      stub_request(:get, "https://api.xposedornot.com/v1/breaches")
        .to_return(status: 200, body: "not json")

      expect { client.get_breaches }.to raise_error(XposedOrNot::APIError, /Invalid JSON/)
    end

    it "raises NetworkError on connection failure" do
      stub_request(:get, "https://api.xposedornot.com/v1/breaches")
        .to_raise(Faraday::ConnectionFailed.new("connection refused"))

      expect { client.get_breaches }.to raise_error(XposedOrNot::NetworkError)
    end

    it "raises NetworkError on timeout" do
      stub_request(:get, "https://api.xposedornot.com/v1/breaches")
        .to_raise(Faraday::TimeoutError)

      expect { client.get_breaches }.to raise_error(XposedOrNot::NetworkError)
    end
  end

  describe "custom headers" do
    it "includes custom headers in requests" do
      client = described_class.new(custom_headers: { "X-Custom" => "test" })

      stub_request(:get, "https://api.xposedornot.com/v1/breaches")
        .with(headers: { "X-Custom" => "test" })
        .to_return(status: 200, body: '{"exposedBreaches": []}')

      client.get_breaches
    end
  end

  describe "Plus API headers" do
    it "includes x-api-key header for Plus API requests" do
      client = described_class.new(api_key: "my-key")

      stub_request(:get, "https://plus-api.xposedornot.com/v3/check-email/test%40example.com")
        .with(
          headers: { "x-api-key" => "my-key" },
          query: { "detailed" => "true" }
        )
        .to_return(status: 200, body: '{"status":"success","email":"test@example.com","breaches":[]}')

      client.check_email("test@example.com")
    end
  end
end
