#!/usr/bin/perl -w

use strict;
use Net::SMTP;

my $alarm_str;
my @alarm_data;
my %alarm;
my %email;

sub mail_alarm($$$$);

#
# put the email you want the alarm notifcations to come from here
#
$email{from} = 'you@yourdomain.com';

	#
	# check for the correct number of command line arguements
	# and die and print usage if not correct
	#
die "\nUsage: $0 \"alarm_string\" \n\n" unless ($#ARGV == 0);
$alarm_str = shift;

chomp($alarm_str);

@alarm_data = split(/,/, $alarm_str);
$alarm{name} = "$alarm_data[0]:$alarm_data[1]";
$alarm{desc} = $alarm_data[2];
$alarm{type} = $alarm_data[4];
$alarm{date} = $alarm_data[5];
$alarm{meas} = $alarm_data[6];
$alarm{trip} = $alarm_data[7];
$alarm{text} = $alarm_data[8];
$alarm{state} = $alarm_data[10];
$alarm{email} = $alarm_data[11];

$email{to} = $alarm{email};
$email{subj} = "Alarm Monitor - $alarm{name}:$alarm{type} - $alarm{desc} -  $alarm{text}";
$email{body} = "Alarm Timestamp = $alarm{date}<br>\n";
$email{body} .=  "Alarm Tag = $alarm{name}<br>\n";
$email{body} .=  "Alarm Type = $alarm{type}<br>\n";
$email{body} .= "Tag Description = $alarm{desc}<br>\n";
$email{body} .= "Alarm Text = $alarm{text}<br>\n";
$email{body} .= "Tag Measurement = $alarm{meas}<br>\n";
$email{body} .= "Alarm Trip = $alarm{trip}<br>\n";
$email{body} .= "Alarm State = $alarm{state}";

mail_alarm($email{to}, $email{from}, $email{subj}, $email{body});

exit;

sub mail_alarm($$$$) {    
    my $to_list = shift;
    my $from = shift;
    my $subject = shift;
    my $body = shift;
    my $smtp;
    my @recipients;

    my $mailhost = 'mailhost';

    #Create a new object with 'new'. 
    $smtp = Net::SMTP->new($mailhost, Timeout => 30)|| die "ERROR creating SMTP obj: $! \n";

    #Send the MAIL command to the server.
    $smtp->mail($from);

    #Send the server the 'Mail To' address. 
    @recipients = split(/\s+/, $to_list);
    $smtp->recipient(@recipients, { SkipBad => 1 });

    #Start the message. 
    $smtp->data();

    #Send the message. 
    $smtp->datasend("Subject: $subject\n");
    $smtp->datasend("Content-Type: text/html\n");
    $smtp->datasend("\n");
    $smtp->datasend($body);

    #End the message. 
    $smtp->dataend();

    #Close the connection to your server. 
    $smtp->quit();
}
