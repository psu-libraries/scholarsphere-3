#!/bin/bash
#============================================================
#  Date:         March 21, 2017
#  Script:       dump_and_truncate_searches.bash
#  Version:      01
#  Description:  Used to dump and trincate the search table yearly
#============================================================


if [ -d "/opt/heracles/deploy/scholarsphere/current" ]; then
  cd /opt/heracles/deploy/scholarsphere/current
  RAILS_ENV=production
else
  echo "You appear to be working on a local machine, we'll set for development"
  echo "Please ensure you're calling this script from the Rails root directory"
  RAILS_ENV=development
fi
export RAILS_ENV

RESULTS=`bundle exec rake scholarsphere:truncate_searches 2>&1`

if [ $? -ne 0 ]; then
  SUBJECT="`hostname` truncate search"
  MESSAGE="bundle exec rake scholarsphere:truncate_searches exited with a non-zero status.  $RESULTS"
  echo $MESSAGE | mail -s "$SUBJECT" umg-up.its.scholarsphere-support@groups.ucs.psu.edu
fi

echo $RESULTS
exit 0;
