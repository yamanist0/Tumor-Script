# TumorScript

An esoteric, biomorphic programming language where data mutates when observed, code infects its neighbors, and developers must fight entropy to keep programs alive.

## Installation

You can install TumorScript globally using either **npm** or **pip**:

### Via npm (Node.js)
```bash
npm install -g tumorscript
```

### Via pip (Python)
```bash
pip install tumorscript
```

Once installed, the `tumorscript` command is available system-wide:
```bash
tumorscript examples/hospital_core.tmq
```

---

## Building the Native Executable

TumorScript can also be compiled locally into a standalone, single-file native executable (`tumorscript.exe` / `tumorscript`) with zero external dependencies:

### Windows
```cmd
build.bat
```
The compiled binary will be placed at `bin\tumorscript.exe`.

### Linux / macOS
```bash
chmod +x build.sh
./build.sh
```
The compiled binary will be placed at `bin/tumorscript`.

---

## Quick Start

### Using the Compiled Binary
```bash
# Windows
bin\tumorscript.exe examples\hospital_core.tmq

# Linux / macOS
./bin/tumorscript examples/hospital_core.tmq
```

### Using the Lua Script (Development)
```bash
lua main.lua examples/hospital_core.tmq
```

---

## Windows File Association (.tmq Double-Click)

TumorScript can register itself as the default application for `.tmq` files on Windows:
- All `.tmq` files display the **TumorScript application icon**.
- **Double-clicking** any `.tmq` file opens a dedicated CMD terminal, runs the script through the biomorphic engine, and keeps the terminal open so you can view the output and mutation results.

### Register Association:
```cmd
register_file_association.bat
```
*(Or run `tumorscript --register`)*

### Unregister Association:
```cmd
unregister_file_association.bat
```
*(Or run `tumorscript --unregister`)*

---

## Project Structure

```
tumor_script/
├── bin/                       # binary & cli launchers
│   ├── tumorscript.exe        # native Windows executable
│   └── cli.js                 # npm global CLI launcher
├── build.bat                  # Windows native build script
├── build.sh                   # Linux/macOS native build script
├── Cargo.toml                 # native Rust build configuration
├── package.json               # npm distribution package
├── pyproject.toml             # pip / PyPI distribution package
├── tumorscript/               # Python package bundle
│   ├── __init__.py
│   └── cli.py                 # pip CLI entry point
├── src_native/
│   └── main.rs                # native runner embedding Lua 5.4 + TumorScript
├── main.lua                   # script entry point
├── src/                       # language implementation
│   ├── lexer.lua              # tokenizer (indentation + quarantine braces)
│   ├── parser.lua             # recursive descent parser -> AST
│   ├── memory.lua             # biomorphic memory system (mutation, infection, chemo)
│   └── interpreter.lua        # tree-walking interpreter
├── examples/
│   ├── simple_test.tmq        # minimal test
│   ├── hospital_core.tmq      # full-featured example
│   ├── quarantine_limit_fail.tmq # 20% limit test
│   └── illegal_brace_fail.tmq # syntax error test
├── wiki/                      # complete GitHub Wiki documentation
└── README.md
```

## Documentation & GitHub Wiki

Full documentation is available in the [`wiki/`](wiki/Home.md) directory, pre-formatted for GitHub Wiki:
* [Wiki Home](wiki/Home.md)
* [Setup and Installation](wiki/Setup-and-Installation.md)
* [Language Specification](wiki/Language-Specification.md)
* [Biomorphic Runtime Mechanics](wiki/Biomorphic-Runtime.md)
* [Syntax and Keywords](wiki/Syntax-and-Keywords.md)
* [Architecture and Compiler Design](wiki/Architecture-and-Compiler.md)
* [Examples and Cookbook](wiki/Examples-and-Cookbook.md)

## File Extensions

| Extension | Name | Purpose |
|-----------|------|---------|
| `.tmq` | Tumor Quarantine | Main source files |
| `.tmr` | Tumor Source Module | Library modules |
| `.tmh` | Tumor Header | Immune header files (rna only) |
| `.tmz` | Tumor Zone | High-risk experimental modules |
| `.tmb` | Tumor Bytecode | Compiled binary intermediate code |

## Language Reference

### Variables

```
dna x = 42          # mutable, mutates on every read
rna PI = 3.14159    # immutable, immune to mutation
```

### Functions (Genes)

```
gene add(a, b):
    apoptosis a + b
```

### Objects (Cells)

```
cell Patient:
    dna age = 30
    rna id = "P001"

gene main():
    dna p = mitosis Patient()
    print(p.age)
```

### Control Flow

```
if x > 10:
    print("big")
elif x > 5:
    print("medium")
else:
    print("small")

while i < 10:
    i = i + 1
```

### Quarantine (Sterile Zone)

Freezes all mutation inside the block. Curly braces `{}` are **only** valid here.
Maximum 20% of source code can be quarantined.

```
quarantine {
    dna safe = x
    print(safe)     # will NOT mutate
}
```

### Chemo (Reset Mutation)

Resets a mutated variable to its original value. 15% chance of destroying it entirely.

```
chemo x
```

### Import (Metastasis)

```
metastasis System.IO
```

## Core Mechanics

### Read-Based Mutation
Every time a `dna` variable is read, its value shifts:
- **Numbers**: `V_new = V_old * (1 ± δ)` where δ scales from 0.5% to 5%
- **Strings**: Random ASCII character shifts
- **Booleans**: Can flip at high mutation rates

### Infection Spread
When a malignant variable interacts with a healthy one, there's a 30% chance the healthy variable gets infected.

### Gene Contamination
Passing mutated arguments to a gene gradually infects the gene itself, causing its return values to drift.

### Organ Failure
When 50%+ of variables become malignant (deviation > 50%), the runtime crashes with `ORGAN_FAILURE_EXCEPTION`.
