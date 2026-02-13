%{ 
#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

extern int yylineno;
%}

%option noyywrap nounput noinput caseless yylineno

DIGIT      [0-9]
LETTER     [A-Za-z]
IDENT      {LETTER}({LETTER}|{DIGIT}|-)*
NUMBER     {DIGIT}+
WS         [ \t\r]+

%%
"DECLARE"            { return DECLARE; }
"PIC"                { return PIC; }
"MOVE"               { return MOVE; }
"TO"                 { return TO; }
"IF"                 { return IF; }
"THEN"               { return THEN; }
"END-IF"             { return END_IF; }
"PERFORM"            { return PERFORM; }
"UNTIL"              { return UNTIL; }
"END-PERFORM"        { return END_PERFORM; }
"TRUE"               { return TRUE; }
"FALSE"              { return FALSE; }
"INT"                { return INT_T; }
"BOOL"               { return BOOL_T; }
"AND"                { return AND; }
"OR"                 { return OR; }
"NOT"                { return NOT; }

"<>"                 { return NE; }
"<="                 { return LE; }
">="                 { return GE; }
"="                  { return EQ; }
"<"                  { return LT; }
">"                  { return GT; }
"+"                  { return PLUS; }
"-"                  { return MINUS; }
"*"                  { return MUL; }
"/"                  { return DIV; }
"("                  { return LPAREN; }
")"                  { return RPAREN; }
"."                  { return DOT; }

{NUMBER}             { yylval.str = strdup(yytext); return NUMBER; }
{IDENT}              { yylval.str = strdup(yytext); return IDENT; }

^[ \t]*\*.*          { /* COBOL-style comment line */ }
{WS}                 { /* ignore spaces/tabs */ }
\n                   { /* yylineno is auto-maintained by flex */ }

.                    {
                        fprintf(stderr, "Lexical error at line %d: unexpected character '%s'\n", yylineno, yytext);
                        return 0;
                     }
%%
