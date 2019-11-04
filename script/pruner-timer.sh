#!/bin/bash
TREE=$1
CSV=$2
DB=$3
NTIPS=$4

# sample $NTIPS lines and make comma separated
TIPS=$(cut -f3 -d, $CSV | egrep -v 'n\d+' | sort -R | head -$NTIPS | sed -e ':a' -e 'N;$!ba' -e 's/\n/,/g')

# time python
time perl megatree-pruner -d "$DB" -l "$TIPS" -v
time python megatree-pruner.py -t "$TREE" -l "$TIPS" -v