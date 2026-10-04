# Standard Library Reference

TumorScript ships with a built-in standard library of biological routines. Every function follows the biomorphic naming convention, though conventional aliases are also accepted.

---

## 1. Input / Output (I/O)

### `absorb(prompt?)` — User Input

Reads a line of text from standard input. Optionally displays a prompt string first.

| Alias | Biological Name |
|---|---|
| `input(prompt?)` | `absorb(prompt?)` |
| `io.read_line()` | `read_line()` |

```python
dna name = absorb("enter patient name: ")
print("admitted: ", name)
```

### `ingest(path)` — File Read

Reads the entire contents of a file into a string. Returns `nil` if the file does not exist.

| Alias | Biological Name |
|---|---|
| `read_file(path)` | `ingest(path)` |
| `io.read_file(path)` | `fs.read_file(path)` |

```python
dna log = ingest("report.txt")
if log != nil:
    print("log contents: ", log)
```

### `secrete(path, content)` — File Write

Writes content to a file, overwriting any existing data. Returns `true` on success.

| Alias | Biological Name |
|---|---|
| `write_file(path, content)` | `secrete(path, content)` |
| `io.write_file(path, content)` | `fs.write_file(path, content)` |

```python
dna ok = secrete("output.txt", "tumor mass: 42")
print("write ok: ", ok)
```

### `infiltrate(path, content)` — File Append

Appends content to an existing file without overwriting. Returns `true` on success.

| Alias | Biological Name |
|---|---|
| `append_file(path, content)` | `infiltrate(path, content)` |

```python
infiltrate("log.txt", "new entry\n")
```

### `file_exists(path)` — File Existence Check

Returns `true` if the file at the given path can be opened, `false` otherwise.

| Alias | Biological Name |
|---|---|
| `file_exists(path)` | `fs.exists(path)` |

```python
if file_exists("config.tmq"):
    print("config found")
```

---

## 2. String & Array Tools

### `lyse(str, separator?)` — String Split

Splits a string into a tumor array by the given separator (defaults to `" "`).

| Alias | Biological Name |
|---|---|
| `split(str, sep?)` | `lyse(str, sep?)` |
| `string.split(str, sep?)` | — |

```python
dna parts = lyse("alpha-beta-gamma", "-")
print("count: ", mass(parts))
```

### `fuse(tumor, separator?)` — Array Join

Joins a tumor array into a single string, separated by the given glue (defaults to `""`).

| Alias | Biological Name |
|---|---|
| `join(tumor, sep?)` | `fuse(tumor, sep?)` |
| `string.join(tumor, sep?)` | — |

```python
dna tags = tumor("cell", "tissue", "organ")
dna csv = fuse(tags, ", ")
print(csv)
```

### `hypertrophy(str)` — Uppercase

Converts an entire string to uppercase letters, like aggressive cellular overgrowth.

| Alias | Biological Name |
|---|---|
| `upper(str)` | `hypertrophy(str)` |
| `string.upper(str)` | — |

```python
print(hypertrophy("benign"))  # BENIGN
```

### `atrophy(str)` — Lowercase

Converts an entire string to lowercase letters, simulating tissue atrophy and degradation.

| Alias | Biological Name |
|---|---|
| `lower(str)` | `atrophy(str)` |
| `string.lower(str)` | — |

```python
print(atrophy("MALIGNANT"))  # malignant
```

### `trim(str)` — Whitespace Trim

Strips leading and trailing whitespace from a string.

```python
dna raw = "  specimen  "
print(trim(raw))  # "specimen"
```

### `contains(collection, target)` — Containment Test

Returns `true` if the target is found in the collection. Works on strings, tumor arrays, and membrane keys.

```python
dna found = contains("hemoglobin", "glob")  # true
dna arr = tumor(10, 20, 30)
print(contains(arr, 20))  # true
```

### `resect(collection, start, end?)` — Slice / Substring

Extracts a sub-range from a string or tumor array using 0-based indexing. The `end` parameter is inclusive.

| Alias | Biological Name |
|---|---|
| `slice(col, start, end?)` | `resect(col, start, end?)` |

```python
dna prefix = resect("cellular", 0, 4)  # "cellu"
dna sub = resect(tumor(10, 20, 30, 40), 1, 2)  # tumor(20, 30)
```

