# frozen_string_literal: true

module XposedOrNot
  # Configuration for the XposedOrNot client.
  #
  # @example
  #   config = XposedOrNot::Configuration.new(api_key: "my-key", timeout: 15)
  class Configuration
    # @return [String] base URL for the free API
    attr_reader :base_url

    # @return [String] base URL for the Plus (commercial) API
    attr_reader :plus_base_url

    # @return [String] base URL for the password check API
    attr_reader :passwords_base_url

    # @return [Integer] request timeout in seconds
    attr_accessor :timeout

    # @return [Integer] maximum number of retries on 429 responses
    attr_accessor :max_retries

    # @return [String, nil] API key for Plus API access
    attr_accessor :api_key

    # @return [Hash] custom headers to include in every request
    attr_accessor :custom_headers

    # @return [Boolean] whether to allow insecure (HTTP) base URLs
    attr_reader :allow_insecure

    DEFAULT_BASE_URL = "https://api.xposedornot.com"
    DEFAULT_PLUS_BASE_URL = "https://plus-api.xposedornot.com"
    DEFAULT_PASSWORDS_BASE_URL = "https://passwords.xposedornot.com/api"
    DEFAULT_TIMEOUT = 30
    DEFAULT_MAX_RETRIES = 3

    # @param base_url [String] base URL for the free API
    # @param plus_base_url [String] base URL for the Plus API
    # @param passwords_base_url [String] base URL for the password API
    # @param timeout [Integer] request timeout in seconds
    # @param max_retries [Integer] max retries on 429 responses
    # @param api_key [String, nil] API key for Plus API
    # @param custom_headers [Hash] additional headers
    # @param allow_insecure [Boolean] allow HTTP URLs (default false, for testing only)
    def initialize(
      base_url: DEFAULT_BASE_URL,
      plus_base_url: DEFAULT_PLUS_BASE_URL,
      passwords_base_url: DEFAULT_PASSWORDS_BASE_URL,
      timeout: DEFAULT_TIMEOUT,
      max_retries: DEFAULT_MAX_RETRIES,
      api_key: nil,
      custom_headers: {},
      allow_insecure: false
    )
      @allow_insecure = allow_insecure
      @base_url = base_url
      @plus_base_url = plus_base_url
      @passwords_base_url = passwords_base_url
      @timeout = timeout
      @max_retries = max_retries
      @api_key = api_key
      @custom_headers = custom_headers

      validate!
    end

    # Sets the base URL for the free API.
    #
    # @param url [String]
    def base_url=(url)
      validate_url!(:base_url, url)
      @base_url = url
    end

    # Sets the base URL for the Plus API.
    #
    # @param url [String]
    def plus_base_url=(url)
      validate_url!(:plus_base_url, url)
      @plus_base_url = url
    end

    # Sets the base URL for the password check API.
    #
    # @param url [String]
    def passwords_base_url=(url)
      validate_url!(:passwords_base_url, url)
      @passwords_base_url = url
    end

    # Returns true if an API key is configured (Plus API access).
    #
    # @return [Boolean]
    def plus_api?
      !@api_key.nil? && !@api_key.empty?
    end

    # Redacts sensitive fields from the inspect output.
    #
    # @return [String]
    def inspect
      "#<#{self.class.name} base_url=#{@base_url.inspect} api_key=#{@api_key ? '[REDACTED]' : 'nil'}>"
    end

    private

    # Validates all URL fields use HTTPS unless allow_insecure is set.
    #
    # @raise [ValidationError] if any URL does not start with https://
    def validate!
      return if @allow_insecure

      validate_url!(:base_url, @base_url)
      validate_url!(:plus_base_url, @plus_base_url)
      validate_url!(:passwords_base_url, @passwords_base_url)
    end

    # Validates a single URL uses HTTPS.
    #
    # @param name [Symbol] the field name (for error messages)
    # @param url [String] the URL to validate
    # @raise [ValidationError] if the URL does not start with https://
    def validate_url!(name, url)
      return if @allow_insecure
      return if url.start_with?("https://")

      raise ValidationError, "#{name} must use HTTPS (got: #{url})"
    end
  end
end
