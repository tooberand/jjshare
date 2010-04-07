use strict;

use Storable;

use Player;

#----------------------
package Team;
#----------------------

my $roster_def = { 'P' => 11,
                   'C' => 2,
                   '1B' => 1,
                   '2B' => 1,
                   'SS' => 1,
                   '3B' => 1,
                   'IF' => 3,
                   'OF' => 5 };

sub new
{
   my ($package) = @_;
   my $self = bless {}, $package;
   
   $self
}

sub setup_game
{
   my ($self) = @_;

   $self->{lineup_point} = 0;
   $self->{current_pitcher} = pop(@{$self->{rotation}});
   unshift(@{$self->{rotation}}, $self->{current_pitcher});
}

sub current_pitcher
{
   my ($self) = @_;

   $self->{current_pitcher}
}

sub next_batter
{
   my ($self) = @_;

   my $nb;

   if ($self->{lineup_point} > 7)
   {
      $nb = $self->current_pitcher();
      $self->{lineup_point} = 0;
   }
   else
   {
      $nb = $self->{lineup}[$self->{lineup_point}++];
   }

   $nb
}

sub generate
{
   my ($name_query) = @_;

   my $t = Team->new();

   # Generate roster
   foreach my $pos (keys %$roster_def)
   {
      for (my $i = 0; $i < $roster_def->{$pos}; ++$i)
      {
         my $p = Player::generate($pos);
         push(@{$t->{roster}{$p->{attrs}{pos}}}, $p);
         if ($name_query)
         {
            print "Player name for $pos: ";
            my $name = <STDIN>;
            chomp $name;
            $p->{attrs}{name} = $name;
         }
      }
   }

   # Define initial lineup
   push(@{$t->{lineup}}, $t->{roster}{'OF'}[0]);
   push(@{$t->{lineup}}, $t->{roster}{'OF'}[1]);
   push(@{$t->{lineup}}, $t->{roster}{'OF'}[2]);
   push(@{$t->{lineup}}, $t->{roster}{'1B'}[0]);
   push(@{$t->{lineup}}, $t->{roster}{'2B'}[0]);
   push(@{$t->{lineup}}, $t->{roster}{'3B'}[0]);
   push(@{$t->{lineup}}, $t->{roster}{'C'}[0]);
   push(@{$t->{lineup}}, $t->{roster}{'SS'}[0]);

   # Define initial rotation
   push(@{$t->{rotation}}, $t->{roster}{'P'}[0]);
   push(@{$t->{rotation}}, $t->{roster}{'P'}[1]);
   push(@{$t->{rotation}}, $t->{roster}{'P'}[2]);
   push(@{$t->{rotation}}, $t->{roster}{'P'}[3]);
   push(@{$t->{rotation}}, $t->{roster}{'P'}[4]);

   $t
}

sub save
{
   my ($self, $team_name) = @_;

   Storable::store($self, "data/$team_name.dat");
}

sub load
{
   my ($team_name) = @_;

   Storable::retrieve("data/$team_name.dat");
}

sub dump
{
   my ($self) = @_;

   foreach my $pos (keys %{$self->{roster}})
   {
      print "\nPlayers at $pos:\n----------------------\n";
      for (my $i = 0; $i < scalar(@{$self->{roster}{$pos}}); ++$i)
      {
         my $p = $self->{roster}{$pos}[$i];
         $p->dump();
      }
   }

   print "\nLineup\n----------------------\n";
   foreach my $p (@{$self->{lineup}})
   {
      print $p->name() . "\n";
   }

   print "\nRotation\n----------------------\n";
   foreach my $p (@{$self->{rotation}})
   {
      print $p->name() . "\n";
   }
}

1;

__END__

=head1 NAME

Team - Team object

=head1 SYNOPSIS

   use Team;
   my $t = Team->new();

=head1 DESCRIPTION

The C<Team> perl module will be the closest thing to a professional
baseball team that you will ever get.

=head2 Roster

 11 Pitchers
  2 Catchers
  1 First Baseman
  1 Second Baseman
  1 Short Stop
  1 Third Baseman
  3 Utility Infielders
  5 Outfielders

=head1 METHODS

=over 8

=item I<new>

Accepts no parameters and creates a C<Team>.

=item I<generate>

Creates a C<Team> of C<Player>s with randomized abilities and zero
game stats.

=back

=head1 SEE ALSO

the C<Game> manpage, the C<Player> manpage

=head1 AUTHOR

Tooberand Magillicutty.

=cut
