#!/usr/bin/perl -w

use strict;

sub get_config($);
sub match_alarms($);
sub check_alarm($$);

my $config_file;
my @config_data;

	#
	# check for the correct number of command line arguements
	# and die and print usage if not correct
	#
die "\nUsage: $0 config_file \n\n" unless ($#ARGV == 0);
$config_file = shift;

# parse the config file
die "\nCould not open the config file: $config_file\n\n" unless open(FILE, $config_file);
@config_data = get_config(\*FILE);
close(FILE);

# filter the alarm file
match_alarms(\@config_data);
close(FILE);

exit;

####################################################################

# read in the config file and store the data in a hash of hashes
sub get_config($) {
	my $file = shift;
	my $line;
	my @config;

	while($line = <$file>) {
		# ignore comments
		if($line !~ /^\s+$/ and $line !~ /^\s*\#/) {
			chomp $line;
			push(@config, [ split(/\s*,\s*/, $line) ] );
		}
	}
	return @config;
}

# read in a alarm listing file and load the data into a hash of hashes 
sub match_alarms($) {
	my $filter = shift;
	my @alarm;
	my $line;

	while($line = <>) {
		chomp($line);
        @alarm = split(/,/, $line);

		if(check_alarm(\@alarm, $filter)) {
            print join(',', @alarm) . "\n";
		}
		@alarm = ();
	}
}

# check the block to see if it passes the filter 
sub check_alarm($$) {
	my $alarm = shift;
	my $config = shift;
	my $f_comp;
	my $f_block;
    my $f_type;
    my $f_state;
    my $f_email;
	my $elem;
    my $a_comp = $alarm->[0];
    my $a_block = $alarm->[1];
    my $a_type = $alarm->[4];
    my $a_state = $alarm->[10];

	foreach $elem (@$config) {
		($f_comp, $f_block, $f_type, $f_state, $f_email) = @$elem;

		if($a_comp =~ /$f_comp/) {
			if($a_block =~ /$f_block/) {
				if($a_type =~ /$f_type/) {
                    if($a_state =~ /$f_state/) {
                        push(@$alarm, $f_email);
					    return(1);
                    }
				}
			}
		}
	}
	return(0);
}
