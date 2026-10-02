-- lexer module for tumorscript
-- tokenizes source code into a flat token stream
-- handles indentation-based blocks (python style) and quarantine {} blocks

local lexer = {}

-- token types
lexer.TOKEN = {
    -- keywords
    DNA         = "DNA",
    RNA         = "RNA",
    CELL        = "CELL",
    GENE        = "GENE",
    MITOSIS     = "MITOSIS",
    APOPTOSIS   = "APOPTOSIS",
    METASTASIS  = "METASTASIS",
    CHEMO       = "CHEMO",
    QUARANTINE  = "QUARANTINE",
    IF          = "IF",
    ELIF        = "ELIF",
    ELSE        = "ELSE",
    WHILE       = "WHILE",
    FOR         = "FOR",
    IN          = "IN",
    AND         = "AND",
    OR          = "OR",
    NOT         = "NOT",
    PRINT       = "PRINT",
    TRUE        = "TRUE",
    FALSE       = "FALSE",
    NIL         = "NIL",

    -- literals
    NUMBER      = "NUMBER",
    STRING      = "STRING",
    IDENTIFIER  = "IDENTIFIER",

    -- symbols
    PLUS        = "PLUS",
    MINUS       = "MINUS",
    STAR        = "STAR",
    SLASH       = "SLASH",
    PERCENT     = "PERCENT",
    ASSIGN      = "ASSIGN",
    EQ          = "EQ",
    NEQ         = "NEQ",
    LT          = "LT",
    GT          = "GT",
    LTE         = "LTE",
    GTE         = "GTE",
    LPAREN      = "LPAREN",
    RPAREN      = "RPAREN",
    LBRACE      = "LBRACE",    -- only valid after quarantine
    RBRACE      = "RBRACE",    -- only valid to close quarantine
    COMMA       = "COMMA",
    COLON       = "COLON",
    DOT         = "DOT",

    -- structure
    INDENT      = "INDENT",
    DEDENT      = "DEDENT",
    NEWLINE     = "NEWLINE",
    EOF         = "EOF",
}

local KEYWORDS = {
    dna         = lexer.TOKEN.DNA,
    rna         = lexer.TOKEN.RNA,
    cell        = lexer.TOKEN.CELL,
    gene        = lexer.TOKEN.GENE,
    mitosis     = lexer.TOKEN.MITOSIS,
    apoptosis   = lexer.TOKEN.APOPTOSIS,
    metastasis  = lexer.TOKEN.METASTASIS,
    chemo       = lexer.TOKEN.CHEMO,
    quarantine  = lexer.TOKEN.QUARANTINE,
    ["if"]      = lexer.TOKEN.IF,
    elif        = lexer.TOKEN.ELIF,
    ["else"]    = lexer.TOKEN.ELSE,
    ["while"]   = lexer.TOKEN.WHILE,
    ["for"]     = lexer.TOKEN.FOR,
    ["in"]      = lexer.TOKEN.IN,
    ["and"]     = lexer.TOKEN.AND,
    ["or"]      = lexer.TOKEN.OR,
    ["not"]     = lexer.TOKEN.NOT,
    print       = lexer.TOKEN.PRINT,
    ["true"]    = lexer.TOKEN.TRUE,
    ["false"]   = lexer.TOKEN.FALSE,
    ["nil"]     = lexer.TOKEN.NIL,
}

local function make_token(type, value, line, col)
    return { type = type, value = value, line = line, col = col }
end

