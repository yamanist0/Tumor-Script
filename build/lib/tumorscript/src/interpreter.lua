-- interpreter module for tumorscript
-- walks the ast and executes it with biomorphic runtime semantics

local memory = require("src.memory")

local interpreter = {}
interpreter.__index = interpreter

function interpreter.new(ast, source)
    local self = setmetatable({}, interpreter)
    self.ast = ast
    self.source = source
    self.mem = memory.new()
    self.genes = {}       -- registered gene definitions
    self.cells = {}       -- registered cell definitions
    self.call_stack = {}   -- for tracking gene calls
    return self
end

-- main execution entry
function interpreter:execute()
    local ok, err = pcall(function()
        -- first pass: register all genes and cells
        self:register_definitions(self.ast.body)
        
        -- second pass: execute top-level statements
        self.mem:push_scope()
        self:exec_block(self.ast.body)
        
        -- auto-call main() if it exists
        if self.genes["main"] then
            self:call_gene("main", {})
        end
        
        self.mem:pop_scope()
    end)
    
    if not ok then
        return false, tostring(err)
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

-- execute a block of statements, returns apoptosis value if hit
function interpreter:exec_block(statements)
    for _, stmt in ipairs(statements) do
        local result, is_apoptosis = self:exec_statement(stmt)
        if is_apoptosis then
            return result, true
        end
    end
    return nil, false
end

-- execute a single statement
function interpreter:exec_statement(stmt)
    local t = stmt.node_type

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
    elseif t == "quarantine_block" then
        return self:exec_quarantine(stmt)
    elseif t == "chemo_statement" then
        return self:exec_chemo(stmt)
    elseif t == "apoptosis_statement" then
        return self:exec_apoptosis(stmt)
    elseif t == "expression_statement" then
        self:eval_expression(stmt.expression)
        return nil, false
    elseif t == "metastasis" then
        -- import is a no-op for now, just acknowledge it
        return nil, false
    elseif t == "gene_definition" or t == "cell_definition" then
        -- already registered in first pass
        return nil, false
    else
        error("RUNTIME_TUMOR: unknown statement type '" .. tostring(t) .. "'")
    end
end

-- variable declaration
function interpreter:exec_var_declaration(stmt)
    local value = self:eval_expression(stmt.value)
    local var, err = self.mem:declare(stmt.name, value, stmt.var_type)
    if err then error(err) end
    return nil, false
end

