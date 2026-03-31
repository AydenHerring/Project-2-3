#Authors: Parker Riggs and Ayden Herring

#compile
LEX = flex
CC = gcc

#output
TARGET = lexer

all: $(TARGET)

$(TARGET): lex.yy.c
	$(CC) lex.yy.c -o $(TARGET)

lex.yy.c: TreeBuilder.l
	$(LEX) TreeBuilder.l

test: $(TARGET)
	./$(TARGET) < input.txt

clean:
	rm -f lex.yy.c $(TARGET)