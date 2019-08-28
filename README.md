[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1035856.svg)](https://doi.org/10.5281/zenodo.1035856)
[![Build Status](https://travis-ci.org/rvosa/bio-phylo-forest-dbtree.svg?branch=master)](https://travis-ci.org/rvosa/bio-phylo-forest-dbtree)
![CPAN](https://img.shields.io/cpan/l/Bio-Phylo-Forest-DBTree?color=success)

Bio::Phylo::Forest::DBTree
==========================
An object-oriented API to operate on very large phylogenies stored in portable databases

Requires
--------
* [Bio::Phylo](http://search.cpan.org/dist/Bio-Phylo/)
* [DBIx::Class](http://search.cpan.org/dist/DBIx-Class/)
* [DBD::SQLite](http://search.cpan.org/dist/DBD-SQLite/)
* An installation of [sqlite3](https://www.sqlite.org/)

Installation
------------
This package can be installed in the standard ways, e.g. after downloading from this 
repository, using the `ExtUtils::MakeMaker` workflow:

    $ perl Makefile.PL
    $ make
    $ sudo make install

Alternatively, the `cpanm` workflow can be used to install directly from github, i.e.

    $ sudo cpanm git://github.com/rvosa/bio-phylo-forest-dbtree.git

Or, opting for the most recent [release](http://search.cpan.org/dist/Bio-Phylo-Forest-DBTree/)
from CPAN, using:

    $ sudo cpanm Bio::Phylo::Forest::DBTree

BUGS
----
Please report any bugs or feature requests on the GitHub bug tracker:

https://github.com/rvosa/bio-phylo-forest-dbtree/issues

Releases
--------

- Stable, tested, polished releases are posted intermittently to the Comprehensive Perl Archive
  Network, here: [B/Bio-Phylo-Forest-DBTree](https://metacpan.org/release/Bio-Phylo-Forest-DBTree).
  The CPAN releases are tested on very many different computers, the results of which you
  can verify at [cpantesters.org](http://www.cpantesters.org/distro/B/Bio-Phylo-Forest-DBTree.html)
- To accompany scholarly manuscripts, certain snapshots of the repository are posted to
  Zenodo and assigned a DOI, the most recent of which is [10.5281/zenodo.1035856](https://doi.org/10.5281/zenodo.1035856)
- The [git repository](https://github.com/rvosa/bio-phylo-forest-dbtree) always contains the 
  most recent code, though with this you run the minor risk of installing untested features.
  If you go this route, the key thing to look out for is whether the current build is passing
  all tests: [![Build Status](https://travis-ci.org/rvosa/bio-phylo-forest-dbtree.svg?branch=master)](https://travis-ci.org/rvosa/bio-phylo-forest-dbtree)

COPYRIGHT & LICENSE
-------------------
Copyright 2013-2019 Rutger Vos, All Rights Reserved. This program is free software; 
you can redistribute it and/or modify it under the same terms as Perl itself, i.e.
a choice between the following licenses:
- [The Artistic License](COPYING)
- [GNU General Public License v3.0](LICENSE)

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
