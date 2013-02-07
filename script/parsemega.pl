#!/usr/bin/perl
use strict;
use warnings;

=begin comment

opening Greengenes2011-labeled.txt at parsemega.pl line 19.
slurped newick at parsemega.pl line 22, <$fh> line 1.
captured outer clade at parsemega.pl line 26, <$fh> line 1.

real    12m32.761s
user    11m43.797s
sys     0m3.732s

=cut comment

my $file = shift;
open my $fh, '<', $file or die $!;
warn "opening $file";

my $newick = do { local $/; <$fh> };
warn "slurped newick";

if ( $newick =~ /^(.+);$/ ) {
	my $clade = $1;
	warn "captured outer clade";
	
	traverse( $clade );
}
else {
	die "no ; in newick: $newick";
}

sub traverse {
	my ( $tokens, $parent ) = @_;
	no warnings 'recursion';
	
	# split tokens into clades, traverse
	my ( $depth, $label, $clade, @clades ) = ( 0, '', '' );
	for my $i ( 0 .. length($tokens) - 1 ) {
		my $t = substr $tokens, $i, 1;
		
		# have completed a clade, store it
		if ( $t eq ',' ^ $t eq ')' && $depth == 1 ) {
			push @clades, $clade;
			$clade = '';
		}
		
		# extending clade
		elsif ( $depth > 0 ) {
			$clade .= $t;
		}
		
		# at level zero, either the node label or at
		# beginning of token string
		elsif ( $depth == 0 && $t ne '(' ) {
			$label .= $t;
		}
		
		$depth++ if $t eq '(';
		$depth-- if $t eq ')';		
	}
	print_branch( $label, $parent ) if $parent;
	traverse( $_, $label ) for @clades;
}

sub print_branch {
	my ( $child, $parent ) = @_;
	$parent =~ s/:.+//;	
	my $length = 0;
	if ( $child =~ /(.+?):(.+)/ ) {
		( $child, $length ) = ( $1, $2 );
	}
	print $child, "\t", $parent, "\t", $length, "\n";
}