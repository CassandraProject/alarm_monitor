#!/bin/bash

#
# script to scan for matching process alarms
#

PROG_DIR=/opt/customer/scripts/alarm_monitor
ALMHIST=/usr/hstorian/almhist
ALARM_LOG=$PROG_DIR/alarms_log.csv
MAIL_PROG=$PROG_DIR/mail_alarm.pl
GET_ALARM_PROG=$PROG_DIR/get_alarms.pl
MATCH_ALARM_PROG=$PROG_DIR/match_alarms.pl
MATCH_ALARM_CONFIG=$PROG_DIR/match_alarms.conf
MATCH_ALARM_FILE=$PROG_DIR/alarms_matched.csv
LOG_CHECK_PROG=$PROG_DIR/check_log.pl
NEW_ALARMS=$PROG_DIR/new_alarms.csv
SORT_PROG=/nutc/mksnt/sort
TOUCH_PROG=/nutc/mksnt/touch
RM_PROG=/nutc/mksnt/rm

# get all the possible alarms
start_time=0
end_time=0

# delete the matched alarm file if it exists and then create an empty one
if [ -f $MATCH_ALARM_FILE ]
then
	$RM_PROG $MATCH_ALARM_FILE
fi    


# find matching alarms and concatenate them to the matched file
$GET_ALARM_PROG $ALMHIST "$start_time" "$end_time" | $MATCH_ALARM_PROG $MATCH_ALARM_CONFIG | $SORT_PROG -t, -k6,7 -k1,3 > $MATCH_ALARM_FILE

#
# see if the matching alarms are already in the log file
#
if [ ! -f $ALARM_LOG ]
then
	# create the log file if it doesn't already exist
	$TOUCH_PROG $ALARM_LOG
fi    

$LOG_CHECK_PROG $ALARM_LOG < $MATCH_ALARM_FILE > $NEW_ALARMS
while read line
do
	$MAIL_PROG "$line"
	echo "$line" >> $ALARM_LOG
done < $NEW_ALARMS
