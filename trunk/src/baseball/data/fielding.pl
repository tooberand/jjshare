#! /usr/local/bin/perl -w

use strict;

main();

sub main
{
   my %totals;
   my %averages;
   my %medians = get_medians();

   open(FH, "<fielding.avg");

   # ignore first line
   <FH>;

   while (<FH>)
   {
      # ignore name
      my $stats = <FH>;
      
      # A - Assists
      # CS - Caught Stealing
      # DP - Double Plays
      # E - Errors
      # FPCT - Fielding Percentage
      # G - Games Played
      # INN - Innings Played
      # OFA - Outfield Assists
      # PB - Passed Balls
      # PO - Putouts
      # SB - Stolen Bases (allowed)
      # TC - Total Chances
      # TP - Triple Plays
      my ($team, $pos, $g, $gs, $inn, $tc, $po, $a, $e, $dp, $pb, $sb, $cs) = 
         split(/\s+/, $stats);
      
      $totals{$pos}{inn} += $inn;
      $totals{$pos}{tc} += $tc;
      $totals{$pos}{po} += $po;
      $totals{$pos}{a} += $a;
      $totals{$pos}{e} += $e;
      $totals{$pos}{dp} += $dp;
      $totals{$pos}{pb} += ($pb eq "---") ? 0 : $pb;
      $totals{$pos}{sb} += ($sb eq "---") ? 0 : $sb;
      $totals{$pos}{cs} += ($cs eq "---") ? 0 : $cs;
      
      if ($tc >= $medians{$pos}{tc})
      {
         push(@{$averages{$pos}{fpct}}, ($tc - $e) / $tc);
      }
   }
   close FH;

   print "my \$fpct_seed = {\n";
   foreach my $pos (keys %totals)
   {
      my $fpct = ($totals{$pos}{tc} - $totals{$pos}{e}) / $totals{$pos}{tc};
      my $ad = statistics($averages{$pos}{fpct})->[2];
      print "                 \'$pos\' => [" . int(1000 * $fpct) . ", "
         . int(1000 * $ad) . "],\n";
   }
   print "                };\n";
}

sub get_medians
{
   open(FH, "<fielding.avg");

   my %totals;
   my %medians;

   # ignore first line
   <FH>;

   while (<FH>)
   {
      # ignore name
      my $stats = <FH>;
      
      my ($team, $pos, $g, $gs, $inn, $tc, $po, $a, $e, $dp, $pb, $sb, $cs) = 
         split(/\s+/, $stats);
      
      push(@{$totals{$pos}{tc}}, $tc);
   }
   close FH;
   
   foreach my $pos (keys %totals)
   {
      $medians{$pos}{tc} = statistics($totals{$pos}{tc})->[0];
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
