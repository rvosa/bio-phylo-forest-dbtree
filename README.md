[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1035856.svg)](https://doi.org/10.5281/zenodo.1035856)
[![Build Status](https://travis-ci.org/rvosa/bio-phylo-forest-dbtree.svg?branch=master)](https://travis-ci.org/rvosa/bio-phylo-forest-dbtree)
![CPAN](https://img.shields.io/cpan/l/Bio-Phylo-Forest-DBTree?color=success)

DBTree - toolkit for megatrees in portable databases
====================================================

Installation
------------

The following installation instructions describe three different ways to install the
package. Unless you know what you are doing, the first way is probably the best one.

### 1. From the Comprehensive Perl Archive Network (CPAN)

On many Linux-like operating systems as well as MacOSX, the entire installation completes
with this single command:

    sudo cpanm Bio::Phylo::Forest::DBTree

- **Advantages** - it's simple, all prerequisites are automatically installed. You will
  obtain the [latest stable release][5] on CPAN, which is [amply tested][6].
- **Disadvantages** - you will likely get code that is a lot older than the latest work
  on this package.

### 2. From GitHub

On many Linux-like operating systems as well as MacOSX, you can instal the latest code
from the [repository][8] with this single command:

    sudo cpanm git://github.com/rvosa/bio-phylo-forest-dbtree.git

- **Advantages** - it's simple, all prerequisites are automatically installed. You will
  get the latest code, including any new features and bug fixes.
- **Disadvantages** - you will install untested, recent code, which might include new bugs 
  or other features, in your system folders.

### 3. From an archive snapshot

This is the approach you might take if you want complete control over the installation,
and/or if there is a specific archive (such as zenodo release [10.5281/zenodo.1035856][7])
you wish to install or verify. 

This approach starts by installing the prerequisites manually:

    # do this only if you don't already have these already
    sudo cpanm Bio::Phylo
    sudo cpanm DBIx::Class
    sudo cpanm DBD::SQLite

Then, unpack the archive, move into the top level folder, and issue the build commands:

    perl Makefile.PL
    make
    make test

Finally, you can opt to install the built products (using `sudo make install`), or
keep them in the present location, which would require you to update two environment
variables:

    # add the script folder inside the archive to the search path for executables
    export PATH="$PATH":`pwd`/script
    
    # add the lib folder to the search path for perl libraries
    export PERL5LIB="$PERL5LIB":`pwd`/lib

BUGS
----
Please report any bugs or feature requests on the GitHub bug tracker:
https://github.com/rvosa/bio-phylo-forest-dbtree/issues

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
[5]: https://metacpan.org/release/Bio-Phylo-Forest-DBTree
[6]: http://www.cpantesters.org/distro/B/Bio-Phylo-Forest-DBTree.html
[7]: https://doi.org/10.5281/zenodo.1035856
[8]: https://github.com/rvosa/bio-phylo-forest-dbtree
