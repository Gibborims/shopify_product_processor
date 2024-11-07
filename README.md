
## 1. Usage Instructions

1. Install dependencies:
```bash
bundle install
```

2. Set up your environment variables in `.env`. An example is found in `.env.test`

3. Run the script:
```bash
./bin/run_process
```

4. API Keys are inputted into the `test_api_keys.csv` file. The column headers are:
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
