-- json module for tumorscript
-- handles transcription and expression between json and cellular structures

local json = {}

-- helper to make tumor arrays
local function make_tumor(elements)
    local original = {}
    local rates = {}
    local reads = {}
    for i, el in ipairs(elements) do
        original[i] = el
        rates[i] = 0.005
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

-- helper to make cell membranes
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

-- escapes string for json output
local function escape_string(str)
    local escapes = {
        ['"']  = '\\"',
        ['\\'] = '\\\\',
        ['\b'] = '\\b',
        ['\f'] = '\\f',
        ['\n'] = '\\n',
        ['\r'] = '\\r',
        ['\t'] = '\\t',
    }
    return '"' .. str:gsub('["\\%z\1-\31]', function(c)
        return escapes[c] or string.format('\\u%04x', string.byte(c))
    end) .. '"'
end

-- serializes value into json string
-- transcribe converts cellular data to json text
function json.transcribe(val, indent_opt, entropy_rate)
    local indent_str = nil
    if type(indent_opt) == "number" and indent_opt > 0 then
        indent_str = string.rep(" ", indent_opt)
    elseif type(indent_opt) == "string" then
        indent_str = indent_opt
    end

    local rate = tonumber(entropy_rate) or 0

    local function encode_internal(v, level)
        if v == nil then
            return "null"
        end

        local vtype = type(v)

        if vtype == "boolean" then
            if rate > 0 and math.random() < rate then
                return tostring(not v)
            end
            return tostring(v)
        end

        if vtype == "number" then
            if rate > 0 and math.random() < rate then
                v = v * (1 + (math.random() * 2 - 1) * rate)
            end
            if v ~= v or v == math.huge or v == -math.huge then
                return "null"
            end
            if math.floor(v) == v and math.abs(v) < 1e14 then
                return string.format("%d", math.floor(v))
            else
                return tostring(v)
            end
        end

        if vtype == "string" then
            if rate > 0 and #v > 0 and math.random() < rate * 5 then
                local idx = math.random(1, #v)
                local b = string.byte(v, idx)
                local shift = math.random(-2, 2)
                b = math.max(32, math.min(126, b + shift))
                v = v:sub(1, idx - 1) .. string.char(b) .. v:sub(idx + 1)
            end
            return escape_string(v)
        end

        if vtype == "table" then
            local is_pretty = (indent_str ~= nil)
            local pad = is_pretty and string.rep(indent_str, level) or ""
            local pad_inner = is_pretty and string.rep(indent_str, level + 1) or ""
            local nl = is_pretty and "\n" or ""
            local sp = is_pretty and " " or ""

            -- tumor array
            if v.__type == "tumor" then
                local parts = {}
                for _, el in ipairs(v.elements) do
                    parts[#parts + 1] = pad_inner .. encode_internal(el, level + 1)
                end
                if #parts == 0 then return "[]" end
                return "[" .. nl .. table.concat(parts, "," .. nl) .. nl .. pad .. "]"
            end

            -- cell membrane
            if v.__type == "membrane" then
                local parts = {}
                local keys = {}
                for k, _ in pairs(v.receptors) do keys[#keys + 1] = k end
                table.sort(keys)
                for _, k in ipairs(keys) do
                    local el = v.receptors[k]
                    local entry = pad_inner .. escape_string(tostring(k)) .. ":" .. sp .. encode_internal(el, level + 1)
                    parts[#parts + 1] = entry
                end
                if #parts == 0 then return "{}" end
                return "{" .. nl .. table.concat(parts, "," .. nl) .. nl .. pad .. "}"
            end

            -- cell instance
            if v.__cell_data then
                local parts = {}
                local keys = {}
                for k, _ in pairs(v.__cell_data) do keys[#keys + 1] = k end
                table.sort(keys)
                for _, k in ipairs(keys) do
                    local el = v.__cell_data[k].value
                    local entry = pad_inner .. escape_string(tostring(k)) .. ":" .. sp .. encode_internal(el, level + 1)
                    parts[#parts + 1] = entry
                end
                if #parts == 0 then return "{}" end
                return "{" .. nl .. table.concat(parts, "," .. nl) .. nl .. pad .. "}"
            end

            -- plain list
            if #v > 0 then
                local parts = {}
                for _, el in ipairs(v) do
                    parts[#parts + 1] = pad_inner .. encode_internal(el, level + 1)
                end
                if #parts == 0 then return "[]" end
                return "[" .. nl .. table.concat(parts, "," .. nl) .. nl .. pad .. "]"
            end

            -- plain map
            local parts = {}
            for k, el in pairs(v) do
                local entry = pad_inner .. escape_string(tostring(k)) .. ":" .. sp .. encode_internal(el, level + 1)
                parts[#parts + 1] = entry
            end
            if #parts == 0 then return "{}" end
            return "{" .. nl .. table.concat(parts, "," .. nl) .. nl .. pad .. "}"
        end

        return "null"
    end

    return encode_internal(val, 0)
end

-- parses json text into membranes and tumors
-- express synthesizes cellular structures from json string
function json.express(str)
    if type(str) ~= "string" then
        return nil, "JSON_SYNTAX_TUMOR: expected string input"
    end

    local pos = 1
    local len = #str

    local function skip_whitespace()
        while pos <= len do
            local c = str:sub(pos, pos)
            if c == " " or c == "\t" or c == "\n" or c == "\r" then
                pos = pos + 1
            else
                break
            end
        end
    end

    local function syntax_error(msg)
        local line = 1
        local col = 1
        for i = 1, pos - 1 do
            if str:sub(i, i) == "\n" then
                line = line + 1
                col = 1
            else
                col = col + 1
            end
        end
        return string.format("JSON_SYNTAX_TUMOR at line %d, col %d (pos %d): %s",
            line, col, pos, msg)
    end

    local parse_value

    local function parse_string()
        if str:sub(pos, pos) ~= '"' then
            error(syntax_error("expected '\"' to open string"))
        end
        pos = pos + 1
        local buf = {}
        while pos <= len do
            local c = str:sub(pos, pos)
            if c == '"' then
                pos = pos + 1
                return table.concat(buf)
            elseif c == '\\' then
                pos = pos + 1
                if pos > len then error(syntax_error("unexpected end of string escape")) end
                local esc = str:sub(pos, pos)
                pos = pos + 1
                if esc == '"' then buf[#buf + 1] = '"'
                elseif esc == '\\' then buf[#buf + 1] = '\\'
                elseif esc == '/' then buf[#buf + 1] = '/'
                elseif esc == 'b' then buf[#buf + 1] = '\b'
                elseif esc == 'f' then buf[#buf + 1] = '\f'
                elseif esc == 'n' then buf[#buf + 1] = '\n'
                elseif esc == 'r' then buf[#buf + 1] = '\r'
                elseif esc == 't' then buf[#buf + 1] = '\t'
                elseif esc == 'u' then
                    local hex = str:sub(pos, pos + 3)
                    if #hex < 4 or not hex:match("^%x%x%x%x$") then
                        error(syntax_error("invalid unicode escape"))
                    end
                    pos = pos + 4
                    local code = tonumber(hex, 16)
                    if code < 128 then
                        buf[#buf + 1] = string.char(code)
                    elseif code < 2048 then
                        buf[#buf + 1] = string.char(192 + math.floor(code / 64), 128 + (code % 64))
                    else
                        buf[#buf + 1] = string.char(224 + math.floor(code / 4096), 128 + (math.floor(code / 64) % 64), 128 + (code % 64))
                    end
                else
                    error(syntax_error("unknown escape sequence '\\" .. esc .. "'"))
                end
            else
                buf[#buf + 1] = c
                pos = pos + 1
            end
        end
        error(syntax_error("unterminated string literal"))
    end

    local function parse_number()
        local start = pos
        if str:sub(pos, pos) == '-' then pos = pos + 1 end
        while pos <= len and str:sub(pos, pos):match("[0-9]") do
            pos = pos + 1
        end
        if pos <= len and str:sub(pos, pos) == '.' then
            pos = pos + 1
            while pos <= len and str:sub(pos, pos):match("[0-9]") do
                pos = pos + 1
            end
        end
        if pos <= len and (str:sub(pos, pos) == 'e' or str:sub(pos, pos) == 'E') then
            pos = pos + 1
            if pos <= len and (str:sub(pos, pos) == '+' or str:sub(pos, pos) == '-') then
                pos = pos + 1
            end
            while pos <= len and str:sub(pos, pos):match("[0-9]") do
                pos = pos + 1
            end
        end
        local num_str = str:sub(start, pos - 1)
        local n = tonumber(num_str)
        if n == nil then
            error(syntax_error("invalid numeric format: " .. num_str))
        end
        return n
    end

    local function parse_array()
        pos = pos + 1
        skip_whitespace()
        local elements = {}
        if pos <= len and str:sub(pos, pos) == ']' then
            pos = pos + 1
            return make_tumor(elements)
        end

        while pos <= len do
            elements[#elements + 1] = parse_value()
            skip_whitespace()
            if pos <= len and str:sub(pos, pos) == ']' then
                pos = pos + 1
                return make_tumor(elements)
            elseif pos <= len and str:sub(pos, pos) == ',' then
                pos = pos + 1
                skip_whitespace()
            else
                error(syntax_error("expected ',' or ']' inside array"))
            end
        end
        error(syntax_error("unclosed array literal"))
    end

    local function parse_object()
        pos = pos + 1
        skip_whitespace()
        local pairs_list = {}
        if pos <= len and str:sub(pos, pos) == '}' then
            pos = pos + 1
            return make_membrane(pairs_list)
        end

        while pos <= len do
            skip_whitespace()
            if str:sub(pos, pos) ~= '"' then
                error(syntax_error("expected string key inside object"))
            end
            local key = parse_string()
            skip_whitespace()
            if pos > len or str:sub(pos, pos) ~= ':' then
                error(syntax_error("expected ':' after object key"))
            end
            pos = pos + 1
            skip_whitespace()
            local val = parse_value()
            pairs_list[#pairs_list + 1] = key
            pairs_list[#pairs_list + 1] = val

            skip_whitespace()
            if pos <= len and str:sub(pos, pos) == '}' then
                pos = pos + 1
                return make_membrane(pairs_list)
            elseif pos <= len and str:sub(pos, pos) == ',' then
                pos = pos + 1
                skip_whitespace()
            else
                error(syntax_error("expected ',' or '}' inside object"))
            end
        end
        error(syntax_error("unclosed object literal"))
    end

    function parse_value()
        skip_whitespace()
        if pos > len then
            error(syntax_error("unexpected end of input"))
        end
        local c = str:sub(pos, pos)

        if c == '{' then
            return parse_object()
        elseif c == '[' then
            return parse_array()
        elseif c == '"' then
            return parse_string()
        elseif c == '-' or c:match("[0-9]") then
            return parse_number()
        elseif str:sub(pos, pos + 3) == "true" then
            pos = pos + 4
            return true
        elseif str:sub(pos, pos + 4) == "false" then
            pos = pos + 5
            return false
        elseif str:sub(pos, pos + 3) == "null" then
            pos = pos + 4
            return nil
        else
            error(syntax_error("unexpected character '" .. c .. "'"))
        end
    end

    local ok, res = pcall(function()
        local val = parse_value()
        skip_whitespace()
        if pos <= len then
            error(syntax_error("trailing characters after json payload"))
        end
        return val
    end)

    if not ok then
        local err_msg = tostring(res):gsub("^.-:%d+:%s*", "")
        return nil, err_msg
    end

    return res, nil
end

-- analyzes json structure and returns diagnostic metrics
-- karyotype reports structural mass depth and strain breakdown
function json.karyotype(target)
    local val = target
    local is_text = false
    if type(target) == "string" then
        local parsed, err = json.express(target)
        if not parsed then
            return make_membrane({
                "valid", false,
                "error", tostring(err),
                "mass", 0,
                "depth", 0,
                "strain", "corrupted",
            })
        end
        val = parsed
        is_text = true
    end

    local total_mass = 0
    local receptor_count = 0
    local tumor_cells = 0

    local function inspect_depth(v, current_depth)
        if type(v) ~= "table" then
            total_mass = total_mass + 1
            return current_depth
        end

        local max_d = current_depth
        if v.__type == "membrane" then
            for k, child in pairs(v.receptors) do
                receptor_count = receptor_count + 1
                total_mass = total_mass + 1
                local d = inspect_depth(child, current_depth + 1)
                if d > max_d then max_d = d end
            end
        elseif v.__type == "tumor" then
            for _, child in ipairs(v.elements) do
                tumor_cells = tumor_cells + 1
                total_mass = total_mass + 1
                local d = inspect_depth(child, current_depth + 1)
                if d > max_d then max_d = d end
            end
        else
            for _, child in pairs(v) do
                total_mass = total_mass + 1
                local d = inspect_depth(child, current_depth + 1)
                if d > max_d then max_d = d end
            end
        end
        return max_d
    end

    local depth = inspect_depth(val, 1)
    local primary_strain = "primitive"
    if type(val) == "table" and val.__type then
        primary_strain = val.__type
    end

    return make_membrane({
        "valid", true,
        "strain", primary_strain,
        "mass", total_mass,
        "depth", depth,
        "receptors", receptor_count,
        "tumor_cells", tumor_cells,
        "is_source_text", is_text,
    })
end

-- merges json data directly into target membrane or tumor
-- transduce integrates external genetic data
function json.transduce(target, source)
    local payload = source
    if type(source) == "string" then
        local p, err = json.express(source)
        if not p then return nil, err end
        payload = p
    end

    if type(target) == "table" and target.__type == "membrane" then
        if type(payload) == "table" and payload.__type == "membrane" then
            for k, v in pairs(payload.receptors) do
                target.receptors[k] = v
            end
            return target
        end
        return nil, "TRANSDUCE_FAILURE: cannot transduce non-membrane into membrane"
    elseif type(target) == "table" and target.__type == "tumor" then
        if type(payload) == "table" and payload.__type == "tumor" then
            for _, el in ipairs(payload.elements) do
                target.elements[#target.elements + 1] = el
                target.original_elements[#target.original_elements + 1] = el
                target.rates[#target.rates + 1] = 0.005
                target.reads[#target.reads + 1] = 0
            end
            return target
        else
            target.elements[#target.elements + 1] = payload
            target.original_elements[#target.original_elements + 1] = payload
            target.rates[#target.rates + 1] = 0.005
            target.reads[#target.reads + 1] = 0
            return target
        end
    end

    return nil, "TRANSDUCE_FAILURE: target must be a membrane or tumor"
end

-- writes serialized json data to a file
function json.secrete_json(arg1, arg2, indent, entropy)
    local path, val
    if type(arg1) == "string" and (type(arg2) == "table" or type(arg2) == "number" or type(arg2) == "boolean" or type(arg2) == "string" or arg2 == nil) then
        path = arg1
        val = arg2
    else
        val = arg1
        path = tostring(arg2 or "")
    end

    local text, err = json.transcribe(val, indent, entropy)
    if not text then return false, err end

    local f, io_err = io.open(path, "w")
    if not f then
        return false, "IO_TUMOR: failed to open file for secretion: " .. tostring(io_err)
    end
    f:write(text)
    f:close()
    return true, nil
end

-- reads and expresses a json file from disk
function json.ingest_json(path)
    local f, io_err = io.open(tostring(path or ""), "r")
    if not f then
        return nil, "IO_TUMOR: failed to open file for ingestion: " .. tostring(io_err)
    end
    local content = f:read("*a")
    f:close()
    return json.express(content)
end

-- standard library aliases
json.transcribe_file = json.secrete_json
json.express_file = json.ingest_json
json.dumps = json.transcribe
json.loads = json.express
json.dump = json.secrete_json
json.load = json.ingest_json
json.encode = json.transcribe
json.decode = json.express

return json
