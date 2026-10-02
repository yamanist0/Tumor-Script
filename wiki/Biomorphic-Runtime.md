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

## 2. Metastasis and Contagion Spread

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

## 3. Immune Interventions

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

## 4. Organ Failure (`ORGAN_FAILURE_EXCEPTION`)

The runtime constantly monitors the ratio of malignant variables across the active heap:

$$\text{Malignancy Ratio} = \frac{\text{Count}(\text{Malignant Variables})}{\text{Count}(\text{Total Variables})}$$

A variable is classified as **malignant** when its net deviation exceeds **$50\%$** from its original declared value, or when sustained read pressure maxes out its mutation index.

If $\text{Malignancy Ratio} \ge 50\%$ in a system containing active memory cells, the runtime halts unconditionally with:

```
FATAL: ORGAN_FAILURE_EXCEPTION - 3/4 variables are malignant (75.0%)
```
