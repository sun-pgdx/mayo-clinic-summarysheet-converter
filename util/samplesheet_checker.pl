#!/usr/bin/env perl
use strict;
use File::Slurp;
my $infile = $ARGV[0];
if (!defined($infile)){
	die "Usage : perl $0 summarysheet.csv\n";
}

my @lines = read_file($infile);

chomp @lines;

my $lookup = {};

my $line_ctr = 0;

foreach my $line (@lines){

	$line_ctr++;
	if ($line_ctr == 1){
		next;
	}

	my @parts = split(',', $line);
	
	my $sample_id = $parts[2];

	if ($sample_id =~ m/(MAYO\d{4}P)/){
		$lookup->{$1}++;
	}
}


foreach my $id (sort keys %{$lookup}){
	my $count = $lookup->{$id};
	print "For id '$id' count was '$count'\n";
}