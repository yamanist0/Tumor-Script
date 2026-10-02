#!/usr/bin/env bash
set -e

# verify lua source syntax with luac if installed
if command -v luac >/dev/null 2>&1; then
    echo "[1/3] checking lua bytecode syntax with luac..."
    luac -p main.lua src/lexer.lua src/parser.lua src/memory.lua src/interpreter.lua
else
    echo "[1/3] luac not found, skipping syntax check..."
fi

# compile native executable with cargo
echo "[2/3] compiling tumorscript executable with cargo..."
cargo build --release

# copy binary to bin directory
echo "[3/3] preparing bin output..."
mkdir -p bin tumorscript/bin
cp target/release/tumorscript bin/tumorscript
cp target/release/tumorscript tumorscript/bin/tumorscript
chmod +x bin/tumorscript tumorscript/bin/tumorscript

echo ""
echo "build complete! binary located at bin/tumorscript"
echo "test it with: ./bin/tumorscript examples/hospital_core.tmq"
