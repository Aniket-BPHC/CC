# CS F365 Compiler Construction Assignment

This repository contains a complete reference implementation for the assignment using a **COBOL subset language** (as selected by the group).

## Chosen Language

- **Language name:** COBOL (educational subset)
- **Why this choice:** clear business-style statement forms and explicit control structures.

## Deliverables Covered

- ✅ Phase 1
  - Language design
  - CFG specification
  - Lexical specification (regex per terminal)
  - Lex/Flex lexer
  - Valid and lexical-error test inputs
- ✅ Phase 2
  - Bison parser
  - Three-address code (TAC) generation
  - Valid and syntax-error test inputs

## Structure

- `docs/group_report_template.md` — fill in member names/IDs for reporting.
- `docs/cfg.md` — context-free grammar for the COBOL subset.
- `docs/lexical_spec.md` — regex mapping for terminals.
- `src/lexer.l` — Flex lexer.
- `src/parser.y` — Bison parser + TAC generation.
- `examples/` — sample valid/error input programs.
- `Makefile` — build and run helpers.

## Build

```bash
make
```

## Run

```bash
# Full pipeline: lexer + parser + TAC
./compiler examples/valid.cbl

# Lexical error example
./compiler examples/lex_error.cbl

# Syntax error example
./compiler examples/syntax_error.cbl
```

## Clean

```bash
make clean
```
