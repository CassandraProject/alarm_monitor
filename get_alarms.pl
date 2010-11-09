#!/usr/bin/perl -w

use strict;

sub fix_text($);
sub rm_trailing_spaces($);
sub rm_leading_spaces($);
sub rm_mult_spaces($);
sub get_alm_year($$$);
sub check_alm_date($$$);

my $almhist;
my $line;
my @alarm_from_file;
my @alarm_unpack;
my @alarm_joined;
my @alarm_joined_sorted;
my $elem;
my $item;
my $alarm;
my $reg_template = "A40 A32 A1 A7 A6 A9 A17 A12 A33 A3";
my $alt_template = "A40 A32 A1 A7 A6 A9 A54 A11";
my $disabl_template = "A40 A32 A1 A7 A6 A9 A65";
my $range_template = "A40 A32 A1 A7 A6 A9 A52 A10 A3";
my $alm_date;
my $alm_time;
my $alm_year;
my $full_alm_date;
my $sec;
my $min;
my $hour;
my $day;
my $month;
my $year;
my $date;
my $time;
my $start_time;
my $end_time;
my $compound;
my $block;

die "\nUsage: $0 [almhist_file] \"[start time]\" \"[end time]\"\n\nTime is in YYYY-MM-DD HH:MM:SS format [Use 0 for any]\n\n" unless ($#ARGV == 2);
$almhist = shift;
$start_time = shift;
$end_time = shift;

	# open the alarm history file, or quit if it is not found
open(ALMHIST, $almhist) or die "Cannot locate alarm history file $almhist: $!\n";

	# read in the binary header of the file, but don't do anything with it
	# since it is junk
sysread(ALMHIST, $line, 160);

	# continue reading in each alarm from the file, each alarm is 160 
    # charactes long, and put each one into an array
while(sysread(ALMHIST, $line, 160)) {
	push(@alarm_from_file, $line);
}

	
	# get the year and the date in the alarm date format
	# we must inrecemt the month by 1 since it is ranged 0 = 11
	# and add 1900 to the year
($sec, $min, $hour, $day, $month, $year) = localtime(time);
$month += 1;
$sec = (length($sec) == 1) ? "0" . $sec: $sec; 
$min = (length($min) == 1) ? "0" . $min: $min; 
$hour = (length($hour) == 1) ? "0" . $hour: $hour; 
$day = (length($day) == 1) ? "0" . $day: $day; 
$month = (length($month) == 1) ? "0" . $month: $month; 
$year += 1900;
$date = $month . "-" . $day . " " . $hour . ":" . $min . ":" . $sec;

foreach $elem (@alarm_from_file) {
		# change all commas into spaces since we will use commas as a field
		# delimiter below
	$elem =~ s/,/ /g;

		# change the fixed width alarm string into an array with the field
		# lengths given by the template
	@alarm_unpack = unpack($reg_template, $elem);

	$alm_date = $alarm_unpack[4] . " " . $alarm_unpack[5];
	$alm_year = get_alm_year($year, $date, $alm_date);
	$full_alm_date = $alm_year . "-" . $alarm_unpack[4] . " " . $alarm_unpack[5];

	if(check_alm_date($start_time, $end_time, $full_alm_date) == 1) {
			# remove leading spaces from the measuremnet value
		$alarm_unpack[6] = rm_leading_spaces($alarm_unpack[6]);

			# remove '+' and digits from the end of the
			# alarm type field, this will fix alarm types
			# like HIDEV+, LOABS1, etc.
		if($alarm_unpack[3] =~ /(\w+)[\d|\+]$/) {
			$alarm_unpack[3] = $1;
		}

		if($alarm_unpack[3] eq "STATE") {
			@alarm_unpack = unpack($alt_template, $elem);
	
			$alarm_unpack[6] = rm_leading_spaces($alarm_unpack[6]);
			$alarm_unpack[6] = rm_trailing_spaces($alarm_unpack[6]);
			$alarm_unpack[6] = ",," . $alarm_unpack[6];

			$alarm_unpack[7] = rm_leading_spaces($alarm_unpack[7]);
			$alarm_unpack[7] = rm_trailing_spaces($alarm_unpack[7]);

			if($alarm_unpack[2] == 0) {
				$alarm_unpack[7] = $alarm_unpack[7] . ",RTN";
			} else {
				$alarm_unpack[7] = $alarm_unpack[7] . ",ALM";
			}
		} elsif($alarm_unpack[3] eq "DISABL" or $alarm_unpack[3] eq "ENABLE") {
			@alarm_unpack = unpack($disabl_template, $elem);
			$alarm_unpack[6] = rm_leading_spaces($alarm_unpack[6]);
			$alarm_unpack[6] = rm_trailing_spaces($alarm_unpack[6]);
			$alarm_unpack[6] = ",," . $alarm_unpack[6];

			if($alarm_unpack[2] == 0) {
				$alarm_unpack[7] = "RTN";
			} else {
				$alarm_unpack[7] = "ALM";
			}
		} elsif($alarm_unpack[3] eq "RANGE") {
			@alarm_unpack = unpack($range_template, $elem);

			$alarm_unpack[6] = rm_leading_spaces($alarm_unpack[6]);
			$alarm_unpack[6] = rm_trailing_spaces($alarm_unpack[6]);
			$alarm_unpack[7] = rm_leading_spaces($alarm_unpack[7]);
			$alarm_unpack[7] = rm_trailing_spaces($alarm_unpack[7]);

			$alarm_unpack[6] = ",,$alarm_unpack[6] $alarm_unpack[7]";
			$alarm_unpack[6] = rm_trailing_spaces($alarm_unpack[6]);

			$alarm_unpack[7] = "";
		} else {
				# if the limit value is surounded by () remove them and any
				# leading whitespace
			if($alarm_unpack[7] =~ /^\((.+)\)$/) {
				$alarm_unpack[7] = rm_leading_spaces($1);
			}
	
			$alarm_unpack[8] = $alarm_unpack[8] . ",";
		}


			# split the compound:block field into compound,block
		($compound, $block) = split(/:/, $alarm_unpack[0]);

		if(defined($block)) {
			$block =~ s/\..*$//;
			$alarm_unpack[0] = $compound . "," . $block;
		} else {
			$alarm_unpack[0] = $compound . ",";
		}
	
			# remove multiple spaces from the desciprion field
		$alarm_unpack[1] = fix_text($alarm_unpack[1]);
		$alarm_unpack[7] = fix_text($alarm_unpack[7]);

			# combine the individual array elements into one string delimited
			# by a comma
		$alarm_unpack[4] = $full_alm_date;
		splice(@alarm_unpack, 5, 1);
		$alarm = join(',', @alarm_unpack);


			# add the alarm string to a new array where all the delimited alarm
			# strings will be stored
		push(@alarm_joined, $alarm);
	}
}

foreach $elem (@alarm_joined) {
	print "$elem\n";
}

exit;

sub fix_text($) {
	my $str = shift;

	if(defined($str)) {
		$str = rm_mult_spaces($str);
		$str = rm_leading_spaces($str);
		$str =  rm_trailing_spaces($str);

		return($str);
	}

	return('');
}

sub rm_mult_spaces($) {
	my $str = shift;

		# remove multiple spaces
	$str =~ s/\s+/ /g;

	return($str);
}

sub rm_leading_spaces($) {
	my $str = shift;

		# remove all leading spaces
	$str =~ s/^\s+//g;

	return($str);
}

sub rm_trailing_spaces($) {
	my $str = shift;

		# remove all leading spaces
	$str =~ s/\s+$//g;

	return($str);
}

sub get_alm_year($$$) {
	my $year = shift;
	my $date = shift;
	my $alm_date = shift;

		#
		# if the alarm date is greate than the current date, it must
		# have occured last year, so return last year, if not, then it
		# occured this year
		#
	if(($date cmp $alm_date) == -1) {
		return($year - 1);
	} else {
		return($year);
	}
}

sub check_alm_date($$$) {
	my $start = shift;
	my $end = shift;
	my $alm_time = shift;
	my $cmp_val;

		#
		# return -1 if alarm is not between start and end, and a 1
		# if it is
		#
	$cmp_val = ($alm_time cmp $start);

	if( ((($alm_time cmp $start) == -1) and $start ne "0") or ((($end cmp $alm_time) == -1) and $end ne "0")) {
		return(-1);
	} else {
		return(1);
	}
}
