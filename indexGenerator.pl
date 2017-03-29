#!/usr/bin/perl

use strict;
use warnings;
use version;	our $VERSION = qv('5.16.0');
use Text::CSV	1.32;

my $COMMA = q{,};

my @records;
my @year;
my @location;
my @violation;
my @unique_stattype;
my @stattype;
my @coordinate;
my $record_count = -1;
my $csv 		 = Text::CSV->new({ sep_char => $COMMA });

open my $file_fh, '<', "province_data/1.csv" or
  die "";

@records = <$file_fh>;

foreach my $file_record (@records) {
	if ($csv->parse($file_record)) {
		my @master_fields = $csv->fields();
		$record_count++;
		$year[$record_count] = $master_fields[0];
        $location[$record_count] = $master_fields[1];
        $violation[$record_count] = $master_fields[2];
        $stattype[$record_count] = $master_fields[3];
        $coordinate[$record_count] = $master_fields[5];
	 } else {
	  warn "Line/record could not be parsed: $records[$record_count]\n"; 
	 }
}

close $file_fh or
die "";

print("Done read.\n");

open my $output_fh, '>', 'testoutput.csv' or die "";

for (my $i = 0; $i < scalar(@stattype); $i++) {
    my $unique = 1;
    foreach my $uni_statt (@unique_stattype) {
        if($stattype[$i] eq $uni_statt) {
            $unique = 0;
        }
    }
    
    if ($unique == 1) {
        print $coordinate[$i]." -> ";
        my @coordinates = split(/\./, $coordinate[$i]);
        print @coordinates."\n";
        $unique_stattype[$#unique_stattype + 1] = $stattype[$i];
        print $output_fh $coordinates[2].",\"".$stattype[$i]."\"\n";
    }
}

close $output_fh or die "";

