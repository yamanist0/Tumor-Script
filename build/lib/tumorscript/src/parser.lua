-- parser module for tumorscript
-- transforms token stream into an abstract syntax tree (ast)
-- handles indentation-based blocks and quarantine {} blocks

local parser = {}

local TOKEN -- will be set from lexer module

-- ast node constructors
local function node(type, props)
    props = props or {}
    props.node_type = type
    return props
end

-- parser state
local State = {}
State.__index = State

function State.new(tokens, source)
    local self = setmetatable({}, State)
    self.tokens = tokens
    self.source = source
    self.pos = 1
    self.total_lines = 0
    self.quarantine_lines = 0
    -- count total source lines for quarantine limit enforcement
    for _ in source:gmatch("[^\n]+") do
        self.total_lines = self.total_lines + 1
    end
    return self
end

function State:peek(offset)
    offset = offset or 0
    local idx = self.pos + offset
    if idx <= #self.tokens then
        return self.tokens[idx]
    end
    return { type = "EOF", value = nil, line = -1 }
end

function State:current()
    return self:peek(0)
end

function State:advance()
    local tok = self.tokens[self.pos]
    self.pos = self.pos + 1
    return tok
end

function State:expect(type, msg)
    local tok = self:current()
    if tok.type ~= type then
        error(string.format("PARSE_TUMOR at line %d: expected %s, got %s (%s). %s",
            tok.line or 0, type, tok.type, tostring(tok.value), msg or ""))
    end
    return self:advance()
end

function State:match(type)
    if self:current().type == type then
        return self:advance()
    end
    return nil
end

function State:skip_newlines()
    while self:current().type == "NEWLINE" do
        self:advance()
    end
end

function State:at_end()
    return self:current().type == "EOF"
end

-- check quarantine limit (max 20% of code)
function State:check_quarantine_limit(line_count)
    self.quarantine_lines = self.quarantine_lines + line_count
    local ratio = self.quarantine_lines / math.max(self.total_lines, 1)
    if ratio > 0.20 then
        error(string.format(
            "QUARANTINE_OVERFLOW at line %d: quarantine blocks exceed 20%% limit (%.1f%% used)",
            self:current().line or 0, ratio * 100))
    end
end

-- expression parsing

function State:parse_expression()
    return self:parse_or()
end

function State:parse_or()
    local left = self:parse_and()
    while self:current().type == "OR" do
        self:advance()
        local right = self:parse_and()
        left = node("binary_op", { op = "or", left = left, right = right })
    end
    return left
end

function State:parse_and()
    local left = self:parse_not()
    while self:current().type == "AND" do
        self:advance()
        local right = self:parse_not()
        left = node("binary_op", { op = "and", left = left, right = right })
    end
    return left
end

function State:parse_not()
    if self:current().type == "NOT" then
        self:advance()
        local operand = self:parse_not()
        return node("unary_op", { op = "not", operand = operand })
    end
    return self:parse_comparison()
end

function State:parse_comparison()
    local left = self:parse_addition()
    local comp_ops = { EQ = "==", NEQ = "!=", LT = "<", GT = ">", LTE = "<=", GTE = ">=" }
    while comp_ops[self:current().type] do
        local op = comp_ops[self:current().type]
        self:advance()
        local right = self:parse_addition()
        left = node("binary_op", { op = op, left = left, right = right })
    end
    return left
end

function State:parse_addition()
    local left = self:parse_multiplication()
    while self:current().type == "PLUS" or self:current().type == "MINUS" do
        local op = self:advance().value
        local right = self:parse_multiplication()
        left = node("binary_op", { op = op, left = left, right = right })
    end
    return left
end

function State:parse_multiplication()
    local left = self:parse_unary()
    while self:current().type == "STAR" or self:current().type == "SLASH" 
          or self:current().type == "PERCENT" do
        local op = self:advance().value
        local right = self:parse_unary()
        left = node("binary_op", { op = op, left = left, right = right })
    end
    return left
end

function State:parse_unary()
    if self:current().type == "MINUS" then
        self:advance()
        local operand = self:parse_unary()
        return node("unary_op", { op = "-", operand = operand })
    end
    return self:parse_primary()
end

