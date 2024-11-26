# frozen_string_literal: true

# spec/shopify_processor/services/product_by_id_fetcher_spec.rb
require 'spec_helper'

RSpec.describe ShopifyProcessor::Services::ProductByIdFetcher do
  let(:product_id) { '12345' }
  let(:shopify_product) { instance_double(ShopifyAPI::Product, body_html: expected_html) }
  let(:expected_html) { '<p>Product Description</p>' }

  before do
    allow(ShopifyAPI::Product).to receive(:find).with(id: product_id).and_return(shopify_product)
  end

  describe '#call' do
    it 'fetches the product body_html successfully' do
      fetcher = described_class.new(product_id: product_id)
      result = fetcher.call

      expect(result).to eq(expected_html)
      expect(ShopifyAPI::Product).to have_received(:find).with(id: product_id)
    end

    context 'when product fetching fails' do
      it 'raises an error with product details' do
        allow(ShopifyAPI::Product).to receive(:find).and_raise(StandardError.new('API Error'))

        fetcher = described_class.new(product_id: product_id)
        
        expect { fetcher.call }
          .to raise_error(RuntimeError, /Failed to fetch product #{product_id}/)
      end
    end
  end
end
