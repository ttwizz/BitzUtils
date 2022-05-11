local Args = {"A", "B", "GP", "EN"}

local function ScanTable(Table)
    for i, v in ipairs(Args) do
        if (not rawget(Table, v)) then
            return false
        end
    end
    return true
end

local Functions do
    for i,v in pairs(getgc(true)) do
        if typeof(v) == "table" and ScanTable(v) then
            Functions = v
            break
        end
    end
end

if Functions and (Functions.A and Functions.B) then
    hookfunction(Functions.A, function() end)
    hookfunction(Functions.B, function() end)
    return true
else
    error("anticheat functions not found!")
end
return false
