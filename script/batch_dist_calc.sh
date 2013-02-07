#! /bin/bash

# This script takes a file containing pairs of IDs as argument.
# Then it calls search.pl to retrieve the distance that separates them on the tree

ID_FILE=$1

SEARCH_DIST="./search.pl"

cat $ID_FILE | while read LINE ; do
    #echo $LINE
    ID1=`echo $LINE | cut -d ' ' -f 1`
    ID2=`echo $LINE | cut -d ' ' -f 2`
    #echo "got $ID1 vs $ID2"
    DIST=`$SEARCH_DIST -t1 $ID1 -t2 $ID2`
    echo -e "$ID1\t$ID2\t$DIST"
done

