# frozen_string_literal: true

# spec/shopify_processor/product_update_processor_spec.rb
require 'spec_helper'

RSpec.describe ShopifyProcessor::ProductUpdateProcessor do
  # Mock dependencies
  let(:shopify_product) { instance_double(ShopifyAPI::Product, body_html: original_html) }
  let(:original_html) { '<p>Original Product Description</p>' }
  let(:enhanced_description) { 'Enhanced product description with more details' }
  let(:enhanced_html) { '<div>Enhanced product description with more details</div>' }
  let(:product_id) { '12345' }

  # Create a temporary CSV for testing
  let(:csv_content) do
    [
      ['Product ID', 'Original Description', 'Enhanced Description', 'Changed'],
      [product_id, 'Original Desc', enhanced_description, 'true'],
      ['67890', 'Another Desc', 'Another Enhanced', 'false'],
      ['11111', 'Third Desc', 'Third Enhanced', nil]
    ]
  end

  let(:temp_csv) do
    Tempfile.new('enhanced_product_desc.csv').tap do |file|
      CSV.open(file.path, 'w') do |csv|
        csv_content.each { |row| csv << row }
      end
      file.close
    end
  end

  before do
    # Stub external dependencies
    # Mock ShopifyAPI::Product.find to return the double
    allow(ShopifyAPI::Product).to receive(:find).with(id: product_id).and_return(shopify_product)

    allow(OPENAI_CLIENT).to receive(:chat).and_return(
      {
        'choices' => [
          {
            'message' => {
              'content' => enhanced_html
            }
          }
        ]
      }
    )
    allow(shopify_product).to receive(:save)

    # Override the CSV file path for testing
    stub_const('ShopifyProcessor::ProductUpdateProcessor::CSV_FILE_PATH', temp_csv.path)
  end

  after do
    temp_csv.unlink
  end

  describe '#process_updates' do
    xcontext 'when processing product updates' do
      it 'skips products with changed not set to true' do
        # Expectations for skipped products
        expect(ShopifyProcessor::Services::ProductByIdFetcher).not_to receive(:new)
          .with(product_id: '67890')
        expect(ShopifyProcessor::Services::ProductByIdFetcher).not_to receive(:new)
          .with(product_id: '11111')

        # Perform the update
        processor = described_class.new
        processor.process_updates
      end
    end

    context 'when processing product updates' do
      let(:csv_data) do
        [{ 'Product ID' => product_id, 'Enhanced Description' => enhanced_description,
           'Changed' => 'true' }]
      end
      let(:shopify_product) do
        double(ShopifyAPI::Product,
               body_html: original_html,
               save: true).tap do |product|
          allow(product).to receive(:body_html=)
        end
      end

      before do
        # Mock CSV.foreach to simulate a row with "Changed" set to true
        allow(CSV).to receive(:foreach).and_yield(csv_data.first)

        # Ensure product.save returns true to simulate a successful save
        allow(shopify_product).to receive(:save).and_return(true)

        # Stub body_html methods
        allow(shopify_product).to receive(:body_html=)
      end

      it 'processes products with changed set to true' do
        # Expectations for service interactions
        expect(ShopifyProcessor::Services::ProductByIdFetcher).to receive(:new)
          .with(product_id: product_id)
          .and_call_original

        expect(ShopifyProcessor::Services::EnhancedDescriptionTagger).to receive(:new)
          .with(
            original_description: original_html,
            enhanced_description: enhanced_description
          )
          .and_call_original

        expect(ShopifyProcessor::Services::ProductDescriptionUpdater).to receive(:new)
          .with(
            product_id: product_id,
            enhanced_html_description: enhanced_html
          )
          .and_call_original

        # Perform the update
        processor = described_class.new
        processor.process_updates
      end
    end

    context 'error handling' do
      let(:csv_data) do
        [{ 'Product ID' => product_id, 'Enhanced Description' => enhanced_description,
           'Changed' => 'true' }]
      end
      let(:shopify_product) { double(ShopifyAPI::Product) }

      before do
        allow(CSV).to receive(:foreach).and_yield(csv_data.first)

        # Mock the interactions with shopify_product
        allow(shopify_product).to receive(:body_html).and_return(original_html)
        allow(shopify_product).to receive(:body_html=)
      end

      it 'handles errors during product fetching' do
        allow(ShopifyAPI::Product).to receive(:find).and_raise(StandardError.new('Fetch Error'))

        expect(OPENAI_CLIENT).not_to receive(:chat)

        expect do
          described_class.new.process_updates
        end.to raise_error(StandardError, /Failed to fetch product/)
      end

      it 'handles errors during description tagging' do
        allow(OPENAI_CLIENT).to receive(:chat).and_raise(StandardError.new('OpenAI Error'))

        expect do
          described_class.new.process_updates
        end.to raise_error(StandardError, /Failed to generate HTML tags/)
      end

      it 'handles errors during product update' do
        allow(shopify_product).to receive(:save).and_raise(StandardError.new('Update Error'))

        expect do
          described_class.new.process_updates
        end.to raise_error(StandardError, /Failed to update product/)
      end
    end
  end

  describe 'service classes' do
    describe ShopifyProcessor::Services::ProductByIdFetcher do
      it 'fetches product body_html' do
        fetcher = described_class.new(product_id: product_id)
        expect(fetcher.call).to eq(original_html)
      end
    end

    describe ShopifyProcessor::Services::EnhancedDescriptionTagger do
      it 'generates enhanced HTML description' do
        tagger = described_class.new(
          original_description: original_html,
          enhanced_description: enhanced_description
        )
        expect(tagger.call).to eq(enhanced_html)
      end
    end

    describe ShopifyProcessor::Services::ProductDescriptionUpdater do
      let(:shopify_product) { double(ShopifyAPI::Product, save: true, body_html: nil) }

      before do
        allow(shopify_product).to receive(:body_html=)
        allow(shopify_product).to receive(:save).and_return(true)
      end

      it 'updates product description' do
        updater = described_class.new(
          product_id: product_id,
          enhanced_html_description: enhanced_html
        )
        expect { updater.call }.not_to raise_error
        expect(shopify_product).to have_received(:body_html=).with(enhanced_html)
        expect(shopify_product).to have_received(:save)
      end
    end
  end
end
