# Benchmarks

A special set of RSpec scripts used to test a running instance of Scholarsphere.

## Setup

Detailed setup instructions are available from [our documentation](http://sites.psu.edu/dltdocs/?p=4166).

Bundler will cover the gem dependencies but there are a few that will need to be installed using
brew.

    bundle install
    brew cask install chromedriver
    brew install geckodriver

## Basic Tests

Execute the benchmarks by entering this directory and running the rspec commands. If
available on the host, New Relic data can be gathered as well.

On the server that you intending to test, go to the Rails console and make sure that the FPS user is registered with Devise:

    bundle exec rails c production
    
    > User.create(email: '{SELENIUM_USERNAME}@psu.edu', login: '{SELENIUM_USERNAME}', ldap_available: 1, ldap_last_update: DateTime.now)

    cd benchmark
    SELENIUM_USERNAME=[fps-user]
    export SELENIUM_USERNAME
    SELENIUM_PASSWORD=[password]
    export SELENIUM_PASSWORD
    BOX_USERNAME=[scholarsphere-box-user]
    export BOX_USERNAME
    BOX_PASSWORD=[password]
    export BOX_PASSWORD
    time bundle exec rspec spec/solr_query_spec.rb
    time bundle exec rspec spec/upload_from_my_computer_spec.rb
    time bundle exec rspec spec/upload_from_my_computer_with_resque_spec.rb

The Selenium user information can be found in the
 [setup information](http://sites.psu.edu/dltdocs/?p=4166) and the Box credentials are
 [documented here](http://sites.psu.edu/dltdocs/?p=2014).

For more information on running the tests as well as enabling New Relic instrumentation,
see [the docs](http://sites.psu.edu/dltdocs/?p=4258).

## Reporting

Data from the tests are gathered on our [reporting page](http://sites.psu.edu/dltdocs/?p=4265).
