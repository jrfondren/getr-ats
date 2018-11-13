CC=patscc
CFLAGS=-O3

all:: getr

clean::
	rm -fv getr *_[sd]ats.[co]

getr: getr.dats
	$(CC) $(CFLAGS) -o $@ $<
