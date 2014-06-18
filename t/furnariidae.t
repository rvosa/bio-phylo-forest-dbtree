#!/usr/bin/perl
use strict;
use warnings;
use FindBin '$Bin';
use Bio::Phylo::Factory;
use Bio::Phylo::Treedrawer;
use Test::More 'no_plan';
use Config;

my $size = 3267;

# Test to use the Megatree class. This needs to be in a BEGIN block (i.e. during
# the "compile" phase), and any 'use Megatree' statement at the top of the script
# needs to be omitted, else we would never reach a failing test as the compile phase
# would already have bombed had the 'use' statement posed problems.
BEGIN { use_ok('Megatree'); }

# The dbfile holds the tree as in trivial.newick. Here using FindBin::$Bin so that
# the relative path to the SQLite file can be computed portably from any location.
my $dbfile = "$Bin/Furnariidae.db";
ok( -e $dbfile, "$dbfile exists" );

# connect and test
my $mega = Megatree->connect($dbfile);
ok($mega, "Megatree instantiated correctly");
isa_ok($mega, 'Bio::Phylo::Forest::DrawTreeRole'); # note the new inheritance topology

# Get the root of the tree and test
my $root = $mega->get_root;
isa_ok($root, 'Bio::Phylo::Forest::DrawNodeRole'); # note the new inheritance topology

# Instantiate tree drawer and test
my $drawer = Bio::Phylo::Treedrawer->new(
    '-width'  => $size,
    '-height' => $size,
    '-shape'  => 'rect', 
    '-mode'   => 'CLADO', 
    '-format' => 'SVG',
    '-tree'   => $mega, # note how the $mega tree can be passed in here
);
isa_ok( $drawer, 'Bio::Phylo::Treedrawer' );

# In previous Bio::Phylo's, the class inheritance was a bit awkward in that "draweable"
# trees and nodes were sister classes to normal trees and nodes. As a consequence,
# when passing a normal tree to the treedrawer, it had to be cloned and reproduced
# as a "draweable" tree. There were many problems with this; some obscure, but for
# the purpose of drawing large, persisted trees the obvious problem is that we would
# then end up reproducing the big tree in RAM anyway. This test is just to show that
# the draweable tree and node classes are superclasses of everything else so we don't
# have to do this cloning, so the tree held by the drawer is the same one that went in.
ok( $mega == $drawer->get_tree, "drawer stores original object reference" );

# In the interest of keeping this as a somewhat portable test case I will leave the
# part where you invoke inkscape out of this. it should work as expected, though. Note
# also that you don't have to invoke compute_coordinates() explicitly, as this is 
# normally done internally by draw(). If however you have your own computations for
# coordinates (e.g. if you wanted to make a "ratogram") you would apply the coordinates
# yourself, and then call render() instead of draw()
ok( $drawer->draw );

# A long time ago we had a conversation about wanting to have pre-computed coordinates
# available in NeXML and JSON. In response I have made it so that all the "draweable"
# node properties (e.g. x,y coordinates, fonts, colors, etc.) are now all properties 
# that belong to the fictional "phylomap" controlled vocabulary. Here now a brief
# demonstration as to how these could be accessed:

# semantic annotations consist of a prefix and a property. the prefix is tied to a 
# namespace URI. the URI that is used here doesn't point to anything (yet), but it
# is recognized as identifying a vocabular where things are defined about tree drawing
my $prefix = $mega->get_prefix_for_namespace('http://purl.org/phylo/phylomap/terms#');
$mega->visit(sub{
	my $node = shift;
	
	# in addition to X and Y, the following other properties might be present:
	# 	radius tip_radius node_color node_outline_color
	# 	node_shape node_image branch_color branch_shape branch_width branch_style
	# 	collapsed collapsed_width font_face font_size font_style font_color
	# 	text_horiz_offset text_vert_offset rotation
	my $x = $node->get_meta_object( "${prefix}:x" );
	my $y = $node->get_meta_object( "${prefix}:y" );
	ok( $x && $y, "$node x=$x y=$y" );
});