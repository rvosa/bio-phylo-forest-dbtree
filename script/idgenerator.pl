#!/usr/bin/perl
use strict;
use warnings;

my %id;
my $counter = 1;
while(<>) {
	chomp;
	my ( $child, $parent, $length ) = split /\t/, $_;
	$id{$child}  = $counter++ unless $id{$child};
	$id{$parent} = $counter++ unless $id{$parent};
	my $label = $child =~ /^\d+$/ ? $child : '';
	print $id{$child}, ",", $id{$parent}, ",", $label, ",", $length, "\n";
}