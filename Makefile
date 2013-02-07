DBDIR=db
INFILE=16S_candiv_gg_2011_1
CHUNKSIZE=1000
SUBTREES:= $(wildcard $(DBDIR)/*.dnd)
PATHS:=$(patsubst %.dnd,%.tsv,$(SUBTREES))

.PHONY : clean chunks

clean :
	rm -rf $(DBDIR)

clean_subtrees :
	rm -rf $(SUBTREES)

chunks :
	perl chunkify.pl -o $(DBDIR) -i $(INFILE) -c $(CHUNKSIZE)

%.tsv : %.dnd
	perl distify.pl -i $< > $@
	
paths : $(PATHS)