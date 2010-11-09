#!/bin/bash

PROG_DIR=/opt/customer/scripts/alarm_monitor
PROG=$PROG_DIR/alarm_monitor.sh
LOCKFILE=$PROG_DIR/alarm_monitor.lock


if [ ! -f $LOCKFILE ]; then
    trap "/nutc/mksnt/rm -f $LOCKFILE; exit" INT TERM EXIT
    /nutc/mksnt/touch $LOCKFILE
    $PROG
    /nutc/mksnt/rm $LOCKFILE
    trap - INT TERM EXIT
else
    echo "alarm_monitor.sh is already running"
fi
