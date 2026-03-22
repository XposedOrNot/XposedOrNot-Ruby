# frozen_string_literal: true

require "spec_helper"

RSpec.describe XposedOrNot::Endpoints::Email do
  let(:client) { XposedOrNot::Client.new }
  let(:plus_client) { XposedOrNot::Client.new(api_key: "test-api-key") }

  describe "#check_email" do
    context "with free API" do
      it "returns an EmailBreachResponse for a breached email" do
        stub_request(:get, "https://api.xposedornot.com/v1/check-email/test%40example.com")
          .to_return(
            status: 200,
            body: '{"breaches": [["Adobe", "LinkedIn", "Dropbox"]]}'
          )

        result = client.check_email("test@example.com")

        expect(result).to be_a(XposedOrNot::Models::EmailBreachResponse)
        expect(result.breached?).to be true
        expect(result.breaches).to eq(%w[Adobe LinkedIn Dropbox])
        expect(result.count).to eq(3)
      end

      it "returns an EmailBreachResponse with empty breaches" do
        stub_request(:get, "https://api.xposedornot.com/v1/check-email/clean%40example.com")
          .to_return(status: 200, body: '{"breaches": [[]]}')

        result = client.check_email("clean@example.com")

        expect(result.breached?).to be false
        expect(result.count).to eq(0)
      end

      it "raises NotFoundError when email not found" do
        stub_request(:get, "https://api.xposedornot.com/v1/check-email/nobody%40example.com")
          .to_return(status: 404, body: "Not Found")

        expect { client.check_email("nobody@example.com") }
          .to raise_error(XposedOrNot::NotFoundError)
      end
    end

    context "with Plus API" do
      let(:detailed_response) do
        {
          "status" => "success",
          "email" => "test@example.com",
          "breaches" => [
            {
              "breach_id" => "Adobe",
              "breached_date" => "2013-10-04",
              "logo" => "https://example.com/adobe.png",
              "password_risk" => "high",
              "searchable" => true,
              "xposed_data" => "Emails, Passwords",
              "xposed_records" => 152_445_165,
              "xposure_desc" => "Adobe breach in 2013",
              "domain" => "adobe.com"
            }
          ]
        }
      end

      it "returns an EmailBreachDetailedResponse" do
        stub_request(:get, "https://plus-api.xposedornot.com/v3/check-email/test%40example.com")
          .with(query: { "detailed" => "true" })
          .to_return(status: 200, body: detailed_response.to_json)

        result = plus_client.check_email("test@example.com")

        expect(result).to be_a(XposedOrNot::Models::EmailBreachDetailedResponse)
        expect(result.status).to eq("success")
        expect(result.email).to eq("test@example.com")
        expect(result.breached?).to be true
        expect(result.count).to eq(1)

        breach = result.breaches.first
        expect(breach.breach_id).to eq("Adobe")
        expect(breach.breached_date).to eq("2013-10-04")
        expect(breach.password_risk).to eq("high")
        expect(breach.exposed_records).to eq(152_445_165)
        expect(breach.domain).to eq("adobe.com")
      end

      it "sends x-api-key header" do
        stub_request(:get, "https://plus-api.xposedornot.com/v3/check-email/test%40example.com")
          .with(
            headers: { "x-api-key" => "test-api-key" },
            query: { "detailed" => "true" }
          )
          .to_return(status: 200, body: detailed_response.to_json)

        plus_client.check_email("test@example.com")
      end
    end

    context "with validation" do
      it "raises ValidationError for nil email" do
        expect { client.check_email(nil) }
          .to raise_error(XposedOrNot::ValidationError, /non-empty/)
      end

      it "raises ValidationError for empty email" do
        expect { client.check_email("") }
          .to raise_error(XposedOrNot::ValidationError, /non-empty/)
      end

      it "raises ValidationError for invalid email format" do
        expect { client.check_email("not-an-email") }
          .to raise_error(XposedOrNot::ValidationError, /Invalid email/)
      end
    end
  end

  describe "#breach_analytics" do
    let(:analytics_response) do
      {
        "ExposedBreaches" => {
          "breaches_details" => [
            {
              "breachID" => "Adobe",
              "breachedDate" => "2013-10-04",
              "domain" => "adobe.com",
              "industry" => "Technology",
              "exposedData" => "Emails, Passwords",
              "exposedRecords" => 152_445_165
            }
          ]
        },
        "BreachesSummary" => { "total" => 1 },
        "BreachMetrics" => { "risk" => "high" },
        "PastesSummary" => { "total" => 0 },
        "ExposedPastes" => []
      }
    end

    it "returns a BreachAnalyticsResponse" do
      stub_request(:get, "https://api.xposedornot.com/v1/breach-analytics")
        .with(query: { "email" => "test@example.com" })
        .to_return(status: 200, body: analytics_response.to_json)

      result = client.breach_analytics("test@example.com")

      expect(result).to be_a(XposedOrNot::Models::BreachAnalyticsResponse)
      expect(result.breaches_details.length).to eq(1)
      expect(result.breaches_details.first.breach_id).to eq("Adobe")
      expect(result.breaches_summary).to eq({ "total" => 1 })
      expect(result.breach_metrics).to eq({ "risk" => "high" })
      expect(result.pastes_summary).to eq({ "total" => 0 })
      expect(result.exposed_pastes).to eq([])
    end

    it "sends email as query parameter" do
      stub_request(:get, "https://api.xposedornot.com/v1/breach-analytics")
        .with(query: { "email" => "user@test.com" })
        .to_return(status: 200, body: analytics_response.to_json)

      client.breach_analytics("user@test.com")
    end

    it "raises ValidationError for invalid email" do
      expect { client.breach_analytics("bad-email") }
        .to raise_error(XposedOrNot::ValidationError)
    end
  end
end
