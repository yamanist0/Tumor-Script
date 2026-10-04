# Language Specification

TumorScript is an experimental programming language merging biological principles with computational execution. This document outlines the official language identity, syntax paradigm, and file specification.

---

## 1. Project Identity

* **Language Name:** TumorScript
* **Target Paradigms:** Biomorphic, Entropic, Dynamic, Imperative, Object-Oriented (Cellular).
* **Reference Implementation:** Standalone native compiler (Rust MLua embedded runtime) and direct tree-walking interpreter.
* **Indentation Model:** Minimalist, Python-like significant indentation without statement semicolons (`;`).
* **Brace Exclusivity:** Curly braces `{}` are strictly prohibited across the entire language grammar except immediately after the `quarantine` keyword.

---

## 2. File Specification

TumorScript standardizes on a single official file format:

| Extension | Formal Name | Containment Level | Description |
|---|---|---|---|
| `.tmq` | Tumor Quarantine | Level 4 (Primary) | Official executable source file containing cellular logic, quarantine chambers, and program entrypoints. |

All TumorScript interpreters and compilers require the `.tmq` extension for source execution.

---

## 3. Grammar Synopsis

A TumorScript program consists of a sequence of top-level declarations, including `metastasis` imports, `cell` definitions, `gene` definitions, and executable statements.

```ebnf
Program         ::= Statement* EOF ;
Statement       ::= VarDecl | GeneDef | CellDef | Metastasis | Quarantine | Chemo | Apoptosis
                  | IfStmt | WhileStmt | ForStmt | RemissionStmt | RelapseStmt | PrintStmt | AssignStmt ;

VarDecl         ::= ("dna" | "rna") IDENTIFIER "=" Expression ;
CellDef         ::= "cell" IDENTIFIER ":" INDENT VarDecl* DEDENT ;
GeneDef         ::= "gene" IDENTIFIER "(" ParameterList? ")" ":" INDENT Statement* DEDENT ;
Quarantine      ::= "quarantine" "{" NEWLINE Statement* "}" ;
Chemo           ::= "chemo" (IDENTIFIER | DotAccess) ;
Apoptosis       ::= "apoptosis" Expression? ;
IfStmt          ::= "if" Expression ":" INDENT Statement* DEDENT
                    ("elif" Expression ":" INDENT Statement* DEDENT)*
                    ("else" ":" INDENT Statement* DEDENT)? ;
WhileStmt       ::= "while" Expression ":" INDENT Statement* DEDENT ;
ForStmt         ::= "for" IDENTIFIER "in" Expression ":" INDENT Statement* DEDENT ;
RemissionStmt   ::= "remission" ;
RelapseStmt     ::= "relapse" ;
PrintStmt       ::= "print" "(" ArgumentList? ")" ;
AssignStmt      ::= (IDENTIFIER | DotAccess | IndexAccess) "=" Expression ;

Expression      ::= LogicalOr ;
LogicalOr       ::= LogicalAnd ("or" LogicalAnd)* ;
LogicalAnd      ::= Equality ("and" Equality)* ;
Equality        ::= Comparison (("==" | "!=") Comparison)* ;
Comparison      ::= Term (("<" | "<=" | ">" | ">=") Term)* ;
Term            ::= Factor (("+" | "-") Factor)* ;
Factor          ::= Unary (("*" | "/" | "%") Unary)* ;
Unary           ::= ("-" | "not") Unary | Postfix ;
Postfix         ::= Primary (CallSuffix | DotSuffix | IndexSuffix)* ;

CallSuffix      ::= "(" ArgumentList? ")" ;
DotSuffix       ::= "." IDENTIFIER ;
IndexSuffix     ::= "[" Expression "]" ;

Primary         ::= NUMBER | STRING | "true" | "false" | "nil" | IDENTIFIER
                  | TumorLiteral | MitosisExpr | "(" Expression ")" ;

TumorLiteral    ::= "[" ArgumentList? "]" ;
MitosisExpr     ::= "mitosis" IDENTIFIER "(" ")" ;
ParameterList   ::= IDENTIFIER ("," IDENTIFIER)* ;
ArgumentList    ::= Expression ("," Expression)* ;
```
