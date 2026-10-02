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

## 2. Case Study: `hospital_core.tmq`

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
    # 'patient.age' mutates upon observation
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

## 3. Defensive Programming Patterns

### Pattern A: Immutable RNA Anchors
Use `rna` for thresholds, step sizes, and mathematical constants to minimize infection vectors:

```python
rna BASE_STEP = 1
dna current = 0

while current < 10:
    current = current + BASE_STEP
```

### Pattern B: Strategic Quarantine Freezing
Save your 20% quarantine budget for mission-critical calculations where precision cannot be compromised:

```python
quarantine {
    dna exact_total = order.subtotal + order.tax
    apoptosis exact_total
}
```

### Pattern C: Chemotherapy Fallbacks
Always be prepared for the 15% lethal toxicity rate when issuing chemo:

```python
chemo subject.vital_index
# Note: subject.vital_index may be destroyed if lethal toxicity triggers
```
