# frozen_string_literal: true

# spec/lib/api_keys_spec.rb
# require 'rspec'
# require 'csv'
require_relative '../../lib/api_keys'

RSpec.describe ApiKeys do
  let(:csv_content) do
    <<~CSV
      shopify_shop_name,shopify_access_token,openai_api_key,shopify_api_version,shopify_api_secret_key
      example_shop,example_token,example_openai_key,2023-07,example_secret_key
    CSV
  end

  before do
    # Stub CSV.foreach to return our custom CSV content
    allow(CSV).to receive(:foreach).and_yield(
      {
        'shopify_shop_name' => 'example_shop',
        'shopify_access_token' => 'example_token',
        'openai_api_key' => 'example_openai_key',
        'shopify_api_version' => '2023-07',
        'shopify_api_secret_key' => 'example_secret_key'
      }
    )

    # Mock ENV.fetch to avoid dependency on actual environment variable
    allow(ENV).to receive(:fetch).with('RUBY_ENV').and_return('test')

    # Load keys before each test
    ApiKeys.load_keys
  end

  describe '.load_keys' do
    it 'loads the Shopify shop name correctly' do
      expect(ApiKeys.shopify_shop_name).to eq('example_shop')
    end

    it 'loads the Shopify access token correctly' do
      expect(ApiKeys.shopify_access_token).to eq('example_token')
    end

    it 'loads the OpenAI API key correctly' do
      expect(ApiKeys.openai_api_key).to eq('example_openai_key')
    end

    it 'loads the Shopify API version correctly' do
      expect(ApiKeys.shopify_api_version).to eq('2023-07')
    end

    it 'loads the Shopify API secret key correctly' do
      expect(ApiKeys.shopify_api_secret_key).to eq('example_secret_key')
    end
  end
end
