#!/bin/bash
#
# Deletes everything in the hydra-jetty instances of Solr and Fedora
# https://github.com/psu-stewardship/scholarsphere/wiki/Cleaning-up-hydra-jetty

bundle exec rake jetty:stop
(cd jetty && git clean -df && git checkout .)
bundle exec rake jetty:config
bundle exec rake jetty:start

