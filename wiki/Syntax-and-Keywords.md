# Syntax and Keywords Dictionary

TumorScript uses an intuitive, indentation-based grammar combined with biological keywords and data structures.

---

## Keyword & Built-in Dictionary

| Conventional Concept | TumorScript Construct | Biological Meaning & Role |
|---|---|---|
| `var` / `let` | `dna` | Standard mutable variable subject to entropic decay on each read. |
| `const` | `rna` | Immutable constant, immune to mutation and modification. |
| `array` / `list` | `tumor(...)` / `[...]` | Ordered cluster of cells; reading elements mutates them. |
| `dict` / `map` | `membrane(...)` | Cell membrane receptor-ligand key-value pairs. |
| `break` | `remission` | Premature cessation of loop iteration (tumor remission). |
| `continue` | `relapse` | Skip remainder of cycle and jump to next phase (tumor relapse). |
| `for ... in` | `for cell in cluster:` | Cellular iteration over tumors, membranes, and sequences. |
| `range(start, stop)` | `range(...)` | Generates a sequential tumor growth array. |
| ⭐ *Unique* | `necrosis(N, val)` | Timed cell death; automatically decays and dies after N reads. |
| `biopsy(t, idx)` | `biopsy` | Surgical clean read of a tumor element without mutation. |
| `spread(t, val)` | `spread` | Appends a new cell to a tumor growth cluster. |
| `excise(t, idx)` | `excise` | Surgically removes and returns a cell from a tumor. |
| `len(x)` | `mass(x)` | Measures biological tumor mass, membrane receptor count, or string length. |
| `typeof(x)` | `strain(x)` | Identifies biological data strain ("tumor", "membrane", "cell", etc.). |
| `bind / unbind` | `bind / unbind` | Attaches or removes receptor ligands on a cell membrane. |
| `keys(m)` | `receptors(m)` | Extracts all bound receptor keys from a cell membrane as a tumor. |
| `class` / `struct` | `cell` | Living blueprint defining fields, states, and cellular parameters. |
| `function` / `def` | `gene` | Functional expression of cellular logic. Susceptible to contagion. |
| `new` / `clone` | `mitosis` | Spawns an independent living cellular instance from a `cell` blueprint. |
| `return` | `apoptosis` | Clean programmed cell death; terminates execution and returns data. |
| `import` / `export` | `metastasis` | Cross-module dissemination of cells and logic across file boundaries. |
| `try` / `catch` | `chemo` / `quarantine` | Error and entropy containment strategies. |
| **I/O** | | |
| `input(prompt?)` | `absorb(prompt?)` | Read a line from standard input (user absorption). |
| `read_file(path)` | `ingest(path)` | Ingest file contents into a string. |
| `write_file(path, data)` | `secrete(path, data)` | Secrete data into a file (overwrite). |
| `append_file(path, data)` | `infiltrate(path, data)` | Infiltrate data into an existing file. |
| `file_exists(path)` | `file_exists(path)` | Check if a file path can be opened. |
| **String & Array** | | |
| `split(str, sep?)` | `lyse(str, sep?)` | Lyse a string into a tumor array by separator. |
| `join(tumor, sep?)` | `fuse(tumor, sep?)` | Fuse tumor elements into a single string. |
| `upper(str)` | `hypertrophy(str)` | Aggressive uppercase conversion (cellular overgrowth). |
| `lower(str)` | `atrophy(str)` | Lowercase degradation (tissue atrophy). |
| `trim(str)` | `trim(str)` | Strip leading/trailing whitespace. |
| `contains(col, val)` | `contains(col, val)` | Test if a string, tumor, or membrane contains a value. |
| `slice(col, s, e?)` | `resect(col, s, e?)` | Surgical sub-range extraction (resection). |
| **Math** | | |
| `sqrt / floor / ceil` | `sqrt / floor / ceil` | Standard math operations. |
| `round(x, d?)` | `round(x, d?)` | Round to d decimal places. |
| `abs / min / max / pow` | `abs / min / max / pow` | Absolute value, extrema, exponentiation. |
| `random(...)` | `random(...)` | Pseudo-random number generation. |
| **Time** | | |
| `sleep(seconds)` | `dormancy(seconds)` | Suspend execution (cellular dormancy). |
| `time()` | `time()` | Unix epoch timestamp. |
| `clock()` | `metabolism()` | High-resolution CPU clock (metabolic rate). |

---

## Detailed Syntax Rules

### 1. Variables and Types

Variables are dynamically typed but strictly bounded by their genomic type:

```python
# dynamic mutating variables
dna counter = 0
dna patient_name = "Subject-42"
dna temperature = 98.6

# static immune constants
rna MAX_THRESHOLD = 150
rna PROTOCOL_NAME = "ISO-TUMOR-99"
```

