-- binary capsid packaging module
-- translates between numbers strings and raw binary packets

local capsid = {}

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

local type_sizes = {
    x = 1, c = 1, b = 1, B = 1, ["?"] = 1,
    h = 2, H = 2,
    i = 4, I = 4, l = 4, L = 4,
    q = 8, Q = 8,
    f = 4, d = 8,
    s = 1, p = 1,
}

local type_lua_fmt = {
    b = "b", B = "B",
    h = "i2", H = "I2",
    i = "i4", I = "I4",
    l = "i4", L = "I4",
    q = "i8", Q = "I8",
    f = "f", d = "d",
}

-- parses binary format string
local function parse_format(fmt)
    if type(fmt) ~= "string" or #fmt == 0 then
        error("CAPSID_FAILURE: format string must be non-empty string")
    end

    local endian = "="
    local idx = 1
    local first = fmt:sub(1, 1)
    if first == "<" or first == ">" or first == "!" or first == "=" or first == "@" then
        if first == "!" then
            endian = ">"
        else
            endian = first
        end
        idx = 2
    end

    local fields = {}
    local total_size = 0
    local len = #fmt

    while idx <= len do
        local c = fmt:sub(idx, idx)
        if c:match("%s") then
            idx = idx + 1
        elseif c:match("%d") then
            local num_str = ""
            while idx <= len and fmt:sub(idx, idx):match("%d") do
                num_str = num_str .. fmt:sub(idx, idx)
                idx = idx + 1
            end
            local count = tonumber(num_str) or 1
            if idx > len then
                error("CAPSID_FAILURE: trailing count without type code in format string")
            end
            local type_code = fmt:sub(idx, idx)
            idx = idx + 1
            if not type_sizes[type_code] then
                error("CAPSID_FAILURE: unknown type code '" .. type_code .. "' in format string")
            end
            fields[#fields + 1] = { type = type_code, count = count }
            total_size = total_size + (type_sizes[type_code] * count)
        else
            if not type_sizes[c] then
                error("CAPSID_FAILURE: unknown type code '" .. c .. "' in format string")
            end
            fields[#fields + 1] = { type = c, count = 1 }
            total_size = total_size + type_sizes[c]
            idx = idx + 1
        end
    end

    return endian, fields, total_size
end

-- calculates total byte size of format
function capsid.strand_length(fmt)
    local _, _, total_size = parse_format(fmt)
    return total_size
end
capsid.molecular_weight = capsid.strand_length
capsid.calcsize = capsid.strand_length

-- packs values into raw binary buffer
function capsid.condense(fmt, ...)
    local endian, fields, total_size = parse_format(fmt)
    local raw_args = { ... }
    local args = {}
    
    if #raw_args == 1 and type(raw_args[1]) == "table" and raw_args[1].__type == "tumor" then
        for _, v in ipairs(raw_args[1].elements) do
            args[#args + 1] = v
        end
    elseif #raw_args == 1 and type(raw_args[1]) == "table" and raw_args[1].receptors == nil then
        for _, v in ipairs(raw_args[1]) do
            args[#args + 1] = v
        end
    else
        args = raw_args
    end

    local arg_idx = 1
    local chunks = {}

    for _, f in ipairs(fields) do
        local t = f.type
        local count = f.count

        if t == "x" then
            chunks[#chunks + 1] = string.rep("\0", count)
        elseif t == "s" then
            local val = tostring(args[arg_idx] or "")
            arg_idx = arg_idx + 1
            if #val < count then
                chunks[#chunks + 1] = val .. string.rep("\0", count - #val)
            else
                chunks[#chunks + 1] = val:sub(1, count)
            end
        elseif t == "p" then
            local val = tostring(args[arg_idx] or "")
            arg_idx = arg_idx + 1
            local max_len = math.max(0, count - 1)
            local actual_len = math.min(#val, max_len)
            local sub = val:sub(1, actual_len)
            local pad = count - 1 - actual_len
            chunks[#chunks + 1] = string.char(actual_len) .. sub .. (pad > 0 and string.rep("\0", pad) or "")
        elseif t == "?" then
            for i = 1, count do
                local val = args[arg_idx]
                arg_idx = arg_idx + 1
                local bool_byte = (val ~= nil and val ~= false and val ~= 0) and 1 or 0
                chunks[#chunks + 1] = string.pack(endian .. "B", bool_byte)
            end
        elseif t == "c" then
            for i = 1, count do
                local val = tostring(args[arg_idx] or "")
                arg_idx = arg_idx + 1
                local ch = #val > 0 and val:sub(1, 1) or "\0"
                chunks[#chunks + 1] = ch
            end
        else
            local lua_fmt = type_lua_fmt[t]
            if not lua_fmt then
                error("CAPSID_FAILURE: unsupported type code '" .. t .. "'")
            end
            for i = 1, count do
                local val = tonumber(args[arg_idx]) or 0
                arg_idx = arg_idx + 1
                chunks[#chunks + 1] = string.pack(endian .. lua_fmt, val)
            end
        end
    end

    return table.concat(chunks, "")
end
capsid.pack = capsid.condense
capsid.capsulate = capsid.condense

-- unpacks binary buffer into tumor array
function capsid.decondense(fmt, buffer, start_offset)
    local endian, fields, total_size = parse_format(fmt)
    if type(buffer) ~= "string" then
        error("CAPSID_FAILURE: buffer must be a string or byte array")
    end

    local offset = start_offset or 1
    if (#buffer - offset + 1) < total_size then
        error(string.format("CAPSID_FAILURE: buffer size (%d bytes from offset %d) smaller than required %d bytes",
            #buffer, offset, total_size))
    end

    local results = {}

    for _, f in ipairs(fields) do
        local t = f.type
        local count = f.count

        if t == "x" then
            offset = offset + count
        elseif t == "s" then
            local val = buffer:sub(offset, offset + count - 1)
            offset = offset + count
            results[#results + 1] = val
        elseif t == "p" then
            local actual_len = string.byte(buffer, offset) or 0
            local max_len = math.max(0, count - 1)
            local take = math.min(actual_len, max_len)
            local val = buffer:sub(offset + 1, offset + take)
            offset = offset + count
            results[#results + 1] = val
        elseif t == "?" then
            for i = 1, count do
                local byte = string.byte(buffer, offset) or 0
                offset = offset + 1
                results[#results + 1] = (byte ~= 0)
            end
        elseif t == "c" then
            for i = 1, count do
                local ch = buffer:sub(offset, offset)
                offset = offset + 1
                results[#results + 1] = ch
            end
        else
            local lua_fmt = type_lua_fmt[t]
            if not lua_fmt then
                error("CAPSID_FAILURE: unsupported type code '" .. t .. "'")
            end
            for i = 1, count do
                local val, next_pos = string.unpack(endian .. lua_fmt, buffer, offset)
                offset = next_pos
                results[#results + 1] = val
            end
        end
    end

    return make_tumor(results), offset
end
capsid.unpack = capsid.decondense
capsid.decapsulate = capsid.decondense

-- splices binary data into buffer at offset
function capsid.splice_into(fmt, buffer, offset, ...)
    local raw_off = math.floor(tonumber(offset) or 0)
    local lua_off = raw_off + 1
    if lua_off < 1 then
        error("CAPSID_FAILURE: offset out of bounds")
    end
    local packed = capsid.condense(fmt, ...)
    local buf_str = tostring(buffer or "")
    local prefix = buf_str:sub(1, lua_off - 1)
    if #prefix < (lua_off - 1) then
        prefix = prefix .. string.rep("\0", (lua_off - 1) - #prefix)
    end
    local suffix = buf_str:sub(lua_off + #packed)
    return prefix .. packed .. suffix
end
capsid.pack_into = capsid.splice_into

-- unpacks data from buffer starting at offset
function capsid.biopsy_from(fmt, buffer, offset)
    local raw_off = math.floor(tonumber(offset) or 0)
    local lua_off = raw_off + 1
    local res, next_off = capsid.decondense(fmt, buffer, lua_off)
    return res, next_off - 1
end
capsid.unpack_from = capsid.biopsy_from

-- iteratively unpacks repeating records
function capsid.cleave(fmt, buffer)
    local size = capsid.strand_length(fmt)
    if size <= 0 then
        error("CAPSID_FAILURE: cannot cleave with zero sized format")
    end
    local buf_str = tostring(buffer or "")
    local total_len = #buf_str
    if total_len % size ~= 0 then
        error(string.format("CAPSID_FAILURE: buffer size %d is not a multiple of slice size %d", total_len, size))
    end
    local records = {}
    local curr = 1
    while curr <= total_len do
        local rec, next_curr = capsid.decondense(fmt, buf_str, curr)
        records[#records + 1] = rec
        curr = next_curr
    end
    return make_tumor(records)
end
capsid.iter_unpack = capsid.cleave

-- formats binary data as hex dump
function capsid.hex_biopsy(buffer, bytes_per_row)
    local buf_str = tostring(buffer or "")
    local row_size = tonumber(bytes_per_row) or 16
    local rows = {}
    local len = #buf_str
    for i = 1, len, row_size do
        local hex_part = {}
        local ascii_part = {}
        for j = i, i + row_size - 1 do
            if j <= len then
                local b = string.byte(buf_str, j)
                hex_part[#hex_part + 1] = string.format("%02x", b)
                if b >= 32 and b <= 126 then
                    ascii_part[#ascii_part + 1] = string.char(b)
                else
                    ascii_part[#ascii_part + 1] = "."
                end
            else
                hex_part[#hex_part + 1] = "  "
            end
        end
        local addr = string.format("%08x: %s  %s", i - 1, table.concat(hex_part, " "), table.concat(ascii_part, ""))
        rows[#rows + 1] = addr
    end
    return table.concat(rows, "\n")
end

-- mutates binary buffer with random bit flips
function capsid.radiation_drift(buffer, rate)
    local buf_str = tostring(buffer or "")
    local drift_rate = tonumber(rate) or 0.05
    local bytes = {}
    for i = 1, #buf_str do
        local b = string.byte(buf_str, i)
        if math.random() < drift_rate then
            local bit = 1 << math.random(0, 7)
            b = b ~ bit
        end
        bytes[#bytes + 1] = string.char(b)
    end
    return table.concat(bytes, "")
end

-- analyzes binary buffer properties
function capsid.karyotype_binary(buffer)
    local buf_str = tostring(buffer or "")
    local len = #buf_str
    if len == 0 then
        return make_membrane({
            "size", 0,
            "entropy", 0.0,
            "null_ratio", 0.0,
            "ascii_ratio", 0.0,
            "strain", "sterile_capsid",
        })
    end
    local counts = {}
    local null_count = 0
    local ascii_count = 0
    for i = 1, len do
        local b = string.byte(buf_str, i)
        counts[b] = (counts[b] or 0) + 1
        if b == 0 then null_count = null_count + 1 end
        if b >= 32 and b <= 126 then ascii_count = ascii_count + 1 end
    end
    local entropy = 0
    for _, cnt in pairs(counts) do
        local p = cnt / len
        entropy = entropy - (p * (math.log(p) / math.log(2)))
    end
    return make_membrane({
        "size", len,
        "entropy", math.floor(entropy * 1000 + 0.5) / 1000,
        "null_ratio", math.floor((null_count / len) * 1000 + 0.5) / 1000,
        "ascii_ratio", math.floor((ascii_count / len) * 1000 + 0.5) / 1000,
        "strain", (entropy > 6.5 and "dense_capsid" or "cellular_capsid"),
    })
end

return capsid
