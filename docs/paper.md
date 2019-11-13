---
title: 'DBTree - very large phylogenies in portable databases'
tags:
  - phylogenetics
  - programming toolkits
  - databases
  - topological queries
  - object-relational mapping
authors:
  - name: Rutger A. Vos
    orcid: 0000-0001-9254-7318
    affiliation: "1, 2, 3"
affiliations:
 - name: Naturalis Biodiversity Center, Leiden, the Netherlands
   index: 1
 - name: Institute of Biology Leiden, Leiden University, the Netherlands
   index: 2
 - name: Corresponding author <rutger.vos@naturalis.nl>
   index: 3  
date: 29 August 2019
bibliography: paper.bib
---

# Abstract <!-- 350 max for MEE -->

1. Growing numbers of large phylogenetic syntheses are being published. 
   Sometimes as part of a hypothesis testing framework, sometimes to 
   present novel methods of phylogenetic inference, and sometimes
   as a snapshot of the diversity within a database. Commonly used 
   methods to reuse these trees in scripting environments have their 
   limitations.
2. I present a toolkit that transforms data presented in the most
   commonly used format for such trees into a database schema that
   facilitates quick topological queries. Specifically, the need for 
   recursive traversal commonly presented by schemata based on 
   adjacency lists is largely obviated. This is accomplished by 
   computing pre- and post-order indexes and node heights on the 
   topology as it is being ingested.
3. The resulting toolkit provides several command line tools to 
   do the transformation and to extract subtrees from the resulting
   database files. In addition, reusable library code with 
   object-relational mappings for programmatic access is provided. 
   To demonstrate the utility of the general approach I also provide
   database files for trees published by Open Tree of Life, Greengenes, 
   D-PLACE, PhyloTree, the NCBI taxonomy and a recent estimate of 
   plant phylogeny.
4. The database files that the toolkit produces are highly portable
   (either as SQLite or tabular text) and can readily be queried,
   for example, in the R environment. Programming languages with 
   mature frameworks for object-relational mapping and phylogenetic 
   tree analysis, such as Python, can use these facilities to make
   much larger phylogenies conveniently accessible to 
   researcher-programmers.

### Keywords    

phylogenetics, scripting, databases, topological queries, 
object-relational mapping

# Introduction

Larger and larger phylogenies are being published. The contexts in which 
these trees appear vary somewhat. Sometimes, a tree is published 
as a 'one off' estimate needed for testing a hypothesis in a phylogenetic 
comparative framework [e.g. @Zanne:2014]. In other cases, the tree 
demonstrates the capabilities of initiatives to produce megatrees 
[e.g. @Mctavish:2015; @Redelings:2017; @Rees:2017; @Hinchliff:2015; 
@Smith:2018; @Antonelli:2017]. In yet other cases, the trees are provided 
as snapshots of the diversity contained in a database 
[e.g. @vanOven:2009; @Kirby:2016; @Federhen:2012; @DeSantis:2006; @Piel:2018]. 

All these trees coming publicly available is a wonderful development. 
However, the format in which they are published is not always convenient 
for reuse. Most commonly, large phylogenetic trees are made available 
in Newick format [@Newick], as other formats [e.g. @Nexus; @NeXML] 
are too verbose. From this perspective of conciseness, Newick is a 
sensible choice. However, the researcher-programmer who wants to reuse 
such large trees in a scripting environment is then faced with the need 
to parse complex parenthetical tree descriptions and load some kind of 
graph structure or object into memory every time the script is run. With 
large trees, this takes a lot of time and consumes a lot of working memory. 
For example, loading the latest Open Tree of Life estimate 
[v10.4, see @Hinchliff:2015] into DendroPy [@DendroPy] takes about 13 
minutes and consumes over 8 GB of RAM. This might be fine for some use 
cases (e.g. for processes that subsequently run for very long) but it can 
be a limitation in other situations.

An alternative approach is to ingest a large tree into a portable, 
on-disk database as a one-time operation, and then access the tree
through a database handle. No more recurrent, complex text parsing, and 
the tree does not have to be loaded into memory to query its topology. 
The NCBI taxonomy [@Federhen:2012] is distributed as database tables 
with this usage in mind, for example. In that case, and indeed in most 
cases where trees that might have polytomies are represented in databases, 
the topology is captured using adjacency lists, where each database 
record for a node (except the root) contains a reference to its parent 
by way of a foreign key relation [e.g. see @Vos:2017]. The downside of 
this is that tree traversal requires recursive queries: to get from a 
tip to the root, each focal node along the path has to be visited in 
turn to look up the foreign key relation to its parent. This is 
relatively slow. A possible solution to this is to use relational 
database engines that compute transitive closures, but not all 
commonly-used engines support those, and their computation imposes 
additional computational cost on the ones that do.

