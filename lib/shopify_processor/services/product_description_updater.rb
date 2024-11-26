# frozen_string_literal: true

# lib/shopify_processor/services/product_description_updater.rb
module ShopifyProcessor
  module Services
    class ProductDescriptionUpdater
      def initialize(product_id:, enhanced_html_description:)
        @product_id = product_id
        @enhanced_html_description = enhanced_html_description
      end

      def call
        product = ShopifyAPI::Product.find(id: @product_id)
        product.body_html = @enhanced_html_description
        success = product.save

        raise "Failed to update product #{@product_id}: Update returned false" unless success
      rescue StandardError => e
        raise e.message.include?("Failed to update product #{@product_id}") ? e :
        "Failed to update product #{@product_id}: #{e.message}"
      end
    end
  end
end
