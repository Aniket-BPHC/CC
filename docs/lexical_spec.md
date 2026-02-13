# Lexical Specification (Regex per Terminal) — COBOL Subset

Whitespace and comments are ignored.

## Basic macros

- `DIGIT`  → `[0-9]`
- `LETTER` → `[A-Za-z]`
- `IDENT`  → `{LETTER}({LETTER}|{DIGIT}|-)*`
- `NUMBER` → `{DIGIT}+`

## Reserved words

- `DECLARE`     → `DECLARE`
- `PIC`         → `PIC`
- `MOVE`        → `MOVE`
- `TO`          → `TO`
- `IF`          → `IF`
- `THEN`        → `THEN`
- `END_IF`      → `END-IF`
- `PERFORM`     → `PERFORM`
- `UNTIL`       → `UNTIL`
- `END_PERFORM` → `END-PERFORM`
- `TRUE`        → `TRUE`
- `FALSE`       → `FALSE`
- `INT_T`       → `INT`
- `BOOL_T`      → `BOOL`
- `AND`         → `AND`
- `OR`          → `OR`
- `NOT`         → `NOT`

## Operators and punctuation

- `EQ`     → `=`
- `NE`     → `<>`
- `LE`     → `<=`
- `GE`     → `>=`
- `LT`     → `<`
- `GT`     → `>`
- `PLUS`   → `\+`
- `MINUS`  → `-`
- `MUL`    → `\*`
- `DIV`    → `/`
- `LPAREN` → `\(`
- `RPAREN` → `\)`
- `DOT`    → `\.`

## Ignored tokens

- `WHITESPACE` → `[ \t\r\n]+`
- `COMMENT`    → `\*[^\n]*` (line starting with `*` in this subset)

## Error token

- Any unmatched character is reported as lexical error.
