#!/bin/bash
#==============================================================================
#  Author:       Adam Wead
#  Date:         September 22, 2014
#  Script:       compare_solr.bash
#  Version:      01
#  Description:  Compares number of objects in Solr with Fedora
#                and emails the results
#
# V  Installed  Programmer    Description
# -- ---------- ------------  -------------------------------------------------
# 01 2014-09-22 awead         First Edition
#
#==============================================================================

SUBJECT="`hostname` solr-compare task"
if [ -d "/opt/heracles/deploy/scholarsphere/current" ]; then
  cd /opt/heracles/deploy/scholarsphere/current
  RAILS_ENV=production
else
  echo "You appear to be working on a local machine, we'll set for development"
  echo "Please ensure you're calling this script from the Rails root directory"
  RAILS_ENV=development
fi
export RAILS_ENV

if [ -e "/tmp/last_compare_solr_run" ]; then
  DATE=`cat /tmp/last_compare_solr_run`
else
  DATE="never"
fi
RESULTS=`bundle exec rake scholarsphere:solr:compare`
if [ $? -ne 0 ]; then
  MESSAGE="rake scholarsphere:solr:compare exited with a non-zero status. Last success was $DATE. $RESULTS"
  echo $MESSAGE | mail -s "$SUBJECT" umg-up.its.scholarsphere-support@groups.ucs.psu.edu
else
  date > /tmp/last_compare_solr_run
fi
exit 0;
