#!/usr/bin/perl

#
#    Packages and modules
#
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);
use Statistics::R;
use version; our $VERSION = qv('5.16.0'); #This is our version of perl to be used
use Text::CSV 1.32;

#
#    PROGRAM STARTS HERE
#

my $globalCode;
my $qType;

while(1){
    $qType = interface();

    if ($qType == 0){
        compare();
        
    } elsif ($qType == 1){
        trend();
        
    } elsif ($qType == 2){
        directSearch();
        
    } elsif ($qType == 3){
        rank();
        
    } elsif ($qType == 4){
        rank();
    }
}

sub rank{
    
    #
    #    Variables
    #
    my $EMPTY = q{};
    my $SPACE = q{ };
    my $COMMA = q{,};
    
    my @records;
    my $file_fh;
    my @return_records;
    my $record_count = -1;
    my $return_count = -1;
    
    my $ref_date; my $geo; my $violations;
    my $stat; my $coordinate; my $value;
    
    my $code = $globalCode; my $year = "1998";
    my $geoCode = -1; my $vioCode = -1; my $statCode = -1;
    my $matchFound = 0;
    
    my @region;
    my @figure;
    my $x = 0;
    my $i = 0;
    
    my $csv 		 = Text::CSV->new({ sep_char => $COMMA });
    
    if ($csv->parse($code)){
        my @encoding = $csv->fields();
        $vioCode    = $encoding[2];
        $statCode   = $encoding[3];
        $year       = $encoding[5];
    } else {
        warn "The encoding could not be parsed";
    }
    
    $geoCode = 0;
    $vioCode++;
    $statCode++;
    
    $x = 0;
    for ($i = 1; $i <= 48; $i++){
        $geoCode = $i;
        $code = "$geoCode.$vioCode.$statCode";
        #print "----->> $code <<---\n";
        
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
                
                if ($coordinate eq $code && $ref_date == $year && looks_like_number($value)) {
                    $region[$x] = $geo;
                    $figure[$x]  = $value;
                    $x++;
                    $matchFound = 1;
                    last;
                }
                
            } else {
                warn "Line/record could not be parsed: $records[$record_count]\n";
            }
        }
        
        if($matchFound == 0){
            print "No data found for $geo not available\nData possibly might not exist!\n";
        }
        $geoCode++;
        
    }
    
    my $j = 0;
    my $loc;
    my $total = $x;
    
    for $i (1.. ($x - 1)){
        $value = $figure[$i];
        $loc = $region[$i];
        $j = $i;
        while($j > 0 && $value < $figure[$j - 1]){
            $figure[$j] = $figure[$j - 1];
            $region[$j] = $region[$j - 1];
            $j--;
        }
        $figure[$j] = $value;
        $region[$j] = $loc;
    }
    
    my $num = 0;
    
    do {
        print "Size of list (1-20): ";
        $x = <STDIN>;
        chomp $x;
        
        if(looks_like_number($x) && ($x < 21 && $x > 0)){
            $num = 1;
        }else{
            $num = 0;
            print "Invalid Input!\n";
        }
        
    } while($num != 1);
    
    open $file_fh, '>', 'Trend.csv';
    
    print $file_fh ("\"Region\", \"Value\"\n");
    
    for $i (1.. $x) {
        if($region[$i] ne "Canada"){
            print $file_fh ("\"$region[$i]\", $figure[$i]\n");
        }
    }
    
    close $file_fh or die "close failed";
    
    if($qType == 3){
        printf ("------------------------------------------------------------------------------\n");
        printf ("   |-- %-38s --|-- %6s --|\n\n", "Location", "Value");
        
        $j = 1;
        for($i = ($x + 1); $i > 1; $i--){
            printf ("%-6s |-- %-38s --|-- %6s --|\n", $j.'.', $region[$i], $figure[$i]);
            $j++;
        }
        printf ("------------------------------------------------------------------------------\n");
        
    } elsif($qType == 4){
        printf ("------------------------------------------------------------------------------\n");
        printf ("   |-- %-38s --|-- %6s --|\n\n", "Location", "Value");
        
        $j = 1;
        for($i = 1; $i < ($x + 1); $i++){
            printf ("%-6s |-- %-38s --|-- %6s --|\n", $j.'.', $region[$i], $figure[$i]);
            $j++;
        }
        printf ("------------------------------------------------------------------------------\n");
    }
    
    my $R = Statistics::R->new();
    
    # Set up the PDF file for plots
    $R->run(qq`pdf('Bar_Graph.pdf' , paper="letter")`);
    
    # Load the plotting library
    $R->run(q`library(ggplot2)`);
    
    # read in data from a CSV file
    $R->run(qq`data <- read.csv('Trend.csv')`);
    
    # plot the data as a line bar with each point outlined
    $R->run(q`ggplot(data, aes(x=Region, y=Value, colour=Region)) + ggtitle("Crime Comparison Over Canada") + geom_bar(stat="identity") + theme(axis.text.x=element_text(angle=-90))`);
    # close down the PDF device
    $R->run(q`dev.off()`);
    
    $R->stop();
    system "open Bar_Graph.pdf";
    
}

