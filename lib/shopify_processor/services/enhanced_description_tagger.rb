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
            model: "gpt-4",
            messages: [{
              role: "system",
              content: "You are an HTML tagger. Your task is to apply similar HTML formatting to the enhanced description as seen in the original description."
            }, {
              role: "user",
              content: "Original Description with HTML: #{@original_description}\n\nEnhanced Description to Format: #{@enhanced_description}"
            }]
          }
        )

        response.dig("choices", 0, "message", "content")
      rescue StandardError => e
        raise "Failed to generate HTML tags: #{e.message}"
      end
    end
  end
end
