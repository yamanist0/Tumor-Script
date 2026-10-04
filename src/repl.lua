-- repl module for tumorscript
-- handles interactive execution live variable inspection and commands

local lexer = require("src.lexer")
local parser = require("src.parser")
local interpreter = require("src.interpreter")
local memory = require("src.memory")

local repl = {}

-- ansi terminal colors
local c = {
    reset   = "\27[0m",
    bold    = "\27[1m",
    dim     = "\27[2m",
    red     = "\27[31m",
    b_red   = "\27[1;31m",
    yellow  = "\27[33m",
    b_yel   = "\27[1;33m",
    cyan    = "\27[36m",
    b_cyan  = "\27[1;36m",
    green   = "\27[32m",
    b_green = "\27[1;32m",
    magenta = "\27[35m",
    b_mag   = "\27[1;35m",
    gray    = "\27[90m",
}

-- prints the interactive shell banner
local function print_banner()
    print(c.b_cyan .. "====================================================================" .. c.reset)
    print(c.b_cyan .. "  TumorScript v1.0.0 " .. c.yellow .. "- Biomorphic Interactive Shell (Petri Dish)" .. c.reset)
    print(c.cyan   .. "  Type " .. c.b_yel .. ":help" .. c.cyan .. " for commands, " .. c.b_yel .. ":vitals" .. c.cyan .. " for telemetry, " .. c.b_red .. ":exit" .. c.cyan .. " to quit." .. c.reset)
    print(c.dim    .. "  Variables decay live upon observation. Handle specimens carefully." .. c.reset)
    print(c.b_cyan .. "====================================================================" .. c.reset)
end

-- print help for repl
local function print_help()
    print(c.b_yel .. "\n--- CLINICAL REPL MANUAL ---" .. c.reset)
    print(c.bold .. "Special Commands:" .. c.reset)
    print(string.format("  %-16s %s", c.cyan .. ":vitals" .. c.reset, "Display live specimen telemetry and organ integrity"))
    print(string.format("  %-16s %s", c.cyan .. ":chemo <name>" .. c.reset, "Administer chemotherapy to reset a variable (15% lethal risk)"))
    print(string.format("  %-16s %s", c.cyan .. ":quarantine" .. c.reset, "Toggle sterile cleanroom mode (freeze or resume mutations)"))
    print(string.format("  %-16s %s", c.cyan .. ":clear" .. c.reset, "Clear the terminal screen"))
    print(string.format("  %-16s %s", c.cyan .. ":reset" .. c.reset, "Purge all variables and reset the cellular heap"))
    print(string.format("  %-16s %s", c.cyan .. ":help" .. c.reset, "Display this diagnostic assistance guide"))
    print(string.format("  %-16s %s", c.cyan .. ":exit" .. c.reset, "Terminate session via cellular apoptosis\n"))
    print(c.bold .. "Syntax Quick Reference:" .. c.reset)
    print(string.format("  %-20s %s", c.green .. "dna x = 10" .. c.reset, "Declare mutable decaying variable"))
    print(string.format("  %-20s %s", c.green .. "rna MAX = 100" .. c.reset, "Declare immutable immune constant"))
    print(string.format("  %-20s %s", c.green .. "tumor(1, 2, 3)" .. c.reset, "Declare tumor cell array"))
    print(string.format("  %-20s %s", c.green .. "membrane(\"k\", 1)" .. c.reset, "Declare cell membrane receptors"))
    print(string.format("  %-20s %s", c.green .. "x" .. c.reset, "Observing x triggers mutation and reports live entropy"))
    print(string.format("  %-20s %s", c.green .. "gene add(a, b):" .. c.reset, "Multi-line block (finish with an empty line)\n"))
end

-- display vitals table
local function print_vitals(runtime)
    local mem = runtime.mem
    print(c.b_yel .. "\n--- CLINICAL PETRI DISH VITALS ---" .. c.reset)
    print(string.format("  %-16s %-6s %-16s %-6s %-10s %s",
        "Specimen", "Strain", "Value", "Reads", "Mutation", "Status"))
    print("  " .. string.rep("-", 72))

    local var_found = false
    for scope_idx = #mem.scopes, 1, -1 do
        local scope = mem.scopes[scope_idx]
        for name, var in pairs(scope) do
            var_found = true
            local val_str = runtime:format_val(var.value)
            if #val_str > 15 then val_str = val_str:sub(1, 12) .. "..." end
            local status_str = c.green .. "HEALTHY" .. c.reset
            if var.type == "rna" then
                status_str = c.cyan .. "IMMUNE (RNA)" .. c.reset
            elseif var.is_malignant then
                status_str = c.b_red .. "MALIGNANT" .. c.reset
            elseif var.mutation_rate > memory.INITIAL_MUTATION_RATE * 2 then
                status_str = c.yellow .. "MUTATING" .. c.reset
            end
            print(string.format("  %-16s %-6s %-16s %-6d %-9.2f%% %s",
                name, var.type, val_str, var.read_count, var.mutation_rate * 100, status_str))
        end
    end

    if not var_found then
        print(c.dim .. "  No specimens currently cultivated in the heap." .. c.reset)
    end
    print("  " .. string.rep("-", 72))

    local ratio = (mem.total_vars > 0) and (mem.malignant_count / mem.total_vars) or 0
    local bar_len = 20
    local filled = math.floor(ratio * bar_len)
    local bar = string.rep("█", filled) .. string.rep("░", bar_len - filled)
    local meter_color = (ratio >= 0.5) and c.b_red or ((ratio >= 0.25) and c.yellow or c.green)

    print(string.format("  Organ Health: %s[%s] %.1f%%%s (%d/%d malignant, failure limit: 50.0%%)",
        meter_color, bar, (1 - ratio) * 100, c.reset, mem.malignant_count, mem.total_vars))
    print(string.format("  Quarantine Cleanroom: %s\n",
        mem.in_quarantine and (c.b_green .. "ACTIVE (Mutations Frozen)" .. c.reset)
                           or (c.dim .. "INACTIVE (Mutations Live)" .. c.reset)))
