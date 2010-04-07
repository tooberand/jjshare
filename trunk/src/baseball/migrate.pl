#! /export/home/dwaldhei/bin/perl5.6.1 -w

use strict;

use Team;

main();

sub main
{
   my $name = shift @ARGV;
   my $t = Team::load($name);

   foreach my $pos (keys %{$t->{roster}})
   {
      for (my $i = 0; $i < scalar(@{$t->{roster}{$pos}}); ++$i)
      {
         my $p = $t->{roster}{$pos}[$i];
#          $p->{attrs} = $p->{attributes};
#          delete $p->{attributes};
      }
   }
   
   # Define initial lineup
   $t->{lineup} = [];
   push(@{$t->{lineup}}, $t->{roster}{'OF'}[0]);
   push(@{$t->{lineup}}, $t->{roster}{'OF'}[1]);
   push(@{$t->{lineup}}, $t->{roster}{'OF'}[2]);
   push(@{$t->{lineup}}, $t->{roster}{'1B'}[0]);
   push(@{$t->{lineup}}, $t->{roster}{'2B'}[0]);
   push(@{$t->{lineup}}, $t->{roster}{'3B'}[0]);
   push(@{$t->{lineup}}, $t->{roster}{'C'}[0]);
   push(@{$t->{lineup}}, $t->{roster}{'SS'}[0]);

   # Define initial rotation
   $t->{rotation} = [];
   push(@{$t->{rotation}}, $t->{roster}{'P'}[0]);
   push(@{$t->{rotation}}, $t->{roster}{'P'}[1]);
   push(@{$t->{rotation}}, $t->{roster}{'P'}[2]);
   push(@{$t->{rotation}}, $t->{roster}{'P'}[3]);
   push(@{$t->{rotation}}, $t->{roster}{'P'}[4]);

   $t->dump();
   $t->save($name);
}
