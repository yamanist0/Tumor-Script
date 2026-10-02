-- memory module for tumorscript
-- handles dna mutation, rna immutability, infection spread, and organ failure

local memory = {}
memory.__index = memory

-- config constants
memory.INITIAL_MUTATION_RATE = 0.005     -- 0.5% starting mutation
memory.MAX_MUTATION_RATE = 0.05          -- 5% max mutation
memory.MUTATION_ESCALATION = 0.003       -- how fast mutation rate climbs per read
memory.INFECTION_CHANCE = 0.30           -- 30% chance of infecting healthy vars
memory.CHEMO_KILL_CHANCE = 0.15          -- 15% chance chemo destroys the var
memory.MALIGNANT_THRESHOLD = 0.025       -- mutation rate above this = malignant
memory.ORGAN_FAILURE_RATIO = 0.50        -- 50% malignant vars = system crash
memory.QUARANTINE_CODE_LIMIT = 0.20      -- max 20% of code can be quarantined

-- dna variable structure
local function make_dna(value)
    return {
        type = "dna",
        value = value,
        original_value = value,
        mutation_rate = memory.INITIAL_MUTATION_RATE,
        read_count = 0,
        is_malignant = false,
    }
end

-- rna variable structure (immune to mutation)
local function make_rna(value)
    return {
        type = "rna",
        value = value,
        original_value = value,
        mutation_rate = 0,
        read_count = 0,
        is_malignant = false,
    }
end

function memory.new()
    local self = setmetatable({}, memory)
    self.scopes = { {} }  -- stack of scope tables
    self.total_vars = 0
    self.malignant_count = 0
    self.in_quarantine = false
    self.gene_infection = {}  -- tracks gene contamination levels
    return self
end