Pre-computing certain metrics and topological indexes as column values 
can obviate the need for some recursions entirely, speeding up topological 
queries significantly. The general idea is illustrated in Fig 1. The 
topology shown is represented in the table, with one record for each 
node, by way of the following columns:

- **name** - the node label. The values in this column correspond to those 
  in the tree.
- **length** - the branch length.
- **id** - a primary key, generated as an autoincrementing integer.
- **parent** - a foreign key, whose value references the primary key
  of the parent node.
- **left** - an index generated as an autoincrementing integer in a 
  pre-order traversal: moving from root to tips, parent nodes are 
  assigned the index before their child nodes.
- **right** - an index generated as an autoincrementing integer in a 
  post-order traversal: moving from root to tips, child nodes are 
  assigned the index before their parents. That is, "on the way back"
  in the recursion.
- **height** - the node height, i.e. the distance from the root.

In relational database implementations of trees that use adjacency list
of this form, the children of _n1_ can be selected like so (returning 
_C_ and _D_):

```sql
select CHILD.* from node as PARENT, node as CHILD
  where PARENT.name='n1'
  and PARENT.id==CHILD.parent;
```

The inverse, getting the parent for an input node, should be readily 
apparent. Beyond direct adjacency, traversals that would otherwise require 
recursion can be executed as a single query with the aid of the additional 
indexes. For example, to identify the most recent common ancestor _MRCA_ 
of input nodes _C_ and _F_, we can formulate:

```sql
select MRCA.* from node as MRCA, node as C, node as F 
  where C.name='C' and F.name='F' 
  and MRCA.left < min(C.left,F.left) 
  and MRCA.right > max(C.right,F.right)
  order by MRCA.left desc limit 1;
```

The query selects all nodes whose **left** index is lower, and whose 
**right** index is higher than that of either of the input nodes. This
limits the result set to those nodes that are ancestral to both. By then
ordering these on the **left** index in descending order they are ranked
from most recent to oldest. Limiting the result set to only the first
record in this ordered list returns _MRCA_. Variations on this query to 
obtain, for example, all ancestors or descendants of input nodes follow 
similar logic. The precomputed node heights can be exploited, for example, 
to compute patristic distances between nodes, such as:

```sql
select (C.height-MRCA.height)+(F.height-MRCA.height) 
  from node as MRCA, node as C, node as F 
  where C.name='C' and F.name='F' 
  and MRCA.left < min(C.left,F.left) 
  and MRCA.right > max(C.right,F.right)
  order by MRCA.left desc limit 1;
```

In this query, the final result is 3.3, i.e. the sum of the heights of _C_
and _F_, as the root has no height. Other calculations that take advantage
of the extra indexes are also possible as single queries. For example,
several metrics capturing the tendency of nodes towards the tips (such that 
the tree is "stemmy") or towards the root ("branchy") are used to summarize
the mode of diversification in a clade (e.g., apparently accelerating or 
slowing down, respectively). One of these metrics [@Fiala:1985] iterates over 
all internal nodes and for each calculates the ratio of the focal node's branch
length over the sum of descendent branch lengths plus the focal length,
and then averages over these ratios. This can be expressed in a single query:

```sql
select avg(ratio) from (
   select INTERNAL.length/(sum(CHILDREN.length)+INTERNAL.length) as ratio 
        from node as INTERNAL, node as CHILDREN 
        where INTERNAL.left!=INTERNAL.right
        and CHILDREN.left>INTERNAL.left
        and CHILDREN.right<INTERNAL.right
	    and INTERNAL.parent!=1 
	    group by INTERNAL.id
)
```

These examples illustrate that access to large tree topologies indexed in 
this way is quite powerful, especially when integrated in scripting environments 
that provide additional functionality. The toolkit presented here provides such 
access.

# Materials and Methods

## Database schema and object-relational mapping