end

-- start repl session
function repl.start()
    print_banner()

    -- seed random generator for live entropy
    pcall(function()
        math.randomseed(os.time() + math.floor((os.clock() or 0) * 1000000))
    end)

    -- setup persistent interpreter
    local runtime = interpreter.new({ node_type = "program", body = {} }, "", "<repl>")
    runtime.mem:push_scope()

    local multiline_buffer = {}
    local in_multiline = false

    while true do
        local prompt = in_multiline
            and (c.cyan .. "... " .. c.reset)
            or  (c.b_green .. "tumor> " .. c.reset)
        
        io.write(prompt)
        io.flush()

        local line = io.read("*l")
        if not line then
            -- eof received
            print(c.cyan .. "\n[cellular apoptosis] repl session terminated cleanly." .. c.reset)
            break
        end

        local trimmed = line:match("^%s*(.-)%s*$")

        -- check multi line block collection
        if in_multiline then
            if trimmed == "" or trimmed == "}" then
                if trimmed == "}" then
                    multiline_buffer[#multiline_buffer + 1] = line
                end
                local full_code = table.concat(multiline_buffer, "\n")
                in_multiline = false
                multiline_buffer = {}
                repl.execute_chunk(runtime, full_code)
            else
                multiline_buffer[#multiline_buffer + 1] = line
            end
        else
            -- empty input
            if trimmed == "" then
                -- do nothing
            -- repl command prefix
            elseif trimmed:sub(1, 1) == ":" then
                local cmd, arg_val = trimmed:match("^:([%a_]+)%s*(.*)$")
                cmd = cmd and cmd:lower() or ""
                if cmd == "exit" or cmd == "quit" or cmd == "q" then
                    print(c.cyan .. "[cellular apoptosis] repl session terminated cleanly." .. c.reset)
                    break
                elseif cmd == "help" or cmd == "?" then
                    print_help()
                elseif cmd == "vitals" or cmd == "status" then
                    print_vitals(runtime)
                elseif cmd == "clear" or cmd == "cls" then
                    io.write("\27[2J\27[H")
                    io.flush()
                elseif cmd == "quarantine" then
                    if runtime.mem.in_quarantine then
                        runtime.mem:exit_quarantine()
                        print(c.yellow .. "[quarantine] sterile cleanroom deactivated; mutations resumed." .. c.reset)
                    else
                        runtime.mem:enter_quarantine()
                        print(c.b_green .. "[quarantine] sterile cleanroom active; mutations frozen." .. c.reset)
                    end
                elseif cmd == "chemo" then
                    local target = arg_val:match("^%s*(.-)%s*$")
                    if target == "" then
                        print(c.red .. "usage: :chemo <variable_name>" .. c.reset)
                    else
                        local ok, chemo_err = runtime.mem:apply_chemo(target)
                        if not ok then
                            print(c.red .. tostring(chemo_err) .. c.reset)
                        elseif chemo_err then
                            print(c.b_red .. "[chemo lethal] " .. chemo_err .. c.reset)
                        else
                            local v = runtime.mem:lookup(target)
                            print(string.format("%s[chemo success]%s '%s' reset to baseline (rate: %.2f%%)",
                                c.b_green, c.reset, target, (v and v.mutation_rate or 0) * 100))
                        end
                    end
                elseif cmd == "reset" then
                    runtime.mem = memory.new()
                    runtime.mem:push_scope()
                    runtime.genes = {}
                    runtime.cells = {}
                    print(c.b_yel .. "[reset] cellular heap purged; all specimens cleared." .. c.reset)
                else
                    print(c.red .. "unknown repl command '" .. trimmed .. "'. type :help for options." .. c.reset)
                end
            -- check if entering multi line block
            elseif trimmed:sub(-1) == ":" or (trimmed:match("^quarantine%s*{" ) and not trimmed:match("}$")) then
                in_multiline = true
                multiline_buffer = { line }
            else
                repl.execute_chunk(runtime, line)
            end
        end
    end
end

-- executes a single line or block chunk
function repl.execute_chunk(runtime, code)
    -- tokenize input
    local tokens, lex_err = lexer.tokenize(code, "<repl>")
    if lex_err then
        print(c.red .. "[LEXER_FAILURE] " .. tostring(lex_err) .. c.reset)
        return
    end

    -- parse into ast
    local ast, parse_err = parser.parse(tokens, code, { is_repl = true })
    if parse_err then
        print(c.red .. "[PARSER_FAILURE] " .. tostring(parse_err) .. c.reset)
        return
    end

    if not ast or not ast.body or #ast.body == 0 then
        return
    end

    -- first register definitions
    runtime:register_definitions(ast.body)

    -- execute statements
    for _, stmt in ipairs(ast.body) do
        local ok, res = pcall(function()
            if stmt.node_type == "var_declaration" then
                runtime:exec_var_declaration(stmt)
                local var = runtime.mem:lookup(stmt.name)
                if var then
                    if var.type == "rna" then
                        print(string.format("%s[rna]%s %s = %s %s(immune constant)%s",
                            c.cyan, c.reset, stmt.name, runtime:format_val(var.value), c.dim, c.reset))
                    else
                        local stat = var.is_malignant and (c.b_red .. "malignant" .. c.reset)
                            or (c.green .. "healthy" .. c.reset)
                        print(string.format("%s[dna]%s %s = %s %s(reads: %d, rate: %.2f%%, status: %s)%s",
                            c.green, c.reset, stmt.name, runtime:format_val(var.value),
                            c.dim, var.read_count, var.mutation_rate * 100, stat, c.reset))
                    end
                end
            elseif stmt.node_type == "assignment" then
                runtime:exec_assignment(stmt)
                if stmt.target.node_type == "identifier" then
                    local var = runtime.mem:lookup(stmt.target.name)
                    if var then
                        print(string.format("%s[%s]%s %s = %s %s(rate: %.2f%%)%s",
                            c.green, var.type, c.reset, stmt.target.name,
                            runtime:format_val(var.value), c.dim, var.mutation_rate * 100, c.reset))
                    end
                end
            elseif stmt.node_type == "expression_statement" then
                -- check state before evaluation for delta tracking
                local id_name = (stmt.expression.node_type == "identifier") and stmt.expression.name or nil
                local prev_val = nil
                local target_var = id_name and runtime.mem:lookup(id_name) or nil
                if target_var and type(target_var.value) == "number" then
                    prev_val = target_var.value
                end

                local val = runtime:eval_expression(stmt.expression)

                -- display evaluated expression with live telemetry
                if id_name and target_var and target_var.type == "dna" then
                    local delta_str = ""
                    if prev_val and type(val) == "number" and prev_val ~= 0 then
                        local diff = ((val - prev_val) / prev_val) * 100
                        delta_str = string.format(" | delta: %+.2f%%", diff)
                    end
                    local stat_str = target_var.is_malignant and (c.b_red .. "MALIGNANT" .. c.reset)
                        or (c.green .. "healthy" .. c.reset)
                    print(string.format("%s=>%s %s  %s[dna read #%d | rate: %.2f%%%s | %s]%s",
                        c.b_cyan, c.reset, runtime:format_val(val), c.dim,
                        target_var.read_count, target_var.mutation_rate * 100, delta_str, stat_str, c.reset))
                else
                    local strain_note = ""
                    if type(val) == "table" and val.__type then
                        strain_note = string.format(" %s[%s]%s", c.dim, val.__type, c.reset)
                    end
                    print(string.format("%s=>%s %s%s", c.b_cyan, c.reset, runtime:format_val(val), strain_note))
                end
            elseif stmt.node_type == "gene_definition" then
                print(string.format("%s[gene]%s defined '%s(%s)'",
                    c.b_mag, c.reset, stmt.name, table.concat(stmt.params, ", ")))
            elseif stmt.node_type == "cell_definition" then
                print(string.format("%s[cell]%s defined cellular blueprint '%s'",
                    c.b_mag, c.reset, stmt.name))
            elseif stmt.node_type == "chemo_statement" then
                runtime:exec_chemo(stmt)
            else
                runtime:exec_statement(stmt)
            end
        end)

        if not ok then
            local err_str = tostring(res)
            if err_str:match("ORGAN_FAILURE_EXCEPTION") then
                print(runtime:format_metastasis_traceback(err_str))
                print(c.b_red .. "[organ failure] critical heap saturation reached in repl." .. c.reset)
                print(c.yellow .. "use :chemo <var> or :reset to restore cellular stability.\n" .. c.reset)
            else
                print(c.red .. "[RUNTIME_TUMOR] " .. err_str .. c.reset)
            end
            break
        end
    end
end

return repl