### `to_number(val)` / `to_string(val)` — Type Conversion

Converts values between types. `to_number` returns `nil` if conversion fails.

```python
dna n = to_number("42")
dna s = to_string(3.14)
```

---

## 3. Math Routines

All math functions also accept the `math.` module prefix (e.g. `math.sqrt(x)`).

| Function | Description |
|---|---|
| `sqrt(x)` | Square root of x |
| `floor(x)` | Rounds x down to the nearest integer |
| `ceil(x)` | Rounds x up to the nearest integer |
| `round(x, decimals?)` | Rounds x to the given number of decimal places (default 0) |
| `abs(x)` | Absolute value of x |
| `min(a, b, ...)` | Returns the smallest numeric argument |
| `max(a, b, ...)` | Returns the largest numeric argument |
| `pow(base, exp)` | Raises base to the power of exp |
| `sin(x)` / `cos(x)` / `tan(x)` | Trigonometric sine, cosine, tangent (radians) |
| `asin(x)` / `acos(x)` / `atan(x)` | Inverse trigonometric arc sine, arc cosine, arc tangent |
| `log(x, base?)` / `ln(x)` | Natural logarithm (or optional base logarithm) |
| `log10(x)` | Common base-10 logarithm |
| `exp(x)` | Exponential $e^x$ |
| `rad(deg)` / `deg(rad)` | Angle conversions between degrees and radians |
| `pi()` | Mathematical constant $\pi \approx 3.14159265$ |
| `random()` | Returns a random float between 0 and 1 |
| `random(max)` | Returns a random integer between 1 and max |
| `random(min, max)` | Returns a random integer between min and max |

```python
print(sqrt(144))         # 12.0
print(round(3.14159, 2)) # 3.14
print(sin(rad(90)))      # 1.0
print(log(exp(1)))       # 1.0
print(pi())              # 3.1415926535898
```

---

## 4. Time & Sleep

### `dormancy(seconds)` — Sleep

Pauses execution for the given number of seconds (supports fractional values).

| Alias | Biological Name |
|---|---|
| `sleep(seconds)` | `dormancy(seconds)` |
| `time.sleep(seconds)` | — |

```python
print("entering dormancy...")
dormancy(2.5)
print("awake after 2.5 seconds")
```

### `time()` — Epoch Timestamp

Returns the current Unix epoch timestamp as an integer.

```python
dna now = time()
print("epoch: ", now)
```

### `metabolism()` — CPU Clock

Returns high-resolution CPU clock time in seconds, useful for benchmarking.

| Alias | Biological Name |
|---|---|
| `clock()` | `metabolism()` |
| `time.clock()` | — |

```python
dna start = metabolism()
# do some work...
dna elapsed = metabolism() - start
print("elapsed: ", elapsed, " seconds")
```

---

## 5. Genomics & JSON Serialization

TumorScript features a biomorphic JSON serialization engine that models data interchange as biological transcription (encoding) and expression (decoding). JSON objects are natively mapped to living `membrane` structures, while JSON arrays map to `tumor` collections.

All functions are available globally or under the `json.` and `genome.` namespaces.

### `transcribe(specimen, indent?, entropy?)` — Serialization

Serializes a TumorScript cellular structure (`membrane`, `tumor`, primitive) into a standard JSON string.

| Parameter | Type | Description |
|---|---|---|
| `specimen` | any | The data structure to serialize |
| `indent` | number / boolean | Optional indentation level for pretty-printing (e.g. `2`) |
| `entropy` | number | Optional stochastic mutation rate (e.g. `0.05` introduces 5% radiation drift during transcription) |

| Biomorphic Name | Conventional Aliases |
|---|---|
| `transcribe(val, indent?, entropy?)` | `json.dumps(val, indent?)`, `json.encode(val)` |

```python
dna patient = membrane("name", "Alpha", "stage", 2, "vitals", tumor(120, 80))
dna json_str = transcribe(patient, 2)
print(json_str)

# transcribing under 5% radiation entropy creates mutated json:
dna mutated_json = transcribe(patient, 2, 0.05)
```

### `express(json_string)` — Deserialization

