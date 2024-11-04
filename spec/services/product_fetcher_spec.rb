# frozen_string_literal: true

# spec/services/product_fetcher_spec.rb
require 'spec_helper'

# Define a custom error class for testing
class MockApiError < StandardError; end

RSpec.describe ShopifyProcessor::Services::ProductFetcher do
  let(:service) { described_class.new }

  describe '#fetch_all' do
    context 'when Shopify API call is successful' do
      let(:mock_products) do
        [
          double(
            id: 1,
            title: 'Product 1',
            body_html: 'Description 1'
          ),
          double(
            id: 2,
            title: 'Product 2',
            body_html: 'Description 2'
          )
        ]
      end

      before do
        allow(ShopifyAPI::Product).to receive(:all)
          .and_return(mock_products)
      end

      it 'returns array of formatted products' do
        products = service.fetch_all
        expect(products).to be_an(Array)
        expect(products.length).to eq(2)
        expect(products.first).to include(
          id: 1,
          title: 'Product 1',
          description: 'Description 1'
        )
      end
    end

    context 'when Shopify API fails' do
      before do
        allow(ShopifyAPI::Product).to receive(:all)
          .and_raise(MockApiError.new('Rate limit exceeded'))
      end

      it 'returns empty array and logs error' do
        expect { service.fetch_all }.to output(/Shopify API Error: Rate limit exceeded/).to_stdout
        expect(service.fetch_all).to eq([])
      end
    end
  end
end
