-- interpreter module for tumorscript
-- walks the ast and executes it with biomorphic runtime semantics

local memory = require("src.memory")
local json_mod = require("src.json")
local capsid_mod = require("src.capsid")

local interpreter = {}
interpreter.__index = interpreter

-- makes a new tumor array
local function make_tumor(elements)
    local original = {}
    local rates = {}
    local reads = {}
    for i, el in ipairs(elements) do
        original[i] = el
        rates[i] = memory.INITIAL_MUTATION_RATE
        reads[i] = 0
    end
    return {
        __type = "tumor",
        elements = elements,
        original_elements = original,
        rates = rates,
        reads = reads,
    }
end

-- creates membrane receptor map
local function make_membrane(pairs_list)
    local rec = {}
    local i = 1
    while i <= #pairs_list do
        local k = tostring(pairs_list[i])
        local v = pairs_list[i + 1]
        rec[k] = v
        i = i + 2
    end
    return {
        __type = "membrane",
        receptors = rec,
    }
end

-- create necrosis object
local function make_necrosis(limit, initial_value)
    return {
        __is_necrosis = true,
        limit = tonumber(limit) or 1,
        value = initial_value,
    }
end

-- splits string into pieces by delimiter
local function split_string(str, sep)
    local pieces = {}
    if sep == "" or sep == nil then
        for i = 1, #str do
            pieces[#pieces + 1] = str:sub(i, i)
        end
        return pieces
    end
    local start = 1
    local s_from, s_to = string.find(str, sep, start, true)
    while s_from do
        pieces[#pieces + 1] = string.sub(str, start, s_from - 1)
        start = s_to + 1
        s_from, s_to = string.find(str, sep, start, true)
    end
    pieces[#pieces + 1] = string.sub(str, start)
    return pieces
end

-- pauses execution for a given duration in seconds
local function sys_sleep(seconds)
    local sec = tonumber(seconds) or 0
    if sec <= 0 then return end

    -- use native rust thread sleep if available
    if type(__native_sleep) == "function" then
        __native_sleep(math.floor(sec * 1000))
        return
    end

    -- short durations use clock loop
    if sec < 0.05 then
        local t0 = os.clock()
        while (os.clock() - t0) < sec do end
        return
    end

    -- check platform path separator for windows
    local is_win = package and package.config and package.config:sub(1, 1) == "\\"
    if is_win then
        local ping_count = math.max(1, math.floor(sec + 1))
        local ok = os.execute("ping 127.0.0.1 -n " .. ping_count .. " >nul 2>nul")
        if ok == 0 or ok == true then return end
    else
        local ok = os.execute("sleep " .. sec .. " >/dev/null 2>&1")
        if ok == 0 or ok == true then return end
    end

    -- fallback clock loop
    local t0 = os.clock()
    while (os.clock() - t0) < sec do end
end

-- pretty format values for printing
function interpreter:format_val(val)
    if val == nil then return "nil" end
    if type(val) == "table" then
        if val.__type == "tumor" then
            local items = {}
            for _, el in ipairs(val.elements) do
                items[#items + 1] = self:format_val(el)
            end
            return "tumor(" .. table.concat(items, ", ") .. ")"
        elseif val.__type == "membrane" then
            local items = {}
            for k, v in pairs(val.receptors) do
                items[#items + 1] = tostring(k) .. ": " .. self:format_val(v)
            end
            return "membrane{" .. table.concat(items, ", ") .. "}"
        elseif val.__cell_data then
            local items = {}
            for k, v in pairs(val.__cell_data) do
                items[#items + 1] = tostring(k) .. ": " .. self:format_val(v.value)
            end
            return "cell{" .. table.concat(items, ", ") .. "}"
        end
    end
    return tostring(val)
end

function interpreter.new(ast, source, filename)
    local self = setmetatable({}, interpreter)
    self.ast = ast
    self.source = source
    self.filename = filename or "<specimen>"
    self.mem = memory.new()
    self.genes = {}
    self.cells = {}
    self.call_stack = {}
    self.current_line = 1
    self.current_statement = nil
    self.source_lines = {}
    for line in (source or ""):gmatch("([^\r\n]*)\r?\n?") do
        self.source_lines[#self.source_lines + 1] = line
    end
    return self
end

-- formats clinical colored metastasis traceback for organ failure
function interpreter:format_metastasis_traceback(err_msg)
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
        b_mag   = "\27[1;35m",
    }

    local out = {}
    local function add(s) out[#out + 1] = s end

    add("")
    add(c.b_red .. string.rep("=", 78) .. c.reset)
    add(c.b_red .. " [!] CRITICAL BIOLOGICAL CRASH: ORGAN FAILURE EXCEPTION" .. c.reset)
    add(c.b_red .. string.rep("=", 78) .. c.reset)

    -- summary of organ failure
    local ratio = (self.mem.total_vars > 0) and (self.mem.malignant_count / self.mem.total_vars) or 0
    add(string.format(
        " %s%sMalignant Saturation: %d/%d specimens corrupted (%.1f%% >= 50.0%% fatal threshold)%s",
        c.bold, c.red, self.mem.malignant_count, self.mem.total_vars, ratio * 100, c.reset
    ))
    add(string.format(" %sClinical Diagnostic: Cellular tissue suffered irreversible entropy collapse.%s", c.dim, c.reset))
    add("")

    -- patient zero detection
    add(c.b_yel .. "--- PATIENT ZERO (Initial Site of Malignancy) ---" .. c.reset)
    if self.mem.patient_zero then
        local p0 = self.mem.patient_zero
        local p0_name, p0_reads, p0_from, p0_to, p0_rate
        if p0.event == "contagion" then
            p0_name = p0.target or p0.source or "unknown"
            p0_reads = p0.source_reads or 0
            p0_from = tostring(p0.source or "infected")
            p0_to = string.format("rate %.2f%%", (p0.target_rate or 0) * 100)
            p0_rate = p0.source_rate or 0
        else
            p0_name = p0.var_name or p0.name or "unknown"
            p0_reads = p0.read_count or 0
            p0_from = tostring(p0.original_value or "?")
            p0_to = tostring(p0.value or "?")
            p0_rate = p0.mutation_rate or 0
        end
        add(string.format("  Specimen Name     : %s%s%s", c.bold .. c.red, p0_name, c.reset))
        add(string.format("  Malignant at Read : %sRead #%d%s (drifted from %s to %s)",
            c.yellow, p0_reads, c.reset, p0_from, p0_to))
        add(string.format("  Contagion Rate    : %s%.2f%%%s", c.red, p0_rate * 100, c.reset))
        add(string.format("  Origin Location   : %sgene '%s'%s at line %s%d%s",
            c.cyan, tostring(p0.gene or "global"), c.reset,
            c.yellow, p0.line or 0, c.reset))
    else
        add(string.format("  %sNo single patient zero identified%s", c.dim, c.reset))
    end
    add("")

    -- metastasis transmission trail
    add(c.b_yel .. "--- METASTASIS TRANSMISSION TRAIL (Contagion Vectors) ---" .. c.reset)
    if #self.mem.metastasis_chain > 0 then
        local max_events = math.min(10, #self.mem.metastasis_chain)
        local start_idx = math.max(1, #self.mem.metastasis_chain - max_events + 1)
        local step = 1
        for i = start_idx, #self.mem.metastasis_chain do
            local ev = self.mem.metastasis_chain[i]
            if ev.event == "malignant" then
                add(string.format("  [%d] %sMalignancy Spawned:%s '%s' degraded at read #%d (drift rate: %.2f%%) in %s:%d",
                    step, c.b_red, c.reset, ev.var_name, ev.read_count, ev.mutation_rate * 100, ev.gene, ev.line))
            elseif ev.event == "contagion" then
                add(string.format("  [%d] %sContagion Spread:%s '%s' (reads: %d, rate: %.2f%%) infected '%s' (new rate: %.2f%%) at line %d",
                    step, c.b_yel, c.reset, ev.source, ev.source_reads, ev.source_rate * 100, ev.target, ev.target_rate * 100, ev.line))
            elseif ev.event == "gene_infection" then
                add(string.format("  [%d] %sGene Contaminated:%s '%s' infected gene '%s' (viral load: %.2f%%) at line %d",
                    step, c.b_mag, c.reset, ev.source, ev.gene, (ev.viral_load or 0) * 100, ev.line))
            end
            step = step + 1
        end
    else
        add(string.format("  %sNo contagion propagation logged before systemic crash%s", c.dim, c.reset))
    end
    add("")

    -- active call stack
    add(c.b_cyan .. "--- METASTASIS CALL STACK (Active Cellular Frames) ---" .. c.reset)
    if #self.call_stack > 0 then
        for i = #self.call_stack, 1, -1 do
            local frame = self.call_stack[i]
            local inf = frame.infection or 0
            local inf_str = (inf > 0)
                and string.format(" %s[viral infection load: %.2f%%]%s", c.red, inf * 100, c.reset)
                or string.format(" %s[sterile]%s", c.green, c.reset)
            add(string.format("  Frame [%d] %s%s()%s at %s%s:%d%s%s",
                i - 1, c.bold .. c.cyan, frame.name, c.reset,
                c.yellow, frame.file, frame.line, c.reset, inf_str))
            
            local src_line = self.source_lines and self.source_lines[frame.line]
            if src_line and src_line:match("%S") then
                add(string.format("    %s>>>%s %s", c.b_red, c.reset, src_line:gsub("^%s+", "")))
            end
        end
    else
        add(string.format("  Frame [0] %s<cellular_entrypoint>%s at %s:%d",
            c.cyan, c.reset, self.filename or "<specimen>", self.current_line or 1))
        local src_line = self.source_lines and self.source_lines[self.current_line or 1]
        if src_line and src_line:match("%S") then
            add(string.format("    %s>>>%s %s", c.b_red, c.reset, src_line:gsub("^%s+", "")))
        end
    end
    add("")

    -- specimen biopsy telemetry
    add(c.bold .. "--- SPECIMEN BIOPSY TELEMETRY (Active Memory Heap) ---" .. c.reset)
    add(string.format("  %-16s %-6s %-16s %-6s %-10s %s",
        "Specimen", "Strain", "Value", "Reads", "Mutation", "Status"))
    add("  " .. string.rep("-", 74))

    for scope_idx = #self.mem.scopes, 1, -1 do
        local scope = self.mem.scopes[scope_idx]
        for name, var in pairs(scope) do
            local val_str = tostring(var.value)
            if #val_str > 15 then val_str = val_str:sub(1, 12) .. "..." end
            local status_str = c.green .. "HEALTHY" .. c.reset
            if var.type == "rna" then
                status_str = c.cyan .. "IMMUNE (RNA)" .. c.reset
            elseif var.is_malignant then
                if self.mem.patient_zero and (self.mem.patient_zero.var_name == name or self.mem.patient_zero.name == name) then
                    status_str = c.b_red .. "MALIGNANT [PATIENT ZERO]" .. c.reset
                else
                    status_str = c.red .. "MALIGNANT [METASTASIZED]" .. c.reset
                end
            end
            add(string.format("  %-16s %-6s %-16s %-6d %-9.2f%% %s",
                name, var.type, val_str, var.read_count, var.mutation_rate * 100, status_str))
        end
    end

    add(c.b_red .. string.rep("=", 78) .. c.reset)
    add("")
    return table.concat(out, "\n")
end

-- main execution entry
function interpreter:execute()
    local ok, err = pcall(function()
        -- first pass: register all genes and cells
        self:register_definitions(self.ast.body)
        
        -- second pass: execute top-level statements
        self.mem:push_scope()
        local result, signal = self:exec_block(self.ast.body)
        if signal == "remission" or signal == "relapse" then
            error("SYNTAX_TUMOR: '" .. signal .. "' used outside of loop")
        end
        
        -- auto-call main() if it exists
        if self.genes["main"] then
            self:call_gene("main", {})
        end
        
        self.mem:pop_scope()
    end)
    
    if not ok then
        local err_str = tostring(err)
        if err_str:match("ORGAN_FAILURE_EXCEPTION") then
            return false, self:format_metastasis_traceback(err_str)
        end
        return false, err_str
    end
    return true, nil
end

-- register gene and cell definitions without executing them
function interpreter:register_definitions(statements)
    for _, stmt in ipairs(statements) do
        if stmt.node_type == "gene_definition" then
            self.genes[stmt.name] = stmt
        elseif stmt.node_type == "cell_definition" then
            self.cells[stmt.name] = stmt
        end
    end
end

-- execute a block of statements
function interpreter:exec_block(statements)
    for _, stmt in ipairs(statements) do
        local result, signal = self:exec_statement(stmt)
        if signal then
            return result, signal
        end
    end
    return nil, nil
end

-- execute a single statement
function interpreter:exec_statement(stmt)
    local t = stmt.node_type
    self.current_statement = stmt
    if stmt.line then
        self.current_line = stmt.line
        if self.mem then
            self.mem.current_line = stmt.line
        end
        if #self.call_stack > 0 then
            self.call_stack[#self.call_stack].line = stmt.line
        end
    end

    if t == "var_declaration" then
        return self:exec_var_declaration(stmt)
    elseif t == "assignment" then
        return self:exec_assignment(stmt)
    elseif t == "print_statement" then
        return self:exec_print(stmt)
    elseif t == "if_statement" then
        return self:exec_if(stmt)
    elseif t == "while_statement" then
        return self:exec_while(stmt)
    elseif t == "for_statement" then
        return self:exec_for(stmt)
    elseif t == "remission_statement" then
        return nil, "remission"
    elseif t == "relapse_statement" then
        return nil, "relapse"
    elseif t == "quarantine_block" then
        return self:exec_quarantine(stmt)
    elseif t == "chemo_statement" then
        return self:exec_chemo(stmt)
    elseif t == "apoptosis_statement" then
        return self:exec_apoptosis(stmt)
    elseif t == "expression_statement" then
        local val = self:eval_expression(stmt.expression)
        return val, nil
    elseif t == "metastasis" then
        return nil, nil
    elseif t == "gene_definition" or t == "cell_definition" then
        return nil, nil
    else
        error("RUNTIME_TUMOR: unknown statement type '" .. tostring(t) .. "'")
    end
end

-- variable declaration
function interpreter:exec_var_declaration(stmt)
    local value = self:eval_expression(stmt.value)
    local var, err = self.mem:declare(stmt.name, value, stmt.var_type)
    if err then error(err) end
    return nil, nil
end

-- assignment
function interpreter:exec_assignment(stmt)
    local value = self:eval_expression(stmt.value)
    local target = stmt.target

    if target.node_type == "identifier" then
        local source_var = self.mem:lookup(target.name)
        if source_var then
            self:try_infect_from_expression(target.name, stmt.value)
        end
        local _, err = self.mem:write(target.name, value)
        if err then error(err) end
    elseif target.node_type == "dot_access" then
        local obj = self:eval_expression(target.object)
        if type(obj) == "table" and obj.__type == "membrane" then
            obj.receptors[target.field] = value
        elseif type(obj) == "table" and obj.__cell_data then
            local field_name = target.field
            local field_var = obj.__cell_data[field_name]
            if field_var then
                if field_var.type == "rna" then
                    error("IMMUNE_VIOLATION: cannot reassign rna field '" .. field_name .. "'")
                end
                field_var.value = value
            else
                error("UNDEFINED_CELL: field '" .. field_name .. "' does not exist")
            end
        else
            error("RUNTIME_TUMOR: cannot assign field on non-cell value")
        end
    elseif target.node_type == "index_access" then
        local obj = self:eval_expression(target.object)
        local idx = self:eval_expression(target.index)
        if type(obj) == "table" and obj.__type == "tumor" then
            local raw_idx = math.floor(tonumber(idx) or 0)
            local lua_idx = raw_idx < 0 and (#obj.elements + raw_idx + 1) or (raw_idx + 1)
            if lua_idx < 1 or lua_idx > #obj.elements then
                error("RUNTIME_TUMOR: tumor index out of bounds: " .. tostring(idx))
            end
            obj.elements[lua_idx] = value
            obj.original_elements[lua_idx] = value
            obj.rates[lua_idx] = memory.INITIAL_MUTATION_RATE
            obj.reads[lua_idx] = 0
        elseif type(obj) == "table" and obj.__type == "membrane" then
            obj.receptors[tostring(idx)] = value
        elseif type(obj) == "table" then
            obj[idx] = value
        else
            error("RUNTIME_TUMOR: cannot assign index on non-collection value")
        end
    else
        error("RUNTIME_TUMOR: invalid assignment target")
    end

    return nil, nil
end

-- try to spread infection through expression evaluation
function interpreter:try_infect_from_expression(target_name, expr)
    if expr.node_type == "identifier" then
        local source = self.mem:lookup(expr.name)
        if source then
            self.mem:try_infect(target_name, source)
        end
    elseif expr.node_type == "binary_op" then
        self:try_infect_from_expression(target_name, expr.left)
        self:try_infect_from_expression(target_name, expr.right)
    end
end

-- print statement
function interpreter:exec_print(stmt)
    local parts = {}
    for _, arg in ipairs(stmt.arguments) do
        local val = self:eval_expression(arg)
        parts[#parts + 1] = self:format_val(val)
    end
    print(table.concat(parts, ""))
    return nil, nil
end

-- conditional branching
function interpreter:exec_if(stmt)
    local cond = self:eval_expression(stmt.condition)
    if self:is_truthy(cond) then
        self.mem:push_scope()
        local result, signal = self:exec_block(stmt.body)
        self.mem:pop_scope()
        return result, signal
    end

    -- check elif branches
    if stmt.elif_branches then
        for _, branch in ipairs(stmt.elif_branches) do
            local elif_cond = self:eval_expression(branch.condition)
            if self:is_truthy(elif_cond) then
                self.mem:push_scope()
                local result, signal = self:exec_block(branch.body)
                self.mem:pop_scope()
                return result, signal
            end
        end
    end

    -- else branch
    if stmt.else_body then
        self.mem:push_scope()
        local result, signal = self:exec_block(stmt.else_body)
        self.mem:pop_scope()
        return result, signal
    end

    return nil, nil
end

-- while loop
function interpreter:exec_while(stmt)
    local max_iterations = 100000
    local count = 0
    
    while true do
        count = count + 1
        if count > max_iterations then
            error("RUNTIME_TUMOR: infinite loop detected (>" .. max_iterations .. " iterations)")
        end

        local cond = self:eval_expression(stmt.condition)
        if not self:is_truthy(cond) then break end

        self.mem:push_scope()
        local result, signal = self:exec_block(stmt.body)
        self.mem:pop_scope()
        
        if signal == "apoptosis" then
            return result, "apoptosis"
        elseif signal == "remission" then
            break
        elseif signal == "relapse" then
            -- resume next loop cycle
        end
    end

    return nil, nil
end

-- for loop
function interpreter:exec_for(stmt)
    local iterable = self:eval_expression(stmt.iterable)
    local items = {}

    if type(iterable) == "table" and iterable.__type == "tumor" then
        for _, el in ipairs(iterable.elements) do
            items[#items + 1] = el
        end
    elseif type(iterable) == "table" and iterable.__type == "membrane" then
        for k, _ in pairs(iterable.receptors) do
            items[#items + 1] = k
        end
    elseif type(iterable) == "table" then
        for _, v in ipairs(iterable) do
            items[#items + 1] = v
        end
    elseif type(iterable) == "string" then
        for i = 1, #iterable do
            items[#items + 1] = iterable:sub(i, i)
        end
    else
        error("RUNTIME_TUMOR: value is not iterable")
    end

    for _, val in ipairs(items) do
        self.mem:push_scope()
        self.mem:declare(stmt.var_name, val, "dna")
        local result, signal = self:exec_block(stmt.body)
        self.mem:pop_scope()

        if signal == "apoptosis" then
            return result, "apoptosis"
        elseif signal == "remission" then
            break
        elseif signal == "relapse" then
            -- resume next loop cycle
        end
    end

    return nil, nil
end

-- quarantine block freezes all mutation
function interpreter:exec_quarantine(stmt)
    self.mem:enter_quarantine()
    self.mem:push_scope()
    local result, signal = self:exec_block(stmt.body)
    self.mem:pop_scope()
    self.mem:exit_quarantine()
    return result, signal
end

-- chemo - reset a mutated variable
function interpreter:exec_chemo(stmt)
    local target = stmt.target
    
    -- handle dotted targets like "p1.heart_rate"
    if target:find("%.") then
        local parts = {}
        for part in target:gmatch("[^%.]+") do
            parts[#parts + 1] = part
        end
        -- resolve the object chain
        local obj_name = parts[1]
        local obj_var = self.mem:lookup(obj_name)
        if not obj_var then
            error("UNDEFINED_CELL: '" .. obj_name .. "' does not exist")
        end
        if type(obj_var.value) == "table" and obj_var.value.__cell_data then
            local field_name = parts[2]
            local field = obj_var.value.__cell_data[field_name]
            if not field then
                error("UNDEFINED_CELL: field '" .. field_name .. "' does not exist")
            end
            -- apply chemo to the field directly
            if math.random() < memory.CHEMO_KILL_CHANCE then
                obj_var.value.__cell_data[field_name] = nil
                print("CHEMO_LETHAL: field '" .. field_name .. "' was destroyed by treatment")
            else
                field.value = field.original_value
                field.mutation_rate = memory.INITIAL_MUTATION_RATE
                field.read_count = 0
                field.is_malignant = false
            end
        end
    else
        local success, msg = self.mem:apply_chemo(target)
        if msg then print(msg) end
    end
    
    return nil, false
end

-- apoptosis returns value and signal
function interpreter:exec_apoptosis(stmt)
    local value = nil
    if stmt.value then
        value = self:eval_expression(stmt.value)
    end
    return value, "apoptosis"
end

-- expression evaluation
function interpreter:eval_expression(expr)
    local t = expr.node_type

    if t == "number_literal" then
        return expr.value
    elseif t == "string_literal" then
        return expr.value
    elseif t == "bool_literal" then
        return expr.value
    elseif t == "nil_literal" then
        return nil
    elseif t == "tumor_literal" then
        local elems = {}
        for _, el_expr in ipairs(expr.elements) do
            elems[#elems + 1] = self:eval_expression(el_expr)
        end
        return make_tumor(elems)
    elseif t == "identifier" then
        return self:eval_identifier(expr)
    elseif t == "dot_access" then
        return self:eval_dot_access(expr)
    elseif t == "index_access" then
        local obj = self:eval_expression(expr.object)
        local idx = self:eval_expression(expr.index)
        return self:eval_index_get(obj, idx)
    elseif t == "binary_op" then
        return self:eval_binary_op(expr)
    elseif t == "unary_op" then
        return self:eval_unary_op(expr)
    elseif t == "call_expr" then
        return self:eval_call(expr)
    elseif t == "mitosis_expr" then
        return self:eval_mitosis(expr)
    else
        error("RUNTIME_TUMOR: unknown expression type '" .. tostring(t) .. "'")
    end
end

-- reading a variable triggers mutation
function interpreter:eval_identifier(expr)
    local val, err = self.mem:read(expr.name)
    if err then error(err) end
    return val
end

-- dot access on cells and membranes
function interpreter:eval_dot_access(expr)
    local obj = self:eval_expression(expr.object)
    if type(obj) == "table" and obj.__type == "membrane" then
        return obj.receptors[expr.field]
    end
    if type(obj) == "table" and obj.__cell_data then
        local field = obj.__cell_data[expr.field]
        if not field then
            error("UNDEFINED_CELL: field '" .. expr.field .. "' does not exist")
        end
        -- reading a field triggers mutation too
        if field.type == "dna" and not self.mem.in_quarantine then
            field.read_count = field.read_count + 1
            field.mutation_rate = math.min(
                field.mutation_rate + memory.MUTATION_ESCALATION,
                memory.MAX_MUTATION_RATE
            )
            if type(field.value) == "number" then
                local delta = field.mutation_rate * (math.random() * 2 - 1)
                field.value = field.value * (1 + delta)
            elseif type(field.value) == "string" and #field.value > 0 then
                if math.random() < field.mutation_rate * 10 then
                    local idx = math.random(1, #field.value)
                    local byte = string.byte(field.value, idx)
                    byte = math.max(32, math.min(126, byte + math.random(-2, 2)))
                    field.value = field.value:sub(1, idx - 1) .. string.char(byte) .. field.value:sub(idx + 1)
                end
            end
        end
        return field.value
    elseif type(obj) == "table" then
        return obj[expr.field]
    end
    error("RUNTIME_TUMOR: cannot access field '" .. expr.field .. "' on non-cell value")
end

-- collection index access
function interpreter:eval_index_get(obj, idx)
    if type(obj) == "table" and obj.__type == "tumor" then
        local raw_idx = math.floor(tonumber(idx) or 0)
        local lua_idx = raw_idx < 0 and (#obj.elements + raw_idx + 1) or (raw_idx + 1)
        if lua_idx < 1 or lua_idx > #obj.elements then
            return nil
        end
        -- observation effect mutates elements
        if not self.mem.in_quarantine then
            obj.reads[lua_idx] = (obj.reads[lua_idx] or 0) + 1
            obj.rates[lua_idx] = math.min(
                (obj.rates[lua_idx] or memory.INITIAL_MUTATION_RATE) + memory.MUTATION_ESCALATION,
                memory.MAX_MUTATION_RATE
            )
            local val = obj.elements[lua_idx]
            if type(val) == "number" then
                local delta = obj.rates[lua_idx] * (math.random() * 2 - 1)
                val = val * (1 + delta)
                if math.random() < obj.rates[lua_idx] then
                    val = val + (math.random() > 0.5 and 1 or -1)
                end
                obj.elements[lua_idx] = val
            elseif type(val) == "string" and #val > 0 then
                if math.random() < obj.rates[lua_idx] * 10 then
                    local cidx = math.random(1, #val)
                    local byte = string.byte(val, cidx)
                    local shift = math.random(-2, 2)
                    byte = math.max(32, math.min(126, byte + shift))
                    val = val:sub(1, cidx - 1) .. string.char(byte) .. val:sub(cidx + 1)
                    obj.elements[lua_idx] = val
                end
            elseif type(val) == "boolean" then
                if math.random() < obj.rates[lua_idx] then
                    val = not val
                    obj.elements[lua_idx] = val
                end
            end
        end
        return obj.elements[lua_idx]
    elseif type(obj) == "table" and obj.__type == "membrane" then
        return obj.receptors[tostring(idx)]
    elseif type(obj) == "string" then
        local raw_idx = math.floor(tonumber(idx) or 0)
        local sidx = raw_idx < 0 and (#obj + raw_idx + 1) or (raw_idx + 1)
        if sidx >= 1 and sidx <= #obj then
            return obj:sub(sidx, sidx)
        end
        return nil
    elseif type(obj) == "table" then
        return obj[idx]
    end
    error("RUNTIME_TUMOR: cannot index non-collection value")
end

-- binary operations
function interpreter:eval_binary_op(expr)
    -- short circuit for logical ops
    if expr.op == "and" then
        local left = self:eval_expression(expr.left)
        if not self:is_truthy(left) then return left end
        return self:eval_expression(expr.right)
    end
    if expr.op == "or" then
        local left = self:eval_expression(expr.left)
        if self:is_truthy(left) then return left end
        return self:eval_expression(expr.right)
    end

    local left = self:eval_expression(expr.left)
    local right = self:eval_expression(expr.right)

    if expr.op == "+" then
        if type(left) == "string" or type(right) == "string" then
            return tostring(left) .. tostring(right)
        end
        return (left or 0) + (right or 0)
    elseif expr.op == "-" then return (left or 0) - (right or 0)
    elseif expr.op == "*" then return (left or 0) * (right or 0)
    elseif expr.op == "/" then
        if (right or 0) == 0 then error("RUNTIME_TUMOR: division by zero") end
        return (left or 0) / (right or 0)
    elseif expr.op == "%" then
        if (right or 0) == 0 then error("RUNTIME_TUMOR: modulo by zero") end
        return (left or 0) % (right or 0)
    elseif expr.op == "==" then return left == right
    elseif expr.op == "!=" then return left ~= right
    elseif expr.op == "<" then return (left or 0) < (right or 0)
    elseif expr.op == ">" then return (left or 0) > (right or 0)
    elseif expr.op == "<=" then return (left or 0) <= (right or 0)
    elseif expr.op == ">=" then return (left or 0) >= (right or 0)
    end

    error("RUNTIME_TUMOR: unknown operator '" .. tostring(expr.op) .. "'")
end

-- unary operations
function interpreter:eval_unary_op(expr)
    local operand = self:eval_expression(expr.operand)
    if expr.op == "-" then return -(operand or 0) end
    if expr.op == "not" then return not self:is_truthy(operand) end
    error("RUNTIME_TUMOR: unknown unary operator '" .. tostring(expr.op) .. "'")
end

-- function calls and built in routines
function interpreter:eval_call(expr)
    local callee = expr.callee
    local args = {}
    for _, arg_expr in ipairs(expr.arguments) do
        args[#args + 1] = self:eval_expression(arg_expr)
    end

    local gene_name = nil
    local module_name = nil
    if callee.node_type == "identifier" then
        gene_name = callee.name
    elseif callee.node_type == "dot_access" then
        gene_name = callee.field
        if callee.object and callee.object.node_type == "identifier" then
            module_name = callee.object.name
        end
    end

    -- built in routines
    if gene_name == "tumor" then
        return make_tumor(args)
    elseif gene_name == "membrane" then
        return make_membrane(args)
    elseif gene_name == "necrosis" then
        return make_necrosis(args[1] or 1, args[2])
    elseif gene_name == "range" then
        local start = 0
        local stop = 0
        local step = 1
        if #args == 1 then
            stop = tonumber(args[1]) or 0
        elseif #args == 2 then
            start = tonumber(args[1]) or 0
            stop = tonumber(args[2]) or 0
        elseif #args >= 3 then
            start = tonumber(args[1]) or 0
            stop = tonumber(args[2]) or 0
            step = tonumber(args[3]) or 1
        end
        local elems = {}
        if step > 0 then
            local curr = start
            while curr < stop do
                elems[#elems + 1] = curr
                curr = curr + step
            end
        elseif step < 0 then
            local curr = start
            while curr > stop do
                elems[#elems + 1] = curr
                curr = curr + step
            end
        end
        return make_tumor(elems)
    elseif gene_name == "biopsy" then
        local t = args[1]
        local raw_idx = math.floor(tonumber(args[2]) or 0)
        if type(t) == "table" and t.__type == "tumor" then
            local idx = raw_idx < 0 and (#t.elements + raw_idx + 1) or (raw_idx + 1)
            return t.elements[idx]
        end
        error("RUNTIME_TUMOR: biopsy expects a tumor object")
    elseif gene_name == "spread" then
        local t = args[1]
        local val = args[2]
        if type(t) == "table" and t.__type == "tumor" then
            t.elements[#t.elements + 1] = val
            t.original_elements[#t.original_elements + 1] = val
            t.rates[#t.rates + 1] = memory.INITIAL_MUTATION_RATE
            t.reads[#t.reads + 1] = 0
            return t
        end
        error("RUNTIME_TUMOR: spread expects a tumor object")
    elseif gene_name == "excise" then
        local t = args[1]
        local raw_idx = math.floor(tonumber(args[2]) or 0)
        if type(t) == "table" and t.__type == "tumor" then
            local idx = raw_idx < 0 and (#t.elements + raw_idx + 1) or (raw_idx + 1)
            if idx < 1 or idx > #t.elements then
                return nil
            end
            local excised = table.remove(t.elements, idx)
            table.remove(t.original_elements, idx)
            table.remove(t.rates, idx)
            table.remove(t.reads, idx)
            return excised
        end
        error("RUNTIME_TUMOR: excise expects a tumor object")
    elseif gene_name == "mass" or gene_name == "len" then
        local x = args[1]
        if type(x) == "table" and x.__type == "tumor" then
            return #x.elements
        elseif type(x) == "table" and x.__type == "membrane" then
            local count = 0
            for _ in pairs(x.receptors) do count = count + 1 end
            return count
        elseif type(x) == "string" then
            return #x
        elseif type(x) == "table" then
            return #x
        elseif x == nil then
            return 0
        else
            return 1
        end
    elseif gene_name == "strain" then
        local x = args[1]
        if type(x) == "table" and x.__type == "tumor" then
            return "tumor"
        elseif type(x) == "table" and x.__type == "membrane" then
            return "membrane"
        elseif type(x) == "table" and x.__cell_data then
            return "cell"
        elseif type(x) == "number" then
            return "number"
        elseif type(x) == "string" then
            return "string"
        elseif type(x) == "boolean" then
            return "boolean"
        elseif x == nil then
            return "nil"
        else
            return type(x)
        end
    elseif gene_name == "bind" then
        local m = args[1]
        local key = tostring(args[2])
        local val = args[3]
        if type(m) == "table" and m.__type == "membrane" then
            m.receptors[key] = val
            return m
        end
        error("RUNTIME_TUMOR: bind expects a membrane object")
    elseif gene_name == "unbind" then
        local m = args[1]
        local key = tostring(args[2])
        if type(m) == "table" and m.__type == "membrane" then
            local old = m.receptors[key]
            m.receptors[key] = nil
            return old
        end
        error("RUNTIME_TUMOR: unbind expects a membrane object")
    elseif gene_name == "receptors" then
        local m = args[1]
        if type(m) == "table" and m.__type == "membrane" then
            local keys = {}
            for k, _ in pairs(m.receptors) do
                keys[#keys + 1] = k
            end
            return make_tumor(keys)
        end
        error("RUNTIME_TUMOR: receptors expects a membrane object")

    -- input and output functions
    elseif gene_name == "input" or gene_name == "absorb" or gene_name == "read_line"
       or (module_name == "io" and (gene_name == "read" or gene_name == "input" or gene_name == "read_line")) then
        if args[1] ~= nil and gene_name ~= "read_line" then
            io.write(tostring(args[1]))
            io.flush()
        end
        local line = io.read("*l")
        return line or ""
    elseif gene_name == "read_file" or gene_name == "ingest"
       or ((module_name == "fs" or module_name == "io") and gene_name == "read_file") then
        local path = tostring(args[1] or "")
        local f = io.open(path, "r")
        if not f then return nil end
        local content = f:read("*a")
        f:close()
        return content
    elseif gene_name == "write_file" or gene_name == "secrete"
       or ((module_name == "fs" or module_name == "io") and gene_name == "write_file") then
        local path = tostring(args[1] or "")
        local content = tostring(args[2] or "")
        local f = io.open(path, "w")
        if not f then return false end
        f:write(content)
        f:close()
        return true
    elseif gene_name == "append_file" or gene_name == "infiltrate"
       or ((module_name == "fs" or module_name == "io") and gene_name == "append_file") then
        local path = tostring(args[1] or "")
        local content = tostring(args[2] or "")
        local f = io.open(path, "a")
        if not f then return false end
        f:write(content)
        f:close()
        return true
    elseif gene_name == "file_exists"
       or ((module_name == "fs" or module_name == "io") and gene_name == "exists") then
        local path = tostring(args[1] or "")
        local f = io.open(path, "r")
        if f then f:close(); return true else return false end

    -- string and array tools
    elseif gene_name == "split" or gene_name == "lyse"
       or (module_name == "string" and gene_name == "split") then
        local str = tostring(args[1] or "")
        local sep = args[2] and tostring(args[2]) or " "
        return make_tumor(split_string(str, sep))
    elseif gene_name == "join" or gene_name == "fuse"
       or (module_name == "string" and gene_name == "join") then
        local col = args[1]
        local sep = args[2] and tostring(args[2]) or ""
        local raw = {}
        if type(col) == "table" and col.__type == "tumor" then
            for _, el in ipairs(col.elements) do
                raw[#raw + 1] = tostring(el)
            end
        elseif type(col) == "table" then
            for _, el in ipairs(col) do
                raw[#raw + 1] = tostring(el)
            end
        end
        return table.concat(raw, sep)
    elseif gene_name == "upper" or gene_name == "hypertrophy"
       or (module_name == "string" and gene_name == "upper") then
        return string.upper(tostring(args[1] or ""))
    elseif gene_name == "lower" or gene_name == "atrophy"
       or (module_name == "string" and gene_name == "lower") then
        return string.lower(tostring(args[1] or ""))
    elseif gene_name == "trim"
       or (module_name == "string" and gene_name == "trim") then
        local s = tostring(args[1] or "")
        return s:match("^%s*(.-)%s*$")
    elseif gene_name == "contains" then
        local col = args[1]
        local target = args[2]
        if type(col) == "string" then
            return string.find(col, tostring(target), 1, true) ~= nil
        elseif type(col) == "table" and col.__type == "tumor" then
            for _, v in ipairs(col.elements) do
                if v == target then return true end
            end
            return false
        elseif type(col) == "table" and col.__type == "membrane" then
            return col.receptors[tostring(target)] ~= nil
        end
        return false
    elseif gene_name == "slice" or gene_name == "resect" then
        local col = args[1]
        local s = math.floor(tonumber(args[2]) or 0) + 1
        local e = args[3] and (math.floor(tonumber(args[3]) or 0)) or nil
        if type(col) == "string" then
            return string.sub(col, s, e or #col)
        elseif type(col) == "table" and col.__type == "tumor" then
            local sl = {}
            local stop_idx = e or #col.elements
            for i = s, stop_idx do
                if col.elements[i] ~= nil then
                    sl[#sl + 1] = col.elements[i]
                end
            end
            return make_tumor(sl)
        end
        return nil
    elseif gene_name == "to_number" or gene_name == "tonumber" then
        return tonumber(args[1])
    elseif gene_name == "to_string" or gene_name == "tostring" then
        return tostring(args[1])

    -- math routines
    elseif gene_name == "random" or (module_name == "math" and gene_name == "random") then
        if #args == 0 then
            return math.random()
        elseif #args == 1 then
            local max_val = tonumber(args[1]) or 1
            if max_val <= 1 then return math.random() * max_val end
            return math.random(1, math.floor(max_val))
        else
            local min_val = tonumber(args[1]) or 0
            local max_val = tonumber(args[2]) or 1
            if min_val == math.floor(min_val) and max_val == math.floor(max_val) and min_val < max_val then
                return math.random(min_val, max_val)
            elseif min_val > max_val then
                return max_val + math.random() * (min_val - max_val)
            else
                return min_val + math.random() * (max_val - min_val)
            end
        end
    elseif gene_name == "sqrt" or (module_name == "math" and gene_name == "sqrt") then
        return math.sqrt(tonumber(args[1]) or 0)
    elseif gene_name == "floor" or (module_name == "math" and gene_name == "floor") then
        return math.floor(tonumber(args[1]) or 0)
    elseif gene_name == "ceil" or (module_name == "math" and gene_name == "ceil") then
        return math.ceil(tonumber(args[1]) or 0)
    elseif gene_name == "round" or (module_name == "math" and gene_name == "round") then
        local val = tonumber(args[1]) or 0
        local dec = tonumber(args[2]) or 0
        local mult = 10 ^ dec
        if val >= 0 then
            return math.floor(val * mult + 0.5) / mult
        else
            return math.ceil(val * mult - 0.5) / mult
        end
    elseif gene_name == "abs" or (module_name == "math" and gene_name == "abs") then
        return math.abs(tonumber(args[1]) or 0)
    elseif gene_name == "min" or (module_name == "math" and gene_name == "min") then
        local m = nil
        for _, v in ipairs(args) do
            local num = tonumber(v)
            if num and (m == nil or num < m) then m = num end
        end
        return m
    elseif gene_name == "max" or (module_name == "math" and gene_name == "max") then
        local m = nil
        for _, v in ipairs(args) do
            local num = tonumber(v)
            if num and (m == nil or num > m) then m = num end
        end
        return m
    elseif gene_name == "pow" or (module_name == "math" and gene_name == "pow") then
        return (tonumber(args[1]) or 0) ^ (tonumber(args[2]) or 1)
    -- trig and log builtins
    elseif gene_name == "sin" or (module_name == "math" and gene_name == "sin") then
        return math.sin(tonumber(args[1]) or 0)
    elseif gene_name == "cos" or (module_name == "math" and gene_name == "cos") then
        return math.cos(tonumber(args[1]) or 0)
    elseif gene_name == "tan" or (module_name == "math" and gene_name == "tan") then
        return math.tan(tonumber(args[1]) or 0)
    elseif gene_name == "asin" or (module_name == "math" and gene_name == "asin") then
        return math.asin(tonumber(args[1]) or 0)
    elseif gene_name == "acos" or (module_name == "math" and gene_name == "acos") then
        return math.acos(tonumber(args[1]) or 0)
    elseif gene_name == "atan" or (module_name == "math" and gene_name == "atan") then
        return math.atan(tonumber(args[1]) or 0)
    elseif gene_name == "log" or gene_name == "ln" or (module_name == "math" and gene_name == "log") then
        local x = tonumber(args[1]) or 1
        local base = args[2] and tonumber(args[2]) or nil
        if base then return math.log(x, base) end
        return math.log(x)
    elseif gene_name == "log10" or (module_name == "math" and gene_name == "log10") then
        local x = tonumber(args[1]) or 1
        return math.log(x, 10)
    elseif gene_name == "exp" or (module_name == "math" and gene_name == "exp") then
        return math.exp(tonumber(args[1]) or 0)
    elseif gene_name == "rad" or (module_name == "math" and gene_name == "rad") then
        return math.rad(tonumber(args[1]) or 0)
    elseif gene_name == "deg" or (module_name == "math" and gene_name == "deg") then
        return math.deg(tonumber(args[1]) or 0)
    elseif gene_name == "pi" or (module_name == "math" and gene_name == "pi") then
        return math.pi

    -- time and sleep routines
    elseif gene_name == "sleep" or gene_name == "dormancy"
       or (module_name == "time" and gene_name == "sleep") then
        sys_sleep(args[1] or 0)
        return nil
    elseif gene_name == "time" or (module_name == "time" and gene_name == "now") then
        return os.time()
    elseif gene_name == "clock" or gene_name == "metabolism"
       or (module_name == "time" and gene_name == "clock") then
        return os.clock()

    -- json genomic routines
    elseif gene_name == "transcribe"
       or ((module_name == "json" or module_name == "genome") and (gene_name == "transcribe" or gene_name == "dumps" or gene_name == "encode")) then
        local text, err = json_mod.transcribe(args[1], args[2], args[3])
        if not text and err then
            error("GENOMIC_CORRUPTION: " .. tostring(err))
        end
        return text
    elseif gene_name == "express"
       or ((module_name == "json" or module_name == "genome") and (gene_name == "express" or gene_name == "loads" or gene_name == "decode")) then
        local str = tostring(args[1] or "")
        local val, err = json_mod.express(str)
        if val == nil and err then
            error("GENOMIC_CORRUPTION: failed to express json payload: " .. tostring(err))
        end
        return val
    elseif gene_name == "karyotype"
       or ((module_name == "json" or module_name == "genome") and (gene_name == "karyotype" or gene_name == "diagnose")) then
        return json_mod.karyotype(args[1])
    elseif gene_name == "transduce"
       or ((module_name == "json" or module_name == "genome") and (gene_name == "transduce" or gene_name == "splice")) then
        local res, err = json_mod.transduce(args[1], args[2])
        if not res and err then
            error("RUNTIME_TUMOR: " .. tostring(err))
        end
        return res
    elseif gene_name == "secrete_json" or gene_name == "transcribe_file"
       or ((module_name == "json" or module_name == "genome") and (gene_name == "secrete_json" or gene_name == "transcribe_file" or gene_name == "dump")) then
        local ok, err = json_mod.secrete_json(args[1], args[2], args[3], args[4])
        if not ok and err then
            error("RUNTIME_TUMOR: " .. tostring(err))
        end
        return ok
    elseif gene_name == "ingest_json" or gene_name == "express_file"
       or ((module_name == "json" or module_name == "genome") and (gene_name == "ingest_json" or gene_name == "express_file" or gene_name == "load")) then
        local val, err = json_mod.ingest_json(args[1])
        if val == nil and err then
            error("GENOMIC_CORRUPTION: failed to ingest json: " .. tostring(err))
        end
        return val

    -- binary capsid routines
    elseif gene_name == "condense"
       or ((module_name == "capsid" or module_name == "histone" or module_name == "binary" or module_name == "struct") and (gene_name == "condense" or gene_name == "pack" or gene_name == "capsulate")) then
        local fmt = tostring(args[1] or "")
        local pack_args = {}
        for i = 2, #args do
            pack_args[#pack_args + 1] = args[i]
        end
        return capsid_mod.condense(fmt, table.unpack(pack_args))
    elseif gene_name == "decondense"
       or ((module_name == "capsid" or module_name == "histone" or module_name == "binary" or module_name == "struct") and (gene_name == "decondense" or gene_name == "unpack" or gene_name == "decapsulate")) then
        local fmt = tostring(args[1] or "")
        local buf = tostring(args[2] or "")
        local off = args[3] and (math.floor(tonumber(args[3]) or 0) + 1) or 1
        local res, _ = capsid_mod.decondense(fmt, buf, off)
        return res
    elseif gene_name == "strand_length" or gene_name == "molecular_weight"
       or ((module_name == "capsid" or module_name == "histone" or module_name == "binary" or module_name == "struct") and (gene_name == "strand_length" or gene_name == "molecular_weight" or gene_name == "calcsize")) then
        return capsid_mod.strand_length(tostring(args[1] or ""))
    elseif gene_name == "splice_into"
       or ((module_name == "capsid" or module_name == "histone" or module_name == "binary" or module_name == "struct") and (gene_name == "splice_into" or gene_name == "pack_into")) then
        local fmt = tostring(args[1] or "")
        local buf = tostring(args[2] or "")
        local off = tonumber(args[3]) or 0
        local pack_args = {}
        for i = 4, #args do
            pack_args[#pack_args + 1] = args[i]
        end
        return capsid_mod.splice_into(fmt, buf, off, table.unpack(pack_args))
    elseif gene_name == "biopsy_from"
       or ((module_name == "capsid" or module_name == "histone" or module_name == "binary" or module_name == "struct") and (gene_name == "biopsy_from" or gene_name == "unpack_from")) then
        local fmt = tostring(args[1] or "")
        local buf = tostring(args[2] or "")
        local off = tonumber(args[3]) or 0
        local res, _ = capsid_mod.biopsy_from(fmt, buf, off)
        return res
    elseif gene_name == "cleave"
       or ((module_name == "capsid" or module_name == "histone" or module_name == "binary" or module_name == "struct") and (gene_name == "cleave" or gene_name == "iter_unpack")) then
        local fmt = tostring(args[1] or "")
        local buf = tostring(args[2] or "")
        return capsid_mod.cleave(fmt, buf)
    elseif gene_name == "hex_biopsy"
       or ((module_name == "capsid" or module_name == "histone" or module_name == "binary" or module_name == "struct") and gene_name == "hex_biopsy") then
        local buf = tostring(args[1] or "")
        local row_size = args[2] and tonumber(args[2]) or 16
        return capsid_mod.hex_biopsy(buf, row_size)
    elseif gene_name == "radiation_drift"
       or ((module_name == "capsid" or module_name == "histone" or module_name == "binary" or module_name == "struct") and gene_name == "radiation_drift") then
        local buf = tostring(args[1] or "")
        local rate = args[2] and tonumber(args[2]) or 0.05
        return capsid_mod.radiation_drift(buf, rate)
    elseif gene_name == "karyotype_binary"
       or ((module_name == "capsid" or module_name == "histone" or module_name == "binary" or module_name == "struct") and gene_name == "karyotype_binary") then
        local buf = tostring(args[1] or "")
        return capsid_mod.karyotype_binary(buf)
    end

    -- user defined gene calls
    if gene_name and self.genes[gene_name] then
        for i, arg_expr in ipairs(expr.arguments) do
            if arg_expr.node_type == "identifier" then
                local src_var = self.mem:lookup(arg_expr.name)
                if src_var and src_var.mutation_rate > memory.INITIAL_MUTATION_RATE then
                    self.mem:infect_gene(gene_name, src_var.mutation_rate, arg_expr.name, src_var.read_count)
                end
            end
        end
        
        return self:call_gene(gene_name, args, expr.line)
    end

    error("RUNTIME_TUMOR: undefined gene '" .. tostring(gene_name) .. "'")
end

-- call a gene
function interpreter:call_gene(name, args, call_line)
    local gene = self.genes[name]
    if not gene then
        error("RUNTIME_TUMOR: undefined gene '" .. name .. "'")
    end

    local line = call_line or self.current_line or (gene.line or 1)
    local frame = {
        name = name,
        line = line,
        file = self.filename or "<specimen>",
        args = args,
        infection = self.mem:get_gene_infection(name),
    }
    self.call_stack[#self.call_stack + 1] = frame
    if self.mem then
        self.mem.current_gene = name
    end

    -- create new scope for the gene
    self.mem:push_scope()

    -- bind parameters
    for i, param_name in ipairs(gene.params) do
        self.mem:declare(param_name, args[i], "dna")
    end

    -- execute gene body
    local result, _ = self:exec_block(gene.body)

    -- apply gene infection to return value if numeric
    local infection = self.mem:get_gene_infection(name)
    if infection > 0 and type(result) == "number" then
        local delta = infection * (math.random() * 2 - 1)
        result = result * (1 + delta)
    end

    self.mem:pop_scope()

    -- pop call stack
    self.call_stack[#self.call_stack] = nil
    if self.mem then
        local prev = self.call_stack[#self.call_stack]
        self.mem.current_gene = prev and prev.name or "global"
    end

    return result
end

-- mitosis: create a new cell instance
function interpreter:eval_mitosis(expr)
    local cell_def = self.cells[expr.cell_name]
    if not cell_def then
        error("RUNTIME_TUMOR: undefined cell '" .. expr.cell_name .. "'")
    end

    -- create a new cell instance as a table with __cell_data
    local instance = { __cell_data = {} }

    -- initialize fields from the cell definition body
    for _, stmt in ipairs(cell_def.body) do
        if stmt.node_type == "var_declaration" then
            local value = self:eval_expression(stmt.value)
            if stmt.var_type == "rna" then
                instance.__cell_data[stmt.name] = {
                    type = "rna",
                    value = value,
                    original_value = value,
                    mutation_rate = 0,
                    read_count = 0,
                    is_malignant = false,
                }
            else
                instance.__cell_data[stmt.name] = {
                    type = "dna",
                    value = value,
                    original_value = value,
                    mutation_rate = memory.INITIAL_MUTATION_RATE,
                    read_count = 0,
                    is_malignant = false,
                }
            end
        end
    end

    return instance
end

-- truthiness check
function interpreter:is_truthy(value)
    if value == nil then return false end
    if value == false then return false end
    if value == 0 then return false end
    return true
end

return interpreter
