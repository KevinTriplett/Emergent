OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_API_KEY")
  # config.organization_id = ENV.fetch("OPENAI_ORGANIZATION_ID") # Optional.
end

# Anthropic.configure do |config|
#   config.access_token = ENV.fetch("ANTHROPIC_API_KEY")
#   config.anthropic_version = "2023-01-01" # Optional
#   # config.request_timeout = 240 # Optional
# end