A database schema that provides the functionality described in the 
Introduction is shown in Table 1. In addition to the column names and their
data types, shown are the indexes for the database engine to compute. To avoid 
confusion with the usage of 'index' elsewhere in this manuscript, what is referred 
to here are B-Trees that the database engine computes for internally organizing
and searching the data held by a column (or combination of columns) to allow
it to find matches more quickly, sort result sets, and enforce certain 
constraints (such as uniqueness). In other words, this is something else than
the topological indexing described at greater length in this paper. Nevertheless,
these B-Tree indexes also influence performance greatly so I note them here in the
interest of any re-implementations by readers.

As the database consists of a single table, mapping its structure onto 
an object-oriented class is straightforward. Many programming languages have
tools for this. Commonly-used examples are Hibernate for Java, SQLAlchemy for 
Python, and DBIx::Class for Perl, which I used. I then modified the generated 
code so that it inherits from a tree node class of Bio::Phylo 
[@Vos:2011; @VosHettling:2017], providing it with the additional functionality 
of this package (e.g. export to various flat file formats; tree visualization). 
Infeasibly large phylogenies can thus be programmed like any other tree object 
that Bio::Phylo operates on, provided a database is populated with them. 

## Populating databases

My approach for processing input parenthetical statements and emitting 
these as database records of the form discussed in the Introduction is 
described in the following prose algorithm.

1. Apply an auto-incrementing label to each node, i.e., reading the 
   tree statement from left to right, append a unique identifier
   to each closing parenthesis. Careful tokenization, taking into account 
   the Newick rules (loosely observed as they are) for single and double 
   quoting, spaces, underscores, and square bracketed comments, must be 
   applied dilligently here and throughout the algorithm.
2. Remove the closing semicolon of the parenthetical statement. From here
   on, every nested taxon - including the entire tree - is syntactically 
   self-same: it has a name, either tagged using the labeling scheme from step 
   1, or a previously provided one,  and it may have a branch length 
   (the last colon symbol followed by a number).
3. Emit the focal taxon to the database handle. In the root case, no parent 
   of the focal taxon is in the tree, and so the default value
   for **parent** is used, i.e. 1. The **length** and **name** are parsed
   out of the string. An **id** is generated as an auto-incrementing integer
   and is stored as the value for **name** in a lookup table (hash table,
   dictionary). In cases other than the root case, the parent has been
   processed and so the generated identifier for **parent** can be fetched 
   from the lookup table. What is passed to the database handle is thus a 
   new record with values for the fields **id**, **parent**, **name**, and 
   **length**.
4. Strip the outermost set of decorated parentheses (if any) from the 
   tree string, storing the parent label attached to the closing parenthesis. 
   Split the remaining string in the two or more (in case of polytomies) 
   direct children, by scanning for comma symbols that are not nested inside 
   parentheses. This involves keeping track of the nesting levels of opening 
   and closing parentheses while scanning through the string. Pass each of 
   these direct children to step 3. The recursion between 3 and 4 continues 
   until all taxa have been emitted.
5. The Newick string has now been consumed. In a second pass, the **left**
   and **right** indexes and the node **height** are computed by traversing
   through the now populated database. Starting with the root (i.e. 
   **parent**==1), a depth-first traversal is performed by recursively 
   fetching the immediate child nodes from the database (as per the first 
   query example from the Introduction). The pre-order processing of the 
   children is to store the value of an auto-incrementing integer as **left**, 
   and the value of **height** as carried over from the parent increased with 
   the value of **length**. After treating any children, the post-order processing
   then applies the value of the auto-incrementing integer (unchanged in the
   case of terminal nodes) to **right**.

I implemented this basic algorithm in a script and applied it to the following, 
published trees:

- A tree of human societies from the D-PLACE database [@Kirby:2016]. 
  1,647 nodes using the release that was current as of 04.02.2017.
- A tree of 16S rRNA gene sequences from the Greengenes database
  [@DeSantis:2006], release `gg_13_5`, current as of 11.10.2017. Contains
  406,903 nodes.
- A synthesis of plant phylogeny from [@Smith:2018], identified as ALLMB.tre,
  version v1.0, current as of 29.08.2019. Contains 440,712 nodes. 
- A release of the Open Tree of Life project [@Hinchliff:2015]. Identified as 
  v10.4, current as of 24.09.2018. Contains 2,902,755 nodes.

In addition, I implemented two scripts that process tree descriptions in 
proprietary, tabular formats: 

- The tabular dump of the NCBI taxonomy. The database I generated with 
  this is from GenBank release current as of 03.02.2017, and contains 
  1,554,272 nodes.  
