# alarm_monitor #
### alarm_monitor is a program for monitoring Foxboro I/A Process Alarms  ###

`alarm_monitor` is a set of Perl and shell scripts to monitor 
Foxboro I/A Process Alarms. It parses the almhist file and sends emails
when it finds an alarm that matches an entry in its config file.
I have succesfully Windows workstation with version 8.x. It should also
work on Unix v.7 as long as some of the paths are modified.

## Installation ##

Clone the repo from GitHub:

    git clone git://github.com/CassandraProject/alarm_monitor.git

If you didn't use git on an AW, then you will need to transfer the directory to
a Foxboro AW

## Configuration ##

The paths are pre-configured assuming you will run the program from
/opt/customer/scripts/alarm_monitor, if not, you will need to change things

Edit the `match_alarms.conf` file and add the alarms you wish to monitor

Edit the `mail_alarm.pl` file and add the correct `$email{from}` address
Also the mail script is setup to use `mailhost` as the SMTP server, this
will need to be changed if that is not already setup in your host file

## Command line and Scheduled Operation ##

The program should be run via the `run_alarm_monitor.sh` control script
as that makes sure only one copy will run at any one time. This is the
script that needs to be setup to run via the Windows Scheduler.

A lock file is created, it would be a good idea to add a line to the I/A 
startup routine to delete that lockfile in case the machine shuts down while
the script is running. The lockfile is `alarm_monitor.lock`

## Contributing ##

Contributions to alarm_monitor are welcome. There are a few areas where I
know impovements are needed:

* add a deadband parameter to the alarm config so that very frequent alarms
won't potentially send many emails

* add other communication options besides email such as SMS, probably via
Google Voice which would be a free provider

## Thanks ##

The following people have contributed patches to  close_list - thanks!

* [Jeremy Milum](http://github.com/jmilum)
