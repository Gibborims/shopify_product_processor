# frozen_string_literal: true

### Main Configuration (config/initializers.rb)

require 'csv'
require 'dotenv'
require 'shopify_api'
require 'nokogiri'
require 'openai'
require 'amazing_print'
require 'zeitwerk'

# Load environment variables
Dotenv.load

# Initialize Zeitwerk loader
loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../lib")
loader.setup

# Determine the appropriate API keys CSV file based on the Rails environment
api_keys_csv = ENV.fetch('RAILS_ENV') == 'development' ? 'api_keys.csv' : 'test_api_keys.csv'

# Initialize the constants
SHOPIFY_SHOP_NAME = nil
SHOPIFY_ACCESS_TOKEN = nil
OPENAI_API_KEY = nil
SHOPIFY_API_VERSION = nil
SHOPIFY_API_SECRET_KEY = nil

# Load the API keys from the CSV file
CSV.foreach(api_keys_csv, headers: true) do |row|
  # Make the API keys available throughout your application
  SHOPIFY_SHOP_NAME = row['shopify_shop_name']
  SHOPIFY_ACCESS_TOKEN = row['shopify_access_token']
  OPENAI_API_KEY = row['openai_api_key']
  SHOPIFY_API_VERSION = row['shopify_api_version']
  SHOPIFY_API_SECRET_KEY = row['shopify_api_secret_key']
end

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
