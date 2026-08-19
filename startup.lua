-- Auto-start the commissioned RNG pulse controller.
if fs.exists("pulse.lua") then
    shell.run("pulse.lua")
else
    print("pulse.lua not found")
end
