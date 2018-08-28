# Benchmarks

A special set of RSpec scripts used to test a running instance of Scholarsphere.

## Setup

Detailed setup instructions are available from [our documentation](http://sites.psu.edu/dltdocs/?p=4166).

Bundler will cover the gem dependencies but there are a few that will need to be installed using
brew.

    bundle install
    brew cask install chromedriver
    brew install geckodriver

On the server that you intending to test, go to the Rails console and make sure that the FPS user is registered with Devise:

    bundle exec rails c production

### Create An New User

If this is first time you're running the tests on this system, or the user doesn't exist,
create a new one using the configured Selenuim username:

    > User.create(email: "#{SELENIUM_USERNAME}@psu.edu", login: "#{SELENIUM_USERNAME}", ldap_available: 1, ldap_last_update: DateTime.now)

### Updating An Existing User

If a few days have passed, you'll need to update the user. This prevents Scholarsphere from
querying LDAP, which will cause an error with the uploading tests.

    > User.where(login: "#{SELENIUM_USERNAME}").first.update(ldap_available: 1, ldap_last_update: DateTime.now)

### Environment Variables

There are two users and passwords that must be set for all the tests to run successfully.
The Selenium user information can be found in the
 [setup information](http://sites.psu.edu/dltdocs/?p=4166)
 and the Box credentials are
 [documented here](http://sites.psu.edu/dltdocs/?p=2014).

The variables can be set in the shell session, or stored in your `~/.bash_profile`:

    SELENIUM_USERNAME=[fps-user]
    export SELENIUM_USERNAME
    SELENIUM_PASSWORD=[password]
    export SELENIUM_PASSWORD
    BOX_USERNAME=[scholarsphere-box-user]
    export BOX_USERNAME
    BOX_PASSWORD=[password]
    export BOX_PASSWORD

## Running the Tests

Execute the benchmarks by entering this directory and running the rspec commands. If
available on the host, New Relic data can be gathered as well. By default, tests run against the QA
server, in a headless state. Headless tests mean that the browser does not open locally to show
the interaction between the test the server.

    cd benchmark
    time bundle exec rspec spec/solr_query_spec.rb
    time bundle exec rspec spec/upload_from_my_computer_spec.rb
    time bundle exec rspec spec/upload_from_my_computer_with_resque_spec.rb

### Test Examples

Running the tests against a different server:

    BENCHMARK_URL="https://other.server.edu/" bundle exec rspec spec/[etc]

Example: Running in a non-headless state:

    BENCHMARK_HEADLESS="false" bundle exec rspec spec/[etc]

Example: Running in a non-headless state against another server, monitoring the log, and capturing
time information:

In one terminal window:

    tail -f benchmark_info.log

In a second window:

    time BENCHMARK_URL="https://other.server.edu/" BENCHMARK_HEADLESS="false" bundle exec rspec spec/[etc]

While the test is running, you can view the log file reporting each step of the test. This provides more
progress information, especially for long-running tests in a headless state.

## Reporting

Data from the tests are gathered on our [reporting page](http://sites.psu.edu/dltdocs/?p=4265).