sub compare {
    
    my $COMMA = q{,};
    
    my @firstRecord;
    my @secondRecord;
    my @return_records;
    my $record_count = -1;
    my $return_count = -1;
    my $count = 0;
    
    my $ref_date;
    my $geo;
    my $violations;
    my $sta;
    my $vector;
    my $coordinate;
    my $value;
    
    my $found;
    my $found_2;
    my $geo_2;
    my $sta_2;
    my $violations_2;
    
    my $geo_1;
    my $sta_1;
    my $violations_1;
    
    my $code = $globalCode;
    my $year = "1998";
    my $year_2 = "2015";

    my $temp;
    my $file_fh;
    my $geoCode = 0;
    my $vioCode =0;
    my $statCode = 0;
    my $i = 0;
    my $geoCode_2 = 0;
    my $match1 = 0;
    my $match2 = 0;
    
    my $csv	  = Text::CSV->new({ sep_char => $COMMA });
    
    if ($csv->parse($code)){
        my @encoding = $csv->fields();
        $geoCode    = $encoding[1];
        $vioCode    = $encoding[2];
        $statCode   = $encoding[3];
        $geoCode_2  = $encoding[4];
        $year       = $encoding[5];
        $year_2     = $encoding[6];
    } else {
        warn "The encoding could not be parsed";
    }
    
    $geoCode++;
    $vioCode++;
    $statCode++;
    $geoCode_2++;
    
    $temp = $year;
    
    # -------------------------------------------------------- #
    
    open $file_fh, '<', "province_data/$geoCode.csv" or
    die "Unable to open file: $geoCode.csv\n";
    
    @firstRecord = <$file_fh>;
    
    close $file_fh or
    die "Unable to close: $geoCode.csv\n";
    
    # -------------------------------------------------------- #
    
    open $file_fh, '<', "province_data/$geoCode_2.csv" or
    die "Unable to open file: $geoCode_2.csv\n";
    
    @secondRecord = <$file_fh>;
    
    close $file_fh or
    die "Unable to close: $geoCode_2.csv\n";
    
    # -------------------------------------------------------- #
    
    print "\n|----------------RESULT TABLE--------------------------------------------------------------------------------------------------------------------------------------------|\n" or die "print failed\n";
    
    $code = "$geoCode.$vioCode.$statCode";
    foreach my $file_record (@firstRecord) {
        if ($csv->parse($file_record)) {
            my @master_fields = $csv->fields();
            $record_count++;
            $ref_date       = $master_fields[0];
            $geo            = $master_fields[1];
            $violations     = $master_fields[2];
            $sta            = $master_fields[3];
            $vector         = $master_fields[4];
            $coordinate     = $master_fields[5];
            $value          = $master_fields[6];
            
            #print "$temp ------- $ref_date ------ $coordinate --------- $code<-----\n";
            
            if ($coordinate eq $code && $ref_date == $year) {
                print "| $ref_date --|-- $geo --|-- $violations --|-- $sta --|-- $value |\n";
                $found = $value;
                $geo_1 = $geo;
                $sta_1 = $sta;
                $violations_1 = $violations;
                $match1 = 1;
                last;
            }
        } else {
            warn "Line/record could not be parsed\n";
        }
    }
    if($match1 == 0){
        print "   No data found for the region.\nData possibly might not exist!\n";
    }
    
    # -------------------------------------------------------- #
    
    $code = "$geoCode_2.$vioCode.$statCode";
    foreach my $file_record (@secondRecord) {
        if ($csv->parse($file_record)) {
            my @master_fields = $csv->fields();
            $record_count++;
            $ref_date       = $master_fields[0];
            $geo            = $master_fields[1];
            $violations     = $master_fields[2];
            $sta            = $master_fields[3];
            $vector         = $master_fields[4];
            $coordinate     = $master_fields[5];
            $value          = $master_fields[6];
            
            #print "$temp ------- $ref_date ------ $coordinate --------- $code<-----\n";
            
            if ($coordinate eq $code && $ref_date == $year) {
                print "| $ref_date --|-- $geo --|-- $violations --|-- $sta --|-- $value |\n";
                $found_2 = $value;
                $geo_2 = $geo;
                $sta_2 = $sta;
                $violations_2 = $violations;
                $match2 = 1;
                last;
            }
        } else {
            warn "Line/record could not be parsed\n";
        }
    }
    if($match2 == 0){
        print "   No data found for the region.\nData possibly might not exist!\n";
    }
    print "|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|\n" or die "print failed\n";
    
    if($found == ".."){
        $found = 0;
    } elsif($found_2 == "..") {
        $found_2 = 0;
    }
    
    if($match1 == 1 && $match2 == 1){
        $found_2 -= $found;
        
        print "\nThe difference between $sta_2 of $violations_2 in $geo_2 and $geo_1 is $found_2 in the year $year.\n";
        
        if($found == 0){
            $found_2 = 100;
        } else {
            $found_2 /= $found;
            $found_2 *= 100;
        }
        
        if ($found_2 > 0) {
            printf ("Meaning that $geo_2 has %.0f", $found_2);
            print "% MORE $violations_2 rate compared to $geo_1!\n";
        } elsif ($found_2 < 0) {
            printf ("Meaning that $geo_2 has %.0f", $found_2);
            print "% LESS $violations_2 rates compared to $geo_1!\n"
        } else {
            print "Meaning is NO DIFFERENCE!\n";
        }
    }
}

