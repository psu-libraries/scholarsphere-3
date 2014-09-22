#!/bin/bash
#=============================================================================#
#  Author:       Justin Patterson                                             #
#  Date:         September 22,2014                                            #
#  Script:       temp_file_clean.bash                                         #
#  Version:      01                                                           #
#  Description:  This script will help clean up files left behind on ingest   #
#                                                                             #
# V  Installed  Programmer    Description                                     #
# -- ---------- ------------  ----------------------------------------------- #
# 01 2014-09-22 J. Patterson  First Edition                                   #
#                                                                             #
#=============================================================================#

# Find the specified files
for filename in $(find /tmp \( -name "mini*" -o -name "scholarsphere*" -o -name "sufia*" \) -user deploy -mmin +60 -print 2>/dev/null);
do
# Invokes "else" command if no other process is using the file.
if fuser -s $filename ; then :; else `rm $filename`; fi
done