-- push a new scope (entering a block)
function memory:push_scope()
    self.scopes[#self.scopes + 1] = {}
end

-- pop the current scope
function memory:pop_scope()
    local scope = self.scopes[#self.scopes]
    if scope then
        -- clean up var counts
        for _, var in pairs(scope) do
            self.total_vars = self.total_vars - 1
            if var.is_malignant then
                self.malignant_count = self.malignant_count - 1
            end
        end
    end
    self.scopes[#self.scopes] = nil
end

-- declare a new variable in the current scope
function memory:declare(name, value, var_type)
    local scope = self.scopes[#self.scopes]
    if not scope then return nil, "no active scope" end

    local var
    if var_type == "rna" then
        var = make_rna(value)
    else
        var = make_dna(value)
    end

    scope[name] = var
    self.total_vars = self.total_vars + 1
    return var
end

-- find a variable by name, searching scopes from top to bottom
function memory:lookup(name)
    for i = #self.scopes, 1, -1 do
        if self.scopes[i][name] then
            return self.scopes[i][name], i
        end
    end
    return nil
end

-- read a variable's value (this triggers mutation for dna)
function memory:read(name)
    local var = self:lookup(name)
    if not var then
        return nil, "UNDEFINED_CELL: '" .. name .. "' does not exist"
    end

    -- rna is immune, always returns clean value
    if var.type == "rna" then
        return var.value
    end

    -- quarantine freezes all mutation
    if self.in_quarantine then
        return var.value
    end

    -- table objects like cells do not mutate directly
    if type(var.value) == "table" then
        return var.value
    end

    -- dna mutates on every read
    var.read_count = var.read_count + 1

    -- escalate mutation rate with each read
    var.mutation_rate = math.min(
        var.mutation_rate + memory.MUTATION_ESCALATION,
        memory.MAX_MUTATION_RATE
    )

    -- apply mutation based on value type
    local val = var.value
    if type(val) == "number" then
        -- numeric mutation adds or subtracts deviation
        local delta = var.mutation_rate * (math.random() * 2 - 1)
        val = val * (1 + delta)
        -- small chance of integer drift
        if math.random() < var.mutation_rate then
            val = val + (math.random() > 0.5 and 1 or -1)
        end
        var.value = val
    elseif type(val) == "string" then
        -- string mutation shifts random character
        if #val > 0 and math.random() < var.mutation_rate * 10 then
            local idx = math.random(1, #val)
            local byte = string.byte(val, idx)
            local shift = math.random(-2, 2)
            byte = math.max(32, math.min(126, byte + shift))
            val = val:sub(1, idx - 1) .. string.char(byte) .. val:sub(idx + 1)
            var.value = val
        end
    elseif type(val) == "boolean" then
        -- booleans can flip when mutation is high
        if math.random() < var.mutation_rate then
            val = not val
            var.value = val
        end
    end

    -- check if cancer passed fifty percent deviation
    local is_now_malignant = false
    if type(val) == "number" and type(var.original_value) == "number" and var.original_value ~= 0 then
        local deviation = math.abs(val - var.original_value) / math.abs(var.original_value)
        if deviation >= 0.50 then
            is_now_malignant = true
        end
    elseif var.mutation_rate >= memory.MAX_MUTATION_RATE and var.read_count >= 20 then
        is_now_malignant = true
    end

    if not var.is_malignant and is_now_malignant then
        var.is_malignant = true
        self.malignant_count = self.malignant_count + 1
    end

    -- check for organ failure
    self:check_organ_failure()

    return var.value
end

-- write a value to an existing variable
function memory:write(name, value)
    local var = self:lookup(name)
    if not var then
        return nil, "UNDEFINED_CELL: '" .. name .. "' does not exist"
    end

    if var.type == "rna" then
        return nil, "IMMUNE_VIOLATION: cannot reassign rna constant '" .. name .. "'"
    end

    var.value = value
    return value
end

-- apply chemo to a variable (reset it, 15% chance of destruction)
function memory:apply_chemo(name)
    local var, scope_idx = self:lookup(name)
    if not var then
        return false, "UNDEFINED_CELL: '" .. name .. "' does not exist"
    end

    -- 15% chance chemo kills the variable entirely
    if math.random() < memory.CHEMO_KILL_CHANCE then
        self.scopes[scope_idx][name] = nil
        self.total_vars = self.total_vars - 1
        if var.is_malignant then
            self.malignant_count = self.malignant_count - 1
        end
        return true, "CHEMO_LETHAL: variable '" .. name .. "' was destroyed by treatment"
    end

    -- reset the variable to its original state
    var.value = var.original_value
    var.mutation_rate = memory.INITIAL_MUTATION_RATE
    var.read_count = 0
    if var.is_malignant then
        var.is_malignant = false
        self.malignant_count = self.malignant_count - 1
    end

    return true, nil
end

-- attempt to infect a target variable from a malignant source
function memory:try_infect(target_name, source_var)
    if not source_var or source_var.type == "rna" then return end
    if not source_var.is_malignant and source_var.mutation_rate < memory.INITIAL_MUTATION_RATE * 2 then
        return
    end

    local target = self:lookup(target_name)
    if not target or target.type == "rna" then return end

    -- 30% chance of infection spreading
    if math.random() < memory.INFECTION_CHANCE then
        target.mutation_rate = math.min(
            target.mutation_rate + source_var.mutation_rate * 0.5,
            memory.MAX_MUTATION_RATE
        )
        if not target.is_malignant and target.mutation_rate >= memory.MALIGNANT_THRESHOLD then
            target.is_malignant = true
            self.malignant_count = self.malignant_count + 1
        end
    end
end

-- infect a gene's internal state when called with mutated args
function memory:infect_gene(gene_name, arg_mutation_rate)
    if not self.gene_infection[gene_name] then
        self.gene_infection[gene_name] = 0
    end
    self.gene_infection[gene_name] = math.min(
        self.gene_infection[gene_name] + arg_mutation_rate * 0.3,
        memory.MAX_MUTATION_RATE
    )
end

-- get a gene's current infection level
function memory:get_gene_infection(gene_name)
    return self.gene_infection[gene_name] or 0
end

-- check if system has too many malignant variables
function memory:check_organ_failure()
    if self.total_vars > 0 then
        local ratio = self.malignant_count / self.total_vars
        if ratio >= memory.ORGAN_FAILURE_RATIO and self.total_vars >= 3 then
            error("FATAL: ORGAN_FAILURE_EXCEPTION - " 
                .. self.malignant_count .. "/" .. self.total_vars 
                .. " variables are malignant (" 
                .. string.format("%.1f%%", ratio * 100) .. ")")
        end
    end
end

-- enter quarantine mode
function memory:enter_quarantine()
    self.in_quarantine = true
end

-- exit quarantine mode
function memory:exit_quarantine()
    self.in_quarantine = false
end

-- debug: dump current memory state
function memory:dump()
    print("=== MEMORY DUMP ===")
    print("total vars: " .. self.total_vars)
    print("malignant: " .. self.malignant_count)
    print("quarantine: " .. tostring(self.in_quarantine))
    for i = #self.scopes, 1, -1 do
        print("--- scope " .. i .. " ---")
        for name, var in pairs(self.scopes[i]) do
            print(string.format("  %s [%s] = %s (rate=%.4f, reads=%d, malignant=%s)",
                name, var.type, tostring(var.value),
                var.mutation_rate, var.read_count, tostring(var.is_malignant)))
        end
    end
    print("===================")
end

return memory
