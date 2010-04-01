#!/usr/bin/perl -w

=head1 NAME

fit.pl - Utility to process .fit files

=head1 SYNOPSIS

 fit.pl [-s] [-n] [-m] [-a] <.fit files>
 fit.pl [-g<year>]
 fit.pl [-d] <.fit file> <.fit file>

=head1 DESCRIPTION

 print fit info.

=head1 OPTIONS

 -a  aggregate report for multiple years
 -s  tabular monthly breakdown
 -v  detail report
 -m  monthly detail report
 -d  output diff information between two .fit files
 -g<year>  generate new empty .fit file for specified year

=head1 EXAMPLES

  fit.pl 2004.fit

shows monthly fit data

=cut

use strict;
use Getopt::Std;
use Carp;
$SIG{__DIE__} = \&confess;
$SIG{__WARN__} = \&confess;

main();

sub main
{
	my %opt;
	if (!getopts('dmsvag:h?', \%opt) || $opt{h} || $opt{'?'})
	{
		system("perldoc -t $0");
		exit 0;
	}

	generate_template($opt{g}) if ($opt{g});

	$opt{'s'} = 1 if ! keys %opt;

	if ($opt{v} || $opt{'s'} || $opt{'m'})
	{
		my $show_file_name = @ARGV > 1;
		while (my $file = shift @ARGV)
		{
			print "$file\n" if $show_file_name;
			my $fit = FitData->new($file);

			$fit->report_long('totals') if $opt{'v'};
			$fit->report_month_long() if $opt{'m'};
			$fit->report_month_short() if $opt{'s'};
		}
	}
	elsif ($opt{d})
	{
		my ($file1, $file2) = @ARGV;
		$file1 && $file2 || die "-d opt (diff) requires two .fit files\n";
		my $f1 = FitData->new($file1);
		my $f2 = FitData->new($file2);
		$f1->diff_fit_data($f2);
		$f1->report_month_short();
	}
	elsif ($opt{a})
	{
		report_multi_year();
	}
}

sub generate_template
{
	my ($year) = @_;

	$year =~ /\d{4}/ || die "bad -g=<dddd> option: $year\n";
	FitData::generate_template($year);
	exit(0);
}

sub report_multi_year
{
	my $tfit = bless {}, 'FitData';
	my @years;
	while (my $file = shift @ARGV)
	{
		my $fit = FitData->new($file);
		foreach my $mon (0..11)
		{
			my $b = $tfit->get_bucket($mon);
			$b->add_bucket($fit->get_bucket($mon));
		}
		push(@years, $fit->{year});
		my $h = $tfit->{_xmap} ||= {};
		while (my ($key, $desc) = each %{$fit->{_xmap}})
		{
			if ($h->{$key} && $h->{$key} ne $desc)
			{
				print "inconsistent key $key descs: '$h->{$key}' and '$desc'\n";
			}
			$h->{$key} = $desc;
		}
	}

	$tfit->{year} = $years[0] + @years - 1 == $years[-1]
		? "$years[0]-$years[-1]"
			: join(",", @years);

	$tfit->calc_totals();
	$tfit->calc_meta_data();
	$tfit->report_long('totals');
}

#====================
package FitData;
#====================
use FileHandle;
use Time::Local;

BEGIN
{
	my %month;
	my @months = (qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec));
	@month{map(lc $_, @months)} = (0..11);
	@month{(0..11)} = @months;
	sub month { $month{substr("\l$_[0]", 0, 3)}; }
}

sub dbg
{
	print @_ if $ENV{PDBG};
}

sub new
{
	my ($package, $file) = @_;
	my $self = bless {}, $package;
	$self->read_file($file);
	$self->calc_totals();
	$self->calc_meta_data();
	$self
}

