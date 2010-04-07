use strict;

#----------------------
package Player;
#----------------------

my $fpct_seed = {
                 'P' => [961, 45],
                 'C' => [991, 3],
                 '1B' => [992, 6],
                 '2B' => [980, 8],
                 '3B' => [956, 26],
                 'OF' => [983, 9],
                 'SS' => [970, 10],
                };

my $avg_seed = {
                'P' => [153, 64],
                'C' => [250, 28],
                '1B' => [267, 20],
                '2B' => [271, 24],
                '3B' => [257, 23],
                'OF' => [270, 25],
                'SS' => [255, 18],
               };

my $oavg_seed = {
                 'P' => [243, 25],
                };

sub new
{
   my ($package) = @_;
   my $self = bless {}, $package;
   
   $self
}

sub game_stats
{
   my ($self) = @_;

   $self->name() . " (" . ($self->{game}{h} || 0) . " - "
      . ($self->{game}{ab} || 0) . ")"
}

sub name
{
   my ($self) = @_;

   $self->{attrs}{name}
}

sub generate
{
   my ($pos) = @_;

   my $p = new Player;

   if ($pos eq "IF")
   {
      $pos = (qw"1B 2B SS 3B")[rand 4];
   }

   $p->{attrs}{pos} = $pos;
   $p->{attrs}{fpct} =
      stat_rand($fpct_seed->{$pos}[0], $fpct_seed->{$pos}[1]);
   $p->{attrs}{avg} =
      stat_rand($avg_seed->{$pos}[0], $avg_seed->{$pos}[1]);
   if ($pos eq "P")
   {
      $p->{attrs}{oavg} =
         stat_rand($oavg_seed->{$pos}[0], $oavg_seed->{$pos}[1]);
   }

   $p
}

sub dump
{
   my ($self) = @_;

   foreach my $attr (keys %{$self->{attrs}})
   {
      print "$attr = $self->{attrs}{$attr}\n";
   }
}

sub stat_rand
{
   my ($mean, $deviation) = @_;

   $mean + int($deviation * (gaussian_rand() / 3))
#    $mean + int($deviation * sweeney_rand())
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
   my $iterations = 12;
   for (my $i = 0; $i < $iterations; ++$i)
   {
      $s += 2 * rand() - 1;
   }
   $s / $iterations
}

1;

__END__

=head1 NAME

Player - Player object

=head1 SYNOPSIS

   use Player;
   my $p = Player->new();

=head1 DESCRIPTION

The C<Player> perl module will be the closest thing to a professional
baseball player that you will ever get.

=head2 Statistics

 Hitting:
   Hit average: Chance of batter getting a hit
   Power average: Chance of batter sac flying or extra base hit
   Walk average: Chance of batter walking
   Strikeout average: Chance of batter striking out
   Speed: Chance of batter stealing a base (and stretching a 2B to a 3B)
 Fielding:
   Fielding percentage: Chance of fielding cleanly (positional based)
 Pitching:
   Hit average: Chance of batter getting a hit
   Power average: Chance of batter sac flying or extra base hit
   Walk average: Chance of batter walking
   Strikeout average: Chance of batter striking out
   Control: Chance of throwing wild pitch
   Endurance: Ability of pitcher to hold stats over multiple innings
 Overall:
   MOB Factor: Multiplier for stats with men on base
   MISP Factor: Multiplier for stats with men in scoring position
   Slug Fest Factor: Multiplier for stats when team is getting pounded

=head1 METHODS

=over 8

=item I<new>

Accepts no parameters and creates a C<Player>.

=item I<generate>

Accepts a positional parameter and creates a C<Player> with randomized
abilities and zero game stats.

=back

=head1 SEE ALSO

the C<Game> manpage, the C<Team> manpage

=head1 AUTHOR

Tooberand Magillicutty.

=cut
