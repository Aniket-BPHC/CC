%{ 
#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);
extern int yylineno;
extern FILE *yyin;

static int temp_count = 0;
static int label_count = 0;

#define STACK_MAX 256
static char *if_end_stack[STACK_MAX];
static int if_sp = 0;

static char *loop_start_stack[STACK_MAX];
static char *loop_end_stack[STACK_MAX];
static int loop_sp = 0;

static char *new_temp(void) {
    char buf[32];
    snprintf(buf, sizeof(buf), "t%d", temp_count++);
    return strdup(buf);
}

static char *new_label(void) {
    char buf[32];
    snprintf(buf, sizeof(buf), "L%d", label_count++);
    return strdup(buf);
}

static char *emit_bin(const char *a, const char *op, const char *b) {
    char *t = new_temp();
    printf("%s = %s %s %s\n", t, a, op, b);
    return t;
}

static void push_if_end(char *label) {
    if (if_sp >= STACK_MAX) {
        fprintf(stderr, "Internal error: IF stack overflow\n");
        exit(1);
    }
    if_end_stack[if_sp++] = label;
}

static char *pop_if_end(void) {
    if (if_sp <= 0) {
        fprintf(stderr, "Internal error: IF stack underflow\n");
        exit(1);
    }
    return if_end_stack[--if_sp];
}

static void push_loop_labels(char *start, char *end) {
    if (loop_sp >= STACK_MAX) {
        fprintf(stderr, "Internal error: LOOP stack overflow\n");
        exit(1);
    }
    loop_start_stack[loop_sp] = start;
    loop_end_stack[loop_sp] = end;
    loop_sp++;
}

static void pop_loop_labels(char **start, char **end) {
    if (loop_sp <= 0) {
        fprintf(stderr, "Internal error: LOOP stack underflow\n");
        exit(1);
    }
    loop_sp--;
    *start = loop_start_stack[loop_sp];
    *end = loop_end_stack[loop_sp];
}
%}

%union {
    char *str;
}

%token DECLARE PIC MOVE TO IF THEN END_IF PERFORM UNTIL END_PERFORM
%token TRUE FALSE INT_T BOOL_T
%token <str> IDENT NUMBER
%token DOT LPAREN RPAREN
%token PLUS MINUS MUL DIV
%token LT GT LE GE EQ NE
%token AND OR NOT

%type <str> expr logic_or logic_and equality relational additive multiplicative unary primary

%left OR
%left AND
%left EQ NE
%left LT GT LE GE
%left PLUS MINUS
%left MUL DIV
%right NOT UMINUS

%%
program
    : stmt_list
    ;

stmt_list
    : stmt_list stmt
    | stmt
    ;

stmt
    : decl_stmt
    | move_stmt
    | if_stmt
    | perform_stmt
    ;

decl_stmt
    : DECLARE IDENT PIC type DOT
      {
        printf("declare %s\n", $2);
        free($2);
      }
    ;

type
    : INT_T
    | BOOL_T
    ;

move_stmt
    : MOVE expr TO IDENT DOT
      {
        printf("%s = %s\n", $4, $2);
        free($4);
        free($2);
      }
    ;

if_stmt
    : IF expr THEN
      {
        char *lend = new_label();
        push_if_end(lend);
        printf("ifFalse %s goto %s\n", $2, lend);
        free($2);
      }
      stmt_list END_IF DOT
      {
        char *lend = pop_if_end();
        printf("%s:\n", lend);
        free(lend);
      }
    ;

perform_stmt
    : PERFORM UNTIL
      {
        char *lstart = new_label();
        char *lend = new_label();
        push_loop_labels(lstart, lend);
        printf("%s:\n", lstart);
      }
      expr
      {
        printf("if %s goto %s\n", $4, loop_end_stack[loop_sp - 1]);
        free($4);
      }
      stmt_list END_PERFORM DOT
      {
        char *lstart = NULL;
        char *lend = NULL;
        pop_loop_labels(&lstart, &lend);
        printf("goto %s\n", lstart);
        printf("%s:\n", lend);
        free(lstart);
        free(lend);
      }
    ;

expr
    : logic_or { $$ = $1; }
    ;

logic_or
    : logic_or OR logic_and       { $$ = emit_bin($1, "OR", $3); free($1); free($3); }
    | logic_and                   { $$ = $1; }
    ;

logic_and
    : logic_and AND equality      { $$ = emit_bin($1, "AND", $3); free($1); free($3); }
    | equality                    { $$ = $1; }
    ;

equality
    : equality EQ relational      { $$ = emit_bin($1, "=", $3); free($1); free($3); }
    | equality NE relational      { $$ = emit_bin($1, "<>", $3); free($1); free($3); }
    | relational                  { $$ = $1; }
    ;

relational
    : relational LT additive      { $$ = emit_bin($1, "<", $3); free($1); free($3); }
    | relational GT additive      { $$ = emit_bin($1, ">", $3); free($1); free($3); }
    | relational LE additive      { $$ = emit_bin($1, "<=", $3); free($1); free($3); }
    | relational GE additive      { $$ = emit_bin($1, ">=", $3); free($1); free($3); }
    | additive                    { $$ = $1; }
    ;

additive
    : additive PLUS multiplicative { $$ = emit_bin($1, "+", $3); free($1); free($3); }
    | additive MINUS multiplicative{ $$ = emit_bin($1, "-", $3); free($1); free($3); }
    | multiplicative               { $$ = $1; }
    ;

multiplicative
    : multiplicative MUL unary     { $$ = emit_bin($1, "*", $3); free($1); free($3); }
    | multiplicative DIV unary     { $$ = emit_bin($1, "/", $3); free($1); free($3); }
    | unary                        { $$ = $1; }
    ;

unary
    : NOT unary
      {
        char *t = new_temp();
        printf("%s = NOT %s\n", t, $2);
        free($2);
        $$ = t;
      }
    | MINUS unary %prec UMINUS
      {
        char *t = new_temp();
        printf("%s = - %s\n", t, $2);
        free($2);
        $$ = t;
      }
    | primary                      { $$ = $1; }
    ;

primary
    : NUMBER                       { $$ = $1; }
    | TRUE                         { $$ = strdup("TRUE"); }
    | FALSE                        { $$ = strdup("FALSE"); }
    | IDENT                        { $$ = $1; }
    | LPAREN expr RPAREN           { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error at line %d: %s\n", yylineno, s);
}

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <source-file>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("fopen");
        return 1;
    }

    int rc = yyparse();
    fclose(yyin);

    if (rc == 0) {
        printf("Parsing completed successfully.\n");
    }
    return rc;
}
