# frozen_string_literal: true

# # frozen_string_literal: true

# spec/services/shopify_processor/processor_spec.rb
require 'spec_helper'

RSpec.describe ShopifyProcessor::Processor do
  let(:mock_products) do
    [
      { id: '123456789', title: 'Product 1',
        description: 'This is the original description for Product 1.' },
      { id: '987654321', title: 'Product 2',
        description: 'This is the original description for Product 2.' }
    ]
  end

  let(:mock_enhanced_descriptions) do
    ['Enhanced description for Product 1.', 'Enhanced description for Product 2.']
  end

  let(:subject) { described_class.new }

  describe '.run' do
    it 'delegates to the instance method' do
      expect_any_instance_of(described_class).to receive(:run)
      described_class.run
    end
  end

  describe '#run' do
    before do
      allow(ShopifyProcessor::Services::ProductFetcher).to receive(:fetch_all)
        .and_return(mock_products)
      allow(ShopifyProcessor::Services::DescriptionEnhancer).to receive(:process)
        .with(mock_products[0][:description]).and_return(mock_enhanced_descriptions[0])
      allow(ShopifyProcessor::Services::DescriptionEnhancer).to receive(:process)
        .with(mock_products[1][:description]).and_return(mock_enhanced_descriptions[1])
    end

    it 'fetches all products' do
      expect(ShopifyProcessor::Services::ProductFetcher).to receive(:fetch_all)
        .and_return(mock_products)
      subject.run
    end

    it 'processes the products' do
      expect(subject).to receive(:process_products).with(mock_products)
      subject.run
    end
  end

  describe '#process_products' do
    let(:csv_double) { instance_double(CSV) }
    let(:csv_file) { "product_descriptions_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv" }

    before do
      allow(CSV).to receive(:open).with(csv_file, 'wb').and_yield(csv_double)
      allow(csv_double).to receive(:<<)

      # Mock each call to DescriptionEnhancer.process to return the correct enhanced description
      allow(ShopifyProcessor::Services::DescriptionEnhancer).to receive(:process)
        .with(mock_products[0][:description]).and_return(mock_enhanced_descriptions[0])
      allow(ShopifyProcessor::Services::DescriptionEnhancer).to receive(:process)
        .with(mock_products[1][:description]).and_return(mock_enhanced_descriptions[1])
    end

    it 'creates a CSV file with the original and enhanced descriptions' do
      expect(CSV).to receive(:open).with(csv_file, 'wb')
      expect(csv_double).to receive(:<<).with(['Product ID', 'Original Description',
                                               'Enhanced Description', 'Changed'])
      expect(csv_double).to receive(:<<).with([mock_products[0][:id],
                                               mock_products[0][:description],
                                               mock_enhanced_descriptions[0], ''])
      expect(csv_double).to receive(:<<).with([mock_products[1][:id],
                                               mock_products[1][:description],
                                               mock_enhanced_descriptions[1], ''])

      subject.send(:process_products, mock_products)
    end
  end

  describe '#csv_records' do
    it 'returns an array of CSV records' do
      product = { id: '123456789', description: 'Original description' }
      enhanced_description = 'Enhanced description'
      expect(subject.send(:csv_records, product,
                          enhanced_description)).to eq(['123456789', 'Original description',
                                                        'Enhanced description', ''])
    end
  end
end
