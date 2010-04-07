#! /export/home/dwaldhei/bin/perl5.6.1 -w

use strict;

use Team;

main();

sub main
{
   my $t = Team::generate(1);
#    $t->dump();

   $t->save("Rockies");

   my $t2 = Team::load("Rockies");
   $t2->dump();
}
