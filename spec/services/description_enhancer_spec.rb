# frozen_string_literal: true

# spec/services/shopify_processor/services/description_enhancer_spec.rb
require 'spec_helper'

RSpec.describe ShopifyProcessor::Services::DescriptionEnhancer do
  let(:mock_openai_response) do
    {
      'choices' => [
        {
          'message' => {
            'content' => 'Enhanced product description.'
          }
        }
      ]
    }
  end

  let(:mock_openai_error_response) do
    {
      'error' => {
        'type' => 'invalid_request_error',
        'code' => 'something_went_wrong',
        'message' => 'Invalid request: something went wrong.'
      }
    }
  end

  let(:original_description) { 'This is the original product description.' }
  let(:subject) { described_class.new(original_description) }

  describe '.process' do
    it 'delegates to the instance method' do
      expect_any_instance_of(described_class).to receive(:process).and_return(
        'Enhanced description'
      )
      described_class.process(original_description)
    end
  end

  describe '#process' do
    before do
      allow(ENV).to receive(:fetch).with('OPENAI_API_KEY').and_return('fake_api_key')
      allow(subject).to receive(:fetch_openai_response).with(subject.send(:system_prompt))
                                                       .and_return(mock_openai_response)
    end

    it 'fetches the OpenAI response with the correct parameters' do
      expect(subject).to receive(:fetch_openai_response).with(subject.send(:system_prompt))
                                                        .and_return(mock_openai_response)
      subject.process
    end

    it 'extracts the content from the OpenAI response' do
      expect(subject).to receive(:extract_content).with(mock_openai_response)
                                                  .and_return('Enhanced product description.')
      expect(subject.process).to eq('Enhanced product description.')
    end

    context 'when the OpenAI response contains an error' do
      before do
        allow(subject).to receive(:fetch_openai_response).and_return(mock_openai_error_response)
      end

      it 'handles the response error' do
        expect(subject).to receive(:handle_response_error).with(mock_openai_error_response)
        subject.process
      end

      it 'returns the original description' do
        expect(subject.process).to eq(original_description)
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(subject).to receive(:fetch_openai_response).and_raise(StandardError,
                                                                    'Unexpected error')
      end

      it 'logs the error message' do
        expect { subject.process }.to output("Unexpected Error: Unexpected error\n").to_stdout
      end

      it 'returns the original description' do
        expect(subject.process).to eq(original_description)
      end
    end
  end

  describe '#fetch_openai_response' do
    let(:user_content) do
      "Kindly enhance this product description: #{original_description}"
    end
    it 'calls the OpenAI API with the correct parameters' do
      expect(OPENAI_CLIENT).to receive(:chat).with(parameters: {
                                                     model: 'gpt-3.5-turbo',
                                                     messages: [
                                                       { role: 'system',
                                                         content: subject.send(:system_prompt) },
                                                       { role: 'user',
                                                         content: user_content }
                                                     ],
                                                     temperature: 0.7
                                                   }).and_return(mock_openai_response)

      subject.send(:fetch_openai_response, subject.send(:system_prompt))
    end

    context 'when an error occurs during the API call' do
      before do
        allow(OPENAI_CLIENT).to receive(:chat).and_raise(StandardError, 'API error')
      end

      it 'logs the error message' do
        expect do
          subject.send(:fetch_openai_response,
                       subject.send(:system_prompt))
        end.to output("General API Error: API error\n").to_stdout
      end

      it 'returns nil' do
        expect(subject.send(:fetch_openai_response, subject.send(:system_prompt))).to be_nil
      end
    end
  end

  describe '#extract_content' do
    it 'extracts the content from the OpenAI response' do
      expect(subject.send(:extract_content,
                          mock_openai_response)).to eq('Enhanced product description.')
    end
  end

  describe '#handle_response_error' do
    it 'logs the error details' do
      expect do
        subject.send(:handle_response_error, mock_openai_error_response)
      end.to output(<<~OUTPUT).to_stdout
        Error Type: invalid_request_error
        Error Code: something_went_wrong
        Error Message: Invalid request: something went wrong.
        Invalid request: Invalid request: something went wrong.
      OUTPUT
    end
  end
end
