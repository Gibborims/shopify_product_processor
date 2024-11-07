# frozen_string_literal: true

### Main Configuration (config/initializers.rb)

require 'csv'
require 'dotenv'
require 'shopify_api'
require 'nokogiri'
require 'openai'
require 'amazing_print'
require 'zeitwerk'
# Require the ApiKeys module
require_relative '../lib/api_keys'

# Load environment variables
Dotenv.load

# Initialize Zeitwerk loader
loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../lib")
loader.setup

# Load the keys
ApiKeys.load_keys

# Initialize the constants
SHOPIFY_SHOP_NAME = ApiKeys.shopify_shop_name
SHOPIFY_ACCESS_TOKEN = ApiKeys.shopify_access_token
OPENAI_API_KEY = ApiKeys.openai_api_key
SHOPIFY_API_VERSION = ApiKeys.shopify_api_version
SHOPIFY_API_SECRET_KEY = ApiKeys.shopify_api_secret_key

# Configure Shopify API
ShopifyAPI::Context.setup(
  api_key: SHOPIFY_ACCESS_TOKEN,
  api_version: SHOPIFY_API_VERSION,
  host: "#{SHOPIFY_SHOP_NAME}.myshopify.com",
  api_secret_key: SHOPIFY_API_SECRET_KEY, # Add to your .env.test
  scope: [], # Add scopes if needed
  is_private: true, # Set to true for private apps
  is_embedded: false, # Set to false for non-embedded apps
  private_shop: "https://#{SHOPIFY_SHOP_NAME}.myshopify.com",
  user_agent_prefix: 'CustomApp/1.0' # Optional but recommended
)

# Configure OpenAI client
OPENAI_CLIENT = OpenAI::Client.new(access_token: OPENAI_API_KEY)
