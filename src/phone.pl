#!/usr/local/bin/perl -w
do 'dumpvar.pl';
use strict;
use Data::Dumper;
main();

sub main
{
	my $letters = letters();
	my $num = shift @ARGV || die;
	
	my @digits = split(//, $num);
	foreach (@digits) { $_ = 10 if $_ eq '*'; }
	my @combos = rec([map($letters->[$_], @digits)]);
	::dumpValue(\@combos) if @ARGV;
	
	my $words = join("\n", @combos);
	my $output = `echo '$words' | spell 2>/dev/null`;
	my @not_words = split("\n", $output);
	my %combos = map(($_ => 1), @combos);
	delete $combos{$_} foreach (@not_words);
	
	print map("$_\n", keys %combos);
}

sub rec
{
	my ($ar, @stack) = @_;
	return join("", @stack) unless @$ar;
	my ($head, @a) = @$ar;
	map {rec(\@a, @stack, $_)} @$head;
}


sub letters
{
	my $x = [
				['oper'],
				[1],         [qw(a b c)], [qw(d e f)],
				[qw(g h i)], [qw(j
									  k l)], [qw(m n o)],
				[qw(p r s)], [qw(t u v)], [qw(w x y)],
				['a'..'z']
			  ];
}