Synthesizes living cellular structures from a JSON string payload. JSON objects become `membrane` receptors (supporting dot access and dynamic mutation), and JSON arrays become `tumor` arrays (supporting observation effect drift and biopsy).

| Biomorphic Name | Conventional Aliases |
|---|---|
| `express(str)` | `json.loads(str)`, `json.decode(str)`, `genome.express(str)` |

```python
dna raw = "{\"id\":\"PAT-101\",\"count\":42,\"active\":true}"
dna cell = express(raw)

print(cell.id)       # "PAT-101"
print(cell.count)    # 42
print(cell.active)   # true
```

If the payload contains invalid JSON, `GENOMIC_CORRUPTION` is raised, which can be safely isolated inside a `quarantine` block.

### `karyotype(target)` — Structural Diagnostics

Analyzes a JSON string or in-memory cellular specimen without raising errors. Returns a diagnostic `membrane` reporting metrics about payload health, nesting depth, and mass.

| Metric Receptor | Description |
|---|---|
| `diag.valid` | Boolean indicating whether the payload is valid JSON / cellular structure |
| `diag.strain` | Primary strain name (`"membrane"`, `"tumor"`, `"primitive"`, or `"corrupted"`) |
| `diag.mass` | Total cell mass (receptors + tumor elements + scalar values) |
| `diag.depth` | Maximum nesting depth |
| `diag.receptors` | Total count of key-value receptors across all membranes |
| `diag.tumor_cells` | Total count of array elements across all tumors |

```python
dna diag = karyotype("{\"status\":\"stable\",\"readings\":[1,2,3]}")
print("Valid: ", diag.valid)      # true
print("Mass: ", diag.mass)        # 6
print("Depth: ", diag.depth)      # 2
```

### `transduce(target, source)` — Genetic Splicing

Directly splices external genetic data (either a JSON string or another cellular structure) into an existing `membrane` or `tumor` in-place.

```python
dna patient = membrane("id", "P-1")
transduce(patient, "{\"stage\":3,\"chemo\":true}")

print(patient.stage)  # 3
print(patient.chemo)  # true
```

### `secrete_json(path, specimen, indent?, entropy?)` — File Secretion

Encodes and writes a cellular specimen directly to a JSON file on disk.

| Biomorphic Name | Conventional Aliases |
|---|---|
| `secrete_json(path, val, indent?)` | `transcribe_file()`, `json.dump()`, `json.secrete_json()` |

```python
dna patient = membrane("patient", "Subject-99", "score", 95)
secrete_json("patient.json", patient, 2)
```

### `ingest_json(path)` — File Ingestion

Reads a JSON file from disk and expresses it into living cellular memory.

| Biomorphic Name | Conventional Aliases |
|---|---|
| `ingest_json(path)` | `express_file()`, `json.load()`, `json.ingest_json()` |

```python
dna patient = ingest_json("patient.json")
print("Loaded patient: ", patient.patient)
```

---

## 6. Binary Packaging & Capsid (`capsid` / `histone` / `binary`)

TumorScript implements binary structure packing and unpacking through the **Capsid** engine (biologically inspired by viral capsids tightly packaging dense nucleic acid strands into binary payloads). It fulfills all functions of Python's `struct` library while adding biological mutation telemetry and hex diagnostics.

All functions are available globally or under the `capsid.`, `histone.`, `binary.`, and `struct.` namespaces.

### Format Codes & Endianness

| Prefix | Byte Order | Size & Alignment |
|---|---|---|
| `<` | Little-endian | Standard, unaligned |
| `>` | Big-endian | Standard, unaligned |
| `!` | Network byte order (= Big-endian) | Standard, unaligned |
| `=` | Native byte order | Standard, unaligned |
| `@` | Native byte order | Native alignment |

