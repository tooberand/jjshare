use strict;

use Team;

#----------------------
package Game;
#----------------------

sub new
{
   my ($package, $visitor, $home) = @_;
   my $self = bless {}, $package;
   
   $self->{visitor} = Team::load($visitor);
   $self->{home} = Team::load($home);
   $self->{visitor}->setup_game();
   $self->{home}->setup_game();

   ($self->{visitor} && $self->{home}) ? $self : undef
}

sub play_ball
{
   my ($self) = @_;

   for (my $i = 1;
        $i <= 9 || $self->{visitor}{score} == $self->{home}{score};
        ++$i)
   {
      $self->play_inning($i);
   }

   print "Visitors: $self->{visitor}{score} Home: $self->{home}{score}\n";
}

sub play_inning
{
   my ($self, $inning) = @_;
   
   $self->play_half_inning($self->{visitor}, $self->{home});
   if ($inning < 9 || $self->{home}{score} <= $self->{visitor}{score})
   {
      $self->play_half_inning($self->{home}, $self->{visitor});
   }
   print "End of inning $inning\n";
}

sub play_half_inning
{
   my ($self, $hitting, $pitching) = @_;

   print "Pitching: " . $pitching->current_pitcher()->name() . "\n";

   my $runs = 0;
   my $outs = 0;
   $self->{bases} = [];

   while ($outs < 3)
   {
      my ($ab_runs, $ab_outs) = 
         $self->at_bat($hitting->next_batter(), $pitching->current_pitcher());
      $hitting->{score} += $ab_runs;
      $outs += $ab_outs;
   }
   print "End of half inning\n";
}

sub at_bat
{
   my ($self, $batter, $pitcher) = @_;

   my $runs = 0;
   my $outs = 0;

   my $chance = ($batter->{attrs}{avg} + $pitcher->{attrs}{oavg}) / 2;

   if (rand() * 1000 < $chance)
   {
      # Batter gets AB and H
      ++$batter->{game}{ab};
      ++$batter->{game}{h};
      print "Hit: " . $batter->game_stats() . "\n";
      $runs = $self->run_bases($batter);
   }
   else
   {
      # Batter gets AB
      ++$batter->{game}{ab};
      print "Out: " . $batter->game_stats() . "\n";
      ++$outs;
   }

   $runs, $outs
}

sub run_bases
{
   my ($self, $batter) = @_;

   my $runs = 0;

   if (unshift(@{$self->{bases}}, $batter) > 3)
   {
      my $scorer = pop(@{$self->{bases}});
      # Batter gets RBI, Runner gets R
      print "Score: " . $scorer->name() . "\n";
      ++$runs;
   }

   $runs
}

1;

__END__

=head1 NAME

Game - Game object

=head1 SYNOPSIS

   use Game;
   my $t = Game->new($visitor, $home);

=head1 DESCRIPTION

The C<Game> perl module will be the closest thing to a professional
baseball game that you will ever get.

=head1 METHODS

=over 8

=item I<new>

Accepts two parameters and creates a C<Game>.  The first parameter is
the visting team name and the second parameter is the home team name.

=back

=head1 SEE ALSO

the C<Team> manpage, the C<Player> manpage

=head1 AUTHOR

Tooberand Magillicutty.

=cut
