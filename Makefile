all : docs code

########
# DOCS #
########

docs : report.pdf report.html

# WEAVING
report.html : main.nw
	echo "<nowebchunks>" | cat - main.nw | noweave -option longxref -autodefs c -index -html -filter "l2h | btdefn" > report.html
# I ought to figure out how to get that | footohtml noweb program to build an 
# index out of sections and subsections... TODO

report.tex : main.nw Makefile
	cat main.nw | noweave -delay -autodefs c -filter btdefn -index | cpif report.tex
# Preceding -index with -autodefs c should be interesting to try on more
# complete code. For now, I've removed it since it's not enough of a 'web'.
# Edit: using hideunuseddefs \noweboption{} might result in less cruft.
# giving this another go.

# Generating the report could also be done by using noweave -n to not generate
# headers/footers. Then having multiple .nw files generate multiple .tex files,
# then lumping it all together.
# This guarantees total independance, although I'm not sure if it'll look any
# different. Will an index be generated and displayed for each individual file?

# LATEX & GRAPHVIZ
report.pdf : report.tex design.png
	pdflatex -interaction nonstopmode report.tex
design.png : design.dot
	dot -Tpng design.dot > design.png

########
# CODE #
########

code : main

# TANGLING
TANGLE=$(TT) $(TFLAGS) main.nw
TT=notangle
TFLAGS=-L # -L generates #line hints for the compiler, pointing to noweb file
#TFLAGS=

# cpif overwrites the file if stdin version is different
#   (this is to cope with the fact that ALL code files depend on ONE
#          noweb file, which results in constant recompiles)
model.h : main.nw
	$(TANGLE) -Rmodel.h | cpif model.h
load.h : main.nw
	$(TANGLE) -Rload.h  | cpif load.h
load.c : main.nw
	$(TANGLE) -Rload.c | cpif load.c
city.h : main.nw
	$(TANGLE) -Rcity.h  | cpif city.h
city.c : main.nw
	$(TANGLE) -Rcity.c | cpif city.c
main.c : main.nw
	$(TANGLE) -Rmain.c | cpif main.c
vec.h : main.nw
	$(TANGLE) -Rvec.h | cpif vec.h
vec.c : main.nw
	$(TANGLE) -Rvec.c | cpif vec.c
render.h : main.nw
	$(TANGLE) -Rrender.h | cpif render.h
render.c : main.nw
	$(TANGLE) -Rrender.c | cpif render.c
texture.h : main.nw
	$(TANGLE) -Rtexture.h | cpif texture.h
texture.c : main.nw
	$(TANGLE) -Rtexture.c | cpif texture.c

# COMPILATION

CC=gcc
#CFLAGS=-std=c99 -Wall
CFLAGS=-std=c99 -Wall -g

main: main.o city.o load.o vec.o render.o texture.o Makefile
	$(CC) $(CFLAGS) -o main main.o load.o city.o vec.o render.o texture.o -lglut

main.o: main.c load.h model.h vec.h
	$(CC) $(CFLAGS) -c main.c 

load.o : load.c load.h model.h vec.h
	$(CC) $(CFLAGS) -c load.c

city.o : city.c city.h model.h vec.h
	$(CC) $(CFLAGS) -c city.c

vec.o : vec.c vec.h
	$(CC) $(CFLAGS) -c vec.c

render.o : render.c render.h
	$(CC) $(CFLAGS) -c render.c

texture.o : texture.c texture.h
	$(CC) $(CFLAGS) -c texture.c

clean:
	rm -f main *.o
