#!/usr/bin/perl

use strict;
use warnings;
use version;	our $VERSION = qv('5.16.0');
use Text::CSV	1.32;

my $COMMA = q{,};

my @records;
my @return_records;
my $record_count = -1;
my $return_count = -1;
my @ref_date;
my @geo;
my @violations;
my @sta;
my @vector;
my @coordinate;
my @value;
my $code = "2.1.1";
my $year = "2000";
my $csv 		 = Text::CSV->new({ sep_char => $COMMA });

open my $file_fh, '<', "02520051-eng.csv" or 
  die "Unable to open file: 02520051-eng.csv\n";

print ("Loading...\n");

@records = <$file_fh>;

foreach my $file_record (@records) {
	if ($csv->parse($file_record)) {
		my @master_fields = $csv->fields();
		$record_count++;
		$ref_date[0]   = $master_fields[0];
		$geo[0]	       = $master_fields[1];
		$violations[0] = $master_fields[2];
		$sta[0]        = $master_fields[3];
		$vector[0] 	   = $master_fields[4];
		$coordinate[0] = $master_fields[5];
		$value[0] 	   = $master_fields[6];
		if ($coordinate[0] eq $code && $ref_date[0] == $year) {
			print "$sta[0] of $violations[0] in $geo[0] is $value[0] in the year $year\n";
			last;
		}
	 } else {
	  warn "Line/record could not be parsed: $records[$record_count]\n"; 
	 }
} 

close $file_fh or
  die "Unable to close: 02520051-eng.csv\n";
