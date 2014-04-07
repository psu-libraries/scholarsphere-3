# Since we can't set metadata[:type] globally for our suite, and since it will
# be the default once our suite is moved under spec/features, we want to include
# Capybara's whole type: feature config for now:
# https://github.com/jnicklas/capybara/blob/096c1fe832b0d808e20687cbde2d0e33e36f0d13/lib/capybara/rspec.rb

RSpec.configure do |config|
  config.include Capybara::RSpecMatchers

  # A work-around to support accessing the current example that works in both
  # RSpec 2 and RSpec 3.
  fetch_current_example = RSpec.respond_to?(:current_example) ?
      proc { RSpec.current_example } : proc { |context| context.example }

  # The before and after blocks must run instantaneously, because Capybara
  # might not actually be used in all examples where it's included.
  config.after do
    if self.class.include?(Capybara::DSL)
      Capybara.reset_sessions!
      Capybara.use_default_driver
    end
  end
  config.before do
    if self.class.include?(Capybara::DSL)
      example = fetch_current_example.call(self)
      Capybara.current_driver = Capybara.javascript_driver if example.metadata[:js]
      Capybara.current_driver = example.metadata[:driver] if example.metadata[:driver]
    end
  end
end