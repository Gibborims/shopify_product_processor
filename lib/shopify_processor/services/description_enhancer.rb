# frozen_string_literal: true

module ShopifyProcessor
  module Services
    # Implement shopify product description enhancer services
    class DescriptionEnhancer
      def self.process(description)
        new(description).process
      end

      def initialize(description)
        @description = description
      end

      def process
        response = fetch_openai_response(system_prompt)
        puts "Response:: #{response.inspect}"
        return extract_content(response) if response.is_a?(Hash) && response['choices']

        handle_response_error(response) if response.is_a?(Hash) && response['error']

        puts('OpenAI API Error: Unable to process the request.')
        @description
      rescue StandardError => e
        puts("Unexpected Error: #{e.message}")
        @description
      end

      private

      # Fetch response from OpenAI API with error handling
      def fetch_openai_response(system_prompt)
        OPENAI_CLIENT.chat(parameters: openai_chat_params(system_prompt))
      rescue StandardError => e
        puts("General API Error: #{e.message}")
        nil
      end

      # Extract relevant content from the response
      def extract_content(response)
        content = response.dig('choices', 0, 'message', 'content')
        puts("OpenAI API Response: #{content.inspect}")
        content
      end

      # OpenAI Chat parameters setup
      def openai_chat_params(system_prompt)
        {
          model: 'gpt-3.5-turbo',
          messages: [
            { role: 'system', content: system_prompt },
            { role: 'user', content: "Kindly enhance this product description: #{@description}" }
          ],
          temperature: 0.7
        }
      end

      # System prompt definition
      def system_prompt
        'As a professional e-commerce copywriter. Enhance product descriptions to be ' \
          'SEO-friendly while maintaining key product details. ' \
          'Focus on features that drive conversions.'
      end

      # Handle response errors that are returned as a Hash
      def handle_response_error(response)
        error = response['error']
        puts "Error Type: #{error['type']}"
        puts "Error Code: #{error['code']}"
        puts "Error Message: #{error['message']}"

        case error['type']
        when 'invalid_request_error'
          puts "Invalid request: #{error['message']}"
        when 'invalid_authentication_error'
          puts 'Authentication failed. Check your API key.'
        when 'rate_limit_error'
          puts 'Rate limit exceeded. Please slow down your requests.'
        when 'insufficient_quota'
          puts 'Quota exceeded. Please check your plan.'
        when 'server_error'
          puts 'Server error. Please try again later.'
        else
          puts 'An unknown error occurred.'
        end
      end
    end
  end
end
