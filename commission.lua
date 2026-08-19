-- Minecraft-CC-redstone_RNG_16ch_pulse
-- Commission 1-16 CC:Tweaked redstone relay peripherals.

local CONFIG = "rngpulse.cfg"
local MAX_CHANNELS = 16

local function discoverRelays()
    local found = {}
    for _, name in ipairs(peripheral.getNames()) do
        local pType = peripheral.getType(name)
        if pType == "redstone_relay" then
            table.insert(found, name)
        end
    end
    table.sort(found)
    return found
end

local function askNumber(prompt, default, minimum)
    while true do
        write(prompt)
        local raw = read()
        if raw == "" and default ~= nil then return default end
        local value = tonumber(raw)
        if value and value >= minimum then return value end
        print("Enter a number >= " .. minimum)
    end
end

term.clear()
term.setCursorPos(1, 1)
print("RNG Redstone Pulse - Commissioning")
print("==================================")

local relays = discoverRelays()
if #relays == 0 then
    error("No redstone relay peripherals found.", 0)
end

local count = math.min(#relays, MAX_CHANNELS)
print("Found " .. #relays .. " redstone relay(s).")
if #relays > MAX_CHANNELS then
    print("Using first " .. MAX_CHANNELS .. " relays (controller limit).")
end
print("")

local selected = {}
for i = 1, count do
    selected[i] = relays[i]
    print(string.format("%2d: %s", i, relays[i]))
end

print("")
local minTime = askNumber("Minimum random state time [0.1s]: ", 0.1, 0.1)
local maxTime
while true do
    maxTime = askNumber("Maximum random state time [2.0s]: ", 2.0, 0.1)
    if maxTime >= minTime then break end
    print("Maximum must be >= minimum (" .. minTime .. "s).")
end

local cfg = {
    version = 1,
    relays = selected,
    minTime = minTime,
    maxTime = maxTime,
}

local h = fs.open(CONFIG, "w")
h.write(textutils.serialize(cfg))
h.close()

print("")
print("Commissioning complete.")
print("Configured " .. #selected .. " independent channel(s).")
print(string.format("Random state timing: %.3fs to %.3fs", minTime, maxTime))
print("Saved to " .. CONFIG)
