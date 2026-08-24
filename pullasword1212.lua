-- Pull a Sword: Universal Input Auto-Farm

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

_G.AutoTrain = true
_G.AutoClick = true

-- Auto Equip & Click Simulator
task.spawn(function()
    while task.wait(0.01) do
        if _G.AutoTrain then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    -- Tool Equip
                    local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or char:FindFirstChildOfClass("Tool")
                    if tool and tool.Parent ~= char then
                        tool.Parent = char
                    end
                    -- Simulated Mouse Click
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end)
        end
    end
end)

print("Input Simulator Loaded!")