sub interface {
    my $EMPTY = q{};
    my $SPACE = q{ };
    my $COMMA = q{,};
    my $csv 		 = Text::CSV->new({ sep_char => $COMMA });

    my $geofileName = "locations_index.csv";
    my $crimefileName = "crimes_index.csv";
    my $statsfileName = "stats_index.csv";
    my @geoLocations;
    my @crimesLocations;
    my @statsLocations;
    my $fileHandle;
    my $crimesFileHandle;
    my $statsFileHandle;
    my $line;
    my $crimesLine;
    my $statsLine;
    my @lineArray;
    my @crimesLineArray;
    my @statsLineArray;
    my $i = 0;
    my $j = 0;
    my $k = 0;
    my $x = 0;
    
    my $counter = 0;
    my $geoMatch = 0;
    my $crimesMatch = 0;
    my $statsMatch = 0;
    my $geoCounter = 0;
    my $crimeCounter = 0;
    my $statCounter = 0;
    my $eYearGood = 0;
    
    my $sYearGood = 0;
    my $syearUsrInput;
    my $eyearUsrInput;
    my $userInput;
    my @queryType;
    my $queryFound = 0;
    my $query = 0;
    
    my $geo1 = -1;
    my $geo2 = -1;
    my $temp = 0;
    
    
    $queryType[0] = "Comparison";
    $queryType[1] = "Trend";
    $queryType[2] = "Direct Search";
    $queryType[3] = "Highest Magnitude";
    $queryType[4] = "Lowest Magnitude";
    
    print "\n|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|\n" or die "print failed\n";
    print "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MAIN INTERFACE - CRIME CENSUS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|\n" or die "print failed\n";
    print "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|\n\n" or die "print failed\n";
    
    # Reading *_index.csv files
    
    my $record_count = -1;
    
    open my $locations_fh, '<', $geofileName or die $!;
    my @locations_file_contents = <$locations_fh>;
    close $locations_fh or die $!;
    
    foreach my $locations_line (@locations_file_contents) {
        if ( $csv->parse($locations_line) ) {
            my @master_fields = $csv->fields();
            $record_count++;
            $geoLocations[$record_count] = $master_fields[0];
        }
        else {
            warn "Line/record could not be parsed.\n";
        }
    }
    
    $record_count = -1;
    
    open my $crimes_fh, '<', $crimefileName or die $!;
    my @crimes_file_contents = <$crimes_fh>;
    close $crimes_fh or die $!;
    
    foreach my $crimes_line (@crimes_file_contents) {
        if ( $csv->parse($crimes_line) ) {
            my @master_fields = $csv->fields();
            $record_count++;
            $crimesLocations[$record_count] = $master_fields[0];
        }
        else {
            warn "Line/record could not be parsed.\n";
        }
    }
    
    $record_count = -1;
    
    open my $stats_fh, '<', $statsfileName or die $!;
    my @stats_file_contents = <$stats_fh>;
    close $stats_fh or die $!;
    
    foreach my $stats_line (@stats_file_contents) {
        if ( $csv->parse($stats_line) ) {
            my @master_fields = $csv->fields();
            $record_count++;
            $statsLocations[$record_count] = $master_fields[0];
        }
        else {
            warn "Line/record could not be parsed.\n";
        }
    }
    
    # Done reading *_index.csv files
    
    do{
        print "\nWhat type of search do you wish?\n(1) $queryType[0] | (2) $queryType[1] | (3) $queryType[2] | (4) $queryType[3] (All Regions) | (5) $queryType[4] (All Regions) | (6) Exit Program\n" or die "print failed\n";
        print "Action: ";
        $userInput = <STDIN>;
        chomp $userInput;
        
        if($userInput eq "1" || $userInput eq "2" || $userInput eq "3" || $userInput eq "4" || $userInput eq "5" || $userInput eq "6"){
            if($userInput eq "6"){
                exit;
            }
            $queryFound = 1;
            $query = $userInput - 1;
            
            print "\n|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|\n" or die "print failed\n";
        }else{
            print "\nInvalid Input!\n";
            $queryFound = 0;
        }
        
    }while($queryFound != 1);
    
    
    if($query == 0 || $query == 1 || $query == 2){
        $k = 0;
        
        do {
            do{
                print "\nPrint list of all valid geo locations? [YES/NO]: " or die "failed ot print\n";
                $userInput = <STDIN>;
                chomp $userInput;
                if (uc($userInput) eq "YES"){
                    print "(1) $geoLocations[0] ";
                    foreach my $x (1.. $#geoLocations){
                        $temp = $x + 1;
                        print "($temp) $geoLocations[$x] " or die "failed to print region list\n";
                        $k++;
                        if ($k >= 5){
                            $k = 0;
                            print "\n\n";
                        }
                    }
                    print "\n";
                } elsif (uc($userInput) eq "NO"){
                }else{
                    $userInput = "---";
                    print "\nInvalid Input!\n";
                }
                
            } while(uc($userInput) eq "---");
            
            print "Enter a location as a number(#): ";
            $userInput = <STDIN>;
            chomp $userInput;
            
            if(looks_like_number($userInput) && ($userInput < 49 && $userInput > 0)){
                $geoMatch = 1;
                $geo1 = $userInput - 1;
                
                if($query == 0){
                    print "Enter the second location as a number: ";
                    $userInput = <STDIN>;
                    chomp $userInput;
                    
                    if(looks_like_number($userInput) && ($userInput < 49 && $userInput > 0)){
                        $geoMatch = 1;
                        $geo2 = $userInput - 1;
                    }else{
                        $geoMatch = 0;
                    }
                }
            }
            
            if ($geoMatch != 1){
                $geoMatch = 0;
                print "\n---->Failed to find a $userInput, Please enter a valid region<----\n\n" or die "failed to print\n";
            } else {
                if ($query != 0){
                    print "\n$queryType[$query] for $geoLocations[$geo1]\n";
                }else{
                    print "\n$queryType[$query] between $geoLocations[$geo1] and $geoLocations[$geo2]\n";
                }
                print "\n|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|\n" or die "print failed\n";
            }
            
        } while ($geoMatch == 0);
    }
    
    
    if ($geoMatch == 1 || $query == 3 || $query == 4) {
        $counter = 0;
        
        do {
            
            do {
                print "\nPrint list of all valid violations? [YES/NO]: " or die "failed ot print\n";
                $userInput = <STDIN>;
                chomp $userInput;
                if (uc($userInput) eq "YES"){
                    print "(1) $crimesLocations[0] ";
                    foreach my $x (1.. $#crimesLocations){
                        $temp = $x + 1;
                        print "($temp) $crimesLocations[$x] " or die "failed to print region list\n";
                        $k++;
                        if ($k >= 2){
                            $k = 0;
                            print "\n\n";
                        }
                    }
                } elsif (uc($userInput) eq "NO"){
                } else {
                    print "\nInvalid Input!\n";
                    $userInput = "---";
                }
            } while(uc($userInput) eq "---");
            
            print "Enter a violation (A number from the list): ";
            my $crimesUsrInput = <STDIN>;
            chomp $crimesUsrInput;
            
            if(looks_like_number($crimesUsrInput) && ($crimesUsrInput < 256 && $crimesUsrInput > 0)){
                $crimesMatch = 1;
                $crimeCounter = $crimesUsrInput - 1;
            }
            
            if ($crimesMatch != 1){
                print "\n---->Failed to find a $crimesUsrInput, Please enter a valid violation<----\n\n" or die "failed to print\n";
            } else {
                if ($crimesUsrInput != 25 && $crimesUsrInput != 70 && $crimesUsrInput != 71 && $crimesUsrInput != 102 && $crimesUsrInput != 217 && $crimesUsrInput != 218){
                    print "\n$queryType[$query] for $crimesLocations[$crimeCounter]\n";
                    print "\n|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|\n" or die "print failed\n";
                } else {
                    print "Not enough information available for this crime, please choose a different violation\n";
                    $crimesMatch = 0;
                }
            }
            
        } while($crimesMatch == 0);
        
    }
    
    if ($crimesMatch == 1 || $query == 3 || $query == 4) {
        
        $counter = 0;
        
        do {
            do {
                print "\nPrint list of all valid incident types? [YES/NO]: " or die "failed to print\n";
                $userInput = <STDIN>;
                chomp $userInput;
                if (uc($userInput) eq "YES"){
                    print "(1) $statsLocations[0] ";
                    foreach my $x (1.. $#statsLocations){
                        $temp = $x + 1;
                        print "($temp) $statsLocations[$x] " or die "failed to print region list\n";
                        $k++;
                        if ($k >= 3){
                            $k = 0;
                            print "\n\n";
                        }
                    }
                    print "\n";
                } elsif (uc($userInput) eq "NO"){
                } else {
                    print "\nInvalid Input!\n";
                    $userInput = "---";
                }
            } while(uc($userInput) eq "---");
            
            print "Enter a statistic type (A Number from the list): ";
            my $statsUsrInput = <STDIN>;
            chomp $statsUsrInput;
            
            if(looks_like_number($statsUsrInput) && ($statsUsrInput < 15 && $statsUsrInput > 0)){
                $statsMatch = 1;
                $statCounter = $statsUsrInput - 1;
            }
            
            if ($statsMatch != 1){
                print "\n---->Failed to find a $statsUsrInput, Please enter a valid incident<----\n\n" or die "failed to print\n";
            } else {
                print "\n$queryType[$query] for $statsLocations[$statCounter]\n";
                print "\n|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|\n" or die "print failed\n";
            }
        } while ($statsMatch == 0);
    }
    
    $syearUsrInput = -1;
    $eyearUsrInput = -1;
    
    if ($statsMatch == 1  || $query == 3 || $query == 4){
        do {
            print "\nEnter a year(1998 - 2015): ";
            $syearUsrInput = <STDIN>;
            chomp $syearUsrInput;
            
            if (looks_like_number($syearUsrInput) && $syearUsrInput >= 1998 && $syearUsrInput <= 2015)
            {
                $sYearGood = 1
            }
            else
            {
                print "\nInvalid year entered, please enter a year within the range\n" or die "failed to print\n";
            }
        } while ($sYearGood == 0)
    }
    
    if ($query == 1){
        if ($sYearGood == 1)
        {
            do {
                print "Enter an ending year(IMPORTANT: ". ($syearUsrInput + 1) ." - 2015): ";
                $eyearUsrInput = <STDIN>;
                chomp $eyearUsrInput;
                
                if (looks_like_number($eyearUsrInput) && $eyearUsrInput >= ($syearUsrInput + 1) && $eyearUsrInput <= 2015)
                {
                    $eYearGood = 1
                }
                else
                {
                    print "Invalid year entered!\n" or die "failed to print\n";
                }
            } while ($eYearGood == 0);
        }
    }
    print "\n|--------------- SEARCH SPECIFICATIONS ---------------------------------------------------------------------------------------------------------------------------------|\n" or die "print failed\n";
    if($query == 1){
        print "\nThe program will now search for a $queryType[$query] for $geoLocations[$geo1] --> $crimesLocations[$crimeCounter] --> $statsLocations[$statCounter]"
        ." for the year range of $syearUsrInput to $eyearUsrInput\n\n";
        
    } elsif($query == 2){
        print "\nThe program will now do a $queryType[$query] for $geoLocations[$geo1] --> $crimesLocations[$crimeCounter] --> $statsLocations[$statCounter]"
        ." for the year $syearUsrInput\n\n";
        
    } elsif($query == 0){
        print "\nThe program will now do a $queryType[$query] between $geoLocations[$geo1] And $geoLocations[$geo2] --> $crimesLocations[$crimeCounter] --> $statsLocations[$statCounter]"
        ." for the year $syearUsrInput\n";
        
    } elsif($query == 3){ # HIGHEST
        print "\nThe program will now do a $queryType[$query] search for $crimesLocations[$crimeCounter] --> $statsLocations[$statCounter] for the year $syearUsrInput\n\n";
        
    } elsif($query == 4){ # LOWEST
        print "\nThe program will now do a $queryType[$query] search for $crimesLocations[$crimeCounter] --> $statsLocations[$statCounter] for the year $syearUsrInput\n\n";
        
    }

    
    print "|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|\n" or die "print failed\n";

    print "\nThe coordinates for the search are: $query,$geo1,$crimeCounter,$statCounter,$geo2,$syearUsrInput,$eyearUsrInput\n";
    $globalCode = "$query,$geo1,$crimeCounter,$statCounter,$geo2,$syearUsrInput,$eyearUsrInput";
    return $query;
}

