-- Minecraft-CC-redstone_RNG_16ch_pulse installer
-- Installs the current initial-controller branch files.

local BASE = "https://raw.githubusercontent.com/Draze08/Minecraft-CC-redstone_RNG_16ch_pulse/refs/heads/initial-controller/"

local files = {
    "commission.lua",
    "pulse.lua",
    "startup.lua",
}

local function download(name)
    local url = BASE .. name
    local temp = name .. ".new"

    if fs.exists(temp) then fs.delete(temp) end

    print("Downloading " .. name .. "...")
    local response, err = http.get(url)
    if not response then
        error("Failed to download " .. name .. ": " .. tostring(err), 0)
    end

    local data = response.readAll()
    response.close()

    local h = fs.open(temp, "w")
    if not h then error("Could not write " .. temp, 0) end
    h.write(data)
    h.close()

    if fs.exists(name) then fs.delete(name) end
    fs.move(temp, name)
    print("  OK")
end

term.clear()
term.setCursorPos(1,1)
print("RNG Redstone Pulse Installer")
print("============================")
print()

for _, name in ipairs(files) do
    download(name)
end

print()
print("Install complete.")
print("Existing rngpulse.cfg preserved if present.")
print()
print("Next: run commission.lua")
