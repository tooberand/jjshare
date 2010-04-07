#! /usr/local/bin/perl -w

use strict;

my $pos = "P";

main();

sub main
{
   my %totals;
   my %averages;
   my %medians = get_medians();

   open(FH, "<pitching.avg");

   # ignore first line
   <FH>;

   while (<FH>)
   {
      # ignore name
      my $stats = <FH>;

      # AO  - Fly Outs
      # APP - Appearances
      # AVG - Opponents Batting Average
      # BB - Bases on Balls (Walks)
      # BB/9 - Walks per Nine Innings
      # BK - Balks
      # CG - Complete Games
      # CGL - Complete Game Losses
      # CS - Caught Stealing
      # ER - Earned Runs
      # ERA - Earned Run Average
      # G - Games Played
      # GF - Games Finished
      # GIDP - Grounded Into Double Plays
      # GO - Ground Outs
      # GO/AO - Ground Outs/ Fly Outs Ratio
      # GS - Games Started
      # GSH - Grand Slams
      # H - Hits
      # H/9 - Hits per Nine Innings
      # HB - Hit Batsmen
      # HLD - Hold
      # HR - Home Runs
      # I/GS - Innings Per Games Started
      # IBB - Intentional Walks
      # IP - Innings Pitched
      # IRA - Inherited Runs Allowed
      # K/9 - Strikeouts per Nine Innings
      # K/BB - Strikeout/Walk Ratio
      # L - Losses
      # LIPS - Late Inning Pressure Situations
      # LOB - Left on Base
      # MB/9 - Baserunners per 9 Innings
      # NP - Number of Pitches Thrown
      # OBA - On-base Against
      # PA - Plate Appearances
      # P/GS - Pitches per Start
      # P/IP - Pitches per Innings Pitched
      # PK - Pick-offs
      # R - Runs
      # RW - Relief Wins
      # SB- Stolen Bases
      # SHO - Shutouts
      # SLG - Slugging Percentage Allowed
      # SO - Strikeouts
      # SV - Saves
      # SVO - Save Opportunities
      # TB - Total Bases
      # TBF - Total Batters Faced
      # TP - Triple Plays
      # UER - Unearned Runs
      # W - Wins
      # WHIP - Walks + Hits/Innings Pitched
      # WP - Wild Pitches
      # WPCT - Winning Percentage
      # XBA - Extra Base Hits Allowed
      my ($team, $w, $l, $era, $g, $gs, $cg, $sho, $sv, $svo, $ip, $h, $r, $er,
          $hr, $hbp, $bb, $so) = split(/\s+/, $stats);
      
      if ($ip >= $medians{$pos}{ip})
      {
         $totals{$pos}{ip} += $ip;
         $totals{$pos}{h} += $h;
         $totals{$pos}{w} += $w;
         $totals{$pos}{so} += $so;
         $totals{$pos}{er} += $er;
      
         push(@{$averages{$pos}{era}}, $era);
         push(@{$averages{$pos}{oavg}}, $h / ($ip * 3 + $h));
         push(@{$averages{$pos}{oba}}, ($h + $w) / ($ip * 3 + $h));
         push(@{$averages{$pos}{soa}}, ($so) / ($ip * 3 + $h));
      }
   }
   close FH;
   
   print "my \$era_seed = {\n";
   foreach my $pos (keys %totals)
   {
      my $era = $totals{$pos}{er} / ($totals{$pos}{ip} / 9);
      my $ad = statistics($averages{$pos}{era})->[2];
      print "                \'$pos\' => [" . int($era * 1000) . ", "
         . int($ad * 1000) . "],\n";
   }
   print "               };\n";

   print "my \$oavg_seed = {\n";
   foreach my $pos (keys %totals)
   {
      my $oavg = $totals{$pos}{h} / ($totals{$pos}{ip} * 3 + $totals{$pos}{h});
      my $ad = statistics($averages{$pos}{oavg})->[2];
      print "                 \'$pos\' => [" . int($oavg * 1000) . ", "
         . int($ad * 1000) . "],\n";
   }
   print "                };\n";

   print "my \$oba_seed = {\n";
   foreach my $pos (keys %totals)
   {
      my $oba = ($totals{$pos}{h} + $totals{$pos}{w})
         / ($totals{$pos}{ip} * 3 + $totals{$pos}{h});
      my $ad = statistics($averages{$pos}{oba})->[2];
      print "                \'$pos\' => [" . int($oba * 1000) . ", "
         . int($ad * 1000) . "],\n";
   }
   print "               };\n";

   print "my \$soa_seed = {\n";
   foreach my $pos (keys %totals)
   {
      my $soa = $totals{$pos}{so} / ($totals{$pos}{ip} * 3 + $totals{$pos}{h});
      my $ad = statistics($averages{$pos}{soa})->[2];
      print "                \'$pos\' => [" . int($soa * 1000) . ", "
         . int($ad * 1000) . "],\n";
   }
   print "               };\n";
}

sub get_medians
{
   open(FH, "<pitching.avg");

   my %totals;
   my %medians;

   # ignore first line
   <FH>;

   while (<FH>)
   {
      # ignore name
      my $stats = <FH>;
      
      my ($team, $w, $l, $era, $g, $gs, $cg, $sho, $sv, $svo, $ip, $h, $r, $er,
          $hr, $hbp, $bb, $so) = split(/\s+/, $stats);
      
      push(@{$totals{$pos}{ip}}, $ip);
   }
   close FH;
   
   foreach my $pos (keys %totals)
   {
      $medians{$pos}{ip} = statistics($totals{$pos}{ip})->[0];
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
