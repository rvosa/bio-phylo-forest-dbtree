#!/usr/bin/perl
use strict;
use warnings;
use List::Util 'sum';
use Data::Dumper;
use Getopt::Long;

# process command line arguments
my $db = 'db'; # default
my ( $t1, $t2 );
GetOptions(
	't1=s' => \$t1,
	't2=s' => \$t2,
	'db=s' => \$db,
);

my @path1 = concat_path($t1);
my %seen = map { $_ => 1 } grep { defined } map { $_->{'id'} } @path1;

my @path2 = concat_path($t2,%seen);
my $path2_root_id = $path2[-1]->{'id'};

my ( $length1, $length2 );

my $last_id;
MRCA: for my $i ( 0 .. $#path1 ) {
	my $node = $path1[$i];
	if ( $node->{'id'} ) {
		if ( $node->{'id'} eq $path2_root_id ) {
			for my $j ( $last_id .. $i ) {
				for ( my $k = $#path2; $k >= 0; $k-- ) {
					my ( $anc1, $anc2 ) = ( $path1[$j], $path2[$k] );
					
					# this should be the MRCA
					if ( $anc1->{'left'} == $anc2->{'left'} && $anc1->{'right'} == $anc2->{'right'} ) {
						$length1 = sum( map { $_->{'length'} } @path1[0..$j] );
						$length2 = sum( map { $_->{'length'} } @path2[0..$k] );
						last MRCA;
					}
				}
			}
		}
		$last_id = $i;
	}
}
print $length1 + $length2, "\n";

sub concat_path {
	my ( $node, %seen ) = @_;
	my @path;
	
	# traverses from tip to the root, extending @path
	TRAVERSAL: while( my @subpath = get_path($node) ) {
		
		# if sub paths are internal, they start with a
		# graft point, whose length
		# needs to be copied to the root of the current
		# tip-to-root path
		if ( $path[-1] ) {
			my $graftpoint = shift @subpath;
			$path[-1]->{'length'} = $graftpoint->{'length'};
		}
		push @path, @subpath;
		$node = $subpath[-1]->{'id'};
		last TRAVERSAL if $seen{$node};
	}
	
	return @path;
}

# for a terminal node or internal graft node, grep the
# path from the tip to the local root and return as
# pseudo objects
sub get_path {
	my $label = shift;
	my $path = `grep -he '^$label-' $db/*.tsv`;
	
	# strip white space
	$path =~ s/^\s*//;
	$path =~ s/\s*$//;
	
	# split on tabs, which yields (optional id-)l.r:length
	my @parts = split /\t/, $path;
	my @path;
	for my $part ( @parts ) {
	
		# first and last probably have an id
		my $id;
		if ( $part =~ /^(.+)-/ ) {
			$id = $1;
			$part =~ s/^.+-//;
		}
		
		# $index is l.r
		my ( $index, $length ) = split /:/, $part;
		my ( $left, $right ) = split /\./, $index;	
		push @path, {
			'left'   => $left,
			'right'  => $right,
			'length' => $length,
			'id'     => $id,
		};
	}
	return @path;
}