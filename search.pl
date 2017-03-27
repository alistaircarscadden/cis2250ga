#!/usr/bin/perl
use strict;
use warnings;

my $geofileName = "geo_locations_good.txt";
my $crimefileName = "crime_type_good.txt";
my $statsfileName = "stat_type_good.txt";
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

#Ian Bennett Searching Program
#To Be Done:
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

do {

  print "Enter a location: ";
  my $usrInput = <STDIN>;
  chomp $usrInput;

  for $counter (0..$i - 1)
  {
      if ($usrInput eq $geoLocations[$counter])
      {
          print "MATCH!!!\n";
          $geoMatch = 1;
          $geoCounter = $counter + 1;
        }
        else
        {
          print "no match\n";
        }
  }
} while ($geoMatch == 0);


if ($geoMatch == 1)
{
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

    print "Enter a violation: ";
    my $crimesUsrInput = <STDIN>;
    chomp $crimesUsrInput;

    for $counter (0..$j - 1)
    {
        if ($crimesUsrInput eq $crimesLocations[$counter])
        {
            print "CRIME MATCH!!!\n";
            $crimesMatch = 1;
            $crimeCounter = $counter + 1;
          }
          else
          {
            print "no match\n";
          }
        }
      } while($crimesMatch == 0);

}

if ($crimesMatch == 1)
{

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

    print "Enter a statistic type: ";
    my $statsUsrInput = <STDIN>;
    chomp $statsUsrInput;

    for $counter (0..$k - 1)
    {
        if ($statsUsrInput eq $statsLocations[$counter])
        {
            print "STAT MATCH!!!\n";
            $statsMatch = 1;
            $statcounter = $counter + 1;
        }
        else
        {
          print "no match\n";
        }
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
        $sYearGood = 1
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
        $eYearGood = 1
      }
    } while ($eYearGood == 0)
}

if ($eYearGood == 1)
{
  print "*$geoCounter.$crimeCounter.$statcounter $syearUsrInput - $eyearUsrInput*\n";
}
