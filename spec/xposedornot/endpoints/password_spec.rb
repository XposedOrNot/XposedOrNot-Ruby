# frozen_string_literal: true

require "spec_helper"

RSpec.describe XposedOrNot::Endpoints::Password do
  let(:client) { XposedOrNot::Client.new }

  let(:password_response) do
    {
      "SearchPassAnon" => {
        "anon" => "abc1234567",
        "char" => "D:3;A:8;S:0;L:11",
        "count" => "62703"
      }
    }
  end

  describe "#check_password" do
    it "returns a PasswordCheckResponse for an exposed password" do
      hash_prefix = XposedOrNot::Utils.keccak_hash_prefix("password123")

      stub_request(:get, "https://passwords.xposedornot.com/api/v1/pass/anon/#{hash_prefix}")
        .to_return(status: 200, body: password_response.to_json)

      result = client.check_password("password123")

      expect(result).to be_a(XposedOrNot::Models::PasswordCheckResponse)
      expect(result.anon).to eq("abc1234567")
      expect(result.char).to eq("D:3;A:8;S:0;L:11")
      expect(result.count).to eq(62_703)
      expect(result.exposed?).to be true
    end

    it "returns unexposed for count of 0" do
      hash_prefix = XposedOrNot::Utils.keccak_hash_prefix("super-unique-pw-xyz")

      stub_request(:get, "https://passwords.xposedornot.com/api/v1/pass/anon/#{hash_prefix}")
        .to_return(status: 200, body: {
          "SearchPassAnon" => { "anon" => hash_prefix, "char" => "", "count" => "0" }
        }.to_json)

      result = client.check_password("super-unique-pw-xyz")

      expect(result.exposed?).to be false
      expect(result.count).to eq(0)
    end

    it "only sends the first 10 characters of the hash" do
      hash_prefix = XposedOrNot::Utils.keccak_hash_prefix("testpw")
      expect(hash_prefix.length).to eq(10)

      stub_request(:get, "https://passwords.xposedornot.com/api/v1/pass/anon/#{hash_prefix}")
        .to_return(status: 200, body: password_response.to_json)

      client.check_password("testpw")
    end

    it "raises ValidationError for nil password" do
      expect { client.check_password(nil) }
        .to raise_error(XposedOrNot::ValidationError, /non-empty/)
    end

    it "raises ValidationError for empty password" do
      expect { client.check_password("") }
        .to raise_error(XposedOrNot::ValidationError, /non-empty/)
    end

    it "supports to_h conversion" do
      hash_prefix = XposedOrNot::Utils.keccak_hash_prefix("test")

      stub_request(:get, "https://passwords.xposedornot.com/api/v1/pass/anon/#{hash_prefix}")
        .to_return(status: 200, body: password_response.to_json)

      result = client.check_password("test")
      hash = result.to_h

      expect(hash[:anon]).to eq("abc1234567")
      expect(hash[:count]).to eq(62_703)
      expect(hash[:exposed]).to be true
    end
  end
end
