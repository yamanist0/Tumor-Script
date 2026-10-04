# Examples and Cookbook

Practical recipes and annotated code samples illustrating how to survive and thrive within the TumorScript runtime.

---

## 1. Minimal Working Sample

A simple demonstration showing variable decay over sequential loops.

```python
gene main():
    dna counter = 100
    dna step = 0

    while step < 3:
        step = step + 1
        print("Read ", step, ": Counter = ", counter)

    print("Complete")
```

### Typical Output Trace
```
Read 1.002: Counter = 99.814
Read 1.995: Counter = 98.632
Read 2.981: Counter = 97.411
Complete
```
*Note that even the loop counter `step` drifts slightly, occasionally causing loops to run an additional iteration if entropy drags the counter backward.*

---

## 2. Tumor Arrays & Surgical Biopsy

Manage cellular clusters using `tumor`, `biopsy`, `spread`, and `excise`:

```python
gene main():
    # cultivate a tumor array cluster
    dna vitals = tumor(98.6, 120.0, 80.0)
    print("initial tumor mass: ", mass(vitals))

    # observe directly mutating element
    print("observed temp: ", vitals[0])

    # perform surgical biopsy without mutation
    dna sterile_pulse = biopsy(vitals, 1)
    print("biopsy pulse: ", sterile_pulse)

    # spread and excise
    spread(vitals, 95.0)
    dna removed = excise(vitals, 0)
    print("excised element: ", removed)
    print("final mass: ", mass(vitals))
```

---

## 3. Cell Membrane Signaling

Model cell receptors and ligand binding using `membrane`:

```python
gene main():
    # initialize membrane receptors
    dna cell_wall = membrane("glucose", 5.2, "calcium", 1.8)

    # inspect via dot and bracket access
    print("glucose level: ", cell_wall.glucose)
    print("calcium level: ", cell_wall["calcium"])

    # bind ligand and scan receptors
    bind(cell_wall, "insulin", 3.4)
    dna rec_list = receptors(cell_wall)
    for r in rec_list:
        print("active receptor: ", r)
```

---

## 4. Cellular Loops: `remission` & `relapse`

Iterate through cellular populations with loop interruption mechanics:

```python
gene main():
    dna cultures = tumor(10, 20, 30, 40, 50)

    for cell in cultures:
        if cell < 15:
            # skip early phase
            relapse
        if cell > 35:
            # cease growth cycle
            remission
        print("treated cell: ", cell)

    # numeric range iteration
    for i in range(0, 3):
        print("growth stage: ", i)
```

---

## 5. Necrosis: Programmed Variable Decay

Safely use temporary reagents that expire after a predetermined number of reads:

```python
gene main():
    # reagent dies after two observations
    dna reagent = necrosis(2, 500)

    print("measurement 1: ", reagent)
    print("measurement 2: ", reagent)
    # third read triggers necrosis
    print("measurement 3: ", reagent)
```

---

## 6. Standard Library: String & I/O

Use biological aliases for real-world string manipulation and file operations:

```python
gene main():
    # lyse (split) a csv string into a tumor array
    dna raw = "alpha,beta,gamma,delta"
    dna parts = lyse(raw, ",")
    print("cell count: ", mass(parts))

    # fuse (join) back together with a pipe separator
    dna joined = fuse(parts, " | ")
    print("fused: ", joined)

    # hypertrophy (uppercase) and atrophy (lowercase)
    print(hypertrophy("benign"))
    print(atrophy("MALIGNANT"))

    # resect (slice) a substring
    dna prefix = resect("hemoglobin", 0, 4)
    print("prefix: ", prefix)

    # file i/o: secrete, ingest, infiltrate
    secrete("lab_notes.txt", "initial observation\n")
    infiltrate("lab_notes.txt", "follow-up reading\n")
    dna notes = ingest("lab_notes.txt")
    print("lab notes:\n", notes)
```

---

## 7. Standard Library: Math & Timing

Benchmark operations and use mathematical built-ins:

```python
gene main():
    # math operations
    print("sqrt(256) = ", sqrt(256))
    print("floor(9.8) = ", floor(9.8))
    print("ceil(2.1) = ", ceil(2.1))
    print("round(3.14159, 3) = ", round(3.14159, 3))
    print("abs(-99) = ", abs(-99))
    print("pow(2, 10) = ", pow(2, 10))

    # random number generation
    dna coin = random(0, 1)
    print("coin flip: ", coin)

    # timing with metabolism (cpu clock)
    dna t0 = metabolism()
    rna ITERATIONS = 1000
    dna sum = 0
    for i in range(0, ITERATIONS):
        sum = sum + sqrt(i)
    dna elapsed = metabolism() - t0
    print("computed ", ITERATIONS, " square roots in ", elapsed, "s")

    # dormancy (sleep)
    print("entering dormancy for 1 second...")
    dormancy(1)
    print("awake!")
```

## 8. Case Study: `hospital_core.tmq`

This canonical example models medical dosage calculation subject to vital sign degradation:

