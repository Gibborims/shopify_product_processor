# frozen_string_literal: true

# lib/shopify_processor/product_update_processor.rb
module ShopifyProcessor
  class ProductUpdateProcessor
    CSV_FILE_PATH = File.join(File.dirname(__FILE__), '..', '..', 'enhanced_product_desc.csv')

    def self.run
      new.process_updates
    end

    def process_updates
      activate_shopify_session do
        CSV.foreach(CSV_FILE_PATH, headers: true) do |row|
          next unless row['Changed']&.downcase == 'true'

          process_product_update(
            product_id: row['Product ID'],
            enhanced_description: row['Enhanced Description']
          )

          sleep 0.5
        end
      end
    end

    private

    def activate_shopify_session
      session = ShopifyAPI::Auth::Session.new(
        shop: "#{SHOPIFY_SHOP_NAME}.myshopify.com",
        access_token: SHOPIFY_ACCESS_TOKEN
      )
      ShopifyAPI::Context.activate_session(session)
      yield
    ensure
      ShopifyAPI::Context.deactivate_session
    end

    def process_product_update(product_id:, enhanced_description:)
      original_html_description = fetch_product_description(product_id)

      enhanced_html_description = tag_enhanced_description(
        original_description: original_html_description,
        enhanced_description: enhanced_description
      )

      update_product_description(
        product_id: product_id,
        enhanced_html_description: enhanced_html_description
      )
    end

    def fetch_product_description(product_id)
      Services::ProductByIdFetcher.new(product_id: product_id).call
    end

    def tag_enhanced_description(original_description:, enhanced_description:)
      Services::EnhancedDescriptionTagger.new(
        original_description: original_description,
        enhanced_description: enhanced_description
      ).call
    end

    def update_product_description(product_id:, enhanced_html_description:)
      Services::ProductDescriptionUpdater.new(
        product_id: product_id,
        enhanced_html_description: enhanced_html_description
      ).call
    end
  end
end
