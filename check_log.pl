#!/usr/bin/perl -w

use strict;

sub get_data($);
sub match_data($);
sub check_item($$);

my $file;
my @data;

	#
	# check for the correct number of command line arguements
	# and die and print usage if not correct
	#
die "\nUsage: $0 log_file \n\n" unless ($#ARGV == 0);
$file = shift;

# parse the config file
die "\nCould not open the config file: $file\n\n" unless open(FILE, $file);
@data = get_data(\*FILE);
close(FILE);

# filter the alarm file
match_data(\@data);
close(FILE);

exit;

####################################################################

# read in the config file and store the data in a hash of hashes
sub get_data($) {
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
sub match_data($) {
	my $filter = shift;
	my @alarm;
	my $line;

	while($line = <>) {
		chomp($line);
        @alarm = split(/,/, $line);

		if(check_item(\@alarm, $filter)) {
            		print join(',', @alarm) . "\n";
		}

		@alarm = ();
	}
}

# check the item to see if it passes the filter 
sub check_item($$) {
	my $alarm = shift;
	my $config = shift;
	my $f_comp;
	my $f_block;
	my $f_type;
    my $f_state;
    my $f_date;
    my $f_email;

	my $elem;

    my $a_comp = $alarm->[0];
    my $a_block = $alarm->[1];
    my $a_type = $alarm->[4];
    my $a_date = $alarm->[5];
    my $a_state = $alarm->[10];
    my $a_email = $alarm->[11];

	foreach $elem (@$config) {
        $f_comp = $elem->[0];
        $f_block = $elem->[1];
        $f_type = $elem->[4];
        $f_date = $elem->[5];
        $f_state = $elem->[10];
        $f_email = $elem->[11];

		if($a_comp =~ /$f_comp/) {
			if($a_block =~ /$f_block/) {
				if($a_type =~ /$f_type/) {
                    if($a_state =~ /$f_state/) {
                        if($a_date =~ /$f_date/) {
					        return(0);
                        }
                    }
				}
			}
		}
	}

	return(1);
}
