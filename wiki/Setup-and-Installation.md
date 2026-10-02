# Setup and Installation

TumorScript offers multiple installation and deployment pathways, ranging from one-line package manager installations to standalone native binary compilation and Windows shell integration.

---

## 1. Quick Installation via Package Managers

### Option A: npm (Node.js)
Install TumorScript globally using npm:

```bash
npm install -g tumorscript
```

Once installed, the `tumorscript` command is accessible globally from any terminal:

```bash
tumorscript --version
tumorscript path/to/script.tmq
```

### Option B: pip (Python)
Install TumorScript globally or in a virtual environment via pip:

```bash
pip install tumorscript
```

Verify the installation:

```bash
tumorscript path/to/script.tmq
```

---

## 2. Building from Source (Standalone Native Binary)

You can compile TumorScript directly into a self-contained executable with zero runtime dependencies. The compiled binary bundles the Lua 5.4 engine, the application icon, and the TumorScript standard library into a single binary.

### Prerequisites
* [Rust](https://rustup.rs/) (cargo 1.70+)
* Optional: `luac` for bytecode validation

### Windows Build
Run the automated build script:

```cmd
build.bat
```

* Output location: `bin\tumorscript.exe` (~547 KB)
* Embeds: `icon.ico` directly into the Windows executable resource table.

### Linux / macOS Build
Run the Unix build script:

```bash
chmod +x build.sh
./build.sh
```

* Output location: `bin/tumorscript`

### Manual Cargo Compilation
You can also build directly using Cargo:

```bash
cargo build --release
```
The optimized binary will be created in `target/release/`.

---

## 3. Windows Shell Integration (.tmq File Association)

TumorScript includes built-in Windows registry integration that sets `.tmq` files to automatically display the TumorScript application icon and run in a dedicated CMD terminal when double-clicked.

### Enabling File Association
You can register file associations using either method:

1. **Via Batch Script (One-Click):**
   Double-click or run:
   ```cmd
   register_file_association.bat
   ```

2. **Via Command Line:**
   ```cmd
   tumorscript --register
   ```

### What Happens When Registered:
* **Custom Icon:** All `.tmq` files on your desktop and file explorer immediately adopt the official `icon.ico`.
* **Double-Click Execution:** Double-clicking any `.tmq` file launches `cmd.exe /c ""tumorscript.exe" "%1" & pause"`.
* **Persistent Console:** The terminal window remains open after execution finishes, allowing you to inspect mutation values, print outputs, and quarantine stats before closing.
* **No Admin Rights Required:** Registration is scoped to `HKEY_CURRENT_USER\Software\Classes`, meaning it functions without administrator elevation.

### Removing File Association
To unregister `.tmq` associations at any time:

1. Run:
   ```cmd
   unregister_file_association.bat
   ```
2. Or via command line:
   ```cmd
   tumorscript --unregister
   ```

---

## 4. Development Execution (Direct Lua Mode)

If you are modifying the core interpreter files (`src/lexer.lua`, `src/parser.lua`, etc.) and do not wish to rebuild the binary each time, you can run directly using Lua 5.4+:

```bash
lua main.lua examples/hospital_core.tmq
```

---

## 5. Verification

To verify that your installation is working properly, run the included test suite:

```bash
# test minimal mutation
tumorscript examples/simple_test.tmq

# test full clinical dosage and quarantine simulation
tumorscript examples/hospital_core.tmq

# test quarantine 20% limit enforcement (expected to fail)
tumorscript examples/quarantine_limit_fail.tmq
```
