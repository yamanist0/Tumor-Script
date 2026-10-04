-- tumorscript interpreter entry point
-- reads a .tmq file and runs it through the lexer, parser, and interpreter

local lexer = require("src.lexer")
local parser = require("src.parser")
local interpreter = require("src.interpreter")

local function read_file(path)
    local f = io.open(path, "r")
    if not f then
        print("FATAL: could not open file '" .. path .. "'")
        os.exit(1)
    end
    local content = f:read("*a")
    f:close()
    return content
end

local function print_help(prog)
    print("TumorScript Interpreter v1.0.0")
    print("usage: " .. prog .. " [options] [file.tmq]")
    print("\noptions:")
    print("  -i, --repl        launch interactive biomorphic shell")
    print("  -h, --help        show this help message")
    print("  -v, --version     show version")
    print("  --register        register .tmq file association (windows)")
    print("  --unregister      unregister .tmq file association (windows)")
end

local function main()
    local filename = arg and arg[1]
    local prog = "tumorscript"
    if arg and arg[0] and not arg[0]:match("tumorscript") then
        prog = "lua main.lua"
    end

    if filename == "--help" or filename == "-h" then
        print_help(prog)
        os.exit(0)
    end

    if filename == "--version" or filename == "-v" then
        print("TumorScript v1.0.0")
        os.exit(0)
    end

    -- start interactive repl when no arguments provided
    if not filename or filename == "--repl" or filename == "-i" then
        local repl = require("src.repl")
        repl.start()
        os.exit(0)
    end

    -- only allow tmq files for execution
    if not filename:match("%.tmq$") then
        print("FATAL: only .tmq files are supported")
        os.exit(1)
    end

    -- seed random generator for live entropy
    pcall(function()
        math.randomseed(os.time() + math.floor((os.clock() or 0) * 1000000))
    end)

    local source = read_file(filename)
    
    -- tokenize input
    local tokens, lex_err = lexer.tokenize(source, filename)
    if lex_err then
        print("LEXER_FAILURE: " .. lex_err)
        os.exit(1)
    end

    -- parse into ast
    local ast, parse_err = parser.parse(tokens, source)
    if parse_err then
        print("PARSER_FAILURE: " .. parse_err)
        os.exit(1)
    end

    -- interpret with biomorphic runtime
    local runtime = interpreter.new(ast, source, filename)
    local ok, runtime_err = runtime:execute()
    if not ok then
        print(runtime_err or "unknown catastrophic failure")
        os.exit(1)
    end
end

main()
