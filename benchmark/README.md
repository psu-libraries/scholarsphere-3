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

    cd benchmark
    SELENIUM_USERNAME=[username]
    export SELENIUM_USERNAME
    SELENIUM_PASSWORD=[password]
    export SELENIUM_PASSWORD
    time bundle exec rspec spec/solr_query_spec.rb
    time bundle exec rspec spec/upload_from_my_computer_spec.rb
    time bundle exec rspec spec/upload_from_my_computer_with_resque_spec.rb

For more information on running the tests as well as enabling New Relic instrumentation,
see [the docs](http://sites.psu.edu/dltdocs/?p=4258).

## Reporting

Data from the tests are gathered on our [reporting page](http://sites.psu.edu/dltdocs/?p=4265).
