#!/usr/bin/perl
use strict;
use warnings;
use Test::More 'no_plan';
use FindBin;
use lib "$FindBin::Bin/../lib";

# try to use the Megatree class
use_ok('Bio::Phylo::Forest::DBTree');

# the dbfile holds the tree as in trivial.newick
my $dbfile = "$FindBin::Bin/../data/16S_candiv_gg_2011_1.db";

# try to connect to the database
my $mega = Bio::Phylo::Forest::DBTree->connect($dbfile);
ok($mega);

# get the root of the tree
my $root = $mega->get_root;
isa_ok($root, 'Bio::Phylo::Forest::Node');

# get a tip
my $tip = $mega->get_by_name('307310');
isa_ok($tip, 'Bio::Phylo::Forest::Node');
ok($tip->is_terminal, '307310 is a tip');

# get an internal node
my $node = $mega->get_by_name('n408888');
isa_ok($node, 'Bio::Phylo::Forest::Node');
ok($node->is_internal, 'n408888 is a node');

# do an MRCA and a patristic distance calc
my $t1 = $mega->get_by_name('307310');
my $t2 = $mega->get_by_name('354287');
my $mrca = $mega->get_mrca([ $t1, $t2 ]);
my $mrca_id = $mrca->get_id;
ok( $mrca_id == 817788, "MRCA is $mrca_id (expected: 817788)" );

my $h_mrca = $mrca->height;
my $h_t1   = $t1->height;
my $h_t2   = $t2->height;
my $dist   = ( $h_t1 - $h_mrca ) + ( $h_t2 - $h_mrca );
my $p_dist = $t1->calc_patristic_distance($t2);
ok( $p_dist == $dist, "patristic distance is $p_dist (expected: $dist)" );
