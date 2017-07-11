#!/bin/bash
#============================================================
#  Date:         December 8, 2014
#  Script:       update_user_stats.bash
#  Version:      01
#  Description:  Fetches file view and download stats from
#                Google Analytics for each user, and caches
#                the results in the database.
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


RESULTS=`bundle exec rake scholarsphere:stats:user_stats 2>&1`

if [ $? -ne 0 ]; then
  SUBJECT="`hostname` user stats task"
  MESSAGE="rake scholarsphere:stats:user_stats exited with a non-zero status.  $RESULTS"
  echo $MESSAGE | mail -s "$SUBJECT" umg-up.its.scholarsphere-support@groups.ucs.psu.edu
fi

echo $RESULTS
exit 0;
