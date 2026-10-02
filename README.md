<a id="readme-top"></a>

<!-- project shields -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![Version][version-shield]][version-url]

<!-- project logo -->
<br />
<div align="center">
  <a href="https://github.com/yamanist0/Tumor-Script">
    <img src="icon.svg" alt="TumorScript Logo" width="100" height="100">
  </a>

  <h1 align="center">TumorScript</h1>

  <p align="center">
    <strong>The World's First Biomorphic, Entropic & Malignant Programming Language</strong>
    <br />
    <em>Where data decays when observed, variables spread contagious infections, and developers race against systemic organ failure.</em>
    <br />
    <br />
    <a href="https://github.com/yamanist0/Tumor-Script/wiki"><strong>Explore the Wiki Documentation »</strong></a>
    <br />
    <br />
    <a href="examples/hospital_core.tmq">View Clinical Sample</a>
    &middot;
    <a href="https://github.com/yamanist0/Tumor-Script/issues">Report Biological Mutation</a>
    &middot;
    <a href="https://github.com/yamanist0/Tumor-Script/issues">Request Genetic Feature</a>
  </p>
</div>

<!-- table of contents -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#the-biological-philosophy">The Biological Philosophy</a></li>
        <li><a href="#core-biomorphic-mechanisms">Core Biomorphic Mechanics</a></li>
        <li><a href="#file-extension-taxonomy">File Extension Taxonomy</a></li>
        <li><a href="#keyword-dictionary">Keyword Dictionary</a></li>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
        <li><a href="#building-from-source">Building from Source</a></li>
        <li><a href="#windows-file-association">Windows File Association (.tmq Double-Click)</a></li>
      </ul>
    </li>
    <li>
      <a href="#usage">Usage</a>
      <ul>
        <li><a href="#clinical-case-study-hospital_coretmq">Clinical Case Study</a></li>
        <li><a href="#runtime-mutation-trace">Runtime Mutation Trace</a></li>
        <li><a href="#oncology-survival-guide">Oncology Survival Guide</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- about the project -->
## About The Project

[![TumorScript Banner][product-screenshot]](wiki/Home.md)

Modern computer science spent six decades obsessed with "determinism", "memory safety", and "predictable side effects". **What a sterile, boring way to compute.**

**TumorScript** rejects this artificial stability. In nature, living tissue is messy, mutations are inevitable, and observation alters the state of matter. TumorScript bridges biological cancer dynamics and quantum observer physics into software architecture:

* **Observation causes corruption:** Reading a variable actively degrades its value. Printing a variable five times might turn your integer into a floating-point tumor.
* **Metastasis is contagious:** Malignant variables pass infections to innocent numbers across arithmetic equations.
* **Chemotherapy is a gamble:** You can purge mutations with `chemo`, but there is an intrinsic **15% chance** of destroying the variable permanently.
* **Organ failure is terminal:** If more than **50%** of your heap becomes malignant, the virtual machine panics with `FATAL: ORGAN_FAILURE_EXCEPTION` and kills the process.

Writing software in TumorScript is no longer about writing logic. It is an oncological race against time to extract answers before your program dies on the operating table.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### The Biological Philosophy

Traditional programming treats memory as a warehouse of immutable storage boxes. TumorScript treats memory as an immunocompromised petri dish:

$$V_{\text{mutated}} = V_{\text{original}} \times (1 \pm \delta)$$

Every time a CPU instruction observes a piece of DNA data, $\delta$ climbs from an initial **0.5%** up to a terminal **5.0%** per read. The more you watch your code, the worse it behaves.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Core Biomorphic Mechanics