sub directSearch {
    
    #
    #    Variables
    #
    my $EMPTY = q{};
    my $SPACE = q{ };
    my $COMMA = q{,};
    
    my @records;
    my $file_fh;
    my @return_records;
    my $record_count = -1;
    my $return_count = -1;
    
    my $ref_date; my $geo; my $violations;
    my $stat; my $coordinate; my $value;
    
    my $code = $globalCode; my $year = "1998";
    my $geoCode = -1; my $vioCode = -1; my $statCode = -1;
    my $matchFound = 0;
    
    my $csv 		 = Text::CSV->new({ sep_char => $COMMA });
    
    if ($csv->parse($code)){
        my @encoding = $csv->fields();
        $geoCode    = $encoding[1];
        $vioCode    = $encoding[2];
        $statCode   = $encoding[3];
        $year       = $encoding[5];
    } else {
        warn "The encoding could not be parsed";
    }
    
    $geoCode++;
    $vioCode++;
    $statCode++;
    
    $code = "$geoCode.$vioCode.$statCode";
    #print "----->> $code <<---\n";
    
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
                print "\n|----------------RESULT-------------------------------------------------------------------------------------------------------------------------------------------------|\n" or die "print failed\n";
                print "\n$stat of $violations in $geo is $value(%/#) in the year $year\n";
                print "\n|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|\n" or die "print failed\n";
                $matchFound = 1;
                last;
            }
        } else {
            warn "Line/record could not be parsed: $records[$record_count]\n"; 
        }
    }
    if($matchFound == 0){
        print "No data found for the direct search\nData possibly might not exist!\n";
    }
}

