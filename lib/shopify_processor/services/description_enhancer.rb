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
        response = OPENAI_CLIENT.chat(
          parameters: openai_chat_params(system_prompt)
        )

        puts("OpenAI API Response: #{response.inspect}")
        response.dig('choices', 0, 'message', 'content')
      rescue StandardError => e
        puts("OpenAI API Error: #{e.message}")
        @description
      end

      private

      def system_prompt
        'As a professional e-commerce copywriter. Enhance product descriptions to be ' \
          'SEO-friendly while maintaining key product details. ' \
          'Focus on features that drives conversions.'
      end

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
    end
  end
end
