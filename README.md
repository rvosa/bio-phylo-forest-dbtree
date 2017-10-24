Bio::Phylo::Forest::DBTree
==========================
An object-oriented API to operate on very large phylogenies stored in portable databases

Release
-------
The most recent release is: 

[![DOI](https://zenodo.org/badge/8080160.svg)](https://zenodo.org/badge/latestdoi/8080160)

Requires
--------
* [Bio::Phylo](http://search.cpan.org/dist/Bio-Phylo/)
* [DBIx::Class](http://search.cpan.org/dist/DBIx-Class/)
* [DBD::SQLite](http://search.cpan.org/dist/DBD-SQLite/)
* An installation of [sqlite3](https://www.sqlite.org/)

Installation
------------
This package can be installed in the standard ways, e.g. using the `ExtUtils::MakeMaker`
workflow:

    $ perl Makefile.PL
    $ make
    $ sudo make install

Alternatively, the `cpanm` workflow can be used to install directly from github, i.e.

    $ sudo cpanm git://github.com/rvosa/bio-phylo-forest-dbtree.git

BUGS
----
Please report any bugs or feature requests on the GitHub bug tracker:

https://github.com/rvosa/bio-phylo-forest-dbtree/issues

BUILD STATUS
------------
Currently, the build status at Travis is:

[![Build Status](https://travis-ci.org/rvosa/bio-phylo-forest-dbtree.svg?branch=master)](https://travis-ci.org/rvosa/bio-phylo-forest-dbtree)

SEE ALSO
--------
Several curated, large phylogenies released by ongoing projects are made available as
database files that this distribution can operate on. These are:
- PhyloTree ([van Oven et al., 2009][1])   - [10.6084/m9.figshare.4620757.v1](http://doi.org/10.6084/m9.figshare.4620757.v1)
- D-Place ([Kirby et al., 2016][2])        - [10.6084/m9.figshare.4620217.v1](http://doi.org/10.6084/m9.figshare.4620217.v1)
- NCBI taxonomy ([Federhen, 2011][3])      - [10.6084/m9.figshare.4620733.v1](http://doi.org/10.6084/m9.figshare.4620733.v1)
- Green Genes ([DeSantis et al., 2006][4]) - [10.6084/m9.figshare.4620214.v1](http://doi.org/10.6084/m9.figshare.4620214.v1)

[1]: http://doi.org/10.1002/humu.20921
[2]: http://doi.org/10.1371/journal.pone.0158391
[3]: http://doi.org/10.1093/nar/gkr1178
[4]: http://doi.org/10.1128/AEM.03006-05
