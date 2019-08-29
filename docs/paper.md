---
title: 'DBTree - toolkit for megatrees in portable databases'
tags:
  - phylogenetics
  - scripting
  - databases
  - topological queries
  - object-relational mapping
authors:
  - name: Rutger A. Vos
    orcid: 0000-0001-9254-7318
    affiliation: "1, 2"
affiliations:
 - name: Naturalis Biodiversity Center, Leiden, the Netherlands
   index: 1
 - name: Institute of Biology Leiden, Leiden University, the Netherlands
   index: 2
date: 29 August 2019
bibliography: paper.bib
type: application
head: megatrees in portable databases
---

# Abstract

1. Growing numbers of very large phylogenetic syntheses are being 
   published. Sometimes to serve as part of the framework within
   which a hypothesis is being tested, sometimes to present the 
   outcomes of novel methods of phylogenetic inference, and sometimes
   as a snapshot of the molecular diversity within a large group.
   Commonly used methods to reuse these trees in scripting 
   environments have their limitations.   
2. I present a toolkit that transforms data presented in the most
   commonly used format for such trees into a database schema that
   facilitates quick topological queries. Specifically, the need for 
   recursive traversal commonly presented by schemata based on 
   adjacency lists is largely obviated. This is accomplished by 
   computing pre- and post-order indexes and node heights on the 
   topology as it is being ingested.
3. The resulting toolkit provides several command line tools to 
   do the transformation and to extract subtrees from the resulting
   database files. In addition, library code with object-relational 
   mappings that integrate with Bio::Phylo are provided. To 
   demonstrate the utility of the general approach I also provided
   database files for trees provided by Green Genes, D-PLACE, 
   PhyloTree, the NCBI taxonomy and the recently published, largest
   estimate of plant phylogeny to date.
4. The database files that the toolkit produces are highly portable
   (either as SQLite or tabular text) and can readily be queried,
   for example, in the R environment. Programming languages with 
   mature frameworks for object-relational mapping and phylogenetic 
   tree analysis, such as Python, can use these facilities to make
   much larger phylogenies conveniently available to 
   researcher-programmers.

### Keywords    

phylogenetics, scripting, databases, topological queries, 
object-relational mapping

# Introduction

The estimates of phylogeny that appear in the literature are continuing
to get larger and larger. The contexts within which these trees appear
vary somewhat. In some cases, the tree is constructed as a 'one off'
estimate that was required in order to test a hypothesis in a phylogenetic 
comparative framework (e.g. [Zanne:2014]). In other cases, the tree is
the outcome of an initiative to produce such trees and is thus a 
demonstration of the method (e.g. [Hinchliff:2015], [Smith:2018]). In yet 
other cases, the trees are provided as snapshots of the diversity contained 
in a database (e.g. [vanOven:2009], [Kirby:2016], [Federhen:2011], 
[DeSantis:2006]). 

All these data coming publicly available is a wonderful development. 
However, the format in which these data are published is not necessarily 
the most convenient from the perspective of programmatic reuse. Most 
commonly, phylogenetic trees of this size are made available in the Newick 
format ([Newick]), as other formats (e.g. [Nexus], [NeXML]) add verbosity 
in exchange for a potential level of richness of annotation that is not
needed in this case anyway. From the perspective of conciseness when 
transmitting tree files, Newick is thus a sensible choice. However, the
researcher-programmer who wants to reuse such a tree in a scripting 
environment is then faced with the need to parse text containing the 
parenthetical tree description and load some kind of graph structure or
object into memory every time the script is run. With large trees, this
takes a lot of time and consumes a lot of working memory.

An alternative approach is to ingest the tree file into a portable, 
on-disk database as a one-time operation, and then access the tree data
through a database handle. Subsequently, there is no more complex text
parsing, and the tree does not have to be loaded into memory to be able 
to query its topology. To exploit these advantages, the NCBI taxonomy 
([Federhen:2011]) is distributed in the form of database tables, for
example. In that case, and indeed in most cases where trees that might
be polytomous are represented in databases, the topology is captured
using adjacency lists, where each database record for a node (except 
the root) contains a reference to its parent by way of a foreign key
relation. The downside of this is that tree traversal requires recursive
queries: to get from a tip to the root, each focal node along the path
has to be visited in turn to look up its foreign key relation to its 
parent. This is relatively slow. A possible solution to this is to
use relational database engines that can compute transitive closures,
but not all commonly-used engines support those and the computation
imposes additional computational cost on the ones that do.

