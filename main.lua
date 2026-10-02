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

local function main()
    local filename = arg and arg[1]
    if not filename then
        local prog = "tumorscript"
        if arg and arg[0] and not arg[0]:match("tumorscript") then
            prog = "lua main.lua"
        end
        print("TumorScript Interpreter v0.1")
        print("usage: " .. prog .. " <file.tmq>")
        os.exit(0)
    end

    -- only allow .tmq files for now
    if not filename:match("%.tmq$") then
        print("FATAL: only .tmq files are supported")
        os.exit(1)
    end

    local source = read_file(filename)
    
    -- phase 1: tokenize
    local tokens, lex_err = lexer.tokenize(source, filename)
    if lex_err then
        print("LEXER_FAILURE: " .. lex_err)
        os.exit(1)
    end

    -- phase 2: parse into ast
    local ast, parse_err = parser.parse(tokens, source)
    if parse_err then
        print("PARSER_FAILURE: " .. parse_err)
        os.exit(1)
    end

    -- phase 3: interpret with biomorphic runtime
    local runtime = interpreter.new(ast, source)
    local ok, runtime_err = runtime:execute()
    if not ok then
        print("ORGAN_FAILURE_EXCEPTION: " .. (runtime_err or "unknown catastrophic failure"))
        os.exit(1)
    end
end

main()
