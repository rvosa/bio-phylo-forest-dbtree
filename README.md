Bio::Phylo::Forest::DBTree
==========================
A portable database-backed, object-relational, Bio::Phylo-like API to 
handle very large, immutable phylogenetic trees

Requires
========
* Bio::Phylo v0.52 or later
* DBIx::Class
* DBD::SQLite

Importing data
==============
Given a very large newick file (such as the example `16S_candiv_gg_2011_1`
green genes tree), the first thing you want to do is transform this into
an adjacency list, like so:

    $ megatree-loader -i <tree file> -d <db to create>

When you omit the -d flag, the adjacency list is printed to STDOUT as
comma separated values, which you can then import into a database.

The columns written to STDOUT are:
* child ID
* parent ID
* node label
* branch length

At present, everything else assumes that you will import this into 
sqlite3. This would happen automatically when you provide the -d flag 
with an argument, i.e. a file name to which to write the database. 

Such a database, when produced by the `megatree-loader` scripts, 
contains additional pre- and post-order indexes (to compute MRCAs, 
ancestors and descendents), respectively labeled `left` and `right`, 
and pre-computed tip heights, labeled `height`, which is used to 
compute patristic distances.

Usage
=====
Once you've created your database file, you can then connect to it 
and traverse the tree as per the example shown in t/megatree.t

The API is just like Bio::Phylo::Forest::Node so it can be used as a 
drop-in replacement, with the caveat that any methods that try to 
load all nodes in the tree into memory should be avoided. (So, the 
methods that cleverly use the visit* methods are fine, but the naive 
ones that treat the tree as a list of nodes are not. Yeah, I should 
fix that.)

A reasonably scalable example of what can be done is provided by the 
pruner script, whose usage is:

    $ megatree-pruner -d <db> -i <file> > <newick>

The script takes two arguments: a database file created by 
`megatree-loader` and a simple text file that lists taxa to retain 
(one per line) to create the pruned output tree, which is written to 
STDOUT in newick format.
