#Authors: Parker Riggs and Ayden Herring

# Compiler flags
CFLAGS   = -Wall -Werror -O2
CXXFLAGS = -Wall -Werror -O2

CC  = gcc
CXX = g++

PROGRAM = compiler

all: $(PROGRAM)

$(PROGRAM): tree_builder.tab.c lex.yy.c main.cc parse_tree.h tree_node.h
	$(CXX) $(CXXFLAGS) -x c++ tree_builder.tab.c lex.yy.c main.cc -o $(PROGRAM) $(LEXLIB)

tree_builder.tab.c tree_builder.tab.h: tree_builder.y parse_tree.h tree_node.h
	bison -d tree_builder.y

lex.yy.c: tree_builder.l tree_builder.tab.h
	flex tree_builder.l

test: $(PROGRAM)
	./$(PROGRAM) < input.txt

clean:
	rm -f lex.yy.c tree_builder.tab.c tree_builder.tab.h $(PROGRAM)