Reassigning to an `rna` identifier triggers a fatal runtime error:
```
IMMUNE_VIOLATION: cannot reassign rna constant 'MAX_THRESHOLD'
```

---

### 2. Tumor Arrays (`tumor(...)` or `[...]`)

Arrays in TumorScript grow like tumors: ordered clusters of cellular elements.
Accessing elements by index `samples[0]` subjects that specific element to the observation effect (DNA mutation).

```python
# declare a tumor cluster
dna samples = tumor(10, 20, 30)
dna alt_samples = [100, 200, 300]

# read index (0-based) with mutation
print("first sample: ", samples[0])

# surgical clean read (biopsy) without mutation
dna clean_sample = biopsy(samples, 1)

# grow the tumor cluster
spread(samples, 40)

# surgically excise an element
dna removed = excise(samples, 0)

# inspect tumor mass and biological strain
print("mass: ", mass(samples))
print("strain: ", strain(samples))
```

---

### 3. Cell Membranes (`membrane(...)`)

Membranes represent key-value structures modeling cellular receptor-ligand bindings:

```python
# create membrane with receptor bindings
dna cell_surface = membrane("glucose", 5.0, "insulin", 2.1)

# dot access and bracket access
print("glucose: ", cell_surface.glucose)
print("insulin: ", cell_surface["insulin"])

# bind a new receptor
bind(cell_surface, "oxygen", 99.5)

# unbind an existing receptor
dna old_val = unbind(cell_surface, "insulin")

# list all active receptors as a tumor array
dna active_receptors = receptors(cell_surface)
```

---

### 4. Loop Control: `remission` and `relapse`

Loops control cellular growth cycles. When tumors respond to treatment or mutate unexpectedly:
* **`remission`** (`break`): The tumor enters remission, breaking immediately out of the loop.
* **`relapse`** (`continue`): The tumor relapses, skipping the rest of the current cycle and jumping straight into the next iteration.

```python
for cell in samples:
    if cell < 2:
        relapse
    if cell > 10:
        remission
    print("processing cell: ", cell)
```

---

### 5. Cellular Iteration (`for ... in`) and `range(...)`

Iterate sequentially over tumor clusters, membrane receptors, or generated sequences:

```python
# iterate over tumor elements
dna cluster = tumor("alpha", "beta", "gamma")
for c in cluster:
    print("cell node: ", c)

# iterate over generated numeric ranges
for i in range(0, 5):
    print("cycle step: ", i)
```

---

### 6. Unique Feature: `necrosis` (Timed Variable Decay)

Variables marked with `necrosis(N, initial_value)` automatically decay and die after `N` reads, mimicking biological tissue necrosis.
Once expired, further reads return `nil` and print a necrosis diagnostic alert:

```python
dna temporary_marker = necrosis(3, 100)

print(temporary_marker) # read 1: 100 (mutated slightly)
print(temporary_marker) # read 2: ~100
print(temporary_marker) # read 3: ~100
print(temporary_marker) # read 4: NECROSIS: variable 'temporary_marker' has decayed beyond recovery -> nil
```

Applying `chemo temporary_marker` resets the necrosis read counter back to zero if tissue destruction did not occur.

---

### 7. Cellular Definitions (`cell`) and Division (`mitosis`)

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

---

### 8. Functional Logic (`gene`) and Termination (`apoptosis`)

Genes receive parameters as local variables and terminate via `apoptosis`:

```python
gene synthesize(sample, factor):
    dna adjusted = sample.density * factor
    if adjusted > 10.0:
        print("Hyper-dense reaction detected!")
    apoptosis adjusted
```

---

### 9. Quarantine Blocks (`quarantine { ... }`)

The `{}` symbols are reserved exclusively for the `quarantine` block. Using them anywhere else causes an immediate `SYNTAX_TUMOR` error during lexical analysis. Quarantine chambers are strictly capped at 20% of total source lines.

```python
quarantine {
    dna safe_val = volatile_data * 2
    print("[STERILE] Safe Value:", safe_val)
}
```

---

### 10. Interactive Shell (REPL) Commands

When running the interactive session via `tumorscript` without arguments, meta-commands prefixed with `:` provide live clinical monitoring:

* `:vitals` — Diagnostic printout of all active heap specimens and malignancy ratio.
* `:chemo <var>` — Targeted chemotherapy resetting a variable to baseline.
* `:flush` — Purge active heap memory.
* `:clear` — Clear terminal screen.
* `:help` — Show clinical commands and interactive syntax tips.
* `:exit` / `:quit` — Programmed apoptosis to exit the shell.

See [Interactive Shell (REPL)](Interactive-REPL) for detailed workflows.
