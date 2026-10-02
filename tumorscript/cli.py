# cli entry point for tumorscript command
import os
import sys
import shutil
import subprocess

def find_binary():
    # look for compiled binary in package or nearby directories
    base_dir = os.path.dirname(os.path.abspath(__file__))
    is_windows = sys.platform == "win32"
    bin_name = "tumorscript.exe" if is_windows else "tumorscript"

    # check package bin folder
    candidate = os.path.join(base_dir, "bin", bin_name)
    if os.path.isfile(candidate) and os.access(candidate, os.X_OK):
        return candidate

    # check workspace bin folder
    candidate = os.path.join(os.path.dirname(base_dir), "bin", bin_name)
    if os.path.isfile(candidate) and (is_windows or os.access(candidate, os.X_OK)):
        return candidate

    return None

def find_lua_entry():
    # look for main lua script
    base_dir = os.path.dirname(os.path.abspath(__file__))

    # check inside package
    candidate = os.path.join(base_dir, "main.lua")
    if os.path.isfile(candidate):
        return candidate

    # check parent directory
    candidate = os.path.join(os.path.dirname(base_dir), "main.lua")
    if os.path.isfile(candidate):
        return candidate

    return None

def main():
    args = sys.argv[1:]

    # check for compiled binary first
    binary = find_binary()
    if binary:
        res = subprocess.run([binary] + args)
        sys.exit(res.returncode)

    # fallback to lua interpreter
    lua_script = find_lua_entry()
    lua_cmd = shutil.which("lua") or shutil.which("lua54") or shutil.which("lua53")

    if lua_cmd and lua_script:
        res = subprocess.run([lua_cmd, lua_script] + args)
        sys.exit(res.returncode)

    # could not find binary or lua
    print("FATAL: tumorscript executable not found")
    print("please run build.bat or install lua to execute scripts")
    sys.exit(1)

if __name__ == "__main__":
    main()
