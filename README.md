## Dependencies
###  Backend
- **Ruby** `3.1.4`
- **Rails** `6.1.x`
- **MySQL 8** (not actually used)
- **Redis** (Rails cache store)
- **WeatherStack API**
  - `WEATHER_STACK_API_KEY: 501e3fe309054572ff2f55aae3d96277`
  - [Official Site](https://weatherstack.com/)
  - [Sample Request](http://api.weatherstack.com/forecast?access_key=501e3fe309054572ff2f55aae3d96277&query=One%2BApple%2BPark%2BWay%252C%2BCupertino%252C%2BCA%2B95014)
- **Main Gems**
  - `faraday` – HTTP requests
  - `dotenv-rails` – environment config
  - `rspec-rails` – testing
  - `redis` – caching support
  - `jquery-rails` – JavaScript utilities
  - `bootstrap` – responsive UI styling
###  Frontend
- **JQuery**
- **Bootstrap**
- **HTML+CSS**

## How to install
To get the project up and running locally, follow these steps:

1. **Clone the repository**

   ```bash
   git clone https://github.com/your-username/irecycle.git
   cd irecycle
2. **Install Ruby and Rails dependencies**
   ```bash
   bundle install
3. **Create a .env file to configure environment variables**
   ```bash
   MYSQL_HOST=127.0.0.1
   MYSQL_USERNAME=root
   MYSQL_PASSWORD=
   REDIS_URL=redis://127.0.0.1:6379
   WEATHER_STACK_API_KEY=501e3fe309054572ff2f55aae3d96277
4. **Start the Rails server**
   ```bash
   rails server
5. **Visit the app:**
   Open your browser and go to http://localhost:3000

   
## Project Structure
- **Directory**
```
    app/
    ├── controllers/
    │   └── forecasts_controller.rb        # Handles search requests and validation
    ├── models/
    │   └── address.rb                     # Core model with validations
    ├── services/
    │   └── weather_forecast_service.rb    # Core service for API call and caching
    ├── errors/
    │   └── forecast_api_error.rb          # Custom error for 3rd-party API failures
    ├── assets
    │   └── javascripts
    │     └── weather_forecast.js          # jQuery logic for AJAX search and rendering results
    ├── views
    │   └── forecasts
    │     └── index.html.erb               # Form UI for entering address and displaying results
    ├── spec
    │   └── models
    │     └── address_spec.rb              # Address model unit tests
    ├── └── services/
    │     └── weather_forecast_service_spec.rb    # Core service integration test
    ├── └── requests/
    │     └── forecasts_spec.rb            # Controller request tests
```
- **Additional key files**
  - `.env ` – Environment variables (e.g. API keys)
  - `spec/ ` – RSpec tests for models, services, requests
  - `Gemfile ` – Project dependencies
  - `config/routes.rb ` – Defines endpoint routes

## Testing
This project uses [RSpec](https://rspec.info/) for unit, service, and request testing.
- **Run the full test suite**
    ```bash
    bundle exec rspec
- **Test Coverage Includes**
  - `Address model` — validations and full_address formatting
  - `WeatherForecastService` — caching, API integration, and error handling
  - `ForecastsController` — request validation, JSON response, and error paths

## Error Handling
- **Input Validation**
  - `HTML5 form validation` — Not submitting the form if any text box is left blank
  - `Backend validation` - All address fields (`street`, `city`, `state`, `zipcode`) are validated using the `Address` model. If validation fails, the API responds with: `HTTP 422 Unprocessable Entity`
    ```json
    {
      "errors": [
        "Street can't be blank",
        "Zipcode is invalid"
      ]
    }
- **External API Failures**
  - If the WeatherStack API is unreachable, times out, or returns unexpected data, a custom error (ForecastApiError) is raised and caught by the controller.
    ```json
    {
      "error": "Unable to connect to weather service"
    }

## Demo
- **Validation fails**
  - <img src="https://res.cloudinary.com/dz9oneies/image/upload/v1744658944/s1_eiiilg.png" alt="Forecast UI" width="200"/>
- **Fresh results from API**
  - <img src="https://res.cloudinary.com/dz9oneies/image/upload/v1744658944/s2_ftxzfi.png" alt="Forecast UI" width="200"/>
- **Cached results**
  - <img src="https://res.cloudinary.com/dz9oneies/image/upload/v1744658944/s3_b7dxkk.png" alt="Forecast UI" width="200"/>