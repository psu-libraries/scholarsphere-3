#!/bin/bash

# Also see: http://vitobotta.com/resque-automatically-kill-stuck-workers-retry-failed-jobs/

ps -eo pid,command |
grep [l]ibre | 
while read PID COMMAND; do  
	if [[ -d /proc/$PID ]]; then
		SECONDS=`expr $(awk -F. '{print $1}' /proc/uptime) - $(expr $(awk '{print $22}' /proc/${PID}/stat) / 100)`

		if [ $SECONDS -gt 600 ]; then
			kill -9 $PID

			echo "
				The forked child with pid #$PID (libre office instance) was found stuck for longer than 600 seconds.
				#$COMMAND
			" >> /tmp/stuck-jobs.log
		fi
	fi
done 

ps -eo pid,command | 
grep [r]esque | 
grep "Processing" |
while read PID COMMAND; do  
	if [[ -d /proc/$PID ]]; then
		SECONDS=`expr $(awk -F. '{print $1}' /proc/uptime) - $(expr $(awk '{print $22}' /proc/${PID}/stat) / 100)`

		QUEUE=`echo "$COMMAND" | cut -d ' ' -f 3`

		if [ $SECONDS -gt 600 ] && [ "$QUEUE" = "files" ]; then
			kill -9 $PID

			echo "
				The forked child with pid #$PID (queue: $QUEUE) was found stuck for longer than 600 seconds.
			" >> /tmp/stuck-jobs.log

		fi
	fi
done