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

    it "filters by breach_id when provided" do
      stub_request(:get, "https://api.xposedornot.com/v1/breaches")
        .with(query: { "breach_id" => "Adobe" })
        .to_return(status: 200, body: {
          "exposedBreaches" => [breaches_response["exposedBreaches"].first]
        }.to_json)

      result = client.get_breaches(breach_id: "Adobe")

      expect(result.length).to eq(1)
      expect(result.first.breach_id).to eq("Adobe")
    end
  end

  describe "#get_domain_breaches" do
    let(:plus_client) { XposedOrNot::Client.new(api_key: "test-api-key") }

    let(:domain_breaches_response) do
      {
        "status" => "success",
        "metrics" => {
          "Yearly_Metrics" => { "2013" => 1, "2012" => 1 },
          "Domain_Summary" => { "example.com" => 2 },
          "Breach_Summary" => { "Adobe" => 1, "LinkedIn" => 1 },
          "Breaches_Details" => [
            { "email" => "alice@example.com", "domain" => "example.com", "breach" => "Adobe" },
            { "email" => "bob@example.com", "domain" => "example.com", "breach" => "LinkedIn" }
          ],
          "Top10_Breaches" => { "Adobe" => 152_000_000, "LinkedIn" => 164_000_000 },
          "Detailed_Breach_Info" => {
            "Adobe" => { "breached_date" => "2013-10-04", "domain" => "adobe.com" }
          }
        }
      }
    end

    it "returns a DomainBreachesResponse with an API key" do
      stub_request(:post, "https://api.xposedornot.com/v1/domain-breaches")
        .with(headers: { "x-api-key" => "test-api-key" })
        .to_return(status: 200, body: domain_breaches_response.to_json)

      result = plus_client.get_domain_breaches

      expect(result).to be_a(XposedOrNot::Models::DomainBreachesResponse)
      expect(result.status).to eq("success")
      expect(result.yearly_metrics).to eq({ "2013" => 1, "2012" => 1 })
      expect(result.domain_summary).to eq({ "example.com" => 2 })
      expect(result.breach_summary).to eq({ "Adobe" => 1, "LinkedIn" => 1 })
      expect(result.top10_breaches).to eq({ "Adobe" => 152_000_000, "LinkedIn" => 164_000_000 })
      expect(result.detailed_breach_info).to have_key("Adobe")

      expect(result.breaches_details.length).to eq(2)
      first = result.breaches_details.first
      expect(first).to be_a(XposedOrNot::Models::DomainBreachDetail)
      expect(first.email).to eq("alice@example.com")
      expect(first.domain).to eq("example.com")
      expect(first.breach).to eq("Adobe")
    end

    it "raises AuthenticationError without an API key" do
      expect { client.get_domain_breaches }
        .to raise_error(XposedOrNot::AuthenticationError, /API key is required/)
    end

    it "raises AuthenticationError for an invalid API key" do
      stub_request(:post, "https://api.xposedornot.com/v1/domain-breaches")
        .to_return(status: 401, body: '{"Error": "Unauthorized"}')

      expect { plus_client.get_domain_breaches }
        .to raise_error(XposedOrNot::AuthenticationError)
    end

    it "supports to_h conversion" do
      stub_request(:post, "https://api.xposedornot.com/v1/domain-breaches")
        .to_return(status: 200, body: domain_breaches_response.to_json)

      hash = plus_client.get_domain_breaches.to_h

      expect(hash[:status]).to eq("success")
      expect(hash[:breaches_details].first).to eq(
        { email: "alice@example.com", domain: "example.com", breach: "Adobe" }
      )
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
