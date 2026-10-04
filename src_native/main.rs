use mlua::prelude::*;
use std::env;
use std::process;

// embedded source files
const MAIN_SRC: &str = include_str!("../main.lua");
const LEXER_SRC: &str = include_str!("../src/lexer.lua");
const PARSER_SRC: &str = include_str!("../src/parser.lua");
const MEMORY_SRC: &str = include_str!("../src/memory.lua");
const INTERPRETER_SRC: &str = include_str!("../src/interpreter.lua");
const REPL_SRC: &str = include_str!("../src/repl.lua");
const JSON_SRC: &str = include_str!("../src/json.lua");
const CAPSID_SRC: &str = include_str!("../src/capsid.lua");

#[cfg(windows)]
#[link(name = "shell32")]
extern "system" {
    fn SHChangeNotify(event_id: i32, flags: u32, item1: usize, item2: usize);
}

#[cfg(windows)]
fn refresh_shell() {
    // notify windows shell to refresh icons and file associations
    unsafe {
        SHChangeNotify(0x08000000, 0, 0, 0);
    }
}

#[cfg(windows)]
fn register_association() {
    // register file association in windows registry
    let exe = env::current_exe().unwrap_or_default();
    let exe_str = exe.to_string_lossy();
    let open_cmd = format!("cmd.exe /c \"\"{}\" \"%1\" & pause\"", exe_str);
    let icon_val = format!("{},0", exe_str);

    let entries = [
        ("HKCU\\Software\\Classes\\.tmq", "", "TumorScript.File"),
        ("HKCU\\Software\\Classes\\TumorScript.File", "", "TumorScript Quarantine Source"),
        ("HKCU\\Software\\Classes\\TumorScript.File\\DefaultIcon", "", icon_val.as_str()),
        ("HKCU\\Software\\Classes\\TumorScript.File\\shell\\open\\command", "", open_cmd.as_str()),
    ];

    for (key, val_name, val) in entries {
        let mut cmd = process::Command::new("reg");
        cmd.args(["add", key, "/f"]);
        if val_name.is_empty() {
            cmd.arg("/ve");
        } else {
            cmd.args(["/v", val_name]);
        }
        cmd.args(["/d", val]);
        let _ = cmd.output();
    }

    refresh_shell();

    println!("registered .tmq file association successfully");
    println!("double clicking any .tmq file will now open and run it in cmd");
}

#[cfg(windows)]
fn unregister_association() {
    // remove file association from windows registry
    let _ = process::Command::new("reg").args(["delete", "HKCU\\Software\\Classes\\.tmq", "/f"]).output();
    let _ = process::Command::new("reg").args(["delete", "HKCU\\Software\\Classes\\TumorScript.File", "/f"]).output();

    refresh_shell();

    println!("unregistered .tmq file association successfully");
}

fn run() -> LuaResult<()> {
    let args: Vec<String> = env::args().collect();

    // check for registration commands on windows
    #[cfg(windows)]
    if args.len() > 1 {
        if args[1] == "--register" || args[1] == "register" {
            register_association();
            return Ok(());
        }
        if args[1] == "--unregister" || args[1] == "unregister" {
            unregister_association();
            return Ok(());
        }
    }

    // enable ansi escape processing on windows for colored output
    #[cfg(windows)]
    {
        use std::os::windows::io::AsRawHandle;
        let handle = std::io::stdout().as_raw_handle();
        unsafe {
            let mut mode: u32 = 0;
            extern "system" {
                fn GetConsoleMode(h: *mut std::ffi::c_void, m: *mut u32) -> i32;
                fn SetConsoleMode(h: *mut std::ffi::c_void, m: u32) -> i32;
            }
            GetConsoleMode(handle as *mut _, &mut mode);
            SetConsoleMode(handle as *mut _, mode | 0x0004);
        }
    }

    // create the lua state
    let lua = Lua::new();

    // collect command line arguments
    let arg_table = lua.create_table()?;
    for (i, val) in args.iter().enumerate() {
        arg_table.set(i as i64, val.as_str())?;
    }
    lua.globals().set("arg", arg_table)?;

    // native sleep helper for lua
    lua.globals().set(
        "__native_sleep",
        lua.create_function(|_, ms: u64| {
            std::thread::sleep(std::time::Duration::from_millis(ms));
            Ok(())
        })?,
    )?;

    // preload bundled modules into package preload
    let preload: mlua::Table = lua.load("package.preload").eval()?;
    preload.set("src.lexer", lua.load(LEXER_SRC).into_function()?)?;
    preload.set("src.parser", lua.load(PARSER_SRC).into_function()?)?;
    preload.set("src.memory", lua.load(MEMORY_SRC).into_function()?)?;
    preload.set("src.interpreter", lua.load(INTERPRETER_SRC).into_function()?)?;
    preload.set("src.repl", lua.load(REPL_SRC).into_function()?)?;
    preload.set("src.json", lua.load(JSON_SRC).into_function()?)?;
    preload.set("src.capsid", lua.load(CAPSID_SRC).into_function()?)?;

    // execute the main script
    lua.load(MAIN_SRC).exec()?;

    Ok(())
}

fn main() {
    // run runtime and handle any errors
    if let Err(err) = run() {
        eprintln!("{}", err);
        process::exit(1);
    }
}
