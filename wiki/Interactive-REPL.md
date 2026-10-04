# Interactive Cellular Shell (REPL)

TumorScript features a real-time, biomorphic interactive shell (REPL) that allows developers to evaluate expressions, define cells and genes interactively, and observe memory decay in real time on a per-read basis.

---

## 1. Launching the REPL

Starting TumorScript without arguments immediately launches the interactive malignancy shell:

```bash
# via system command (npm / pip / native binary)
tumorscript

# or via local script entrypoint
lua main.lua
```

When launched, the terminal displays the interactive session banner:

```
======================================================================
  TumorScript Interactive Malignancy Shell (REPL) v1.0.0
  Type expressions to evaluate or statements to execute.
  Type ':help' for clinical commands, ':exit' to quit.
======================================================================
```

---

## 2. Interactive Features

### Real-Time Entropy Observation
Every evaluation in the REPL updates the live environment. Reading variables directly demonstrates real-time biological drift:

```python
>>> dna cell_count = 100
>>> cell_count
100.32049182371
>>> cell_count
99.81239102941
```

### Expression Evaluation & Statement Execution
You can evaluate standalone expressions (e.g. arithmetic, standard library calls) or execute full language statements:

```python
>>> dna specimen = "cellular culture"
>>> hypertrophy(specimen)
"CELLULAR CULTURE"
>>> sqrt(144)
12.0
```

---

## 3. Clinical REPL Commands

The REPL provides built-in commands prefixed with a colon (`:`):

| Command | Action | Biological Purpose |
|---|---|---|
| `:vitals` | Telemetry Heap Dump | Displays real-time pathology of all active variables, read counts, mutation rates, and malignancy status. |
| `:chemo <var>` | Chemical Intervention | Resets a corrupted variable back to baseline (with a 15% lethal toxicity gamble). |
| `:flush` | Complete Heap Purge | Destroys all current memory allocations and resets the heap to a sterile state. |
| `:clear` | Console Screen Clear | Clears the terminal screen while preserving in-memory specimens. |
| `:help` | Clinical Manual | Shows available commands and interactive tips. |
| `:exit` / `:quit` | Programmed Apoptosis | Safely terminates the interactive session. |

### Example: Checking Memory Vitals

```
>>> dna patient = 37.5
>>> patient
37.620192
>>> :vitals

--- SPECIMEN VITALS (Active Heap Telemetry) ---
Specimen         Strain Value            Reads  Mutation   Status
--------------------------------------------------------------------------
patient          dna    37.620192        1      0.80     % HEALTHY
==========================================================================
System Malignancy: 0/1 specimens corrupted (0.0% / 50.0% failure threshold)
```
