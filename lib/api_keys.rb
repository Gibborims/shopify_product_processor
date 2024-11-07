# frozen_string_literal: true

# lib/api_keys.rb
require 'csv'

module ApiKeys
  @shopify_shop_name = nil
  @shopify_access_token = nil
  @openai_api_key = nil
  @shopify_api_version = nil
  @shopify_api_secret_key = nil

  def self.load_keys
    api_keys_csv = ENV.fetch('RUBY_ENV') == 'development' ? 'api_keys.csv' : 'test_api_keys.csv'
    CSV.foreach(api_keys_csv, headers: true) do |row|
      @shopify_shop_name = row['shopify_shop_name']
      @shopify_access_token = row['shopify_access_token']
      @openai_api_key = row['openai_api_key']
      @shopify_api_version = row['shopify_api_version']
      @shopify_api_secret_key = row['shopify_api_secret_key']
    end
  end

  class << self
    attr_reader :shopify_shop_name, :shopify_access_token, :openai_api_key, :shopify_api_version,
                :shopify_api_secret_key
  end
end
