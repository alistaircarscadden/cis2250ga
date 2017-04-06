#!/usr/bin/perl
#
# generateAll.pl                 purpose: Generate all necessary files from 02520051-eng.csv
#    provinceDataGnerator.pm                  generate province_data/(1-48).csv
#    crimesIndexGenerator.pm                  generate crimes_index.csv
#    locationsIndexGenerator.pm               generate locations_index.csv
#    statsIndexGenerator.pm                   generate stats_index.csv
#
# Usage
#     once 02520051-eng.csv  is in the same directory as the scripts listed above
#     run `perl generateAll.pl` to generate all necessary files. Must use a copy
#     of 02520051-eng.csv that has the csv-incompatible/non-ASCII/accented chars
#     removed.
#
# Author
#     Alistair Carscadden
#

use strict;
use warnings;
use version; our $VERSION = qv('5.16.0');
use Text::CSV 1.32;

use provinceDataGenerator;
use statsIndexGenerator;
use locationsIndexGenerator;
use crimesIndexGenerator;

my $COMMA = q{,};

my @records;

my @col0;    # year
my @col1;    # loc
my @col2;    # violation type
my @col3;    # stat type
my @col4;    # v
my @col5;    # coordinate
my @col6;    # value

my $max_violation_number = 260;
my @unique_violations;

my $record_count = -1;
my $csv = Text::CSV->new( { sep_char => $COMMA } );

print "Starting..";

open my $file_fh, '<', $ARGV[0] or die $!;
@records = <$file_fh>;
close $file_fh or die $!;

foreach my $file_record (@records) {
    if ( $csv->parse($file_record) ) {
        my @master_fields = $csv->fields();
        $record_count++;
        $col0[$record_count] = $master_fields[0];
        $col1[$record_count] = $master_fields[1];
        $col2[$record_count] = $master_fields[2];
        $col3[$record_count] = $master_fields[3];
        $col4[$record_count] = $master_fields[4];
        $col5[$record_count] = $master_fields[5];
        $col6[$record_count] = $master_fields[6];
    }
    else {
        warn "Line/record could not be parsed: $records[$record_count]\n";
    }
}

print("... done read.\n");

generateProvinceData( \@records, \@col0, \@col1, \@col2, \@col3, \@col4, \@col5, \@col6 );

print("... done writing province_data/1-48.csv.\n");

generateCrimesIndex( \@records, \@col0, \@col1, \@col2, \@col3, \@col4, \@col5, \@col6 );

print("... done writing crimes_index.csv.\n");

generateStatsIndex( \@records, \@col0, \@col1, \@col2, \@col3, \@col4, \@col5, \@col6 );

print("... done writing stats_index.csv.\n");

generateLocationsIndex( \@records, \@col0, \@col1, \@col2, \@col3, \@col4, \@col5, \@col6 );

print("... done writing locations_index.csv.\n");
