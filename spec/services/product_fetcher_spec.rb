# frozen_string_literal: true

# # frozen_string_literal: true

# # spec/services/product_fetcher_spec.rb
require 'spec_helper'

RSpec.describe ShopifyProcessor::Services::ProductFetcher do
  let(:mock_products) do
    [
      instance_double(ShopifyAPI::Product, id: 1, title: 'Product 1',
                                           body_html: '<p>This is product 1.</p>'),
      instance_double(ShopifyAPI::Product, id: 2, title: 'Product 2',
                                           body_html: '<p>This is product 2.</p>')
    ]
  end

  describe '.fetch_all' do
    it 'delegates to the instance method' do
      instance = instance_double(described_class)
      expect(described_class).to receive(:new).and_return(instance)
      expect(instance).to receive(:fetch_all).and_return([])
      described_class.fetch_all
    end
  end

  describe '#fetch_all' do
    before do
      allow(ShopifyAPI::Auth::Session).to receive(:new).and_return(
        instance_double(ShopifyAPI::Auth::Session)
      )
      allow(ShopifyAPI::Context).to receive(:activate_session)
      allow(ShopifyAPI::Product).to receive(:all).and_return(mock_products)
      allow(ShopifyAPI::Context).to receive(:deactivate_session)
    end

    it 'creates a Shopify API session' do
      expect(ShopifyAPI::Auth::Session).to receive(:new).with(
        shop: "#{ENV.fetch('SHOPIFY_SHOP_NAME')}.myshopify.com",
        access_token: ENV.fetch('SHOPIFY_ACCESS_TOKEN')
      ).and_return(instance_double(ShopifyAPI::Auth::Session))
      subject.fetch_all
    end

    it 'activates the Shopify API session' do
      expect(ShopifyAPI::Context).to receive(:activate_session)
      subject.fetch_all
    end

    it 'fetches all Shopify products' do
      expect(ShopifyAPI::Product).to receive(:all).and_return(mock_products)
      subject.fetch_all
    end

    it 'deactivates the Shopify API session' do
      expect(ShopifyAPI::Context).to receive(:deactivate_session)
      subject.fetch_all
    end

    it 'returns an array of product hashes' do
      expected_products = [
        { id: 1, title: 'Product 1', description: 'This is product 1.' },
        { id: 2, title: 'Product 2', description: 'This is product 2.' }
      ]
      expect(subject.fetch_all).to eq(expected_products)
    end

    context 'when a Shopify API error occurs' do
      before do
        allow(ShopifyAPI::Product).to receive(:all).and_raise(StandardError, 'Shopify API error')
      end

      it 'logs the error message' do
        expect { subject.fetch_all }.to output(/Shopify API Error: Shopify API error/).to_stdout
      end

      it 'deactivates the Shopify API session' do
        expect(ShopifyAPI::Context).to receive(:deactivate_session)
        subject.fetch_all
      end

      it 'returns an empty array' do
        expect(subject.fetch_all).to eq([])
      end
    end
  end

  describe '#product_params' do
    let(:product) do
      instance_double(ShopifyAPI::Product, id: 1, title: 'Product 1',
                                           body_html: '<p>This is product 1.</p>')
    end

    it 'extracts the relevant product information' do
      expected_params = { id: 1, title: 'Product 1', description: 'This is product 1.' }
      expect(subject.send(:product_params, product)).to eq(expected_params)
    end
  end

  describe '#extract_text' do
    it 'extracts the plain text from the HTML body' do
      html_body = '<p>This is the product description.</p>'
      expect(subject.send(:extract_text, html_body)).to eq('This is the product description.')
    end
  end
end
