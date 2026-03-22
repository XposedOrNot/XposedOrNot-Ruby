# frozen_string_literal: true

require "faraday"
require "faraday/retry"
require "json"

module XposedOrNot
  # Main client for interacting with the XposedOrNot API.
  #
  # @example Free API usage
  #   client = XposedOrNot::Client.new
  #   result = client.check_email("test@example.com")
  #
  # @example Plus API usage
  #   client = XposedOrNot::Client.new(api_key: "your-api-key")
  #   result = client.check_email("test@example.com")
  class Client
    include Endpoints::Email
    include Endpoints::Breaches
    include Endpoints::Password

    # @return [Configuration] the client configuration
    attr_reader :config

    # @param api_key [String, nil] API key for Plus API access
    # @param options [Hash] additional configuration options
    # @option options [String] :base_url override default free API base URL
    # @option options [String] :plus_base_url override default Plus API base URL
    # @option options [String] :passwords_base_url override default passwords API base URL
    # @option options [Integer] :timeout request timeout in seconds
    # @option options [Integer] :max_retries max retries on 429 responses
    # @option options [Hash] :custom_headers additional headers
    def initialize(api_key: nil, **options)
      @config = Configuration.new(api_key: api_key, **options)
      @last_request_time = nil
      @mutex = Mutex.new
    end

    private

    # Resolves the base URL for a given API target.
    #
    # @param base [Symbol] one of :free, :plus, :passwords
    # @return [String]
    def base_url_for(base)
      case base
      when :plus
        @config.plus_base_url
      when :passwords
        @config.passwords_base_url
      else
        @config.base_url
      end
    end

    # Enforces client-side rate limiting for free API (1 req/sec).
    # Skipped when an API key is configured.
    #
    # @return [void]
    def rate_limit!
      return if @config.plus_api?

      @mutex.synchronize do
        if @last_request_time
          elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @last_request_time
          sleep(1.0 - elapsed) if elapsed < 1.0
        end
        @last_request_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    end

    # Builds a Faraday connection for the given base URL.
    #
    # @param url [String] the base URL
    # @return [Faraday::Connection]
    def connection(url)
      Faraday.new(url: url) do |f|
        f.request :retry,
                  max: @config.max_retries,
                  interval: 1,
                  backoff_factor: 2,
                  retry_statuses: [429],
                  exceptions: [Faraday::ConnectionFailed, Faraday::TimeoutError]

        f.options.timeout = @config.timeout
        f.options.open_timeout = @config.timeout

        f.headers["Content-Type"] = "application/json"
        f.headers["Accept"] = "application/json"
        f.headers["x-api-key"] = @config.api_key if @config.plus_api?

        @config.custom_headers.each do |key, value|
          f.headers[key.to_s] = value.to_s
        end

        f.adapter Faraday.default_adapter
      end
    end

    # Makes an HTTP request and handles error responses.
    #
    # @param method [Symbol] HTTP method (:get, :post, etc.)
    # @param path [String] request path
    # @param base [Symbol] API target (:free, :plus, :passwords)
    # @param params [Hash] query parameters
    # @return [Hash] parsed JSON response
    # @raise [RateLimitError, NotFoundError, AuthenticationError, APIError, NetworkError]
    def request(method, path, base: :free, params: {})
      rate_limit!

      url = base_url_for(base)
      conn = connection(url)

      response = conn.public_send(method, path) do |req|
        req.params.update(params) unless params.empty?
      end

      handle_response(response)
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
      raise NetworkError, "Network error: #{e.message}"
    end

    # Parses and validates an HTTP response.
    #
    # @param response [Faraday::Response]
    # @return [Hash] parsed JSON body
    # @raise [RateLimitError, NotFoundError, AuthenticationError, APIError]
    def handle_response(response)
      case response.status
      when 200..299
        parse_body(response.body)
      when 401, 403
        raise AuthenticationError, "Authentication failed (HTTP #{response.status})"
      when 404
        raise NotFoundError, "Resource not found (HTTP 404)"
      when 429
        raise RateLimitError, "Rate limit exceeded (HTTP 429)"
      else
        raise APIError.new("API error (HTTP #{response.status}): #{response.body}", status: response.status)
      end
    end

    # Safely parses a JSON response body.
    #
    # @param body [String] raw response body
    # @return [Hash]
    # @raise [APIError] if the body is not valid JSON
    def parse_body(body)
      return {} if body.nil? || body.strip.empty?

      JSON.parse(body)
    rescue JSON::ParserError => e
      raise APIError.new("Invalid JSON response: #{e.message}")
    end
  end
end
