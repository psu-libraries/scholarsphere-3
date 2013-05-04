#!/bin/bash
#
# Deletes everything in the test instance of the app's RDBMS and reinits it

bundle exec rake db:test:purge
bundle exec rake db:test:prepare
