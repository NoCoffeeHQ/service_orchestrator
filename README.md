# ServiceOrchestrator

ServiceOrchestrator is a lightweight dependency injection framework, greatly inspired by the awesome [Morphine](https://github.com/bkeepers/morphine) gem.

Compared to Morphine, it automatically wires dependencies between services thanks to some simple conventions.

If you wonder if you need this library, please check out [my article]() about Services in Rails.

## Installation

Install the gem and add it to the application's Gemfile by executing:

    $ bundle add service_orchestrator

## Usage

The framework is composed of 2 main Ruby classes:

- `ServiceOrchestrator::Container` which registers all the services and wires the dependencies.
- `ServiceOrchestrator::Service` that any service with dependencies inherits from.

**Conventions**

- a service has a single public method named **call**.
- the **call** method of a service takes N named arguments.
- don't use instance variables inside the Service Ruby class.

## Example

First, declare a container in order to register all your services.

```ruby
class ApplicationContainer < ServiceOrchestrator::Container
  
  register :onboarding, 'OnBoardingService'

  register :analytics_tracker, 'AmplitudeAnalyticsTrackerService'

  private

  register :amplitude_sdk do
    AmplitudeSDK.new(api_key: Rails.application.credentials.amplitude.api_key)
  end
end
```

Then, declare your services.

```ruby
class AmplitudeAnalyticsTrackerService < ServiceOrchestrator::Service
  dependency :amplitude_sdk

  def call(event_name:, properties: {})
    amplitude_sdk.send_event(event_name, properties)
  end
```

```ruby
class OnboardingService < ServiceOrchestrator::Service
  dependency :analytics_tracker
  
  def call(attributes:)
    User.create(attributes).tap do |user|
      analytics_tracker.call(:new_user, { email: user.email })
    end
  end
end
```

Create an instance of a container to get access to your services.

```ruby
container = ApplicationContainer.new

container.onboarding.call({ email: 'john@doe.net', name: 'John' })
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nocoffeehq/service_orchestrator.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
