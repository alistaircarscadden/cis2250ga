package provinceDataGenerator;

use Exporter;
@ISA = ('Exporter');
@EXPORT = ('generateProvinceData');

use strict;
use warnings;
use version;	our $VERSION = qv('5.16.0');

sub generateProvinceData {
    my ($records_ref, $col0_ref, $col1_ref, $col2_ref, $col3_ref, $col4_ref, $col5_ref, $col6_ref) = @_;
    
    my @records = @{ $records_ref };
    my @col0 = @{ $col0_ref}; # year
    my @col1 = @{ $col1_ref}; # loc
    my @col2 = @{ $col2_ref}; # violation type
    my @col3 = @{ $col3_ref}; # stat type
    my @col4 = @{ $col4_ref}; # v
    my @col5 = @{ $col5_ref}; # coordinate
    my @col6 = @{ $col6_ref}; # value

    # Open a set of 48 output files
    my @output_fhs;
    for (my $i = 1; $i <= 48; $i++) {
        open $output_fhs[$i], '>', "province_data/$i.csv" or die $!;
    }

    # For every record in the file, find what the geo code is (by finding the first # in the coordinate #.#.#)
    # and then print the record to the correct file 1-48.csv
    for(my $i = 0; $i < @records; $i++) {
        my @coordinates = split(/\./, $col5[$i]);
        my $specific_fh = $output_fhs[$coordinates[0]];
        my $record = $records[$i];
        print $specific_fh $record;
    }

    for (my $i = 1; $i <= 48; $i++) {
        close $output_fhs[$i] or die $!;
    }
}
