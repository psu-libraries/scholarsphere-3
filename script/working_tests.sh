#! /bin/bash
# keep a running tally of tests that we know are working so we can re-run them
bundle exec rake scholarsphere:unit
bundle exec rspec\
  spec/features/authentication_spec.rb\
  spec/features/batch_edit_spec.rb\
  spec/features/catalog_search_spec.rb\
  spec/features/contact_form_spec.rb\
  spec/features/featured_work_spec.rb\
  spec/features/home_page_spec.rb\
  spec/features/static_pages_spec.rb\
  spec/features/unified_search_spec.rb\
  spec/features/user_stats_spec.rb\
  spec/features/users_spec.rb\
  spec/features/collection/view_and_search_spec.rb\
  spec/features/collection/edit_spec.rb\
  spec/features/file_set/thumbnail_spec.rb\
  spec/features/generic_work/thumbnail_spec.rb\
  spec/features/dashboard/dashboard_shares_spec.rb\
  spec/features/dashboard/dashboard_highlights_spec.rb\
  spec/features/generic_file/view_and_download_spec.rb