-- tokenize the source string into a list of tokens
function lexer.tokenize(source, filename)
    local tokens = {}
    local pos = 1
    local line = 1
    local col = 1
    local len = #source
    local indent_stack = { 0 }  -- track indentation levels
    local at_line_start = true
    local brace_depth = 0       -- track quarantine brace nesting
    local last_keyword = nil    -- track if last keyword was quarantine

    local function peek(offset)
        offset = offset or 0
        local p = pos + offset
        if p <= len then return source:sub(p, p) end
        return nil
    end

    local function advance()
        local ch = source:sub(pos, pos)
        pos = pos + 1
        if ch == "\n" then
            line = line + 1
            col = 1
        else
            col = col + 1
        end
        return ch
    end

    local function skip_comment()
        while pos <= len and source:sub(pos, pos) ~= "\n" do
            advance()
        end
    end

    local function read_string(quote)
        local start_line = line
        local buf = {}
        advance() -- skip opening quote
        while pos <= len do
            local ch = source:sub(pos, pos)
            if ch == "\\" then
                advance()
                local esc = advance()
                if esc == "n" then buf[#buf + 1] = "\n"
                elseif esc == "t" then buf[#buf + 1] = "\t"
                elseif esc == "\\" then buf[#buf + 1] = "\\"
                elseif esc == quote then buf[#buf + 1] = quote
                else buf[#buf + 1] = "\\" .. (esc or "") end
            elseif ch == quote then
                advance()
                return table.concat(buf)
            elseif ch == "\n" then
                return nil, "unterminated string at line " .. start_line
            else
                buf[#buf + 1] = advance()
            end
        end
        return nil, "unterminated string at line " .. start_line
    end

    local function read_number()
        local start = pos
        local has_dot = false
        while pos <= len do
            local ch = source:sub(pos, pos)
            if ch == "." and not has_dot then
                has_dot = true
                advance()
            elseif ch:match("[0-9]") then
                advance()
            else
                break
            end
        end
        return tonumber(source:sub(start, pos - 1))
    end

    local function read_identifier()
        local start = pos
        while pos <= len do
            local ch = source:sub(pos, pos)
            if ch:match("[a-zA-Z0-9_]") then
                advance()
            else
                break
            end
        end
        return source:sub(start, pos - 1)
    end

    local function emit(type, value)
        tokens[#tokens + 1] = make_token(type, value, line, col)
        -- track last keyword for brace validation
        if type == lexer.TOKEN.QUARANTINE then
            last_keyword = "quarantine"
        elseif type ~= lexer.TOKEN.NEWLINE and type ~= lexer.TOKEN.INDENT 
               and type ~= lexer.TOKEN.DEDENT then
            last_keyword = nil
        end
    end

    -- handle indentation at the start of a logical line
    local function handle_indentation()
        local spaces = 0
        while pos <= len and source:sub(pos, pos) == " " do
            advance()
            spaces = spaces + 1
        end
        -- tabs count as 4 spaces
        while pos <= len and source:sub(pos, pos) == "\t" do
            advance()
            spaces = spaces + 4
        end

        -- skip blank lines and comment-only lines
        if pos > len or source:sub(pos, pos) == "\n" then
            return
        end
        if source:sub(pos, pos) == "#" then
            return
        end

        local current_indent = indent_stack[#indent_stack]

        if spaces > current_indent then
            indent_stack[#indent_stack + 1] = spaces
            emit(lexer.TOKEN.INDENT, spaces)
        elseif spaces < current_indent then
            while #indent_stack > 1 and indent_stack[#indent_stack] > spaces do
                indent_stack[#indent_stack] = nil
                emit(lexer.TOKEN.DEDENT, spaces)
            end
            if indent_stack[#indent_stack] ~= spaces then
                return nil, "inconsistent indentation at line " .. line
            end
        end
    end

    -- main tokenization loop
    while pos <= len do
        -- handle line starts for indentation
        if at_line_start then
            at_line_start = false
            local err = handle_indentation()
            if err then return nil, err end
        end

        if pos > len then break end

        local ch = source:sub(pos, pos)

        -- skip whitespace (not newlines, those are significant)
        if ch == " " or ch == "\t" then
            advance()

        -- newlines
        elseif ch == "\n" then
            emit(lexer.TOKEN.NEWLINE, "\\n")
            advance()
            at_line_start = true

        -- carriage return (windows line endings)
        elseif ch == "\r" then
            advance()

        -- comments
        elseif ch == "#" then
            skip_comment()

        -- strings
        elseif ch == '"' or ch == "'" then
            local str, err = read_string(ch)
            if err then return nil, err end
            emit(lexer.TOKEN.STRING, str)

        -- numbers
        elseif ch:match("[0-9]") then
            local num = read_number()
            emit(lexer.TOKEN.NUMBER, num)

        -- identifiers and keywords
        elseif ch:match("[a-zA-Z_]") then
            local ident = read_identifier()
            local kw = KEYWORDS[ident]
            if kw then
                emit(kw, ident)
            else
                emit(lexer.TOKEN.IDENTIFIER, ident)
            end

        -- two-char operators
        elseif ch == "=" and peek(1) == "=" then
            advance(); advance()
            emit(lexer.TOKEN.EQ, "==")
        elseif ch == "!" and peek(1) == "=" then
            advance(); advance()
            emit(lexer.TOKEN.NEQ, "!=")
        elseif ch == "<" and peek(1) == "=" then
            advance(); advance()
            emit(lexer.TOKEN.LTE, "<=")
        elseif ch == ">" and peek(1) == "=" then
            advance(); advance()
            emit(lexer.TOKEN.GTE, ">=")

        -- standalone comparison operators (must come after two-char checks)
        elseif ch == "<" then advance(); emit(lexer.TOKEN.LT, "<")
        elseif ch == ">" then advance(); emit(lexer.TOKEN.GT, ">")

        -- single-char operators and symbols
        elseif ch == "=" then advance(); emit(lexer.TOKEN.ASSIGN, "=")
        elseif ch == "+" then advance(); emit(lexer.TOKEN.PLUS, "+")
        elseif ch == "-" then advance(); emit(lexer.TOKEN.MINUS, "-")
        elseif ch == "*" then advance(); emit(lexer.TOKEN.STAR, "*")
        elseif ch == "/" then advance(); emit(lexer.TOKEN.SLASH, "/")
        elseif ch == "%" then advance(); emit(lexer.TOKEN.PERCENT, "%")
        elseif ch == "(" then advance(); emit(lexer.TOKEN.LPAREN, "(")
        elseif ch == ")" then advance(); emit(lexer.TOKEN.RPAREN, ")")
        elseif ch == "," then advance(); emit(lexer.TOKEN.COMMA, ",")
        elseif ch == ":" then advance(); emit(lexer.TOKEN.COLON, ":")
        elseif ch == "." then advance(); emit(lexer.TOKEN.DOT, ".")

        -- braces - only valid in quarantine context
        elseif ch == "{" then
            if last_keyword ~= "quarantine" and brace_depth == 0 then
                return nil, "SYNTAX_TUMOR: '{' is only allowed after 'quarantine' at line " .. line
            end
            brace_depth = brace_depth + 1
            advance()
            emit(lexer.TOKEN.LBRACE, "{")

        elseif ch == "}" then
            if brace_depth == 0 then
                return nil, "SYNTAX_TUMOR: unexpected '}' at line " .. line
            end
            brace_depth = brace_depth - 1
            advance()
            emit(lexer.TOKEN.RBRACE, "}")

        else
            return nil, "unexpected character '" .. ch .. "' at line " .. line
        end
    end

    -- emit remaining dedents
    while #indent_stack > 1 do
        indent_stack[#indent_stack] = nil
        emit(lexer.TOKEN.DEDENT, 0)
    end

    emit(lexer.TOKEN.EOF, nil)
    return tokens, nil
end

return lexer
