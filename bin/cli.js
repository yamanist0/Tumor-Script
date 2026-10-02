#!/usr/bin/env node

// cli launcher for tumorscript npm package
const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

function findBinary() {
    // look for compiled binary in bin directory
    const isWindows = process.platform === 'win32';
    const binName = isWindows ? 'tumorscript.exe' : 'tumorscript';
    const binaryPath = path.join(__dirname, binName);

    if (fs.existsSync(binaryPath)) {
        return binaryPath;
    }
    return null;
}

function findLua() {
    // look for main lua script
    const rootDir = path.resolve(__dirname, '..');
    const mainScript = path.join(rootDir, 'main.lua');

    if (fs.existsSync(mainScript)) {
        return mainScript;
    }
    return null;
}

function main() {
    const args = process.argv.slice(2);

    // check for compiled native binary
    const binary = findBinary();
    if (binary) {
        const result = spawnSync(binary, args, { stdio: 'inherit' });
        process.exit(result.status !== null ? result.status : 1);
    }

    // fallback to lua interpreter if installed
    const luaScript = findLua();
    if (luaScript) {
        const luaCmd = process.platform === 'win32' ? 'lua.exe' : 'lua';
        const result = spawnSync(luaCmd, [luaScript, ...args], { stdio: 'inherit' });
        if (!result.error) {
            process.exit(result.status !== null ? result.status : 1);
        }
    }

    // neither binary nor lua was found
    console.error('FATAL: tumorscript executable not found');
    console.error('please run build.bat or install lua to execute scripts');
    process.exit(1);
}

main();
