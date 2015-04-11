#!/bin/bash
# ---------------------------------------------------------------------
# Description:
#
# Wrapper script for our migration rake task. If the rake task exits
# with an error, the task restarted. This repeats until there is a 
# successful exit.
# ---------------------------------------------------------------------

echo "`date` -- Migration started"
bundle exec rake scholarsphere:migrate:repository RAILS_ENV=production
while [ $? -gt 0 ]; do
  echo "`date` -- Migration failed, restarting..."
  bundle exec rake scholarsphere:migrate:repository RAILS_ENV=production
done
echo "`date` -- Migration complete"
exit 0;
