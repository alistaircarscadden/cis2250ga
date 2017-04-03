#!/usr/bin/perl
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);

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

#
#   Authors: Ian Bennett, Ozair Ashfaq
#
#   To Be Done:
#           Test if decimals are accurate
#           Link with recieving function
#

$queryType[0] = "Comparison";
$queryType[1] = "Trend";
$queryType[2] = "Direct Search";
$queryType[3] = "Highest Magnitude";
$queryType[4] = "Lowest Magnitude";

print "\n|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|\n" or die "print failed\n";
print "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MAIN INTERFACE - CRIME CENSUS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|\n" or die "print failed\n";
print "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|\n\n" or die "print failed\n";

do{
   print "What type of search do you wish?\n(1) $queryType[0] | (2) $queryType[1] | (3) $queryType[2]\n" or die "print failed\n";
   print "Action: ";
   $userInput = <STDIN>;
   chomp $userInput;

   if($userInput eq "1" || $userInput eq "2" || $userInput eq "3"){
      $queryFound = 1;
      $query = $userInput - 1;
   }else{
      print "Invalid Input!\n";
      $queryFound = 0;
   }

}while($queryFound != 1);

open($fileHandle, '<', $geofileName) or die "nope.avi";
while($line = <$fileHandle>){
    chomp $line;
    @lineArray = split(/\n/, $line);
    $i++;
    push(@geoLocations, @lineArray);
}
close $fileHandle;

$k = 0;
my $temp = 0;

do {
   do{
      print "Print list of all valid geo locations? [YES/NO]: " or die "failed ot print\n";
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
         print "Invalid Input!\n";
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
         print "\n$queryType[$query] for $geoLocations[$geo1]";
      }else{
         print "\n$queryType[$query] between $geoLocations[$geo1] and $geoLocations[$geo2]";
      }
      print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n";
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

      do {
         print "Print list of all valid violations? [YES/NO]: " or die "failed ot print\n";
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
            print "\n";
         } elsif (uc($userInput) eq "NO"){
         } else {
            print "Invalid Input!\n";
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
         print "\n$queryType[$query] for $crimesLocations[$crimeCounter]";
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
      $k++;
      push(@statsLocations, @statsLineArray);
    }
   close $statsFileHandle;

    do {
        do {
            print "Print list of all valid incident types? [YES/NO]: " or die "failed to print\n";
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
                print "Invalid Input!\n";
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
            print "\n$queryType[$query] for $statsLocations[$statCounter]";
            print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n";
        }
    } while ($statsMatch == 0);
}

$syearUsrInput = -1;
$eyearUsrInput = -1;

if ($statsMatch == 1){
    do {
        print "Enter a starting year(1998 - 2015): ";
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
            print "Enter an ending year(IMPORTANT: $syearUsrInput - 2015): ";
            $eyearUsrInput = <STDIN>;
            chomp $eyearUsrInput;

            if (looks_like_number($syearUsrInput) && $eyearUsrInput >= $syearUsrInput && $eyearUsrInput <= 2015)
            {
                $eYearGood = 1
            }
            else
            {
                print "\nInvalid year entered\n" or die "failed to print\n";
            }
        } while ($eYearGood == 0);
    }
}

print "\n|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|\n" or die "print failed\n";

if($query == 1){
    print "\nThe program will now search for a $queryType[$query] for $geoLocations[$geo1] --> $crimesLocations[$crimeCounter] --> $statsLocations[$statCounter]"
      ." for the year range of $syearUsrInput to $eyearUsrInput\n\n";
    
} elsif($query == 2){
    print "\nThe program will now do a $queryType[$query] for $geoLocations[$geo1] --> $crimesLocations[$crimeCounter] --> $statsLocations[$statCounter]"
    ." for the year $syearUsrInput\n\n";
    
} elsif($query == 0){
    print "\nThe program will now do a $queryType[$query] between $geoLocations[$geo1] And $geoLocations[$geo2] --> $crimesLocations[$crimeCounter] --> $statsLocations[$statCounter]"
    ." for the year $syearUsrInput\n";
}

print "|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|\n" or die "print failed\n";

print "\nThe coordinates for the search are: $query,$geo1,$crimeCounter,$statCounter,$geo2,$syearUsrInput,$eyearUsrInput\n";

#
#   END OF SCRIPT
#