| Type Code | C / Python Equivalent | Standard Size | Description |
|---|---|---|---|
| `x` | Pad byte | 1 byte | Null pad byte (no argument) |
| `c` | char | 1 byte | Single character |
| `b` | signed char | 1 byte | Signed integer (-128 to 127) |
| `B` | unsigned char | 1 byte | Unsigned integer (0 to 255) |
| `?` | _Bool / bool | 1 byte | Boolean value (`true` / `false`) |
| `h` | short | 2 bytes | Signed 16-bit integer |
| `H` | unsigned short | 2 bytes | Unsigned 16-bit integer |
| `i` | int | 4 bytes | Signed 32-bit integer |
| `I` | unsigned int | 4 bytes | Unsigned 32-bit integer |
| `q` | long long | 8 bytes | Signed 64-bit integer |
| `Q` | unsigned long long | 8 bytes | Unsigned 64-bit integer |
| `f` | float | 4 bytes | IEEE 754 single precision |
| `d` | double | 8 bytes | IEEE 754 double precision |
| `s` | char[] | count bytes | Fixed-length string (e.g. `10s` pads or truncates to 10 bytes) |
| `p` | pascal string | count bytes | Length-prefixed string (1 byte length + data) |

Multipliers can precede any type code (e.g. `4h` = 4 shorts, `2i` = 2 integers, `16x` = 16 pad bytes).

### `condense(format, ...)` — Binary Packing

Packs values into a contiguous binary byte buffer according to the format string. Arguments can be passed as varargs or as a single `tumor` array.

| Biomorphic Name | Conventional Aliases |
|---|---|
| `condense(fmt, ...)` | `capsid.pack()`, `capsid.condense()`, `struct.pack()` |

```python
dna packet = condense("<2h 8s ? d", 100, 200, "Virus-X", true, 37.5)
print("Packed length: ", mass(packet)) # 21 bytes
```

### `decondense(format, buffer, offset?)` — Binary Unpacking

Unpacks a binary byte buffer into a TumorScript living `tumor` array according to the format string.

| Biomorphic Name | Conventional Aliases |
|---|---|
| `decondense(fmt, buf, offset?)` | `capsid.unpack()`, `capsid.decondense()`, `struct.unpack()` |

```python
dna values = decondense("<2h 8s ? d", packet)
print("Unpacked count: ", mass(values)) # 5
print("ID 1: ", values[0])              # 100
print("Label: ", values[2])             # "Virus-X"
```

### `strand_length(format)` — Buffer Size Calculation

Calculates the exact byte size required by a format string.

| Biomorphic Name | Conventional Aliases |
|---|---|
| `strand_length(fmt)` | `molecular_weight(fmt)`, `capsid.calcsize()`, `struct.calcsize()` |

```python
dna size = strand_length("<4h 10s ? Q") # 27 bytes
```

### `splice_into(format, buffer, offset, ...)` — Pack Into Buffer

Overwrites a slice of an existing buffer starting at `offset` (0-indexed) with newly packed binary data.

| Biomorphic Name | Conventional Aliases |
|---|---|
| `splice_into(fmt, buf, off, ...)` | `capsid.pack_into()`, `struct.pack_into()` |

```python
dna buf = "...................."
dna updated = splice_into("<2i", buf, 4, 1000, 2000)
```

### `biopsy_from(format, buffer, offset)` — Unpack From Buffer

Extracts and unpacks fields from a buffer starting at `offset` (0-indexed).

| Biomorphic Name | Conventional Aliases |
|---|---|
| `biopsy_from(fmt, buf, off)` | `capsid.unpack_from()`, `struct.unpack_from()` |

```python
dna vals = biopsy_from("<2i", updated, 4)
print("Extracted: ", vals[0], ", ", vals[1])
```

### `cleave(format, buffer)` — Iterative Record Slicing

Unpacks repeated records from a stream whose length is an exact multiple of the record size. Returns a `tumor` of `tumor` arrays.

| Biomorphic Name | Conventional Aliases |
|---|---|
| `cleave(fmt, buffer)` | `capsid.iter_unpack()`, `struct.iter_unpack()` |

```python
dna stream = condense("<2h", 1, 2) + condense("<2h", 3, 4)
dna records = cleave("<2h", stream)
for rec in records:
    print("Record: ", rec[0], ", ", rec[1])
```

### `hex_biopsy(buffer, bytes_per_row?)` — Clinical Hex Dump

Formats binary memory into an offset-addressed hexadecimal and ASCII inspection string.

```python
print(hex_biopsy(packet))
# 00000000: 64 00 c8 00 56 69 72 75 73 2d 58 00 01 00 00 00  d...Virus-X.....
```

