-- Pull a Sword - AFK Automation Script

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Anti-AFK (Prevents Roblox Disconnect)
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Automation Toggles
_G.AutoTrain = true
_G.AutoPull = true
_G.AutoRebirth = true
_G.AutoHatch = true

-- Config
local SelectedEgg = "Basic" -- Replace with desired Egg Name (e.g., "Forest", "Desert")

-- 1. Auto Train / Auto Clicker
task.spawn(function()
    while task.wait(0.01) do
        if _G.AutoTrain then
            pcall(function()
                -- Equips weapon/tool automatically
                local Character = LocalPlayer.Character
                if Character then
                    local Tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or Character:FindFirstChildOfClass("Tool")
                    if Tool and Tool.Parent ~= Character then
                        Tool.Parent = Character
                    end
                    if Tool then
                        Tool:Activate()
                    end
                end
                
                -- Standard Remote Click Trigger
                local TrainRemote = ReplicatedStorage:FindFirstChild("Train") 
                    or ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Click")
                if TrainRemote then
                    TrainRemote:FireServer()
                end
            end)
        end
    end
end)

-- 2. Auto Pull Sword
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoPull then
            pcall(function()
                -- Triggers ProximityPrompts or Pull Remotes
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.ActionText:lower():find("pull") then
                        fireproximityprompt(prompt)
                    end
                end
                
                local PullRemote = ReplicatedStorage:FindFirstChild("PullSword") 
                    or ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Pull")
                if PullRemote then
                    PullRemote:FireServer()
                end
            end)
        end
    end
end)

-- 3. Auto Rebirth
task.spawn(function()
    while task.wait(1) do
        if _G.AutoRebirth then
            pcall(function()
                local RebirthRemote = ReplicatedStorage:FindFirstChild("Rebirth") 
                    or ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Rebirth")
                if RebirthRemote then
                    RebirthRemote:FireServer()
                end
            end)
        end
    end
end)

-- 4. Auto Hatch Eggs
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoHatch then
            pcall(function()
                local HatchRemote = ReplicatedStorage:FindFirstChild("OpenEgg") 
                    or ReplicatedStorage:FindFirstChild("BuyEgg") 
                    or ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Hatch")
                if HatchRemote then
                    HatchRemote:FireServer(SelectedEgg, 1) -- 1 = Single Hatch
                end
            end)
        end
    end
end)

print("Pull a Sword Script Successfully Loaded!")
