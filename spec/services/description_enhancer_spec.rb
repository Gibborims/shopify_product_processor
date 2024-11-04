# frozen_string_literal: true

# spec/services/description_enhancer_spec.rb
require 'spec_helper'

RSpec.describe ShopifyProcessor::Services::DescriptionEnhancer do
  let(:description) { 'Basic black t-shirt' }
  let(:openai_content) do
    'This sleek, comfortable black t-shirt is perfect for everyday wear. ' \
      'Made from high-quality materials, it offers a great fit and timeless style.'
  end
  let(:enhanced_response) do
    {
      choices: [
        {
          message: {
            content: openai_content
          }
        }
      ]
    }.to_json
  end
  let(:service) { described_class.new(description) }

  before do
    stub_request(:post, 'https://api.openai.com/v1/chat/completions')
      .to_return(
        status: 200,
        body: enhanced_response,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  describe '#process' do
    context 'when OpenAI API call is successful' do
      it 'returns enhanced description' do
        VCR.use_cassette('openai_successful_enhancement') do
          enhanced = service.process
          expect(enhanced).to be_a(String)
          expect(enhanced).not_to eq(description)
          expect(enhanced.length).to be > description.length
        end
      end
    end

    context 'when OpenAI API fails' do
      before do
        allow(OPENAI_CLIENT).to receive(:chat).and_raise(OpenAI::Error)
      end

      it 'returns original description and logs error' do
        expect { service.process }.to output(/OpenAI API Error/).to_stdout
        expect(service.process).to eq(description)
      end
    end
  end
end
