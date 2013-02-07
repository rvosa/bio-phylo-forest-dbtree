The approach I took is to first break the tree string down into nested
chunks of about equal sizes (set by CHUNKSIZE in the Makefile). This
creates a set of newick tree files where the root label of each subtree
matches one of the tip labels in its containing backbone tree. (This was
done recursively by the chunkify.pl script). Subsequently, I created tab-
separated files that enumerate each tip-to-root path in a subtree (this is
the distify.pl script). 

By grepping through these files in the db folder, we can then reconstruct 
the paths to the MRCA for every pair of tips, and add up their branch 
lengths to get the total distance.

You can compute the distance between any two tips by this command:

perl search.pl -t1 <tip1 id> -t2 <tip2 id>

For example:

perl search.pl -t1 51110 -t2 75371

This will return a patristic distance after 2-3 seconds, which is not great 
but perhaps good enough?

The db folder was created by running the 'make chunks' and 'make paths' targets. 
You can re-do these steps by running 'make clean', perhaps to experiment with 
different chunk sizes. Pretty 1000 seems to work well, 10000 is hard on my laptop 
but it works on my workstation. The newick string for the input tree should be 
rather clean, it's handled by a very stupid initial parser. Have a look in the 
Makefile.
