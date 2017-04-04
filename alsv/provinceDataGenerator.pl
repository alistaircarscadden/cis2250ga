#!/usr/bin/perl

use strict;
use warnings;
use version;	our $VERSION = qv('5.16.0');
use Text::CSV	1.32;

my $COMMA = q{,};

my @records;
my @col0;
my @col1;
my @col2;
my @col3;
my @col4;
my @col5;
my @col6;
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

my @output_fhs;
for (my $i = 1; $i <= 48; $i++) {
    open $output_fhs[$i], '>', "province_data/$i.csv" or die "Unable to open $i.csv for writing.\n";
}

for (my $i = 1; $i <= 48; $i++) {
    close $output_fhs[$i] or die "Unable to close $i.csv.\n";
}

print("Script end.");

