# frozen_string_literal: true

# spec/processor_spec.rb
require 'spec_helper'

RSpec.describe ShopifyProcessor::Processor do
  let(:processor) { described_class.new }
  let(:mock_products) do
    [
      {
        id: 1,
        title: 'Product 1',
        description: 'Original description 1'
      }
    ]
  end

  describe '#run' do
    before do
      allow(ShopifyProcessor::Services::ProductFetcher).to receive(:fetch_all)
        .and_return(mock_products)
      allow(ShopifyProcessor::Services::DescriptionEnhancer).to receive(:process)
        .and_return('Enhanced description 1')
    end

    it 'creates CSV file with processed descriptions' do
      processor.run
      csv_files = Dir.glob('product_descriptions_*.csv')
      expect(csv_files).not_to be_empty

      content = CSV.read(csv_files.last)
      expect(content[0]).to eq(['Original Description', 'Enhanced Description'])
      expect(content[1][0]).to eq('Original description 1')
      expect(content[1][1]).to eq('Enhanced description 1')
    end
  end
end
