#!/usr/bin/perl
use strict;
use warnings;
use Test::More 'no_plan';
use FindBin;
use lib "$FindBin::Bin/../lib";

# try to use the Megatree class
use_ok('Megatree');

# the dbfile holds the tree as in trivial.newick
my $dbfile = "$FindBin::Bin/../data/16S_candiv_gg_2011_1.db";

# try to connect to the database
my $mega = Megatree->connect($dbfile);
ok($mega);

# get the root of the tree
my $root = $mega->get_root;
isa_ok($root, 'Bio::Phylo::Forest::Node');

# now, for example
ok($mega->calc_tree_length);



