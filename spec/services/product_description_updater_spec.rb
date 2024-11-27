# frozen_string_literal: true

# spec/shopify_processor/services/product_description_updater_spec.rb
require 'spec_helper'

describe ShopifyProcessor::Services::ProductDescriptionUpdater do
  describe '#call' do
    let(:product_id) { 123 }
    let(:enhanced_html_description) { '<p>Enhanced Description</p>' }
    let(:product) { double('ShopifyAPI::Product', save: save_result, body_html: nil) }
    let(:save_result) { false }
    let(:updater) do
      described_class.new(product_id: product_id,
                          enhanced_html_description: enhanced_html_description)
    end

    before do
      allow(ShopifyAPI::Product).to receive(:find).with(id: product_id).and_return(product)
      # Mock the setter for body_html
      allow(product).to receive(:body_html=)
    end

    context 'when product update is successful' do
      let(:save_result) { true }
      it 'updates the product description' do
        allow(product).to receive(:body_html=).with(enhanced_html_description)
        allow(product).to receive(:save).and_return(true)

        expect(product).to receive(:body_html=).with(enhanced_html_description)
        expect(product).to receive(:save)

        expect { updater.call }.not_to raise_error
      end
    end

    context 'when product save fails' do
      let(:save_result) { false }
      it 'raises an error indicating the update failure' do
        allow(product).to receive(:body_html=).with(enhanced_html_description)
        allow(product).to receive(:save).and_return(false)

        expect do
          updater.call
        end.to raise_error(RuntimeError,
                           "Failed to update product #{product_id}: Update returned false")
      end
    end

    context 'when an exception occurs during the process' do
      let(:save_result) { false }
      it 'raises an error with the exception message' do
        allow(ShopifyAPI::Product).to receive(:find)
          .and_raise(StandardError.new('API is unavailable'))

        expect do
          updater.call
        end.to raise_error(RuntimeError,
                           "Failed to update product #{product_id}: API is unavailable")
      end
    end
  end
end
