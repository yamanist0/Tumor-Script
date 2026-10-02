# Syntax and Keywords Dictionary

TumorScript uses an intuitive, indentation-based grammar combined with biological keywords.

---

## Keyword Dictionary

| Conventional Concept | TumorScript Keyword | Biological Meaning & Role |
|---|---|---|
| `var` / `let` | `dna` | Standard mutable variable subject to entropic decay on each read. |
| `const` | `rna` | Immutable constant, immune to mutation and modification. |
| `class` / `struct` | `cell` | Living blueprint defining fields, states, and cellular parameters. |
| `function` / `def` | `gene` | Functional expression of cellular logic. Susceptible to contagion. |
| `new` / `clone` | `mitosis` | Spawns an independent living cellular instance from a `cell` blueprint. |
| `return` | `apoptosis` | Clean programmed cell death; terminates execution and returns data. |
| `import` / `export` | `metastasis` | Cross-module dissemination of cells and logic across file boundaries. |
| `try` / `catch` | `chemo` / `quarantine` | Error and entropy containment strategies. |

---

## Detailed Syntax Rules

### 1. Variables and Types

Variables are dynamically typed but strictly bounded by their genomic type:

```python
# dynamic, mutating variables
dna counter = 0
dna patient_name = "Subject-42"
dna temperature = 98.6

# static, immune constants
rna MAX_THRESHOLD = 150
rna PROTOCOL_NAME = "ISO-TUMOR-99"
```

Reassigning to an `rna` identifier triggers a fatal runtime error:
```
IMMUNE_VIOLATION: cannot reassign rna constant 'MAX_THRESHOLD'
```

### 2. Cellular Definitions (`cell`) and Division (`mitosis`)

Cells declare internal `dna` and `rna` fields. Instances are produced via `mitosis`:

```python
cell CultureSample:
    dna density = 1.05
    dna cell_count = 1000
    rna serial = "CS-2026-X"

gene main():
    dna sample_a = mitosis CultureSample()
    dna sample_b = mitosis CultureSample()
    
    print("Sample A Count:", sample_a.cell_count)
```

Each instance holds isolated state; field access mutates that specific field.

### 3. Functional Logic (`gene`) and Termination (`apoptosis`)

Genes receive parameters as local variables and terminate via `apoptosis`:

```python
gene synthesize(sample, factor):
    dna adjusted = sample.density * factor
    if adjusted > 10.0:
        print("Hyper-dense reaction detected!")
    apoptosis adjusted
```

### 4. Control Flow

TumorScript supports `if`, `elif`, `else`, and `while` structures:

```python
if patient.heart_rate > 100:
    print("Tachycardia alert")
elif patient.heart_rate < 50:
    print("Bradycardia alert")
else:
    print("Normal rhythm")

while cycle < 10:
    cycle = cycle + 1
```

### 5. Quarantine Blocks (`quarantine { ... }`)

The `{}` symbols are reserved exclusively for the `quarantine` block. Using them anywhere else causes an immediate `SYNTAX_TUMOR` error during lexical analysis.

```python
quarantine {
    dna safe_val = volatile_data * 2
    print("[STERILE] Safe Value:", safe_val)
}
```