-- assignment
function interpreter:exec_assignment(stmt)
    local value = self:eval_expression(stmt.value)
    local target = stmt.target

    if target.node_type == "identifier" then
        -- try infection: if the value came from a mutated source
        local source_var = self.mem:lookup(target.name)
        if source_var then
            -- check if the rhs involves any mutated variables
            self:try_infect_from_expression(target.name, stmt.value)
        end
        
        local _, err = self.mem:write(target.name, value)
        if err then error(err) end
    elseif target.node_type == "dot_access" then
        -- handle object.field = value
        local obj = self:eval_expression(target.object)
        if type(obj) == "table" and obj.__cell_data then
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
    else
        error("RUNTIME_TUMOR: invalid assignment target")
    end

    return nil, false
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
        parts[#parts + 1] = tostring(val)
    end
    print(table.concat(parts, ""))
    return nil, false
end

-- conditional branching
function interpreter:exec_if(stmt)
    local cond = self:eval_expression(stmt.condition)
    if self:is_truthy(cond) then
        self.mem:push_scope()
        local result, is_apoptosis = self:exec_block(stmt.body)
        self.mem:pop_scope()
        return result, is_apoptosis
    end

    -- check elif branches
    if stmt.elif_branches then
        for _, branch in ipairs(stmt.elif_branches) do
            local elif_cond = self:eval_expression(branch.condition)
            if self:is_truthy(elif_cond) then
                self.mem:push_scope()
                local result, is_apoptosis = self:exec_block(branch.body)
                self.mem:pop_scope()
                return result, is_apoptosis
            end
        end
    end

    -- else branch
    if stmt.else_body then
        self.mem:push_scope()
        local result, is_apoptosis = self:exec_block(stmt.else_body)
        self.mem:pop_scope()
        return result, is_apoptosis
    end

    return nil, false
end

-- while loop
function interpreter:exec_while(stmt)
    local max_iterations = 10000  -- safety net
    local count = 0
    
    while true do
        count = count + 1
        if count > max_iterations then
            error("RUNTIME_TUMOR: infinite loop detected (>" .. max_iterations .. " iterations)")
        end

        local cond = self:eval_expression(stmt.condition)
        if not self:is_truthy(cond) then break end

        self.mem:push_scope()
        local result, is_apoptosis = self:exec_block(stmt.body)
        self.mem:pop_scope()
        
        if is_apoptosis then
            return result, true
        end
    end

    return nil, false
end

-- quarantine block - freezes all mutation
function interpreter:exec_quarantine(stmt)
    self.mem:enter_quarantine()
    self.mem:push_scope()
    local result, is_apoptosis = self:exec_block(stmt.body)
    self.mem:pop_scope()
    self.mem:exit_quarantine()
    return result, is_apoptosis
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

-- apoptosis returns value
function interpreter:exec_apoptosis(stmt)
    local value = nil
    if stmt.value then
        value = self:eval_expression(stmt.value)
    end
    return value, true
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
    elseif t == "identifier" then
        return self:eval_identifier(expr)
    elseif t == "dot_access" then
        return self:eval_dot_access(expr)
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

-- dot access on cell objects
function interpreter:eval_dot_access(expr)
    local obj = self:eval_expression(expr.object)
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

-- binary operations
function interpreter:eval_binary_op(expr)
    -- short-circuit for logical ops
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
    elseif expr.op == "%" then return (left or 0) % (right or 0)
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

-- function calls
function interpreter:eval_call(expr)
    local callee = expr.callee
    local args = {}
    for _, arg_expr in ipairs(expr.arguments) do
        args[#args + 1] = self:eval_expression(arg_expr)
    end

    -- resolve the gene name
    local gene_name = nil
    if callee.node_type == "identifier" then
        gene_name = callee.name
    elseif callee.node_type == "dot_access" then
        -- for now just use the field name
        gene_name = callee.field
    end

    if gene_name and self.genes[gene_name] then
        -- check if any args are from mutated variables, infect the gene
        for i, arg_expr in ipairs(expr.arguments) do
            if arg_expr.node_type == "identifier" then
                local src_var = self.mem:lookup(arg_expr.name)
                if src_var and src_var.mutation_rate > memory.INITIAL_MUTATION_RATE then
                    self.mem:infect_gene(gene_name, src_var.mutation_rate)
                end
            end
        end
        
        return self:call_gene(gene_name, args)
    end

    error("RUNTIME_TUMOR: undefined gene '" .. tostring(gene_name) .. "'")
end

-- call a gene (function)
function interpreter:call_gene(name, args)
    local gene = self.genes[name]
    if not gene then
        error("RUNTIME_TUMOR: undefined gene '" .. name .. "'")
    end

    -- push call stack
    self.call_stack[#self.call_stack + 1] = name

    -- create new scope for the gene
    self.mem:push_scope()

    -- bind parameters
    for i, param_name in ipairs(gene.params) do
        self.mem:declare(param_name, args[i], "dna")
    end

    -- execute gene body
    local result, _ = self:exec_block(gene.body)

    -- apply gene infection to return value (if numeric)
    local infection = self.mem:get_gene_infection(name)
    if infection > 0 and type(result) == "number" then
        local delta = infection * (math.random() * 2 - 1)
        result = result * (1 + delta)
    end

    self.mem:pop_scope()

    -- pop call stack
    self.call_stack[#self.call_stack] = nil

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
