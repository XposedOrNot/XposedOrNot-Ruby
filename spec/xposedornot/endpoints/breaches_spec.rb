# frozen_string_literal: true

require "spec_helper"

RSpec.describe XposedOrNot::Endpoints::Breaches do
  let(:client) { XposedOrNot::Client.new }

  let(:breaches_response) do
    {
      "exposedBreaches" => [
        {
          "breachID" => "Adobe",
          "breachedDate" => "2013-10-04",
          "domain" => "adobe.com",
          "industry" => "Technology",
          "exposedData" => "Emails, Passwords, Usernames",
          "exposedRecords" => 152_445_165,
          "verified" => true
        },
        {
          "breachID" => "LinkedIn",
          "breachedDate" => "2012-05-05",
          "domain" => "linkedin.com",
          "industry" => "Social",
          "exposedData" => "Emails, Passwords",
          "exposedRecords" => 164_611_595,
          "verified" => true
        }
      ]
    }
  end

  describe "#get_breaches" do
    it "returns an array of Breach models" do
      stub_request(:get, "https://api.xposedornot.com/v1/breaches")
        .to_return(status: 200, body: breaches_response.to_json)

      result = client.get_breaches

      expect(result).to be_an(Array)
      expect(result.length).to eq(2)
      expect(result.first).to be_a(XposedOrNot::Models::Breach)
      expect(result.first.breach_id).to eq("Adobe")
      expect(result.first.domain).to eq("adobe.com")
      expect(result.first.industry).to eq("Technology")
      expect(result.first.exposed_records).to eq(152_445_165)
      expect(result.first.verified).to be true
    end

    it "returns an empty array when no breaches exist" do
      stub_request(:get, "https://api.xposedornot.com/v1/breaches")
        .to_return(status: 200, body: '{"exposedBreaches": []}')

      result = client.get_breaches
      expect(result).to eq([])
    end

    it "filters by domain when provided" do
      stub_request(:get, "https://api.xposedornot.com/v1/breaches")
        .with(query: { "domain" => "adobe.com" })
        .to_return(status: 200, body: {
          "exposedBreaches" => [breaches_response["exposedBreaches"].first]
        }.to_json)

      result = client.get_breaches(domain: "adobe.com")

      expect(result.length).to eq(1)
      expect(result.first.breach_id).to eq("Adobe")
    end

    it "does not include domain param when nil" do
      stub_request(:get, "https://api.xposedornot.com/v1/breaches")
        .with(query: {})
        .to_return(status: 200, body: breaches_response.to_json)

      client.get_breaches
    end
  end

  describe "Breach model" do
    it "supports to_h conversion" do
      stub_request(:get, "https://api.xposedornot.com/v1/breaches")
        .to_return(status: 200, body: breaches_response.to_json)

      result = client.get_breaches
      hash = result.first.to_h

      expect(hash[:breach_id]).to eq("Adobe")
      expect(hash[:domain]).to eq("adobe.com")
      expect(hash[:verified]).to be true
    end
  end
end
