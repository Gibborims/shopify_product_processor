# frozen_string_literal: true

module ShopifyProcessor
  module Services
    # Implement shopify product fetcher services
    class ProductFetcher
      def self.fetch_all
        new.fetch_all
      end

      def fetch_all
        products = []

        ShopifyAPI::Product.all.each do |product|
          products << product_params(product)

          sleep 0.5 # Rate limiting
        end

        products
      rescue StandardError => e
        puts("Shopify API Error: #{e.message}")
        []
      end

      def product_params(product)
        {
          id: product.id,
          title: product.title,
          description: product.body_html
        }
      end
    end
  end
end
