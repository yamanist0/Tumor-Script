# Biomorphic Runtime Mechanics

The TumorScript execution engine operates on biological principles rather than deterministic memory models. Every data access, arithmetic expression, or scope transition simulates organic cell dynamics.

---

## 1. Entropic Memory (Observation-Based Mutation)

In standard architectures, reading a variable is a read-only, non-destructive operation. In TumorScript, reading a `dna` variable creates an observation disturbance:

### Mathematical Mutation Curve
When a `dna` variable is accessed (via printing, condition checks, or arithmetic calculations), its entropy counter increments:

$$V_{\text{new}} = V_{\text{old}} \times (1 \pm \delta)$$

* **Initial Mutation Rate:** Begins at $\delta = 0.5\%$ ($0.005$).
* **Escalation:** Each read elevates $\delta$ by $0.3\%$ ($0.003$).
* **Upper Bound:** Caps at $5.0\%$ ($0.05$) per individual read.
* **Integer Drift:** Whole numbers carry a random probability of discrete drift ($\pm 1$).

### String Entropy
Strings under entropic decay experience ASCII / UTF-8 byte shifts. Random characters deviate to neighboring codepoints, mimicking point mutations in genetic codons.

### RNA Immunity
Variables designated with `rna` are completely immune to entropic decay. Their mutation rate remains identically zero throughout the entire runtime lifecycle, and re-assignment is blocked at runtime (`IMMUNE_VIOLATION`).

---

## 2. Tumor Arrays & Surgical Biopsy Mechanics

Arrays in TumorScript behave as biological tumor clusters (`tumor`):
* **Individual Cell Mutation:** When indexing into a tumor (`cluster[i]`), each element tracks its own independent mutation rate and observation count. Accessing a cell mutates that specific cell.
* **Surgical Biopsy (`biopsy(tumor, index)`):** Developers can perform a clean surgical biopsy. A biopsy reads an element safely without triggering any mutation drift or elevating read counters.
* **Tumor Spread (`spread(tumor, value)`):** Appends a new cellular unit to the cluster, initializing its baseline genetic snapshot.
* **Surgical Excision (`excise(tumor, index)`):** Removes an element cleanly from the tissue cluster, returning the excised specimen.

---

## 3. Cell Membrane Receptor Kinetics

Membranes (`membrane`) model lipid bilayers with receptor-ligand docking sites:
* **Receptor Docking (`bind(membrane, key, value)`):** Attaches a ligand value to the specified receptor key.
* **Receptor Cleavage (`unbind(membrane, key)`):** Detaches and returns the bound ligand.
* **Surface Scanning (`receptors(membrane)`):** Extracts all active receptor identifiers as a tumor array for cellular iteration.

---

## 4. Necrosis: Programmed Variable Decay

The `necrosis(limit, initial_value)` primitive models uncontrolled cell death following severe tissue distress:
* **Read Lifespan:** A variable allocated via `necrosis` maintains a strict read quota.
* **Cellular Expiry:** When the variable is read past its quota, the runtime emits:
  `NECROSIS: variable '<name>' has decayed beyond recovery`
  and immediately resolves the variable to `nil`.
* **Chemotherapeutic Reset:** Applying `chemo` to a necrosis variable resets its read counter to zero if lethal toxicity is averted.

---

## 5. Metastasis and Contagion Spread

Variables do not exist in isolation. Infection propagates through mathematical operations and functional boundaries:

### Binary Infection
If a malignant `dna` variable participates in an expression with an uninfected `dna` variable:

```python
dna contaminated_sum = malignant_x + healthy_y
```

There is an intrinsic **$30\%$ probability** that `healthy_y` immediately contracts the malignant state, having its base mutation rate elevated by half of the source variable's corruption.

### Gene Contamination
When mutated data is passed as arguments into a `gene` (function), the internal genetic structure of that function is permanently compromised. Subsequent calls to that `gene` will yield outputs with an inherent variance offset, even if later called with pristine parameters.

---

## 6. Immune Interventions

Developers possess three specific medical interventions to maintain computational viability:

### A. Quarantine (`quarantine { ... }`)
* **Behavior:** Suspends all entropic decay within the scope. Variables read inside quarantine yield exact, deterministic outputs.
* **Containment:** Prevents contaminated variables from leaking infection outwards.
* **Strict Constitutional Limit:** No single source file may place more than **$20\%$ of its total line count** inside quarantine blocks. Exceeding this boundary triggers `QUARANTINE_OVERFLOW` at parse time.

### B. Chemotherapy (`chemo <target>`)
* **Behavior:** Resets a contaminated variable's value to its healthy initial snapshot, setting read counters and mutation rates back to baseline ($0.5\%$).
* **Lethal Toxicity Risk:** Chemo is non-targeted. There is an intrinsic **$15\%$ probability** of total cellular destruction, permanently unbinding the variable from memory (`CHEMO_LETHAL`).

### C. Apoptosis (`apoptosis [value]`)
* **Behavior:** Programmed cell death. Immediately halts execution of the current `gene`, frees allocated local cellular memory, and ejects the specified payload safely to the caller.

---

## 7. Organ Failure (`ORGAN_FAILURE_EXCEPTION`)

The runtime constantly monitors the ratio of malignant variables across the active heap:

$$\text{Malignancy Ratio} = \frac{\text{Count}(\text{Malignant Variables})}{\text{Count}(\text{Total Variables})}$$

A variable is classified as **malignant** when its net deviation exceeds **$50\%$** from its original declared value, or when sustained read pressure maxes out its mutation index.

If $\text{Malignancy Ratio} \ge 50\%$ in a system containing active memory cells, the runtime halts unconditionally with:

```
FATAL: ORGAN_FAILURE_EXCEPTION - 3/4 variables are malignant (75.0%)
```

---

## 8. Metastasis Call Stack & Post-Mortem Autopsy Traceback

When `ORGAN_FAILURE_EXCEPTION` occurs, execution halts and the runtime generates a comprehensive, color-coded clinical autopsy report:

* **Patient Zero Identification:** Pinpoints the exact initial variable where malignancy originated, the read cycle count at which corruption occurred, the mutation delta rate, and the originating gene and line number.
* **Metastasis Transmission Trail:** Chronologically logs contagion transmission vectors where malignant variables infected healthy variables during arithmetic expressions and assignments (`x infected y at line N`).
* **Active Cellular Call Stack:** Details the active gene call stack frames with nesting depths, function names, source file paths, line numbers, and cellular state (`[sterile]` vs `[infected]`).
* **Specimen Biopsy Telemetry:** Renders an exhaustive pathology table of the active memory heap, showing each specimen's biological strain (`dna`, `rna`, `tumor`, `membrane`), degraded value, read counter, mutation percentage, and status (`MALIGNANT [METASTASIZED]` or `HEALTHY`).
