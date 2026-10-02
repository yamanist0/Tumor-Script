# Architecture and Compiler Design

TumorScript's reference implementation is engineered in modular Lua, organized into three distinct pipeline stages: lexical analysis, abstract syntax tree (AST) construction, and the biomorphic virtual runtime.

---

## 1. System Pipeline Overview

```
Source (.tmq)
     │
     ▼
┌──────────────┐
│  src/lexer   │ ──► Tokens (INDENT/DEDENT, Braces Check)
└──────────────┘
     │
     ▼
┌──────────────┐
│  src/parser  │ ──► Abstract Syntax Tree + 20% Quarantine Check
└──────────────┘
     │
     ▼
┌──────────────┐
│ src/runtime  │ ──► Dynamic Heap (src/memory) + Execution (src/interpreter)
└──────────────┘
```

---

## 2. Lexical Analyzer (`src/lexer.lua`)

The lexer converts stream text into discrete tokens while enforcing biomorphic structural rules:

* **Indentation Tracking:** Manages an indentation level stack (`indent_stack`), generating virtual `INDENT` and `DEDENT` tokens.
* **Line-Insensitive Braces:** Enforces that `{` can only occur when `quarantine` was the directly preceding keyword.
* **Multiline String & Comment Strip:** Treats `#` as full-line or trailing comments, stripping them prior to AST emission.

---

## 3. The 20% Quarantine Limit

To preserve the language's core philosophy (preventing developers from simply enclosing entire programs in quarantine), the parser calculates total physical lines upon initial read.

```lua
local q_lines = math.max(1, line_end - line_start + 1)
self.quarantine_lines = self.quarantine_lines + q_lines
local ratio = self.quarantine_lines / math.max(self.total_lines, 1)

if ratio > 0.20 then
    error(string.format(
        "QUARANTINE_OVERFLOW at line %d: quarantine blocks exceed 20%% limit (%.1f%% used)",
        line, ratio * 100))
end
```

If the aggregated line count of all quarantine chambers exceeds $20\%$, compilation immediately halts with `QUARANTINE_OVERFLOW`.

---

## 4. Memory Layout (`src/memory.lua`)

Every variable in TumorScript is represented in the heap as an organic memory block:

```lua
local function make_dna(value)
    return {
        type = "dna",
        value = value,
        original_value = value,
        mutation_rate = 0.005,
        read_count = 0,
        is_malignant = false,
    }
end
```

### Scope Stacks
Scopes are modeled as nested tables. Entering a function or quarantine chamber invokes `push_scope()`, creating isolated namespace layers. Leaving invokes `pop_scope()`, which recalculates the active living population and deducts deceased variables from system statistics.

---

## 5. Execution Engine (`src/interpreter.lua`)

The interpreter conducts a two-phase walk over the AST:
1. **Registration Pass:** Traverses top-level nodes to register all `gene` definitions and `cell` blueprints into module lookup tables.
2. **Execution Pass:** Evaluates sequential statements, automatically triggering the parameterless `main()` gene if declared.