* **Entropic Memory (`dna`):** Every read triggers mutation. Numbers drift mathematically, strings suffer random ASCII codepoint codon shifts, and booleans flip under extreme stress.
* **Immune Constants (`rna`):** Static genetic codes that are 100% resistant to entropic decay. Reassigning them is treated as an `IMMUNE_VIOLATION`.
* **Metastasis (`y = bad_x + 10`):** Performing calculations with an infected variable carries a **30% probability** of immediately spreading malignancy to the target.
* **Quarantine Chamber (`quarantine { ... }`):** A sterile cleanroom where mutation is completely frozen. **Curly braces `{}` are strictly illegal everywhere else in the language.** To prevent developers from cheating by wrapping their whole app in quarantine, the compiler enforces a **strict 20% total line budget**.
* **Chemotherapy (`chemo x`):** Resets a corrupt variable back to its initial healthy state, with a terrifying **15% lethal toxicity chance** of deleting the variable into null oblivion.
* **Apoptosis (`apoptosis value`):** Programmed cell death. Safely terminates a cellular function and ejects its payload before internal mutations spread.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### File Extension Taxonomy

TumorScript classifies source code into containment biosafety levels:

| Extension | Name | Biosafety Level | Purpose |
|---|---|---|---|
| `.tmq` | Tumor Quarantine | Level 4 (Primary) | Main executable files containing quarantine chambers and program logic. |
| `.tmr` | Tumor Source Module | Level 3 (Intermediate) | Importable cellular modules and secondary logic units. |
| `.tmh` | Tumor Header | Level 1 (Sterile) | Mutation-proof header files containing exclusively immutable `rna` constants. |
| `.tmz` | Tumor Zone | Level 5 (Extreme Hazard) | High-risk experimental zones where mutation and metastasis rates are tenfold. |
| `.tmb` | Tumor Bytecode | Machine Artifact | Compiled intermediate binary bytecode for the virtual machine. |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Keyword Dictionary

| Standard Syntax | TumorScript Keyword | Biological Role |
|---|---|---|
| `var` / `let` | `dna` | Mutable variable subject to decay on every read. |
| `const` | `rna` | Mutation-immune constant. |
| `class` / `struct` | `cell` | Living cellular blueprint containing state and traits. |
| `function` / `def` | `gene` | Cellular functional logic; degrades if fed mutated arguments. |
| `new` / `clone` | `mitosis` | Duplicates and spawns an independent living cell instance. |
| `return` | `apoptosis` | Programmed cell death; cleans up scope and yields data. |
| `import` | `metastasis` | Cross-module dissemination of code and functions. |
| `try` / `catch` | `quarantine` / `chemo` | Isolation and toxic intervention strategies. |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

The TumorScript reference compiler and runtime are engineered with zero-compromise native performance:

* [![Rust][Rust-badge]][Rust-url]
* [![Lua][Lua-badge]][Lua-url]
* [![Python][Python-badge]][Python-url]
* [![Node.js][Node-badge]][Node-url]
* [![Windows][Windows-badge]][Windows-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- getting started -->
## Getting Started

You can run TumorScript immediately through your favorite package manager or compile it from source as a standalone native binary with zero runtime dependencies.

### Prerequisites

* To install pre-built packages: **Node.js** (npm) or **Python 3.8+** (pip).
* To compile from source: **Rust** (cargo 1.70+) and optional `luac`.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Installation

#### Global Installation via npm (Node.js)
```sh
npm install -g tumorscript
```

#### Global Installation via pip (Python)
```sh
pip install tumorscript
```

Once installed, the `tumorscript` command is available system-wide:
```sh
tumorscript examples/hospital_core.tmq
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Building from Source

TumorScript compiles into an ultra-fast, single-file native executable (`tumorscript.exe` on Windows or `tumorscript` on Unix) that embeds the full Lua 5.4 engine, the application icon, and the TumorScript standard library into a compact ~547 KB binary.

#### On Windows:
```cmd
build.bat
```
*The compiled binary will be placed at `bin\tumorscript.exe` with `icon.ico` baked into the PE resource table.*

#### On Linux / macOS:
```sh
chmod +x build.sh
./build.sh
```
*The compiled binary will be placed at `bin/tumorscript`.*

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Windows File Association

TumorScript can register itself as the default handler for all `.tmq` files across Windows:

* All `.tmq` files display the official **TumorScript Application Icon**.
* **Double-clicking** any `.tmq` file opens a dedicated CMD terminal, runs the script through the biomorphic engine, and keeps the terminal open with `pause` so you can examine the mutation outputs before closing.
* Requires **no administrator rights** (scoped safely to `HKCU`).

#### To Register:
Double-click `register_file_association.bat` or run:
```cmd
tumorscript --register
```

#### To Unregister:
Double-click `unregister_file_association.bat` or run:
```cmd
tumorscript --unregister
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- usage examples -->
## Usage

### Clinical Case Study: `hospital_core.tmq`

Below is the canonical TumorScript program simulating patient vital signs under entropic stress:

```python
# file: hospital_core.tmq
metastasis System.IO

cell PatientRecord:
    dna age = 30
    dna heart_rate = 75
    rna blood_type = "AB+"

gene calculate_dosage(patient):
    # observation causes patient.age to drift slightly
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

        # pulse data corrupts on each read
        print("Pulse Data (Read ", cycle, "): ", p1.heart_rate)

        # medical intervention if cancer spikes
        if p1.heart_rate > 78:
            print("Pulse data corrupted, applying chemo...")
            chemo p1.heart_rate
            print("Post-Treatment Pulse:", p1.heart_rate)

    print("\n--- STERILE QUARANTINE ZONE ---")

    # sterile cleanroom: values remain completely frozen
    quarantine {
        dna safe_age = p1.age
        dna exact_calc = safe_age * 10
        print("[STERILE] Frozen Age Data:", safe_age)
        print("[STERILE] Precise Calculation:", exact_calc)
    }

    # back to entropic reality
    dna final_dosage = calculate_dosage(p1)
    print("Final Dosage Output:", final_dosage)
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Runtime Mutation Trace

Executing `tumorscript examples/hospital_core.tmq` produces live biomorphic entropy:

```
--- CYCLE START (Mutation Phase) ---
Pulse Data (Read 0.993223): 74.600719
Pulse Data (Read 1.999967): 73.544579
Pulse Data (Read 2.959608): 74.117909
Pulse Data (Read 4.061606): 77.237377
Pulse Data (Read 4.787132): 76.586058
Pulse data corrupted, applying chemo...
Post-Treatment Pulse: 75.000000
Pulse Data (Read 6.283643): 74.939735

--- STERILE QUARANTINE ZONE ---
[STERILE] Frozen Age Data: 30
[STERILE] Precise Calculation: 300
Final Dosage Output: 44.864949
```

Notice that:
1. `cycle` drifted from an integer into fractional values (`0.993`, `1.999`, `4.787`), occasionally repeating iterations!
2. `p1.heart_rate` climbed until triggering chemo, which reset it to baseline!
3. Inside `quarantine { ... }`, the calculations were 100% frozen and exact!

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Oncology Survival Guide

* **Defensive RNA Anchoring:** Use `rna` for iteration limits, step offsets, and critical thresholds. `rna` cannot mutate, preventing infinite loops caused by decaying integers.
* **Quarantine Budgeting:** You only get **20% of your source code lines** in `{}` quarantine. Spend it on financial calculations, cryptography, or critical arithmetic.
* **Chemotherapy Contingency:** Never apply `chemo` to your only pointer to a data structure without a backup clone (`mitosis`), or risk fatal `CHEMO_LETHAL` null pointer vaporization.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- roadmap -->
## Roadmap

- [x] Indentation-based lexical analyzer with virtual INDENT / DEDENT tokens
- [x] Strict quarantine `{}` exclusivity and 20% source limit validation
- [x] Read-based entropic memory engine with escalating delta curves
- [x] Object-oriented cellular mitosis and gene definition systems
- [x] Contagious binary metastasizing between healthy and malignant variables
- [x] Chemotherapy intervention with 15% lethal toxicity chance
- [x] Systemic organ failure detection (`ORGAN_FAILURE_EXCEPTION`)
- [x] Standalone native compiler embedding Lua 5.4 with `icon.ico` resource
- [x] Windows Registry `.tmq` double-click file association in CMD
- [x] npm (`npm install -g tumorscript`) and pip (`pip install tumorscript`) distributions
- [x] Comprehensive GitHub Wiki documentation suite
- [ ] Radiation Therapy (`radiation`): Purges 90% of memory corruption, but mutates all other variables by 30%
- [ ] Network Metastasis: Spreading cancer across remote machines via raw TCP/IP sockets
- [ ] CRISPR Gene Editing: Runtime AST self-modifying code rewrite engine
- [ ] Terminal flatline audio sound effects upon organ failure

See the [open issues](https://github.com/yamanist0/Tumor-Script/issues) for a full list of proposed features and clinical bug reports.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- contributing -->
## Contributing

Contributions to TumorScript are **greatly appreciated**! Whether you want to fix a memory leak or introduce a more aggressive form of cellular corruption, the medical board welcomes your pull requests.

### Biological Safety Guidelines:
1. Fork the Project
2. Create your Malignant Branch (`git checkout -b feature/BenignMutation`)
3. Commit your Genetic Modifications (`git commit -m 'feat: add oncological radiation therapy'`)
4. Push to the Petri Dish (`git push origin feature/BenignMutation`)
5. Open a Clinical Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- license -->
## License

Distributed under the MIT License. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- contact -->
## Contact

TumorScript Project - [@yamanist0](https://github.com/yamanist0/Tumor-Script)

Project Link: [https://github.com/yamanist0/Tumor-Script](https://github.com/yamanist0/Tumor-Script)

Wiki Documentation: [https://github.com/yamanist0/Tumor-Script/wiki](https://github.com/yamanist0/Tumor-Script/wiki)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- acknowledgments -->
## Acknowledgments

* [Erwin Schrödinger](https://en.wikipedia.org/wiki/Schr%C3%B6dinger%27s_cat) - For proving that looking at things ruins them.
* [Werner Heisenberg](https://en.wikipedia.org/wiki/Uncertainty_principle) - For providing our runtime's official excuse for floating-point inaccuracies.
* [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) - For inspiring cellular automation in software.
* [Brainfuck & Malbolge](https://esolangs.org/) - For demonstrating that programming languages do not need to be ergonomic to be art.
* [The Lua Team](https://www.lua.org/) - For creating the world's most embeddable, resilient scripting language.
* [The Rust Team](https://www.rust-lang.org/) - For letting us package insanity into an airtight 500 KB binary.
* [Best-README-Template](https://github.com/othneildrew/Best-README-Template) - For the stunning markdown architecture.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- markdown links and images -->
[contributors-shield]: https://img.shields.io/github/contributors/yamanist0/Tumor-Script.svg?style=for-the-badge
[contributors-url]: https://github.com/yamanist0/Tumor-Script/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/yamanist0/Tumor-Script.svg?style=for-the-badge
[forks-url]: https://github.com/yamanist0/Tumor-Script/network/members
[stars-shield]: https://img.shields.io/github/stars/yamanist0/Tumor-Script.svg?style=for-the-badge
[stars-url]: https://github.com/yamanist0/Tumor-Script/stargazers
[issues-shield]: https://img.shields.io/github/issues/yamanist0/Tumor-Script.svg?style=for-the-badge
[issues-url]: https://github.com/yamanist0/Tumor-Script/issues
[license-shield]: https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge
[license-url]: LICENSE
[version-shield]: https://img.shields.io/badge/version-0.1.0-rose.svg?style=for-the-badge
[version-url]: https://github.com/yamanist0/Tumor-Script/releases
[product-screenshot]: icon.svg
[Rust-badge]: https://img.shields.io/badge/Rust-000000?style=for-the-badge&logo=rust&logoColor=white
[Rust-url]: https://www.rust-lang.org/
[Lua-badge]: https://img.shields.io/badge/Lua_5.4-2C2D72?style=for-the-badge&logo=lua&logoColor=white
[Lua-url]: https://www.lua.org/
[Python-badge]: https://img.shields.io/badge/Python_3.8+-3776AB?style=for-the-badge&logo=python&logoColor=white
[Python-url]: https://www.python.org/
[Node-badge]: https://img.shields.io/badge/Node.js_CLI-339933?style=for-the-badge&logo=nodedotjs&logoColor=white
[Node-url]: https://nodejs.org/
[Windows-badge]: https://img.shields.io/badge/Windows_PE_Binary-0078D6?style=for-the-badge&logo=windows&logoColor=white
[Windows-url]: https://www.microsoft.com/windows
