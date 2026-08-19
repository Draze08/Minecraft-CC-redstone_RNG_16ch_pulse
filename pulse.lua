-- Minecraft-CC-redstone_RNG_16ch_pulse
-- Independent asynchronous RNG redstone controller for 1-16 commissioned relay outputs.

local CONFIG = "rngpulse.cfg"

if not fs.exists(CONFIG) then
    error("No configuration found. Run commission.lua first.", 0)
end

local h = fs.open(CONFIG, "r")
local cfg = textutils.unserialize(h.readAll())
h.close()

if type(cfg) ~= "table" or type(cfg.channels) ~= "table" or #cfg.channels < 1 then
    error("Invalid or old configuration. Run commission.lua again.", 0)
end

local minTime = tonumber(cfg.minTime) or 0.1
local maxTime = tonumber(cfg.maxTime) or 2.0
if minTime < 0.1 then minTime = 0.1 end
if maxTime < minTime then maxTime = minTime end

math.randomseed(os.epoch("utc") + os.getComputerID())

local function randomTime()
    return minTime + math.random() * (maxTime - minTime)
end

local function channelWorker(channel)
    local relay = peripheral.wrap(channel.name)
    if not relay then
        print("Skipping unavailable relay: " .. channel.name)
        return
    end

    local side = channel.side
    local state = math.random(0, 1) == 1

    relay.setOutput(side, state)
    sleep(randomTime())

    while true do
        state = not state
        relay.setOutput(side, state)
        sleep(randomTime())
    end
end

local workers = {}
local activeChannels = {}

for _, channel in ipairs(cfg.channels) do
    if type(channel) == "table"
        and type(channel.name) == "string"
        and type(channel.side) == "string"
        and peripheral.isPresent(channel.name)
        and peripheral.getType(channel.name) == "redstone_relay" then

        table.insert(activeChannels, channel)
        table.insert(workers, function() channelWorker(channel) end)
    else
        local name = type(channel) == "table" and channel.name or "unknown"
        print("Configured relay unavailable, skipping: " .. tostring(name))
    end
end

if #workers == 0 then
    error("None of the commissioned relay outputs are currently available.", 0)
end

print("RNG pulse controller running.")
print("Active channels: " .. #workers .. "/" .. #cfg.channels)
print(string.format("State timing: %.3fs - %.3fs", minTime, maxTime))

local ok, err = pcall(function()
    parallel.waitForAll(table.unpack(workers))
end)

-- Best-effort shutdown: leave every reachable commissioned output OFF.
for _, channel in ipairs(activeChannels) do
    local relay = peripheral.wrap(channel.name)
    if relay then
        pcall(relay.setOutput, channel.side, false)
    end
end

if not ok then error(err, 0) end
