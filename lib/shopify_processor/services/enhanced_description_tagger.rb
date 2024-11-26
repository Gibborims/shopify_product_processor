# frozen_string_literal: true

# lib/shopify_processor/services/enhanced_description_tagger.rb
module ShopifyProcessor
  module Services
    class EnhancedDescriptionTagger
      def initialize(original_description:, enhanced_description:)
        @original_description = original_description
        @enhanced_description = enhanced_description
      end

      def call
        response = OPENAI_CLIENT.chat(
          parameters: {
            model: 'gpt-4',
            messages: [{
              role: 'system',
              content: system_content
            }, {
              role: 'user',
              content: user_content
            }]
          }
        )

        content = response.dig('choices', 0, 'message', 'content')
        raise 'Unexpected response structure' if content.nil?

        content
      rescue StandardError => e
        raise "Failed to generate HTML tags: #{e.message}"
      end

      private

      def system_content
        'You are an HTML tagger. Your task is to apply similar HTML formatting ' \
          'to the enhanced description as seen in the original description.'
      end

      def user_content
        "Original Description with HTML: #{@original_description}\n\nEnhanced " \
          "Description to Format: #{@enhanced_description}"
      end
    end
  end
end