function State:parse_primary()
    local tok = self:current()

    -- number literal
    if tok.type == "NUMBER" then
        self:advance()
        return node("number_literal", { value = tok.value })
    end

    -- string literal
    if tok.type == "STRING" then
        self:advance()
        return node("string_literal", { value = tok.value })
    end

    -- boolean literals
    if tok.type == "TRUE" then
        self:advance()
        return node("bool_literal", { value = true })
    end
    if tok.type == "FALSE" then
        self:advance()
        return node("bool_literal", { value = false })
    end

    -- nil
    if tok.type == "NIL" then
        self:advance()
        return node("nil_literal", {})
    end

    -- mitosis expression (object creation)
    if tok.type == "MITOSIS" then
        self:advance()
        local class_name = self:expect("IDENTIFIER", "expected cell name after 'mitosis'")
        self:expect("LPAREN", "expected '(' after cell name in mitosis")
        self:expect("RPAREN", "expected ')' after mitosis arguments")
        return node("mitosis_expr", { cell_name = class_name.value })
    end

    -- parenthesized expression
    if tok.type == "LPAREN" then
        self:advance()
        local expr = self:parse_expression()
        self:expect("RPAREN", "expected closing ')'")
        return expr
    end

    -- identifier (variable access, possibly with dot access or function call)
    if tok.type == "IDENTIFIER" then
        local name = self:advance().value
        local expr = node("identifier", { name = name })

        -- handle chained dot access and function calls
        while true do
            if self:current().type == "DOT" then
                self:advance()
                local field = self:expect("IDENTIFIER", "expected field name after '.'")
                expr = node("dot_access", { object = expr, field = field.value })
            elseif self:current().type == "LPAREN" then
                self:advance()
                local args = {}
                if self:current().type ~= "RPAREN" then
                    args[#args + 1] = self:parse_expression()
                    while self:current().type == "COMMA" do
                        self:advance()
                        args[#args + 1] = self:parse_expression()
                    end
                end
                self:expect("RPAREN", "expected ')' after function arguments")
                expr = node("call_expr", { callee = expr, arguments = args })
            else
                break
            end
        end

        return expr
    end

    error(string.format("PARSE_TUMOR at line %d: unexpected token '%s' (%s)",
        tok.line or 0, tostring(tok.value), tok.type))
end

-- statement parsing

function State:parse_statement()
    self:skip_newlines()
    if self:at_end() then return nil end

    local tok = self:current()

    -- variable declaration: dna x = 42
    if tok.type == "DNA" or tok.type == "RNA" then
        return self:parse_var_declaration()
    end

    -- gene definition: gene foo(x, y):
    if tok.type == "GENE" then
        return self:parse_gene_definition()
    end

    -- cell definition: cell foo:
    if tok.type == "CELL" then
        return self:parse_cell_definition()
    end

    -- metastasis import: metastasis system.io
    if tok.type == "METASTASIS" then
        return self:parse_metastasis()
    end

    -- quarantine block: quarantine { ... }
    if tok.type == "QUARANTINE" then
        return self:parse_quarantine()
    end

    -- chemo statement: chemo var_name
    if tok.type == "CHEMO" then
        return self:parse_chemo()
    end

    -- apoptosis (return): apoptosis expr
    if tok.type == "APOPTOSIS" then
        return self:parse_apoptosis()
    end

    -- if statement
    if tok.type == "IF" then
        return self:parse_if()
    end

    -- while loop
    if tok.type == "WHILE" then
        return self:parse_while()
    end

    -- print statement
    if tok.type == "PRINT" then
        return self:parse_print()
    end

    -- assignment or expression statement
    if tok.type == "IDENTIFIER" then
        return self:parse_assignment_or_expr()
    end

    -- dedent tokens are handled by the block parser
    if tok.type == "DEDENT" then
        return nil
    end

    error(string.format("PARSE_TUMOR at line %d: unexpected statement starting with '%s' (%s)",
        tok.line or 0, tostring(tok.value), tok.type))
end

function State:parse_var_declaration()
    local var_type = self:advance().type == "DNA" and "dna" or "rna"
    local name_tok = self:expect("IDENTIFIER", "expected variable name")
    self:expect("ASSIGN", "expected '=' in variable declaration")
    local value = self:parse_expression()
    return node("var_declaration", {
        var_type = var_type,
        name = name_tok.value,
        value = value,
    })
end

function State:parse_gene_definition()
    self:advance() -- consume 'gene'
    local name = self:expect("IDENTIFIER", "expected gene name")
    self:expect("LPAREN", "expected '(' after gene name")
    
    local params = {}
    if self:current().type ~= "RPAREN" then
        params[#params + 1] = self:expect("IDENTIFIER", "expected parameter name").value
        while self:current().type == "COMMA" do
            self:advance()
            params[#params + 1] = self:expect("IDENTIFIER", "expected parameter name").value
        end
    end
    
    self:expect("RPAREN", "expected ')' after parameters")
    self:expect("COLON", "expected ':' after gene signature")
    local body = self:parse_block()
    
    return node("gene_definition", {
        name = name.value,
        params = params,
        body = body,
    })
end

function State:parse_cell_definition()
    self:advance() -- consume 'cell'
    local name = self:expect("IDENTIFIER", "expected cell name")
    self:expect("COLON", "expected ':' after cell name")
    local body = self:parse_block()
    
    return node("cell_definition", {
        name = name.value,
        body = body,
    })
end

function State:parse_metastasis()
    self:advance() -- consume 'metastasis'
    local parts = {}
    parts[#parts + 1] = self:expect("IDENTIFIER", "expected module name").value
    while self:current().type == "DOT" do
        self:advance()
        parts[#parts + 1] = self:expect("IDENTIFIER", "expected module path component").value
    end
    return node("metastasis", { module_path = table.concat(parts, ".") })
end

function State:parse_quarantine()
    local start_line = self:current().line
    self:advance() -- consume 'quarantine'
    self:expect("LBRACE", "expected '{' after 'quarantine'")
    self:skip_newlines()
    
    -- skip any indent tokens generated inside the brace block
    while self:current().type == "INDENT" do self:advance(); self:skip_newlines() end
    
    local statements = {}
    local line_start = self:current().line or start_line
    
    while self:current().type ~= "RBRACE" and not self:at_end() do
        -- skip stray indent or dedent tokens inside braces
        if self:current().type == "INDENT" or self:current().type == "DEDENT" then
            self:advance()
            self:skip_newlines()
        else
            local stmt = self:parse_statement()
            if stmt then
                statements[#statements + 1] = stmt
            end
            self:skip_newlines()
        end
    end
    
    local line_end = self:current().line or line_start
    self:expect("RBRACE", "expected '}' to close quarantine block")

    -- enforce quarantine 20% limit
    local q_lines = math.max(1, line_end - line_start + 1)
    self:check_quarantine_limit(q_lines)
    
    return node("quarantine_block", { body = statements })
end

function State:parse_chemo()
    self:advance() -- consume 'chemo'
    -- chemo target can be a dotted name like p1.heart_rate
    local target = self:expect("IDENTIFIER", "expected variable name after 'chemo'").value
    while self:current().type == "DOT" do
        self:advance()
        target = target .. "." .. self:expect("IDENTIFIER", "expected field name").value
    end
    return node("chemo_statement", { target = target })
end

function State:parse_apoptosis()
    self:advance() -- consume 'apoptosis'
    local value = nil
    -- apoptosis can optionally return a value
    if self:current().type ~= "NEWLINE" and self:current().type ~= "EOF" 
       and self:current().type ~= "DEDENT" then
        value = self:parse_expression()
    end
    return node("apoptosis_statement", { value = value })
end

function State:parse_if()
    self:advance() -- consume 'if'
    local condition = self:parse_expression()
    self:expect("COLON", "expected ':' after if condition")
    local body = self:parse_block()
    
    local elif_branches = {}
    local else_body = nil
    
    self:skip_newlines()
    
    while self:current().type == "ELIF" do
        self:advance()
        local elif_cond = self:parse_expression()
        self:expect("COLON", "expected ':' after elif condition")
        local elif_body = self:parse_block()
        elif_branches[#elif_branches + 1] = { condition = elif_cond, body = elif_body }
        self:skip_newlines()
    end
    
    if self:current().type == "ELSE" then
        self:advance()
        self:expect("COLON", "expected ':' after else")
        else_body = self:parse_block()
    end
    
    return node("if_statement", {
        condition = condition,
        body = body,
        elif_branches = elif_branches,
        else_body = else_body,
    })
end

function State:parse_while()
    self:advance() -- consume 'while'
    local condition = self:parse_expression()
    self:expect("COLON", "expected ':' after while condition")
    local body = self:parse_block()
    return node("while_statement", { condition = condition, body = body })
end

function State:parse_print()
    self:advance() -- consume 'print'
    self:expect("LPAREN", "expected '(' after print")
    local args = {}
    if self:current().type ~= "RPAREN" then
        args[#args + 1] = self:parse_expression()
        while self:current().type == "COMMA" do
            self:advance()
            args[#args + 1] = self:parse_expression()
        end
    end
    self:expect("RPAREN", "expected ')' after print arguments")
    return node("print_statement", { arguments = args })
end

function State:parse_assignment_or_expr()
    -- could be: x = expr, x.y = expr, or just a function call
    local expr = self:parse_expression()
    
    if self:current().type == "ASSIGN" then
        self:advance()
        local value = self:parse_expression()
        return node("assignment", { target = expr, value = value })
    end
    
    -- bare expression statement (usually a function call)
    return node("expression_statement", { expression = expr })
end

-- parse an indented block of statements
function State:parse_block()
    local statements = {}
    self:skip_newlines()
    
    if self:current().type ~= "INDENT" then
        -- could be an empty block or single-line, just return empty
        return statements
    end
    
    self:advance() -- consume indent
    self:skip_newlines()
    
    while self:current().type ~= "DEDENT" and not self:at_end() do
        local stmt = self:parse_statement()
        if stmt then
            statements[#statements + 1] = stmt
        end
        self:skip_newlines()
    end
    
    if self:current().type == "DEDENT" then
        self:advance()
    end
    
    return statements
end

-- main parse entry point

function parser.parse(tokens, source)
    TOKEN = require("src.lexer").TOKEN  -- grab token type constants
    
    local state = State.new(tokens, source)
    local program = { node_type = "program", body = {} }
    
    state:skip_newlines()
    
    while not state:at_end() do
        local stmt = state:parse_statement()
        if stmt then
            program.body[#program.body + 1] = stmt
        end
        state:skip_newlines()
    end
    
    return program, nil
end

return parser
