bio-phylo-megatree
==================

Experimental implementation of DBIx::Class-backed, Bio::Phylo-like API

Requires
========
* Bio::Phylo v0.52 or later
* DBIx::Class
* DBD::SQLite

Importing data
==============
Given a very large newick file (such as the example 16S_candiv_gg_2011_1
green genes tree), the first thing you want to do is transform this into
an adjacency list, like so:

$ make_megatree -i <tree file> -d <db to create>

When you omit the -d flag, the adjacency list is printed to STDOUT as
comma separated values, which you can then import into a database. 

The columns are:
- child ID
- parent ID
- node label
- branch length

At present, everything else assumes that you will import this into sqlite3,
as would happen automatically when you provide the -d flag.

Usage
=====
Once you've created your database file, you can then connect to it and 
traverse the tree as per the example shown in t/megatree.t

The API is just like Bio::Phylo::Forest::Node so it can be used as a drop-
in replacement, with the caveat that any methods that try to load all nodes
in the tree into memory should be avoided. (So, the methods that cleverly
use the visit_* methods are fine, but the naive ones that treat the tree
as a list of nodes are not. Yeah, I should fix that.)
