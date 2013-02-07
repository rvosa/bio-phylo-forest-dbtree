#!/usr/bin/perl
use strict;
use warnings;
use Megatree;
use Getopt::Long;

# process command line arguments
my ( $dbfile, $taxon );
GetOptions(
	'dbfile=s' => \$dbfile,
	'taxon=i'  => \$taxon,
);

# load file
my $node_rs = Megatree->connect($dbfile)->resultset('Node');
my $node    = $node_rs->single({ taxon => $taxon });

# traverse to find root
while( $node->get_parent ) {
	$node = $node->get_parent;
}

# compute post-order node ids

=begin comment

my %id;
my $counter = 1;
traverse($node);
sub traverse {
	my $node = shift;
	traverse($_) for @{ $node->get_children };
	$id{$node->id} = $counter++;
}

=cut comment

# fetch tips
my $tips_rs = $node_rs->search({ taxon => { '>=' => 0 } });
while( my $tip = $tips_rs->next ) {
	print $tip->taxon, ",";
	while( $tip->get_parent ) {
		$tip = $tip->get_parent;
		print $tip->id, '|';
	}
	print "\n";
}