- A custom format that captures a tree of Y-chromosome haplotype diversity 
  backing the PhyloTree database [@vanOven:2009], build 17, current as of 
  11.10.2017. Contains 5,438 nodes.

## Performance benchmarking

To assess the performance of the approach I compared subtree extraction as
enabled by DBTree with a naive implementation based on Newick descriptions.
The extraction of a subtree from a large, published phylogeny is a very common
operation. This is done, for example, when trait data are only available for a
subset of the taxa in the tree and these data need to be analysed in a phylogenetic
comparative framework. Such subtree extraction operation is much of the raison d'être 
for the Phylomatic toolkit [@Webb:2005] and the PhyloTastic project [@Stoltzfus:2013];
likewise, NCBI provides a web service to extract the "common tree" from the NCBI 
taxonomy [@Federhen:2012].

I implemented a DBTree-based implementation of subtree extraction that takes
an input list of tip labels, extracts these and their ancestors from the specified 
database (omitting any non-branching ancestors), and returns their relationships
as a Newick-formatted string. I compared this with a script that uses DendroPy's
default implementations for Newick parsing (i.e. `dendropy.Tree.get`) subtree
extraction (`tree.extract_tree_with_taxa_labels`) and output serialization back to
Newick (`tree.as_string`). As benchmark data set I used the most recent release of
the Open Tree of Life topology. From this tree I extracted sets of randomly sampled 
tips of size 2^_n_^ * 10 where _n_ $\in$ \{0,...,12\}, i.e. sets 
ranging in size from 10 to 40,960 tips. For each implementation I ran each sample 
three times, recording the processing time for each replicate. 

# Results

The substantial results of this study comprise library code and scripts. The 
library code introduces two namespaces compatible with the standardized class 
hierarchy for Perl5:

- `Bio::Phylo::Forest::DBTree` - a class containing factory methods for
  instantiating databases and utility methods for persisting and extracting
  trees. This subclasses the core tree class in Bio::Phylo and inherits its
  decorations.
- `Bio::Phylo::Forest::DBTree::Result::Node` - the generated object-
  relational mapping class, modified to inherit from the core tree node
  class of Bio::Phylo. In addition, this class contains several query methods
  of the sort described in the Introduction.   
  
The scripts are:

- `megatree-loader` - Newick tree parser/loader
- `megatree-ncbi-loader` - parser/loader of NCBI taxonomy dump
- `megatree-phylotree-loader` - PhyloTree parser/loader 
- `megatree-pruner` - extracts subtrees from a database

All library code and scripts are made available under the same terms as perl itself,
i.e. a combination of the Artistic License and the GPL v3.0. The entire package
can be installed from the Comprehensive Perl Archive Network using the standard
package manager by issuing the command `cpanm Bio::Phylo::Forest::DBTree`. Each
script has a detailed help message that can be accessed by passing the `--help`
(or `-h`) flag to the script, and longer documentation that can be accessed using
`--man` (`-m`). The documentation of the library code (i.e. the re-usable 
application programming interface or API) is written using the embedded documentation
syntax POD, which can be viewed by issuing the command `perldoc <class name>`, e.g.
`perldoc Bio::Phylo::Forest::DBTree`.

Applying the loader scripts to the trees listed in the Methods resulted in 
databases that can be queried in SQL (e.g. in the SQLite shell, a 3rd 
party database browser, or from a scripting environment via a database handle) 
or using the object library code presented here. I describe in Data Availability 
how to obtain these generated databases and the tools to make more. As an example 
of the time it takes to do the latter: indexing the largest tree in the set (and 
the largest published phylogeny I am aware of), the Open Tree of Life release, 
took approximately one hour on a current MacBook Pro. This is thus a somewhat 
costly operation that, mercifully, needs to be run only once. 

The subtree extraction benchmarking (see Fig. 2) demonstrates that such indexing 
is an operation that may be worth it. Tiny subtrees of a few dozen tips took
DBTree about a second. For small subtrees ($\leqslant$ 640 tips), the DBTree 
implementation returned results in less than 10 seconds where it took 
DendroPy over 13 minutes; for the largest subtree (40,960 tips), DendroPy took 
over an hour longer to complete than DBTree (~69 minutes vs. ~138 minutes).
This is not to suggest that there are performance issues with DendroPy per se,
which is a very well written, popular, and highly regarded toolkit, but simply
to demonstrate the general problem with processing very large Newick strings
and loading entire trees in memory.

# Discussion

