#!/usr/bin/perl -w

use strict;
use Data::Dumper;

sub get_data($$);
sub print_alarms($);

my $file;
my $timestamp;
my @data;

	#
	# check for the correct number of command line arguements
	# and die and print usage if not correct
	#
die "\nUsage: $0 log_file \"timestamp\"\n\ntimestamp is in YYYY-MM-DD HH:MM:SS format\n" unless ($#ARGV == 1);
$file = shift;
$timestamp = shift;

# parse the file
die "\nCould not open the file: $file\n\n" unless open(FILE, $file);
@data = get_data(\*FILE, $timestamp);
close(FILE);
#print Dumper(\@data);

print_alarms(\@data);

exit;

####################################################################

# read in the file and store the data in a hash of hashes
sub get_data($$)
{
	my $file = shift;
	my $time = shift;
	my $line;
	my @alarm;
	my @alarms;

	while($line = <$file>)
	{
		chomp $line;
		@alarm = split(/,/, $line);
		if($alarm[5] ge $time) {
			push(@alarms, [ @alarm ]);
		}
	}
	return @alarms;
}

sub print_alarms($)
{
	my $data = shift;
	my $elem;

	foreach $elem (@$data) { 
		#print $elem;
		print join(',', @$elem) . "\n";
	}
}
