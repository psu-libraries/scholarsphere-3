#! /bin/bash
# keep a running tally of tests that we know are working so we can re-run them
bundle exec rspec\
  spec/models\
  spec/controllers\
  spec/services/generic_work_list_to_csv_spec.rb\
  spec/presenters/collection_presenter_spec.rb
  