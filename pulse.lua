-- Minecraft-CC-redstone_RNG_16ch_pulse
-- Independent asynchronous RNG redstone controller for 1-16 relays.

local CONFIG = "rngpulse.cfg"

if not fs.exists(CONFIG) then
    error("No configuration found. Run commission.lua first.", 0)
end

local h = fs.open(CONFIG, "r")
local cfg = textutils.unserialize(h.readAll())
h.close()

if type(cfg) ~= "table" or type(cfg.relays) ~= "table" or #cfg.relays < 1 then
    error("Invalid configuration. Run commission.lua again.", 0)
end

local minTime = tonumber(cfg.minTime) or 0.1
local maxTime = tonumber(cfg.maxTime) or 2.0
if minTime < 0.1 then minTime = 0.1 end
if maxTime < minTime then maxTime = minTime end

math.randomseed(os.epoch("utc") + os.getComputerID())

local function randomTime()
    return minTime + math.random() * (maxTime - minTime)
end

local function relayWorker(name)
    local relay = peripheral.wrap(name)
    if not relay then
        print("Skipping unavailable relay: " .. name)
        return
    end

    -- Start each worker independently so startup does not form a pattern.
    local state = math.random(0, 1) == 1
    relay.setOutput("front", state)
    sleep(randomTime())

    while true do
        state = not state
        relay.setOutput("front", state)
        sleep(randomTime())
    end
end

local workers = {}
local activeNames = {}

for _, name in ipairs(cfg.relays) do
    if peripheral.isPresent(name) and peripheral.getType(name) == "redstone_relay" then
        table.insert(activeNames, name)
        table.insert(workers, function() relayWorker(name) end)
    else
        print("Configured relay unavailable, skipping: " .. name)
    end
end

if #workers == 0 then
    error("None of the commissioned redstone relays are currently available.", 0)
end

print("RNG pulse controller running.")
print("Active channels: " .. #workers .. "/" .. #cfg.relays)
print(string.format("State timing: %.3fs - %.3fs", minTime, maxTime))

local ok, err = pcall(function()
    parallel.waitForAll(table.unpack(workers))
end)

-- Best effort shutdown: leave every reachable commissioned output OFF.
for _, name in ipairs(activeNames) do
    local relay = peripheral.wrap(name)
    if relay then pcall(relay.setOutput, "front", false) end
end

if not ok then error(err, 0) end
