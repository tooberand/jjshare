#!/usr/local/bin/perl

use strict;

use Data::Dumper;
use File::Find;

main();

sub main
{
	my ($search_str) = shift @ARGV;
	$search_str =~ s/\+/\.\*/g;
	my @matched_files;

	my $wanted = sub
	{
		push(@matched_files, $File::Find::name)
			if ($File::Find::name =~ /$search_str/i);
	};

	find($wanted, "$ENV{HOME}/Music/iTunes/iTunes Media/Music");
	print Dumper \@matched_files;
}

