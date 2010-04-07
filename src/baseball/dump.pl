#! /export/home/dwaldhei/bin/perl5.6.1 -w

use strict;

use Team;

main();

sub main
{
   my $name = shift @ARGV;
   my $t = Team::load($name);
   $t->dump();
}