The concepts, tools and data files presented here are intended to make life 
easier for researchers in computational biology. I would therefore like to
reassure the reader that there is no need to dust off any lingering knowledge 
of SQL or Perl to be able to take advantage of the outcomes of this study. 
The databases produced in this study can be navigated conveniently in R by 
accessing them as data frames and processing them with `dbplyr` and related 
tools. I provide an R Markdown document on the git repository (see Data 
Availability) that provides a simple run through of how to operate on the 
databases, showing how to extract clades, MRCAs, and pairwise distances. 

For programming languages where object-relational mapping is a more common, 
mature technique, the schema and databases presented here may form the basis 
for extending the functionality of some popular toolkits. For example, 
generating a mapping for Python results in a tiny SQLAlchemy class that, 
thanks to Python's multiple inheritance model, might subclass DendroPy's tree 
node model, thus making persistently databased trees accessible through the 
same programming interface as memory resident trees. I invite authors of 
libraries that could take advantage of this to consider this possibility.

The performance of the subtree extraction is such that this very common
operation is much easier supported on DBTree-indexed trees than on Newick 
tree files. The implication of this is twofold: i) projects that release 
very large phylogenies periodically - such as the Open Tree of Life project -
might consider making their products available in DBTree format; ii) because
of the quicker return time of the subtree extraction process, the functionality
can also be exposed as a synchronous request/response web service, e.g. as 
envisioned by the PhyloTastic project [@Stoltzfus:2013].

# Acknowledgements

I would like to thank Bill Piel for the numerous conversations we've had over
the years on the topic of representing trees in relational databases, from which
I learned some of the concepts and ideas presented here. I would also like
to thank Mannis van Oven, who kindly provided me with the data dump of the
PhyloTree project. Lastly, I am grateful to the two anonymous reviewers and the
editor of this journal, who helped to improve this manuscript with their
comments.

# Data availability

The source code of this project is available under the same terms as the 
Perl5 core itself, i.e. a combination of the GNU General Public License (v.3) 
and the Artistic License, and is being developed further in a git repository 
at: https://github.com/rvosa/bio-phylo-forest-dbtree

The version of the software presented in this manuscript has been
stored permanently under a DOI at: https://doi.org/10.5281/zenodo.1035856
and is released through the Comprehensive Perl Archive Network at:
https://metacpan.org/release/Bio-Phylo-Forest-DBTree

The database files discussed in this manuscript are available at
the following locations:

| Name              | Citation          | Database DOI                |
|-------------------|-------------------|-----------------------------|
| PhyloTree         | [@vanOven:2009]   | 10.6084/m9.figshare.4620757 |
| D-PLACE           | [@Kirby:2016]     | 10.6084/m9.figshare.4620217 |
| NCBI Taxonomy     | [@Federhen:2012]  | 10.6084/m9.figshare.4620733 |
| Green Genes       | [@DeSantis:2006]  | 10.6084/m9.figshare.4620214 |
| ALLMB             | [@Smith:2018]     | 10.6084/m9.figshare.9747638 |
| Open Tree of Life | [@Hinchliff:2015] | 10.6084/m9.figshare.9750509 |

The benchmarking results, including shell scripts that demonstrate the 
invocation of the tree pruner are available as a data package under DOI
10.6084/m9.figshare.10273940

\newpage

# Figures and tables

![](fig1.pdf)

Figure 1: representation of a tree shape in a relational database, with
additional, precomputed indexes and values. See text for details.

\newpage

![](fig2.pdf)

Figure 2: tree pruning performance comparison. In this example, sets of taxa
of varying sizes (as shown on the x-axis) are randomly sampled and extracted 
as subtrees from the Open Tree of Life topology. The comparison is between an
implementation based on DendroPy that reads the published, Newick version of
the tree as made available by the OpenTOL consortium, and an implementation
that uses the DBTree-indexed version of the same tree. The latter implementation
is made available as the `megatree-pruner` program in the software release. The
running times for both implementations are recorded as the logarithm to base 10
of the real system time in seconds for the respective processes to complete. 
Values range from less than one second to about two and a half hours. See text 
for details.

\newpage

| Name   | Type        | Index                |
|--------|-------------|----------------------|
| id     | int         | primary key not null |
| parent | int         | index                |
| left   | int         | index                |
| right  | int         | index                |
| name   | varchar(20) | index                |
| length | float       |                      |
| height | float       |                      |

Table 1: schema for DBTree databases. See text for details.

\newpage

# References
