
## 1. Usage Instructions

1. Install dependencies:
```bash
bundle install
```

2. Set up your environment variables in `.env`. An example is found in `.env.test`

3. Run the script to generate CSV of enhanced product description:
```bash
./bin/run_process
```

4. Run the script to upload CSV to update Shopify Product description with enhanced html description:
```bash
./bin/run_desc_updates
```
- CSV Default Name: `enhanced_product_desc.csv`
- CSV Strict Columns: `Product ID` `Original Description` `Enhanced Description` `Changed`

5. Algorithm for `./bin/run_desc_updates` (run description updates) implementation (2nd Task):
- Update the first task to include `Product ID` and `Changed` in the CSV in addition to original_description and enhanced_description.
- Upload this CSV again and use product_id to fetch the product description from SHOPIFY for records with `Changed` as `true`. We discard or skip any record with `Changed` as `nil` or `false`.
- Query the ChatGPT bot with the fetched product description to include HTML tags and CSS styling like the fetched product description. Call this enhanced HTML product description.
- Update the original product description in SHOPIFY with the enhanced HTML description.

6. API Keys are inputted into the `test_api_keys.csv` file. The column headers are:
- shopify_shop_name
- shopify_access_token
- openai_api_key
- shopify_api_version
- shopify_api_secret_key


## 2. Best Practices Implemented

- Modular code structure using services
- Environment variable management
- Proper error handling
- API rate limiting
- Testing setup with VCR
- Code style enforcement with RuboCop
- Modern code loading with Zeitwerk
- Proper logging and debugging tools
- Git-friendly project structure

## 3. Maintenance and Updates

To maintain the code:
1. Run tests: `bundle exec rspec`
2. Check code style: `bundle exec rubocop`
3. Update dependencies periodically: `bundle update`

## 4. Future Improvements

Consider adding:
- Queue system for long-running processes
- Retry mechanism for failed API calls
- Rate Limit for API calls
- Metrics collection
- Detailed Error handling and logging
- Parallel processing for larger datasets
