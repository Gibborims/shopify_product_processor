# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv'
require 'shopify_api'
Dotenv.load('.env.test')
require 'rspec'
require 'vcr'
require 'webmock/rspec'
require 'tempfile'
require_relative '../config/initializers'
require_relative '../lib/shopify_processor'
require_relative '../lib/api_keys'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.filter_sensitive_data('<SHOPIFY_ACCESS_TOKEN>') { SHOPIFY_ACCESS_TOKEN || nil }
  config.filter_sensitive_data('<OPENAI_API_KEY>') { OPENAI_API_KEY || nil }
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
