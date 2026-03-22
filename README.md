<p align="center">
  <a href="https://xposedornot.com">
    <img src="https://xposedornot.com/static/logos/xon.png" alt="XposedOrNot" width="200">
  </a>
</p>

<h1 align="center">xposedornot</h1>

<p align="center">
  Official Ruby SDK for the <a href="https://xposedornot.com">XposedOrNot</a> API<br>
  <em>Check if your email has been exposed in data breaches</em>
</p>

<p align="center">
  <a href="https://rubygems.org/gems/xposedornot"><img src="https://img.shields.io/gem/v/xposedornot.svg" alt="Gem Version"></a>
  <a href="https://github.com/XposedOrNot/XposedOrNot-Ruby/actions"><img src="https://img.shields.io/github/actions/workflow/status/XposedOrNot/XposedOrNot-Ruby/build.yml?branch=main" alt="Build Status"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"></a>
  <a href="https://www.ruby-lang.org"><img src="https://img.shields.io/badge/Ruby-%3E%3D%203.0-red.svg" alt="Ruby Version"></a>
</p>

---

> **Note:** This SDK uses the free public API from [XposedOrNot.com](https://xposedornot.com) - a free service to check if your email has been compromised in data breaches. Visit the [XposedOrNot website](https://xposedornot.com) to learn more about the service and check your email manually.

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [API Reference](#api-reference)
  - [check_email](#check_emailemail)
  - [get_breaches](#get_breachesdomain)
  - [breach_analytics](#breach_analyticsemail)
  - [check_password](#check_passwordpassword)
- [Error Handling](#error-handling)
- [Rate Limits](#rate-limits)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [License](#license)
- [Links](#links)

---

## Features

- **Simple API** - Easy-to-use methods for checking email breaches and password exposure
- **Detailed Analytics** - Get breach details, risk scores, and metrics
- **Password Safety** - Check password exposure using k-anonymity (only a hash prefix is sent)
- **Error Handling** - Custom error classes for different scenarios
- **Configurable** - Timeout, retries, custom headers, and Plus API support
- **Secure** - HTTPS enforced, input validation, no sensitive data logging

## Installation

```bash
gem install xposedornot
```

Or add to your Gemfile:

```ruby
gem 'xposedornot'
```

Then run:

```bash
bundle install
```

## Requirements

- Ruby 3.0 or higher

## Quick Start

```ruby
require 'xposedornot'

client = XposedOrNot::Client.new

# Check if an email has been breached
result = client.check_email('test@example.com')

if result.breached?
  puts "Email found in #{result.breaches.length} breaches:"
  result.breaches.each { |breach| puts "  - #{breach}" }
else
  puts 'Good news! Email not found in any known breaches.'
end
```

## API Reference

### Constructor

```ruby
client = XposedOrNot::Client.new(api_key: nil, **options)
```

See [Configuration](#configuration) for all available options.

### Methods

#### `check_email(email)`

Check if an email address has been exposed in any data breaches. When an API key is configured, uses the Plus API for detailed results including `breach_id` and `password_risk`. Otherwise, uses the free API.

```ruby
# Free API
client = XposedOrNot::Client.new
result = client.check_email('user@example.com')
puts result.breached?   # => true / false
puts result.breaches     # => ["Breach1", "Breach2"]

# Plus API (detailed results)
client = XposedOrNot::Client.new(api_key: 'your-api-key')
result = client.check_email('user@example.com')
puts result.breaches.first.breach_id
puts result.breaches.first.password_risk
```

#### `get_breaches(domain:)`

Get a list of all known data breaches, optionally filtered by domain.

```ruby
# Get all breaches
breaches = client.get_breaches

# Filter by domain
adobe_breaches = client.get_breaches(domain: 'adobe.com')

breaches.each do |breach|
  puts "#{breach.breach_id} - #{breach.domain} (#{breach.exposed_records} records)"
end
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `domain` | `String` | Optional. Filter breaches by domain |

**Returns:** `Array<Models::Breach>` with properties such as `breach_id`, `breached_date`, `domain`, `industry`, `exposed_data`, `exposed_records`, and `verified`.

#### `breach_analytics(email)`

Get detailed breach analytics for an email address, including breach summaries, metrics, and paste exposures.

```ruby
analytics = client.breach_analytics('user@example.com')

puts analytics.breaches_details.length
puts analytics.breaches_summary
puts analytics.breach_metrics
puts analytics.exposed_pastes
```

#### `check_password(password)`

Check if a password has been exposed in data breaches. The password is hashed locally using Keccak-512 and only the first 10 hex characters of the digest are sent to the API, preserving anonymity via k-anonymity.

```ruby
result = client.check_password('mypassword')

if result.exposed?
  puts "This password has been seen #{result.count} time(s) in breaches!"
else
  puts 'Password not found in any known breaches.'
end
```

## Error Handling

The library provides custom error classes for different scenarios:

```ruby
begin
  result = client.check_email('test@example.com')
rescue XposedOrNot::ValidationError => e
  puts "Invalid input: #{e.message}"
rescue XposedOrNot::RateLimitError
  puts 'Rate limited. Try again later.'
rescue XposedOrNot::NotFoundError
  puts 'Email not found in any breaches.'
rescue XposedOrNot::AuthenticationError
  puts 'Invalid API key.'
rescue XposedOrNot::NetworkError => e
  puts "Network error: #{e.message}"
rescue XposedOrNot::APIError => e
  puts "API error (#{e.status}): #{e.message}"
end
```

### Error Classes

| Error Class | Description |
|-------------|-------------|
| `XposedOrNotError` | Base error class for all errors |
| `ValidationError` | Invalid input (e.g., malformed email, blank password) |
| `RateLimitError` | API rate limit exceeded (HTTP 429) |
| `NotFoundError` | Resource not found (HTTP 404) |
| `AuthenticationError` | Authentication failed (HTTP 401/403) |
| `NetworkError` | Network connectivity issues or timeouts |
| `APIError` | General API error (exposes `.status` for the HTTP code) |

## Rate Limits

The XposedOrNot API has the following rate limits:

- 2 requests per second
- 50-100 requests per hour
- 100-1000 requests per day

The client includes automatic retry with exponential backoff for `429` responses and built-in client-side throttling (1 request per second) for the free API.

## Configuration

```ruby
client = XposedOrNot::Client.new(
  api_key:        'your-api-key',  # Optional. Enables Plus API access
  timeout:        15,              # Request timeout in seconds (default: 30)
  max_retries:    5,               # Max retries on 429 responses (default: 3)
  custom_headers: { 'X-Custom' => 'value' }
)
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `api_key` | `String` | `nil` | API key for Plus API access |
| `base_url` | `String` | `https://api.xposedornot.com` | Base URL for the free API |
| `plus_base_url` | `String` | `https://plus-api.xposedornot.com` | Base URL for the Plus API |
| `passwords_base_url` | `String` | `https://passwords.xposedornot.com/api` | Base URL for the password API |
| `timeout` | `Integer` | `30` | Request timeout in seconds |
| `max_retries` | `Integer` | `3` | Max retry attempts on 429 responses |
| `custom_headers` | `Hash` | `{}` | Custom headers for all requests |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Setup

```bash
# Clone the repository
git clone https://github.com/XposedOrNot/XposedOrNot-Ruby.git
cd XposedOrNot-Ruby

# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop
```

## License

MIT - see the [LICENSE](LICENSE) file for details.

## Links

- [XposedOrNot Website](https://xposedornot.com)
- [API Documentation](https://xposedornot.com/api_doc)
- [RubyGems Package](https://rubygems.org/gems/xposedornot)
- [GitHub Repository](https://github.com/XposedOrNot/XposedOrNot-Ruby)
- [XposedOrNot API Repository](https://github.com/XposedOrNot/XposedOrNot-API)

---

<p align="center">
  Made with care by <a href="https://xposedornot.com">XposedOrNot</a>
</p>
