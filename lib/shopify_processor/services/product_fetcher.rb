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

        puts ENV.inspect
        # Create a session for API calls
        session = create_session
        activate_session(session)

        ShopifyAPI::Product.all.first(1).each do |product|
          products << product_params(product)

          sleep 0.5 # Rate limiting
        end

        deactivate_session
        products
      rescue StandardError => e
        puts("Shopify API Error: #{e.message}")

        deactivate_session
        []
      end

      private

      def create_session
        ShopifyAPI::Auth::Session.new(
          shop: "#{ENV.fetch('SHOPIFY_SHOP_NAME')}.myshopify.com",
          access_token: ENV.fetch('SHOPIFY_ACCESS_TOKEN')
        )
      end

      def deactivate_session
        ShopifyAPI::Context.deactivate_session
      end

      def activate_session(session)
        ShopifyAPI::Context.activate_session(session)
      end

      def product_params(product)
        {
          id: product.id,
          title: product.title,
          description: "Ruby Software"
        }
      end
    end
  end
end