sub read_file
{
	my ($self, $file) = @_;

	my $fh = new FileHandle("<$file") || die "cannot read $file\n";

	my $done = 0;
	my $current_date;
	my $in_legend = 0;
	my $year;
	my %xmap;
	my $line;
	while (defined($line = <$fh>))
	{
		if ($in_legend && $line =~ /\s*(\S)\s+(?:\S\s+)?(.*)/)
		{
			$self->add_xmap($1, $2);
			next;
		}

		if ($in_legend = $line =~ /LEGEND/)
		{
			$done = 1;
		}
		elsif ($line =~ /year: (\d+)/)
		{
			$year = $1;
			$self->{year} = $year;
		}
		elsif ($line =~ s/^(\w\w\w)\s*(\d+)\s*// && !$done)
		{
			my $month_text = $1;
			my $mday = $2;
			my $month = month($month_text);
			
			my $line_date = timegm(0,0,0,$mday,$month,$year-1900);
			if (defined $current_date && $month > 0 && $mday > 7)
			{
				$self->check_date($current_date, $line_date, $mday, $month_text);
			}
			else
			{
				$current_date = $line_date;
			}

			my @activities;
			my $description;
			$line =~ s/\t\t.*//;
			(@activities[0..6], $description) = split(/\s+/, $line, 8);

			dbg "num activities: ", scalar(@activities), "\n";
			my $one_day = 60 * 60 * 24;
			foreach my $day_act (@activities)
			{
				my $month = (gmtime($current_date))[4];
				my $b = $self->get_bucket($month);
				$b->add_activities($day_act);
				$current_date += $one_day;
				$done = !$day_act;
			}
		}
	}

	$self
}

sub add_xmap
{
	my ($self, $k, $v) = @_;
	$self->{_xmap}{$k} = $v;
}

sub calc_totals
{
	my ($self) = @_;
	my $b = $self->get_bucket(totals => $self->{year});
	foreach my $i (0..11)
	{
		$b->add_bucket($self->get_bucket($i));
	}
	$b->calc_meta_data();
}

sub get_bucket
{
	my ($self, $name, $when_name) = @_;
	$self->{_t}{$name} ||= FitBucket->new($when_name, $name);
}

sub check_date
{
	my ($self, $current_date, $line_date, $mday, $month_text) = @_;

	if ($current_date != $line_date)
	{
		my $c = gmtime($current_date);
		my $l = gmtime($line_date);
		print "current date: $current_date\n";
		print "line date:    $line_date\n";
		print "$c\n";
		print "$l\n";
		die "date spec problem: $mday $month_text";
	}
}

sub calc_meta_data
{
	my ($self) = @_;

	foreach my $i (0..11)
	{
		my $b = $self->get_bucket($i);
		$b->calc_meta_data() unless $b->is_empty();
	}
}

sub report_long
{
	my ($self, $when) = @_;
	my $t    = $self->get_bucket($when);
	return if $t->is_empty();
	my $xmap = $self->{_xmap};

	my $total = 0;
	my %breakdown;
	my @breakdown;
	my %d = %{$t->{detail}};
	foreach my $key (sort { $d{$b} <=> $d{$a} } keys(%d))
	{
		$xmap->{$key} || warn "WARNING: no description in legend for '$key'\n";
		push(@breakdown, fi($xmap->{$key} || $key, $d{$key}));
	}

	my @totals;
	push(@totals, fs("when",              $t->{when}));
	push(@totals, fi("days",              $t->{days}));
	push(@totals, fi("active days",       $t->{active_days}));
	push(@totals, fi("total workouts",    $t->{total_workouts}));
	push(@totals, fp("days per week",     $t->{days_per_week}));
	push(@totals, fp("workouts per week", $t->{workouts_per_week}));

	my $report = '';
	while (@totals || @breakdown)
	{
		$report .= sprintf("%-32s%-32s\n",
								 shift @totals || '',
								 shift @breakdown || '');
	}

	print $report;
}

sub fs { sprintf("%18s  %4s", @_) }
sub fi { sprintf("%18s  %4d", @_) }
sub fp { sprintf("%18s  %4.2f", @_) }

sub report_month_long
{
	my ($self) = @_;

	foreach my $i (0..11)
	{
		print "----------------------\n";
		$self->report_long($i);
	}
}

sub report_month_short
{
	my ($self) = @_;

	my $tb = $self->get_bucket('totals');
	my $d = $tb->{detail};
	my @detail_order = sort { abs($d->{$b}) <=> abs($d->{$a}) } keys(%$d);
	$tb->{when} = '';

	print "         dpw    wpw   num     ", join("  ", @detail_order), "\n";

	foreach my $i (0..11, 'totals')
	{
		$self->report_single_line($self->get_bucket($i), \@detail_order)
	}
}

sub report_single_line
{
	my ($self, $b, $detail_order) = @_;

	return if $b->is_empty();
	my $d = $b->{detail};
	my @detail;
	foreach my $key (@$detail_order)
	{
		push(@detail, sprintf("%3s", $d->{$key} || '.'));
	}
	
	my $line = sprintf("  %-4s %5.2f  %5.2f  %4d   %s",
							 $b->{when},
							 $b->{days_per_week},
							 $b->{workouts_per_week},
							 $b->{total_workouts},
							 join("", @detail));
	print "$line\n";
}

sub diff_fit_data
{
	my ($self, $f2) = @_;

	foreach my $i (0..11)
	{
		$self->get_bucket($i)->diff_bucket($f2->get_bucket($i));
	}
	$self->calc_totals();
}

sub generate_template
{
	my ($year) = @_;

	print "year: $year\n\n";
	print join("\t", "      ", qw(mon tue wed thu fri sat sun)), "\n";

	my $jan_one = timegm(0,0,0,1,0,$year-1900);
	my $next_year = timegm(0,0,0,1,0,$year-1900+1);
	my @jan_one = gmtime($jan_one);
	my $wday = $jan_one[6];
	# their week starts sunday, ours monday -- adjust it
	$wday = ($wday == 0) ? 6: $wday - 1;

	my $one_day  = 60 * 60 * 24;
	my $one_week = $one_day * 7;

	my ($mday, $month) = (gmtime($jan_one))[3,4];
	my $row_data = join("\t", ('_') x $wday, (' ') x (7 - $wday));
	printf("%s %02d\t%s\n", month($month), $mday, $row_data);
	
	my $date = $jan_one;
	$date += (7 - $wday) * $one_day;

	while ($date < $next_year)
	{
		my ($mday, $month) = (gmtime($date))[3,4];

		printf("%s %02d", month($month), $mday);

		for (0..6)
		{
			my $past_end_of_year = $month == 11 && $mday > 31;
			my $last_week_of_year = $month == 11 && $mday + 6 > 31;
			print "\t_" if $past_end_of_year;
			print "\t" if $last_week_of_year && !$past_end_of_year;
			++$mday;
		}
		print "\n";
		$date += $one_week;
	}

	print"
LEGEND
  r - road bike
  m - mountain bike
  h - hike
  v - volleyball
";
} 

#====================
package FitBucket;
#====================

sub new
{
	my ($package, $when_name, $month_num) = @_;
	my $self = bless {}, $package;
	$self->{days} = 0;
	$self->{active_days} = 0;
	$self->{detail} = {};
	$self->{when} = $when_name || FitData::month($month_num);
	$self;
}

sub add_bucket
{
	my ($self, $bucket) = @_;

	return if $bucket->is_empty();

	my $d1 = $self->{detail};
	my $d2 = $bucket->{detail};

	foreach my $act (keys %$d2)
	{
		$d1->{$act} += $d2->{$act};
	}
	
	foreach my $cat (qw(days active_days))
	{
		$self->{$cat} += $bucket->{$cat};
	}
}

sub diff_bucket
{
	my ($self, $bucket) = @_;

	return if $self->is_empty() || $bucket->is_empty();
	my $d1 = $self->{detail};
	my $d2 = $bucket->{detail};

	foreach my $act (keys %$d2)
	{
		$d1->{$act} -= $d2->{$act};
	}
	
	foreach my $cat (qw(active_days total_workouts
							  days_per_week workouts_per_week))
	{
		$self->{$cat} -= $bucket->{$cat}
	}
}

sub add_activities
{
	my ($self, $activities) = @_;

	if ($activities && $activities ne '_')
	{
		++$self->{days};
		
		if ($activities ne '.')
		{
			++$self->{active_days};
			
			foreach my $a (split(//, $activities))
			{
				++$self->{detail}{$a};
			}
		}
	}
}

sub calc_meta_data
{
	my ($self) = @_;

	$self->{total_workouts} = 0;
	foreach my $num_times (values %{$self->{detail}})
	{
		$self->{total_workouts} += $num_times;
	}

	$self->{days_per_week}     = $self->{active_days} / $self->{days} * 7;
	$self->{workouts_per_week} = $self->{total_workouts} / $self->{days} * 7;
}

sub is_empty
{
	!$_[0]->{days}
}
1;
