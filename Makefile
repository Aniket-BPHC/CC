CC=gcc
CFLAGS=-Wall -Wextra -std=c11
LEX=flex
YACC=bison

all: compiler

parser.tab.c parser.tab.h: src/parser.y
	$(YACC) -d -o parser.tab.c src/parser.y

lex.yy.c: src/lexer.l parser.tab.h
	$(LEX) -o lex.yy.c src/lexer.l

compiler: parser.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o compiler parser.tab.c lex.yy.c -lfl

run-valid: compiler
	./compiler examples/valid.cbl

run-lex-error: compiler
	./compiler examples/lex_error.cbl

run-syntax-error: compiler
	./compiler examples/syntax_error.cbl

clean:
	rm -f compiler parser.tab.c parser.tab.h lex.yy.c
