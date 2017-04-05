package crimesIndexGenerator;

use Exporter;
@ISA    = ('Exporter');
@EXPORT = ('generateCrimesIndex');

use strict;
use warnings;
use version; our $VERSION = qv('5.16.0');

sub generateCrimesIndex {
    my ($records_ref, $col0_ref, $col1_ref, $col2_ref, $col3_ref, $col4_ref, $col5_ref, $col6_ref) = @_;
    
    my @records = @{$records_ref};
    my @col0    = @{$col0_ref};      # year
    my @col1    = @{$col1_ref};      # loc
    my @col2    = @{$col2_ref};      # violation type
    my @col3    = @{$col3_ref};      # stat type
    my @col4    = @{$col4_ref};      # v
    my @col5    = @{$col5_ref};      # coordinate
    my @col6    = @{$col6_ref};      # value
    
    my $max_violation_number = 260;
    my @unique_violations;
    
    # Initialize $max_violation_number strings into @unique_violations
    for ( my $i = 0 ; $i < $max_violation_number ; $i++ ) {
        $unique_violations[$i] = 'STATDOESNOTEXIST';
    }
    
    for ( my $i = 0 ; $i < @records ; $i++ ) {
        my $unique = 1;
        
        # Check if the violation on current line is unique
        foreach my $unique_violation (@unique_violations) {
            if ( $col2[$i] eq $unique_violation ) {
                $unique = 0;
            }
        }
        
        if ( $unique == 1 ) {
            my @coordinates = split( /\./, $col5[$i] );
            $unique_violations[ $coordinates[1] - 1 ] = $col2[$i];
        }
    }
    
    open my $output_fh, '>', 'crimes_index.csv' or die $!;
    for my $str (@unique_violations) {
        print $output_fh '"' . $str . "\"\n";
    }
    close $output_fh or die $!;
}
