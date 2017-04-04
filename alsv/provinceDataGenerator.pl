#!/usr/bin/perl

#
# Alistair's Province Data File (1-48.csv) generator
# using Prof Stacey's parsing code
#

use strict;
use warnings;
use version;	our $VERSION = qv('5.16.0');
use Text::CSV	1.32;

my $COMMA = q{,};

my @records;
my @col0; # year
my @col1; # loc
my @col2; # violation type
my @col3; # stat type
my @col4; # version
my @col5; # coordinate
my @col6; # value
my $record_count = -1;
my $csv = Text::CSV->new({sep_char => $COMMA});

open my $file_fh, '<', "02520051-eng.csv" or die "Unable to open 02520051-eng.csv\n";
@records = <$file_fh>;
close $file_fh or die "Unable to close 02520051-eng.csv";

foreach my $file_record (@records) {
    if ($csv->parse($file_record)) {
        my @master_fields = $csv->fields();
        $record_count++;
        $col0[$record_count] = $master_fields[0];
        $col1[$record_count] = $master_fields[1];
        $col2[$record_count] = $master_fields[2];
        $col3[$record_count] = $master_fields[3];
        $col4[$record_count] = $master_fields[4];
        $col5[$record_count] = $master_fields[5];
        $col6[$record_count] = $master_fields[6];
    } else {
        warn "Line/record could not be parsed: $records[$record_count]\n";
    }
}

print("Done read.\n");

# Open a set of 48 output files
my @output_fhs;
for (my $i = 1; $i <= 48; $i++) {
    open $output_fhs[$i], '>', "province_data/$i.csv" or die "Unable to open $i.csv for writing.\n";
}

# For every record in the file, find what the geo code is (by finding the first # in the coordinate #.#.#)
# and then print the record to the correct file 1-48.csv
for(my $i = 0; $i < @records; $i++) {
    my @coordinates = split(/\./, $col5[$i]);
    my $specific_fh = $output_fhs[$coordinates[0]];
    print $specific_fh $records[$i];
}

for (my $i = 1; $i <= 48; $i++) {
    close $output_fhs[$i] or die "Unable to close $i.csv.\n";
}

print("Script end.");

