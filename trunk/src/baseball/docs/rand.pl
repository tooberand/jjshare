#! /usr/local/bin/perl -w

use strict;

main2();

sub main
{
   my $sum = 0;
   my $i;
   my %dist;
   for ($i = 0; $i < 1000; ++$i)
   {
#       my $n = gaussian_rand();
      my $n = sweeney_rand();
      $n = int($n * 1000);
#       print "$n\n";
      $sum += $n;
      $dist{$n}++;
   }
   my $threes = 0;
   foreach my $key (sort {$a <=> $b} keys %dist)
   {
      printf("%4s:", $key);
#       printf("%4s: %d", $key, $dist{$key});
      for (my $c = 0; $c < $dist{$key}; ++$c)
      {
         print ".";
      }
      print "\n";
      if ($key > 300 || $key < -300)
      {
         $threes += $dist{$key};
      }
   }
   print "average = " . ($sum / $i) . "\n";
   print "outside threes = $threes\n";
}

sub main2
{
   print "fielding % = " . stat_rand(987, 12) . "\n";
}

sub stat_rand
{
   my ($mean, $deviation) = @_;

#    $mean + int($deviation * (gaussian_rand() / 3))
   $mean + int($deviation * sweeney_rand())
}

sub gaussian_rand
{
   my ($u1, $u2);  # uniformly distributed random numbers
   my $w;          # variance, then a weight

   do
   {
      # Generate two random numbers from -1 to 1
      $u1 = 2 * rand() - 1;
      $u2 = 2 * rand() - 1;
      $w = $u1*$u1 + $u2*$u2;
   } while ($w == 0 || $w >= 1); # Disallow 0 to prevent divide by zero error

   $w = sqrt((-2 * log($w)) / $w);

   $u2 * $w
}

sub sweeney_rand
{
   my $s = 0;
   my $iterations = 10;
   for (my $i = 0; $i < $iterations; ++$i)
   {
      $s += 2 * rand() - 1;
   }
   $s / $iterations
}
