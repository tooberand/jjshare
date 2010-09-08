#!/usr/local/bin/perl -w

use strict;

use Time::Local;

main();

sub main
{
	my $header = "BEGIN:VCALENDAR\n";
	$header .= "PRODID:-//Google Inc//Google Calendar 70.9054//EN\n";
	$header .= "VERSION:2.0\n";
	$header .= "CALSCALE:GREGORIAN\n";
	$header .= "METHOD:PUBLISH\n";
	$header .= "X-WR-CALNAME:Birthdays\n";
	$header .= "X-WR-TIMEZONE:America/Denver\n";
	$header .= "X-WR-CALDESC:\n";
	$header .= "BEGIN:VTIMEZONE\n";
	$header .= "TZID:America/Denver\n";
	$header .= "X-LIC-LOCATION:America/Denver\n";
	$header .= "BEGIN:DAYLIGHT\n";
	$header .= "TZOFFSETFROM:-0700\n";
	$header .= "TZOFFSETTO:-0600\n";
	$header .= "TZNAME:MDT\n";
	$header .= "DTSTART:19700308T020000\n";
	$header .= "RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=2SU\n";
	$header .= "END:DAYLIGHT\n";
	$header .= "BEGIN:STANDARD\n";
	$header .= "TZOFFSETFROM:-0600\n";
	$header .= "TZOFFSETTO:-0700\n";
	$header .= "TZNAME:MST\n";
	$header .= "DTSTART:19701101T020000\n";
	$header .= "RRULE:FREQ=YEARLY;BYMONTH=11;BYDAY=1SU\n";
	$header .= "END:STANDARD\n";
	$header .= "END:VTIMEZONE\n";
	my $footer = "END:VCALENDAR";

	my $summary;
	my $sdate;

	open(FH, ">./gmail.ics") || die "Unable to open gmail.ics";
	print FH $header;
	while (($summary, $sdate) = (shift @ARGV, shift @ARGV))
	{
		if (!$summary)
		{
			print "Enter summary or return to exit (ex. Tooberand's Birthday): ";
			$summary = <STDIN>;
			chomp $summary;
			last if !$summary;
			print "Enter date (YYYYMMDD): ";
			$sdate = <STDIN>;
			chomp $sdate;
		}
		last if !$summary;
		my $vevent = gen_vevent($summary, $sdate);
		print FH $vevent;
	}
	print FH $footer;
	close(FH);
}

sub gen_vevent
{
	my ($summary, $sdate) = @_;

	my ($syear, $smonth, $sday) = unpack("a4a2a2", $sdate);
	my $stime = timegm(0, 0, 0, $sday, $smonth - 1, $syear - 1900);
	my $etime = $stime + 60 * 60 * 24;
	my ($sec, $min, $hours, $mday, $mon, $year, $wday) = gmtime($etime);
	my $edate = sprintf("%04d%02d%02d", $year + 1900, $mon + 1, $mday);
	my $uid = "UID$sdate$summary";

	my $vevent = "BEGIN:VEVENT\n";
	$vevent .= "DTSTART;VALUE=DATE:$sdate\n";
	$vevent .= "DTEND;VALUE=DATE:$edate\n";
	$vevent .= "RRULE:FREQ=YEARLY;WKST=SU\n";
	$vevent .= "DTSTAMP:20100401T183253Z\n";
	$vevent .= "UID:$uid\n";
	$vevent .= "CREATED:00001231T000000Z\n";
	$vevent .= "DESCRIPTION:\n";
	$vevent .= "LAST-MODIFIED:20100401T183239Z\n";
	$vevent .= "LOCATION:\n";
	$vevent .= "SEQUENCE:0\n";
	$vevent .= "STATUS:CONFIRMED\n";
	$vevent .= "SUMMARY:$summary\n";
	$vevent .= "TRANSP:OPAQUE\n";
	$vevent .= "END:VEVENT\n";

	$vevent
}