sub trend{
    
    my $COMMA = q{,};
    
    my $userInput;
    my @records;
    my @return_records;
    my $record_count = -1;
    my $return_count = -1;
    my $ref_date;
    my $geo;
    my $violations;
    my $sta;
    my $vector;
    my $coordinate;
    my $value;
    my $code = $globalCode;
    my $year = "1998";
    my $year2 = "2015";
    my @found;
    my $count = 0;
    my $geo_2;
    my $sta_2;
    my $violations_2;
    my $temp;
    my $i = 0;
    my @yearArray;
    my $R;
    
    my $geoCode = 0;
    my $vioCode =0;
    my $statCode = 0;
    
    my $csv	  = Text::CSV->new({ sep_char => $COMMA });
    
    if ($csv->parse($code)){
        my @encoding = $csv->fields();
        $geoCode    = $encoding[1];
        $vioCode    = $encoding[2];
        $statCode   = $encoding[3];
        $year       = $encoding[5];
        $year2      = $encoding[6];
    } else {
        warn "The encoding could not be parsed";
    }
    
    $geoCode++;
    $vioCode++;
    $statCode++;
    
    $code = "$geoCode.$vioCode.$statCode";
    
    open my $file_fh, '<', "province_data/$geoCode.csv" or
    die "Unable to open file: $geoCode.csv\n";
    
    @records = <$file_fh>;
    
    close $file_fh or
    die "Unable to close: $geoCode.csv\n";
    
    $temp = $year;
    print "\n|----------------RESULT TABLE--------------------------------------------------------------------------------------------------------------------------------------------|\n" or die "print failed\n";
    
    foreach my $file_record (@records) {
        if ($csv->parse($file_record)) {
            my @master_fields = $csv->fields();
            $record_count++;
            $ref_date       = $master_fields[0];
            $geo            = $master_fields[1];
            $violations     = $master_fields[2];
            $sta            = $master_fields[3];
            $vector         = $master_fields[4];
            $coordinate     = $master_fields[5];
            $value          = $master_fields[6];
            
            #print "$temp ------- $ref_date ------ $coordinate --------- $code<-----\n";
            
            if ($coordinate eq $code && $ref_date >= $year) {
                $yearArray[$i] = $ref_date;
                $i++;
                print "| $ref_date --|-- $geo --|-- $violations --|-- $sta --|-- $value |\n";
                $found[$count] = $value;
                $geo_2 = $geo;
                $sta_2 = $sta;
                $violations_2 = $violations;
                $count++;
                $temp++;
                if ($temp > $year2) {
                    last;
                }
            }
        } else {
            warn "Line/record could not be parsed: $records[$record_count]\n";
        }
    }
    print "|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|\n" or die "print failed\n";
    
    $count--;
    $temp = $year;
    $i = 0;
    
    open my $fh, '>', 'Trend.csv';
    
    print $fh ("\"Region\", \"Year\", \"Value\"\n");
    
    for my $x (0..$count) {
        if($found[$x] ne ".."){
            $i++;
            print $fh ("\"$geo\", $yearArray[$x], $found[$x]\n");
        }
    }
    
    close $fh;
    
    my $graphType = 0;
    my $graphFound = 0;
    
    do{
        print "\nNOTE: There is/are $i entries to be graphed!\n";
        print "How do you want the results to be presented (Table already shown)?\n(1) Line Graph | (2) Bar Graph | (3) Both | (4) None\n" or die "print failed\n";
        print "Action: ";
        $userInput = <STDIN>;
        chomp $userInput;
        
        if($userInput eq "1" || $userInput eq "2" || $userInput eq "3" || $userInput eq "4"){
            $graphFound = 1;
            $graphType = $userInput;
            
            print "\n|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|\n" or die "print failed\n";
        }else{
            print "Invalid Input!\n";
            $graphFound = 0;
        }
    }while($graphFound != 1);
    
    if($graphType == 1){
        createLineGraph();
    } elsif($graphType == 2){
        createBarGraph();
    } elsif($graphType == 3){
        createLineGraph();
        createBarGraph();
    }
    
    #system "rm Trend.csv";
}

