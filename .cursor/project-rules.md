# Project Rules

## Architecture
- Follow Rails MVC architecture
- Use Service Objects for complex business logic
- Place business logic in models, not controllers
- Use Policies for authorization logic, in this case we use Pundit
- For roles we use Rolify
- Avoid using javascript, use hotwired instead if possible

## Documentation Standards
- Every class must have a documentation block describing its purpose and responsibility
- Document all public methods with:
  - A brief description of what the method does
  - Parameters and their types
  - Return value and type
  - Examples for complex methods
  - Any raised exceptions
- Use YARD documentation format
- Example class documentation:
  ```ruby
  # Manages campaign-related authorization and permissions
  #
  # This class handles all authorization logic for campaign operations,
  # including creation, updates, and access control.
  class CampaignPolicy
  ```
- Example method documentation:
  ```ruby
  # Updates the campaign status and notifies relevant users
  #
  # @param campaign [Campaign] the campaign to update
  # @param status [String] the new status ('active', 'paused', 'completed')
  # @return [Boolean] true if update successful, false otherwise
  # @raise [InvalidStatusError] if status is not valid
  def update_status(campaign, status)
  ```

## Coding Standards
- Follow Ruby Style Guide
- Use 2 spaces for indentation
- Maximum line length: 100 characters
- Use snake_case for Ruby methods and variables
- Use CamelCase for class names

## Testing
- All models must have unit tests
- Controllers require integration tests
- Controllers should not have a unit test, use integration tests instead
- Use RSpec for testing
- Maintain test coverage above 80%

## Technologies
- Ruby 3.2.0
- Rails 8.0
- PostgreSQL
- RSpec for testing
- Pundit for authorization
- Rolify for roles
- Devise for authentication 
- TailwindCSS for styling
- Stimulus for JavaScript
- Hotwired for Turbo