Pre-computing additional values and indexes as column values can obviate
the need for some of these traversals entirely, thereby speeding up tree
traversal significantly. The general idea is illustrated in Fig 1. The
topology shown is represented in the table, with one record for each node,
by way of the following columns:

- **name** - the label (if any), i.e. the values in this column 
  correspond to those in the tree.
- **length** - the branch length (if any).
- **id** - a primary key, which is generated as an autoincrementing 
  integer.
- **parent** - a foreign key, whose value references the primary key,
  i.e. the **id**, of the parent node.
- **left** - an index that is generated as an autoincrementing integer
  in a pre-order traversal, i.e. moving from root to tips, parent nodes
  are assigned the index before their child nodes.      
- **right** - an index that is generated as an autoincrementing integer
  in a post-order traversal, i.e. moving from root to tips, child nodes
  are assigned the index before their parents. That is, "on the way back"
  in the recursion.
- **height** - the node height, i.e. the distance from the root.

Like most relational database implementations of trees, i.e. using
adjacency lists, the parent child node _C_ can be selected like
so (returning _n1_):

```sql
select PARENT.* from node as PARENT, node as CHILD
  where CHILD.name='C'
  and PARENT.id==CHILD.parent;
```

And the children of _n1_ can be select like so (returning _C_ and _D_):

```sql
select CHILD.* from node as PARENT, node as CHILD
  where PARENT.name='n1'
  and PARENT.id==CHILD.parent;
```

Beyond that, and with the aid of the additional indexes, traversals that 
would otherwise require recursion can now be executed as a single query. 
For example, to identify the most recent common ancestor of (MRCA) of input 
nodes C and F, we can formulate in SQL:

```sql
select MRCA.* from node as MRCA, node as C, node as F 
  where C.name='C' and F.name='F' 
  and MRCA.left < min(C.left,F.left) 
  and MRCA.right > max(C.right,F.right)
  order by MRCA.left desc limit 1;
```

The query selects the nodes whose **left** index is lower, and whose 
**right** index is higher than that of either of the input nodes. This
limits the result set to those nodes that are ancestral to both. By then
ordering these on the **left** index in descending order they are ranked
from most recent to oldest. Limiting the result set to only the first
record in this ordered list returns the most recent common ancestor. 
Alterations to the query to obtain, for example, all ancestors to both
(or either) input nodes should be readily apparent. Similar filtering can 
also be applied to identify all tips subtended by an input node:

```sql
select TIP.* from node as TIP, node as ROOT 
  where ROOT.name='n3' 
  and TIP.left > ROOT.left 
  and TIP.right < ROOT.right
  and TIP.left == TIP.right;
```

In this query, the filtering on **left** and **right** indexes is applied 
as a means to define the ingroup. Furthermore, the property of the indexes
that they are not incremented on terminal nodes between the way in (the 
pre-order traversal) and the way out (post-order) is exploited to select 
them using the predicate of equality of their indexes. 

# Materials and Methods

# Results

# Discussion

# Conclusions 

# Acknowledgements

# Authors' contributions

# Data availability

The source code of this project is made available under the same
terms as the Perl5 core itself, i.e. an opportunistic combination 
of the GNU General Public License (v.3) and the Artistic License,
and is being developed further in a git repository at:
https://github.com/rvosa/bio-phylo-forest-dbtree

The version of the software presented in this manuscript has been
stored permanently under a DOI at: https://doi.org/10.5281/zenodo.1035856
and is released through the Comprehensive Perl Archive Network at:
https://metacpan.org/release/Bio-Phylo-Forest-DBTree

The database files discussed in this manuscript are available at
the following locations:

- PhyloTree [vanOven:2009] - http://doi.org/10.6084/m9.figshare.4620757.v1
- D-PLACE [Kirby:2016] - http://doi.org/10.6084/m9.figshare.4620217.v1
- NCBI Taxonomy [Federhen:2011] - http://doi.org/10.6084/m9.figshare.4620733.v1
- Green Genes [DeSantis:2006] - http://doi.org/10.6084/m9.figshare.4620214.v1

# References

# Figures

![](fig1.svg)

Figure 1: representation of a tree shape in a relational database, with
additional, precomputed indexes and values. See text for details.