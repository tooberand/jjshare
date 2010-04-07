#! /export/home/dwaldhei/bin/perl5.6.1 -w

use strict;

use Game;

main();

sub main
{
   my $g = Game->new("Rockies", "Astros");

   $g->play_ball();
}