```python
# ==========================================
# File: hospital_core.tmq
# Lang: TumorScript (.tmq)
# ==========================================

metastasis System.IO

cell PatientRecord:
    dna age = 30
    dna heart_rate = 75
    rna blood_type = "AB+"

gene calculate_dosage(patient):
    # patient.age mutates upon observation
    dna base_dosage = patient.age * 1.5

    if patient.age > 40:
        print("Critical Age Threshold Exceeded:", patient.age)

    apoptosis base_dosage

gene main():
    dna cycle = 0
    dna p1 = mitosis PatientRecord()

    print("--- CYCLE START (Mutation Phase) ---")

    while cycle < 5:
        cycle = cycle + 1

        print("Pulse Data (Read ", cycle, "): ", p1.heart_rate)

        # Intervene if data drifts beyond clinical tolerance
        if p1.heart_rate > 78:
            print("Pulse corrupted, applying chemo...")
            chemo p1.heart_rate
            print("Post-Treatment Pulse:", p1.heart_rate)

    print("\n--- STERILE QUARANTINE ZONE ---")

    # Quarantine chamber: values remain 100% frozen
    quarantine {
        dna safe_age = p1.age
        dna exact_calc = safe_age * 10
        print("[STERILE] Frozen Age Data:", safe_age)
        print("[STERILE] Precise Calculation:", exact_calc)
    }

    # Return to normal entropic flow
    dna final_dosage = calculate_dosage(p1)
    print("Final Dosage Output:", final_dosage)
```

---

## 9. Interactive REPL Session & Real-Time Mutation Tracking

Run `tumorscript` without arguments to launch the interactive malignancy shell:

```python
# $ tumorscript
>>> dna leukocyte_count = 6000
>>> leukocyte_count
6024.182104
>>> leukocyte_count
5978.391021
>>> :vitals

--- SPECIMEN VITALS (Active Heap Telemetry) ---
Specimen            Strain Value            Reads  Mutation   Status
--------------------------------------------------------------------------
leukocyte_count     dna    5978.391021      2      1.10     % HEALTHY
==========================================================================
System Malignancy: 0/1 specimens corrupted (0.0% / 50.0% failure threshold)
>>> :chemo leukocyte_count
[CHEMO SUCCESS] 'leukocyte_count' restored to initial genetic snapshot.
>>> leukocyte_count
6000
```

---

## 10. Inducing Organ Failure & Examining the Autopsy Traceback

When cellular corruption saturates 50% or more of active heap variables, the runtime halts with a comprehensive autopsy trace:

```python
# file: examples/organ_failure_test.tmq
gene corrupt(data):
    dna i = 0
    while i < 150:
        dna leak = data + 1
        i = i + 1

gene main():
    dna cycle = 0
    dna specimen_a = 50
    dna specimen_b = 100
    while cycle < 100:
        corrupt(specimen_a)
        corrupt(specimen_b)
        cycle = cycle + 1
```

Running this file triggers:

```text
==============================================================================
 [!] CRITICAL BIOLOGICAL CRASH: ORGAN FAILURE EXCEPTION
==============================================================================
 Malignant Saturation: 2/3 specimens corrupted (66.7% >= 50.0% fatal threshold)
 Clinical Diagnostic: Cellular tissue suffered irreversible entropy collapse.

--- PATIENT ZERO (Initial Site of Malignancy) ---
  Specimen Name     : cycle
  Malignant at Read : Read #4 (drifted to rate 2.55%)
  Contagion Rate    : 2.55%
  Origin Location   : gene 'main' at line 11

--- METASTASIS TRANSMISSION TRAIL (Contagion Vectors) ---
  [1] Contagion Spread: 'cycle' (reads: 94, rate: 5.00%) infected 'cycle' at line 11
  ...
--- METASTASIS CALL STACK (Active Cellular Frames) ---
  Frame [0] corrupt() at examples/organ_failure_test.tmq:4 [infected]
  Frame [1] main() at examples/organ_failure_test.tmq:14 [sterile]

--- SPECIMEN BIOPSY TELEMETRY (Active Memory Heap) ---
  Specimen         Strain Value            Reads  Mutation   Status
  --------------------------------------------------------------------------
  cycle            dna    52.511859        135    5.00     % MALIGNANT [METASTASIZED]
  specimen_a       dna    112.815418       67     5.00     % MALIGNANT [METASTASIZED]
  specimen_b       dna    131.382166       67     5.00     % HEALTHY
==============================================================================
```

---

## 11. Scientific Calculator TUI (`scientific_calculator.tmq`)

A comprehensive terminal-based scientific calculator demonstrating cellular registers, defensive RNA anchoring, trigonometry, combinatorics, logarithms, and frozen quarantine precision:

```python
# file: examples/scientific_calculator.tmq
cell CalculatorState:
    dna ans = 0
    dna memory = 0
    dna precision = 6
    rna mode = "DEG"
    dna ops_count = 0

gene factorial(n):
    rna limit = n
    if limit <= 1:
        apoptosis 1
    dna result = 1
    dna i = 2
    while i <= limit:
        result = result * i
        i = i + 1
    apoptosis result

gene permutations(n, r):
    if r > n or r < 0:
        apoptosis 0
    dna num = factorial(n)
    dna den = factorial(n - r)
    apoptosis num / den

gene combinations(n, r):
    if r > n or r < 0:
        apoptosis 0
    dna num = factorial(n)
    dna den = factorial(r) * factorial(n - r)
    apoptosis num / den

gene hypotenuse(a, b):
    dna sum_sq = (a * a) + (b * b)
    apoptosis sqrt(sum_sq)

gene trig_deg(fn_name, angle_deg):
    rna op = fn_name
    rna ang = angle_deg
    dna angle_rad = rad(ang)
    if op == "sin":
        apoptosis sin(angle_rad)
    elif op == "cos":
        apoptosis cos(angle_rad)
    elif op == "tan":
        apoptosis tan(angle_rad)
    apoptosis 0
```

Run directly with:
```bash
tumorscript examples/scientific_calculator.tmq
```
