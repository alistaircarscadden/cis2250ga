#!/usr/bin/perl

use strict;
use warnings;
use version;	our $VERSION = qv('5.16.0');
use Text::CSV	1.32;

my $COMMA = q{,};

my @records;
my $file_fh;
my @return_records;
my $record_count = -1;
my $return_count = -1;

my $ref_date;
my $geo;
my $violations;
my $stat;
my $coordinate;
my $value;

my $code = "2,3,1";
my $year = "1998";
my $geoCode = 1;
my $vioCode = 1;
my $statCode = 1;

my $csv 		 = Text::CSV->new({ sep_char => $COMMA });

if ($csv->parse($code)){
   my @encoding = $csv->fields();
   $geoCode    = $encoding[0];
   $vioCode    = $encoding[1];
   $statCode   = $encoding[2];
} else {
   warn "The encoding could not be parsed";
}

$code = "$geoCode.$vioCode.$statCode";

open $file_fh, '<', "province_data/$geoCode.csv" or 
  die "Unable to open file: $geoCode.csv\n";

@records = <$file_fh>;

close $file_fh or
  die "Unable to close: $geoCode.csv\n";

foreach my $file_record (@records) {
   if ($csv->parse($file_record)) {
      my @master_fields = $csv->fields();
      $record_count++;

      $ref_date      = $master_fields[0];
      $geo           = $master_fields[1];
      $violations    = $master_fields[2];
      $stat          = $master_fields[3];
      $coordinate    = $master_fields[5];
      $value         = $master_fields[6];

      if ($coordinate eq $code && $ref_date == $year) {
         print "$stat of $violations in $geo is $value in the year $year\n";
         last;
      }
   } else {
      warn "Line/record could not be parsed: $records[$record_count]\n"; 
   }
}
