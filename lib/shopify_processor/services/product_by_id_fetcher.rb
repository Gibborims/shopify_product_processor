# frozen_string_literal: true

# lib/shopify_processor/services/product_by_id_fetcher.rb
module ShopifyProcessor
  module Services
    class ProductByIdFetcher
      def initialize(product_id:)
        @product_id = product_id
      end

      def call
        product = ShopifyAPI::Product.find(id: @product_id)
        product.body_html
      rescue StandardError => e
        raise "Failed to fetch product #{@product_id}: #{e.message}"
      end
    end
  end
end
