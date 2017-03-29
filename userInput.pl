#!/usr/bin/perl
use strict;
use warnings;

my $geofileName = "geo_locations.txt";
my $crimefileName = "crime_type.txt";
my $statsfileName = "stat_type.txt";
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
my $l = 0;
my $counter = 0;
my $geoMatch = 0;
my $crimesMatch = 0;
my $statsMatch = 0;
my $geoCounter = 0;
my $crimeCounter = 0;
my $statcounter = 0;
my $eYearGood = 0;
my $sYearGood = 0;
my $syearUsrInput;
my $eyearUsrInput;
my $userInput;
my $outputType;
my $outputGood = 0;


#   Ian Bennett Searching Program
#   To Be Done:
#           Test if decimals are accurate
#           Link with recieving function

open($fileHandle, '<', $geofileName) or die "nope.avi";
while($line = <$fileHandle>){
    chomp $line;
    @lineArray = split(/\n/, $line);
    $i++;
    push(@geoLocations, @lineArray);
}
close $fileHandle;

$k = 0;
do {
    
    print "Print list of all valid geo locations? [YES/NO(ANYTHING OTHER THAN \"YES\")]: " or die "failed ot print\n";
    $userInput = <STDIN>;
    chomp $userInput;
    if ($userInput eq "YES"){
        print "(1) $geoLocations[0] ";
        foreach my $x (2.. $#geoLocations){
            print "($x) $geoLocations[$x] " or die "failed to print region list\n";
            $k++;
            if ($k >= 5){
                $k = 0;
                print "\n\n";
            }
        }
        
        print "\n";
    }
    
    print "\nEnter a location (Full Name): ";
    $userInput = <STDIN>;
    chomp $userInput;
    
    for $counter (0..$i - 1)
    {
        if ($userInput eq $geoLocations[$counter])
        {
            #
            # printi "MATCH!!!\n";
            #
            $geoMatch = 1;
            $geoCounter = $counter + 1;
        }
    }
    
    #system "clear";
    
    if ($geoMatch != 1){
        print "\n---->Failed to find a $userInput, Please enter a valid region<----\n\n" or die "failed to print\n";
    } else {
        print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n";
    }
    
} while ($geoMatch == 0);


if ($geoMatch == 1) {
    $counter = 0;
    open($crimesFileHandle, '<', $crimefileName) or die "nopecrimes.avi";
    while($crimesLine = <$crimesFileHandle>){
        chomp $crimesLine;
        @crimesLineArray = split(/\n/, $crimesLine);
        $j++;
        push(@crimesLocations, @crimesLineArray);
    }
    close $crimesFileHandle;
    
    do {
        
        print "Print list of all valid violations? [YES/NO(ANYTHING OTHER THAN \"YES\")]: " or die "failed ot print\n";
        $userInput = <STDIN>;
        chomp $userInput;
        if ($userInput eq "YES"){
            print "(1) $crimesLocations[0] ";
            foreach my $x (2.. $#crimesLocations){
                print "($x) $crimesLocations[$x] " or die "failed to print region list\n";
                $k++;
                if ($k >= 2){
                    $k = 0;
                    print "\n\n";
                }
            }
            
            print "\n";
        }
        
        
        print "\nEnter a violation: ";
        my $crimesUsrInput = <STDIN>;
        chomp $crimesUsrInput;
        
        for $counter (0..$j - 1)
        {
            if ($crimesUsrInput eq $crimesLocations[$counter])
            {
                #
                #print "CRIME MATCH!!!\n";
                #
                
                $crimesMatch = 1;
                $crimeCounter = $counter + 1;
            }
        }
        
        if ($crimesMatch != 1){
            print "\n---->Failed to find a $crimesUsrInput, Please enter a valid violation<----\n\n" or die "failed to print\n";
        } else {
            print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n";
        }
        
    } while($crimesMatch == 0);
    
}

if ($crimesMatch == 1) {
    
    $counter = 0;
    open($statsFileHandle, '<', $statsfileName) or die "nopestats.avi";
    while($statsLine = <$statsFileHandle>){
        chomp $statsLine;
        @statsLineArray = split(/\n/, $statsLine);
        $l++;
        push(@statsLocations, @statsLineArray);
    }
    close $statsFileHandle;
    
    do {
        
        print "Print list of all valid incident types? [YES/NO(ANYTHING OTHER THAN \"YES\")]: " or die "failed ot print\n";
        $userInput = <STDIN>;
        chomp $userInput;
        if ($userInput eq "YES"){
            print "(1) $statsLocations[0] ";
            foreach my $x (2.. $#statsLocations){
                print "($x) $statsLocations[$x] " or die "failed to print region list\n";
                $k++;
                if ($k >= 3){
                    $k = 0;
                    print "\n\n";
                }
            }
            print "\n";
        }
        
        print "\nEnter a statistic type: ";
        my $statsUsrInput = <STDIN>;
        chomp $statsUsrInput;
        
        for $counter (0..$l - 1)
        {
            if ($statsUsrInput eq $statsLocations[$counter])
            {
                #
                #print "STAT MATCH!!!\n";
                #
                $statsMatch = 1;
                $statcounter = $counter + 1;
            }
        }
        
        if ($statsMatch != 1){
            print "\n---->Failed to find a $statsUsrInput, Please enter a valid incident<----\n\n" or die "failed to print\n";
        } else {
            print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n";
        }
        
    } while ($statsMatch == 0);
    
}

if ($statsMatch == 1)
{
    do {
        print "Enter a starting year(1999 - 2015): ";
        $syearUsrInput = <STDIN>;
        chomp $syearUsrInput;
        
        if ($syearUsrInput >= 1999 && $syearUsrInput <= 2015)
        {
            $sYearGood = 1;
        }
        else
        {
            print "\nInvalid year entered, please enter a year within the range\n" or die "failed to print\n";
        }
    } while ($sYearGood == 0)
}

if ($sYearGood == 1)
{
    do {
        print "Enter an ending year(1999 - 2015): ";
        $eyearUsrInput = <STDIN>;
        chomp $eyearUsrInput;
        
        if ($eyearUsrInput >= 1999 && $eyearUsrInput <= 2015)
        {
            $eYearGood = 1;
        }
        else
        {
            print "\nInvalid year entered\n" or die "failed to print\n";
        }
    } while ($eYearGood == 0);
}

if ($eYearGood == 1)
{
    do {
        print "\nBar graph, Line graph, or Numerical\nSpecify output fromat: ";
        $userInput = <STDIN>;
        chomp $userInput;
        
        if ($userInput eq "Bar graph")
        {
            $outputGood = 1;
            $outputType = 1;
        }
        elsif ($userInput eq "Line graph")
        {
            $outputGood = 1;
            $outputType = 2;
        }
        elsif ($userInput eq "Numerical")
        {
            $outputGood = 1;
            $outputType = 3;
        }
        else
        {
            print "\nInvalid output format\n" or die "failed to print\n";
        }
    } while ($outputGood == 0);
}

if ($outputGood == 1)
{
    print "*$geoCounter.$crimeCounter.$statcounter.$outputType $syearUsrInput - $eyearUsrInput*\n";
}

#
#   END OF SCRIPT
#
