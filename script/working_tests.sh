#! /bin/bash
# keep a running tally of tests that we know are working so we can re-run them
bundle exec rspec\
  spec/models\
  spec/controllers\
  spec/jobs\
  spec/services\
  spec/presenters
  