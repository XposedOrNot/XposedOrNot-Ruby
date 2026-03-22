#!/usr/bin/env ruby
# frozen_string_literal: true

require "xposedornot"

client = XposedOrNot::Client.new

# Check if an email has been exposed
result = client.check_email("test@example.com")
if result.breached?
  puts "Found in #{result.breaches.length} breaches:"
  result.breaches.each { |b| puts "  - #{b}" }
else
  puts "Email not found in any known breaches."
end

# Get all known breaches
breaches = client.get_breaches
puts "Total known breaches: #{breaches.length}"

# Check a password (hashed locally, never sent in clear text)
pass_result = client.check_password("test-password-here")  # replace with the password to check
if pass_result.exposed?
  puts "Password found #{pass_result.count} times in breaches"
else
  puts "Password not found in any known breaches"
end
