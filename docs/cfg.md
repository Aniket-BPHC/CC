# Context-Free Grammar (CFG) — COBOL Subset

## Non-terminals

`program, stmt_list, stmt, decl_stmt, move_stmt, if_stmt, perform_stmt,
expr, logic_or, logic_and, equality, relational, additive, multiplicative, unary, primary, type`

## Terminals (token names)

`DECLARE, PIC, MOVE, TO, IF, THEN, END_IF, PERFORM, UNTIL, END_PERFORM,
TRUE, FALSE, IDENT, NUMBER,
DOT, LPAREN, RPAREN,
PLUS, MINUS, MUL, DIV,
LT, GT, LE, GE, EQ, NE,
AND, OR, NOT, INT_T, BOOL_T`

## Productions

```bnf
program        -> stmt_list

stmt_list      -> stmt_list stmt
               | stmt

stmt           -> decl_stmt
               | move_stmt
               | if_stmt
               | perform_stmt

decl_stmt      -> DECLARE IDENT PIC type DOT

type           -> INT_T
               | BOOL_T

move_stmt      -> MOVE expr TO IDENT DOT

if_stmt        -> IF expr THEN stmt_list END_IF DOT

perform_stmt   -> PERFORM UNTIL expr stmt_list END_PERFORM DOT

expr           -> logic_or

logic_or       -> logic_or OR logic_and
               | logic_and

logic_and      -> logic_and AND equality
               | equality

equality       -> equality EQ relational
               | equality NE relational
               | relational

relational     -> relational LT additive
               | relational GT additive
               | relational LE additive
               | relational GE additive
               | additive

additive       -> additive PLUS multiplicative
               | additive MINUS multiplicative
               | multiplicative

multiplicative -> multiplicative MUL unary
               | multiplicative DIV unary
               | unary

unary          -> NOT unary
               | MINUS unary
               | primary

primary        -> NUMBER
               | TRUE
               | FALSE
               | IDENT
               | LPAREN expr RPAREN
```

## Operator precedence (low → high)

1. `OR`
2. `AND`
3. `=` , `<>`
4. `<`, `>`, `<=`, `>=`
5. `+`, `-`
6. `*`, `/`
7. unary `NOT`, unary `-`
