#!/usr/bin/env ruby
# frozen_string_literal: true

require "xposedornot"

api_key = ENV.fetch("XON_API_KEY") { abort "Set XON_API_KEY environment variable" }

client = XposedOrNot::Client.new(api_key: api_key)

# Plus API returns detailed breach information
result = client.check_email("test@example.com")
puts "Status: #{result.status}"
result.breaches.each do |breach|
  puts "  Breach: #{breach.breach_id} (Domain: #{breach.domain}, Records: #{breach.xposed_records})"
end

# Get breach analytics
analytics = client.breach_analytics("test@example.com")
puts "Total breaches: #{analytics.breaches_count}"
puts "Total exposures: #{analytics.exposures_count}"
