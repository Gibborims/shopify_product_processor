# frozen_string_literal: true

module ShopifyProcessor
  # Generates shopify product description as CSV
  class Processor
    def self.run
      new.run
    end

    def run
      products = Services::ProductFetcher.fetch_all
      process_products(products)
    end

    private

    def process_products(products)
      CSV.open("product_descriptions_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv", 'wb') do |csv|
        csv << ['Original Description', 'Enhanced Description']

        products.each_with_index do |product, index|
          print "======================== #{index + 1}. ========================\n"

          enhanced_description = Services::DescriptionEnhancer.process(product[:description])

          csv << csv_records(product, enhanced_description)

          print ".\n" # Progress indicator
        end
      end

      puts "\nProcessing complete!"
    end

    def csv_records(product, enhanced_description)
      [
        product[:description],
        enhanced_description
      ]
    end
  end
end
