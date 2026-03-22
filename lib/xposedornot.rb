# frozen_string_literal: true

require_relative "xposedornot/version"
require_relative "xposedornot/errors"
require_relative "xposedornot/configuration"
require_relative "xposedornot/utils"
require_relative "xposedornot/models/breach"
require_relative "xposedornot/models/email_breach_response"
require_relative "xposedornot/models/email_breach_detailed_response"
require_relative "xposedornot/models/breach_analytics_response"
require_relative "xposedornot/models/password_check_response"
require_relative "xposedornot/endpoints/email"
require_relative "xposedornot/endpoints/breaches"
require_relative "xposedornot/endpoints/password"
require_relative "xposedornot/client"

# XposedOrNot API client library for checking data breaches.
#
# @example
#   client = XposedOrNot::Client.new
#   result = client.check_email("test@example.com")
module XposedOrNot
end
