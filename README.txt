bio-phylo-megatree
==================

Experimental implementation of DBIx::Class-backed, Bio::Phylo-like API

Requires
========
* Bio::Phylo v0.52 or later
* DBIx::Class

Usage
=====
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