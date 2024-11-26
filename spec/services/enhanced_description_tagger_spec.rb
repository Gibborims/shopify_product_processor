# frozen_string_literal: true

# spec/shopify_processor/services/enhanced_description_tagger_spec.rb
require 'spec_helper'

RSpec.describe ShopifyProcessor::Services::EnhancedDescriptionTagger do
  let(:original_description) { '<p>Original Product Description</p>' }
  let(:enhanced_description) { 'Enhanced product description with more details' }
  let(:openai_response) do
    {
      'choices' => [
        {
          'message' => {
            'content' => '<div>Enhanced product description with more details</div>'
          }
        }
      ]
    }
  end

  describe '#call' do
    let(:system_content) do
      'You are an HTML tagger. Your task is to apply similar HTML formatting ' \
        'to the enhanced description as seen in the original description.'
    end

    let(:user_content) do
      "Original Description with HTML: #{original_description}\n\nEnhanced " \
        "Description to Format: #{enhanced_description}"
    end

    it 'generates enhanced HTML description using OpenAI' do
      # Expect the correct parameters to be sent to OpenAI
      expect(OPENAI_CLIENT).to receive(:chat).with(
        parameters: {
          model: 'gpt-4',
          messages: [
            {
              role: 'system',
              content: system_content
            },
            {
              role: 'user',
              content: user_content
            }
          ]
        }
      ).and_return(openai_response)

      # Create and call the tagger
      tagger = described_class.new(
        original_description: original_description,
        enhanced_description: enhanced_description
      )
      result = tagger.call

      # Verify the result
      expect(result).to eq('<div>Enhanced product description with more details</div>')
    end

    context 'when OpenAI API call fails' do
      it 'raises an error with details' do
        # Simulate OpenAI API failure
        allow(OPENAI_CLIENT).to receive(:chat).and_raise(StandardError.new('API Error'))

        tagger = described_class.new(
          original_description: original_description,
          enhanced_description: enhanced_description
        )

        expect { tagger.call }
          .to raise_error(RuntimeError, /Failed to generate HTML tags/)
      end
    end

    context 'when OpenAI returns unexpected response' do
      let(:tagger) do
        described_class.new(
          original_description: original_description,
          enhanced_description: enhanced_description
        )
      end

      it 'handles missing response structure' do
        allow(OPENAI_CLIENT).to receive(:chat).and_return({}) # Simulate malformed response

        expect do
          tagger.call
        end.to raise_error(RuntimeError,
                           'Failed to generate HTML tags: Unexpected response structure')
      end
    end
  end
end
