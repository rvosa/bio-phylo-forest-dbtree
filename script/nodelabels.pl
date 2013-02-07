#!/usr/bin/perl
use strict;
use warnings;

my $file = shift;
my $counter = 1;
open my $fh, '<', $file or die $!;
while(<$fh>) {	
	s/'[^']+'//g; # strip old node labels
	my @line = split /\)/, $_;
	my $line = '';
	for my $token ( @line ) {
		$line .= $token . ')n' . $counter++; # attach unique new labels
	}
	print $line;
}