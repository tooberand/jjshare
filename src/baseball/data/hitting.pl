#! /usr/local/bin/perl -w

use strict;

main();

sub main
{
   my %totals;
   my %averages;
   my %medians = get_medians();

   open(FH, "<hitting.avg");

   # ignore first line
   <FH>;

   while (<FH>)
   {
      # ignore name
      my $stats = <FH>;

      # 2B - Doubles
      # 3B - Triples
      # AB - At Bats
      # AB/GIDP- At-Bats per Grounded Into Double Play
      # AB/HR- At-Bats per Home Run
      # AB/RBI- At-Bats per Runs Batted In
      # AO- Fly Outs
      # AVG - Batting Average
      # BB - Bases on Balls (Walks)
      # CS - Caught Stealing
      # G - Games Played
      # GIDP - Ground into Double Plays
      # GO - Ground Outs
      # GO/AO- Ground Outs/Fly Outs
      # GSH - Grand Slam Home Runs
      # H - Hits
      # HBP - Hit by Pitch
      # HR - Home Runs
      # IBB - Intentional Walks
      # LIPS- Late Inning Pressure Situations
      # LOB - Left On Base
      # NP- Number of Pitches
      # OBP - On-base Percentage
      # OPS - On-base Plus Slugging Percentage
      # PA/SO - Plate Appearances per Strikeout
      # R - Runs Scored
      # RBI - Runs Batted In
      # SAC - Sacrifice Bunts
      # SB% - Stolen Base Percentage
      # SB - Stolen Bases
      # SF - Sacrifice Flies
      # SLG - Slugging Percentage
      # SO - Strikeouts
      # TB - Total Bases
      # TP- Triple Play
      # TPA- Total Plate Appearances
      # XBH- Extra Base Hits
      my ($team, $pos, $g, $ab, $r, $h, $b2, $b3, $hr, $rbi, $tb, $bb, $so, $sb,
          $cs, $obp, $slg, $avg) = split(/\s+/, $stats);
      
      $totals{$pos}{ab} += $ab;
      $totals{$pos}{h} += $h;
#       $totals{$pos}{po} += $po;
#       $totals{$pos}{a} += $a;
#       $totals{$pos}{e} += $e;
#       $totals{$pos}{dp} += $dp;
#       $totals{$pos}{pb} += ($pb eq "---") ? 0 : $pb;
#       $totals{$pos}{sb} += ($sb eq "---") ? 0 : $sb;
#       $totals{$pos}{cs} += ($cs eq "---") ? 0 : $cs;
      
      if ($ab >= $medians{$pos}{ab})
      {
         push(@{$averages{$pos}{avg}}, $h / $ab);
      }
   }
   close FH;

   print "my \$avg_seed = {\n";
   foreach my $pos (keys %totals)
   {
      my $avg = $totals{$pos}{h} / $totals{$pos}{ab};
      my $ad = statistics($averages{$pos}{avg})->[2];
      print "                \'$pos\' => [" . int(1000 * $avg) . ", "
         . int(1000 * $ad) . "],\n";
   }
   print "               };\n";
}

sub get_medians
{
   open(FH, "<hitting.avg");

   my %totals;
   my %medians;

   # ignore first line
   <FH>;

   while (<FH>)
   {
      # ignore name
      my $stats = <FH>;
      
      my ($team, $pos, $g, $ab, $r, $h, $b2, $b3, $hr, $rbi, $tb, $bb, $so, $sb,
          $cs, $obp, $slg, $avg) = split(/\s+/, $stats);
      
      push(@{$totals{$pos}{ab}}, $ab);
   }
   close FH;
   
   foreach my $pos (keys %totals)
   {
      $medians{$pos}{ab} = statistics($totals{$pos}{ab})->[0];
   }

   %medians
}

sub statistics
{
   my ($array) = @_;

   my $sum = 0;
   my @nums = @$array;
   foreach (@nums) { $sum += $_ }
   my $n = scalar(@nums);
   my $mean = $sum/$n;
   my $average_deviation = 0;
   my $standard_deviation = 0;
   my $variance = 0;
   my $skew = 0;
   my $kurtosis = 0;
   foreach (@nums)
   {
      my $deviation = $_ - $mean;
      $average_deviation += abs($deviation);
      $variance += $deviation**2;
      $skew += $deviation**3;
      $kurtosis += $deviation**4;
   }
   $average_deviation /= $n;
   $variance /= ($n - 1);
   $standard_deviation = sqrt($variance);

   if ($variance)
   {
      $skew /= ($n * $variance * $standard_deviation);
      $kurtosis = $kurtosis/($n * $variance * $variance) - 3.0;
   }

   @nums = sort { $a <=> $b } @nums;
   my $mid = int($n/2);
   my $median = ($n % 2) ? $nums[$mid] : ($nums[$mid] + $nums[$mid-1])/2;

#    print "n:                  $n\n";
#    print "median:             $median\n";
#    print "mean:               $mean\n";
#    print "average_deviation:  $average_deviation\n";
#    print "standard_deviation: $standard_deviation\n";
#    print "variance:           $variance\n";
#    print "skew:               $skew\n";
#    print "kurtosis:           $kurtosis\n";

   [$median, $mean, $average_deviation, $standard_deviation]
}
