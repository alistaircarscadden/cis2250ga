package locationsIndexGenerator;

use Exporter;
@ISA    = ('Exporter');
@EXPORT = ('generateLocationsIndex');

use POSIX;
use strict;
use warnings;
use version; our $VERSION = qv('5.16.0');

sub generateLocationsIndex {
    my ($records_ref, $col0_ref, $col1_ref, $col2_ref, $col3_ref, $col4_ref, $col5_ref, $col6_ref) = @_;
    
    my @records = @{$records_ref};
    my @col0    = @{$col0_ref};      # year
    my @col1    = @{$col1_ref};      # loc
    my @col2    = @{$col2_ref};      # violation type
    my @col3    = @{$col3_ref};      # stat type
    my @col4    = @{$col4_ref};      # v
    my @col5    = @{$col5_ref};      # coordinate
    my @col6    = @{$col6_ref};      # value
    
    my $max_location_number = 48;
    my @unique_locations;
    
    # Initialize $max_location_number strings into @unique_violations
    for ( my $i = 0 ; $i < $max_location_number ; $i++ ) {
        $unique_locations[$i] = 'STATDOESNOTEXIST';
    }
    
    print "Generating Locations Index\n";
    print "0%                                                       100%\n";
    
    for ( my $i = 0 ; $i < @records ; $i++ ) {
        if($i % floor(scalar(@records) / 60) == 0) {
            print '#';
        }
        
        my $unique = 1;
        
        # Check if the violation on current line is unique
        foreach my $unique_location (@unique_locations) {
            if ( $col1[$i] eq $unique_location ) {
                $unique = 0;
            }
        }
        
        if ( $unique == 1 ) {
            my @coordinates = split( /\./, $col5[$i] );
            $unique_locations[ $coordinates[0] - 1 ] = $col1[$i];
        }
    }
    
    print "\n";
    
    open my $output_fh, '>', 'locations_index.csv' or die $!;
    for my $str (@unique_locations) {
        print $output_fh '"' . $str . "\"\n";
    }
    close $output_fh or die $!;
}
