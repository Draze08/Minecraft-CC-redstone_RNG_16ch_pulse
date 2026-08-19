-- Minecraft-CC-redstone_RNG_16ch_pulse
-- Commission 1-16 CC:Tweaked redstone relay peripherals and discover output sides.

local CONFIG = "rngpulse.cfg"
local MAX_CHANNELS = 16
local SIDES = { "top", "bottom", "left", "right", "front", "back" }

local function discoverRelays()
    local found = {}
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.getType(name) == "redstone_relay" then table.insert(found, name) end
    end
    table.sort(found)
    return found
end

local function allOff(relay)
    for _, side in ipairs(SIDES) do pcall(relay.setOutput, side, false) end
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

local function validSide(answer)
    answer = string.lower(answer or "")
    for _, side in ipairs(SIDES) do if answer == side then return side end end
    return nil
end

local function askOutputSide(relay, name, index, total)
    while true do
        term.clear(); term.setCursorPos(1, 1)
        print("RNG Redstone Pulse - Commissioning")
        print("==================================")
        print(string.format("Relay %d/%d: %s", index, total, name))
        print("")
        print("Watch the downstream lamp/device.")
        print("Each relay side will pulse for 1 second.")
        print("")
        allOff(relay); sleep(0.25)
        for _, side in ipairs(SIDES) do
            print("Testing " .. side .. "...")
            relay.setOutput(side, true); sleep(1.0)
            relay.setOutput(side, false); sleep(0.25)
        end
        print("")
        print("Which side activated the target?")
        print("top / bottom / left / right / front / back")
        print("R = repeat test   S = skip this relay")
        write("> ")
        local answer = string.lower(read())
        if answer == "r" or answer == "repeat" then
        elseif answer == "s" or answer == "skip" then allOff(relay); return nil
        else
            local side = validSide(answer)
            if side then allOff(relay); return side end
            print("Unknown side. Press any key to retry."); os.pullEvent("key")
        end
    end
end

term.clear(); term.setCursorPos(1, 1)
print("RNG Redstone Pulse - Commissioning")
print("==================================")
local relays = discoverRelays()
if #relays == 0 then error("No redstone relay peripherals found.", 0) end
local count = math.min(#relays, MAX_CHANNELS)
print("Found " .. #relays .. " redstone relay(s).")
if #relays > MAX_CHANNELS then print("Only the first " .. MAX_CHANNELS .. " will be commissioned.") end
print("")
print("Are ALL relay outputs connected on the same side? (y/n)")
write("> ")
local sameSide = string.lower(read())
local sharedSide = nil
if sameSide == "y" or sameSide == "yes" then
    while not sharedSide do
        print("Which side? top / bottom / left / right / front / back")
        write("> ")
        sharedSide = validSide(read())
        if not sharedSide then print("Unknown side.") end
    end
end

local channels = {}
if sharedSide then
    for i = 1, count do table.insert(channels, { name = relays[i], side = sharedSide }) end
else
    print("")
    print("Per-relay side discovery will now begin.")
    print("Press any key to begin.")
    os.pullEvent("key")
    for i = 1, count do
        local name = relays[i]
        local relay = peripheral.wrap(name)
        if relay then
            local side = askOutputSide(relay, name, i, count)
            if side then table.insert(channels, { name = name, side = side }) end
        end
    end
end

if #channels == 0 then error("No usable relay outputs were commissioned.", 0) end

term.clear(); term.setCursorPos(1, 1)
print("RNG Redstone Pulse - Timing")
print("============================")
print("Commissioned channels: " .. #channels)
print("")
local minTime = askNumber("Minimum time until next pulse [0.1s]: ", 0.1, 0.1)
local maxTime
while true do
    maxTime = askNumber("Maximum time until next pulse [2.0s]: ", 2.0, 0.1)
    if maxTime >= minTime then break end
    print("Maximum must be >= minimum (" .. minTime .. "s).")
end
local pulseLength = askNumber("Pulse ON length [0.1s]: ", 0.1, 0.05)

local cfg = { version = 3, channels = channels, minTime = minTime, maxTime = maxTime, pulseLength = pulseLength }
local h = fs.open(CONFIG, "w"); h.write(textutils.serialize(cfg)); h.close()

print("")
print("Commissioning complete.")
for i, channel in ipairs(channels) do print(string.format("%2d: %s -> %s", i, channel.name, channel.side)) end
print("")
print(string.format("Next-pulse delay: %.3fs to %.3fs", minTime, maxTime))
print(string.format("Pulse length: %.3fs", pulseLength))
print("Saved to " .. CONFIG)
