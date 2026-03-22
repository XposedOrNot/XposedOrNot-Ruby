# frozen_string_literal: true

require "spec_helper"

RSpec.describe XposedOrNot::Utils do
  describe ".validate_email" do
    it "accepts valid email addresses" do
      expect { described_class.validate_email("user@example.com") }.not_to raise_error
      expect { described_class.validate_email("user+tag@sub.domain.com") }.not_to raise_error
      expect { described_class.validate_email("a@b.co") }.not_to raise_error
    end

    it "rejects nil" do
      expect { described_class.validate_email(nil) }
        .to raise_error(XposedOrNot::ValidationError, /non-empty/)
    end

    it "rejects empty string" do
      expect { described_class.validate_email("") }
        .to raise_error(XposedOrNot::ValidationError, /non-empty/)
    end

    it "rejects whitespace-only string" do
      expect { described_class.validate_email("   ") }
        .to raise_error(XposedOrNot::ValidationError, /non-empty/)
    end

    it "rejects strings without @ sign" do
      expect { described_class.validate_email("notanemail") }
        .to raise_error(XposedOrNot::ValidationError, /Invalid email/)
    end

    it "rejects strings without domain" do
      expect { described_class.validate_email("user@") }
        .to raise_error(XposedOrNot::ValidationError, /Invalid email/)
    end

    it "rejects strings without TLD" do
      expect { described_class.validate_email("user@domain") }
        .to raise_error(XposedOrNot::ValidationError, /Invalid email/)
    end
  end

  describe ".validate_password" do
    it "accepts non-empty passwords" do
      expect { described_class.validate_password("password") }.not_to raise_error
      expect { described_class.validate_password("a") }.not_to raise_error
    end

    it "rejects nil" do
      expect { described_class.validate_password(nil) }
        .to raise_error(XposedOrNot::ValidationError, /non-empty/)
    end

    it "rejects empty string" do
      expect { described_class.validate_password("") }
        .to raise_error(XposedOrNot::ValidationError, /non-empty/)
    end
  end

  describe ".keccak_hash_prefix" do
    it "returns exactly 10 characters" do
      result = described_class.keccak_hash_prefix("test")
      expect(result.length).to eq(10)
    end

    it "returns a hex string" do
      result = described_class.keccak_hash_prefix("test")
      expect(result).to match(/\A[0-9a-f]{10}\z/)
    end

    it "returns consistent results for the same input" do
      result1 = described_class.keccak_hash_prefix("password123")
      result2 = described_class.keccak_hash_prefix("password123")
      expect(result1).to eq(result2)
    end

    it "returns different results for different inputs" do
      result1 = described_class.keccak_hash_prefix("password1")
      result2 = described_class.keccak_hash_prefix("password2")
      expect(result1).not_to eq(result2)
    end

    it "uses original Keccak-512 (not SHA3-512)" do
      # Keccak-512 of empty string is a known constant, different from SHA3-512.
      # Keccak-512("") starts with "0eab42de4c3ceb92"
      result = described_class.keccak_hash_prefix("")
      expect(result).to eq("0eab42de4c")
    end
  end
end