### `radiation_drift(buffer, rate?)` — Binary Mutation Simulation

Simulates radiation exposure by introducing stochastic bit-flips across the binary payload at the specified rate (default `0.05` = 5% per byte).

```python
dna irradiated = radiation_drift(packet, 0.05)
print(hex_biopsy(irradiated))
```

### `karyotype_binary(buffer)` — Diagnostic Shannon Entropy

Analyzes the byte distribution of a binary buffer. Returns a `membrane` with `size`, `entropy` (Shannon entropy in bits/byte, 0.0 to 8.0), `null_ratio`, `ascii_ratio`, and `strain` classification (`"dense_capsid"` or `"cellular_capsid"`).

```python
dna diag = karyotype_binary(packet)
print("Entropy: ", diag.entropy, " bits/byte")
print("Strain: ", diag.strain)
```

---

## Quick Reference Card

| Category | Biomorphic Name | Conventional Alias | Purpose |
|---|---|---|---|
| **I/O** | `absorb(prompt?)` | `input()` | Read user input |
| | `ingest(path)` | `read_file()` | Read file contents |
| | `secrete(path, data)` | `write_file()` | Write to file |
| | `infiltrate(path, data)` | `append_file()` | Append to file |
| | `file_exists(path)` | `fs.exists()` | Check file existence |
| **String** | `lyse(str, sep?)` | `split()` | Split string to tumor |
| | `fuse(tumor, sep?)` | `join()` | Join tumor to string |
| | `hypertrophy(str)` | `upper()` | Uppercase conversion |
| | `atrophy(str)` | `lower()` | Lowercase conversion |
| | `trim(str)` | `trim()` | Strip whitespace |
| | `contains(col, val)` | — | Search in collection |
| | `resect(col, s, e?)` | `slice()` | Sub-range extraction |
| | `to_number(val)` | `tonumber()` | Parse string to number |
| | `to_string(val)` | `tostring()` | Convert value to string |
| **Math** | `sqrt(x)` | `math.sqrt()` | Square root |
| | `floor(x)` | `math.floor()` | Floor |
| | `ceil(x)` | `math.ceil()` | Ceiling |
| | `round(x, d?)` | `math.round()` | Round to decimals |
| | `abs(x)` | `math.abs()` | Absolute value |
| | `min(...)` | `math.min()` | Minimum |
| | `max(...)` | `math.max()` | Maximum |
| | `pow(b, e)` | `math.pow()` | Power |
| | `random(...)` | `math.random()` | Random number |
| **Time** | `dormancy(s)` | `sleep()` | Pause execution |
| | `time()` | `time.now()` | Unix epoch timestamp |
| | `metabolism()` | `clock()` | CPU clock for benchmarks |
| **Genomics / JSON** | `transcribe(val, ind?, ent?)` | `json.dumps()` / `json.encode()` | Cellular serialization |
| | `express(json_str)` | `json.loads()` / `json.decode()` | Cellular deserialization |
| | `karyotype(target)` | `json.diagnose()` | Structural inspection |
| | `transduce(target, src)` | `json.splice()` | Genetic payload splicing |
| | `secrete_json(path, val)` | `json.dump()` | Write JSON to disk |
| | `ingest_json(path)` | `json.load()` | Read JSON from disk |
| **Capsid / Binary** | `condense(fmt, ...)` | `struct.pack()` / `capsid.pack()` | Binary packet packing |
| | `decondense(fmt, buf)` | `struct.unpack()` / `capsid.unpack()` | Binary packet unpacking |
| | `strand_length(fmt)` | `struct.calcsize()` / `capsid.calcsize()` | Buffer size in bytes |
| | `splice_into(fmt, b, off, ...)` | `struct.pack_into()` | In-place buffer packing |
| | `biopsy_from(fmt, b, off)` | `struct.unpack_from()` | Offset binary extraction |
| | `cleave(fmt, buf)` | `struct.iter_unpack()` | Repeated record unpacking |
| | `hex_biopsy(buf, row?)` | — | Memory telemetry hex dump |
| | `radiation_drift(buf, rate?)` | — | Stochastic bit-flip mutation |
| | `karyotype_binary(buf)` | — | Shannon entropy diagnostics |
