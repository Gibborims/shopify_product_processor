# frozen_string_literal: true

### Main Configuration (config/initializers.rb)

require 'dotenv'
require 'shopify_api'
require 'openai'
require 'amazing_print'
require 'zeitwerk'

# Load environment variables
Dotenv.load

# Initialize Zeitwerk loader
loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../lib")
loader.setup

# Configure Shopify API
ShopifyAPI::Context.setup(
  api_key: ENV.fetch('SHOPIFY_ACCESS_TOKEN'),
  api_version: ENV.fetch('SHOPIFY_API_VERSION'),
  host: "#{ENV.fetch('SHOPIFY_SHOP_NAME')}.myshopify.com",
  api_secret_key: ENV.fetch('SHOPIFY_API_SECRET_KEY', 'test-secret-key'), # Add to your .env.test
  scope: [], # Add scopes if needed
  is_private: true, # Set to true for private apps
  is_embedded: false, # Set to false for non-embedded apps
  private_shop: "https://#{ENV.fetch('SHOPIFY_SHOP_NAME')}.myshopify.com",  # Required for private apps
  user_agent_prefix: "CustomApp/1.0"         # Optional but recommended
)

# Configure OpenAI client
OPENAI_CLIENT = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY'))