sub createLineGraph{
    my $R = Statistics::R->new();
    
    # Set up the PDF file for plots
    $R->run(qq`pdf('Line_Graph.pdf' , paper="letter")`);
    
    # Load the plotting library
    $R->run(q`library(ggplot2)`);
    
    # read in data from a CSV file
    $R->run(qq`data <- read.csv('Trend.csv')`);
    
    # plot the data as a line plot with each point outlined
    $R->run(q`ggplot(data, aes(x=Year, y=Value, colour=Region, group=Region)) + geom_line() + geom_point(size=2) + ggtitle("Crime Trend Within the Given Years") + ylab("Incidence of Crimes") `);
    # close down the PDF device
    $R->run(q`dev.off()`);
    
    $R->stop();
    system "open Line_Graph.pdf";
}

sub createBarGraph{
    my $R = Statistics::R->new();
    
    # Set up the PDF file for plots
    $R->run(qq`pdf('Bar_Graph.pdf' , paper="letter")`);
    
    # Load the plotting library
    $R->run(q`library(ggplot2)`);
    
    # read in data from a CSV file
    $R->run(qq`data <- read.csv('Trend.csv')`);
    
    # plot the data as a line bar with each point outlined
    $R->run(q`ggplot(data, aes(x=Year, y=Value, colour=Region, group=Region)) + ggtitle("Crime Trend Within the Given Years") + geom_bar(stat="identity")`);
    # close down the PDF device
    $R->run(q`dev.off()`);
    
    $R->stop();
    system "open Bar_Graph.pdf";
}

#
#    END OF SCRIPT
#
