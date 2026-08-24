-- Pull a Sword - Optimized & Fixed Full Auto-Farm Script
-- Powered by Rayfield UI Library

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Pull a Sword | Auto-Farm",
   LoadingTitle = "Fixing & Syncing Remotes...",
   LoadingSubtitle = "by Chiniot-EX",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Auto Farm", 4483362458)

-- Toggles
local AutoTrain = false
local AutoPull = false
local AutoRebirth = false
local AutoHatch = false
local SelectedEgg = "Basic"

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

-- UI Toggles Setup
MainTab:CreateToggle({
   Name = "Auto Train / Clicker",
   CurrentValue = false,
   Callback = function(Value) AutoTrain = Value end,
})

MainTab:CreateToggle({
   Name = "Auto Pull Sword",
   CurrentValue = false,
   Callback = function(Value) AutoPull = Value end,
})

MainTab:CreateToggle({
   Name = "Auto Rebirth",
   CurrentValue = false,
   Callback = function(Value) AutoRebirth = Value end,
})

MainTab:CreateToggle({
   Name = "Auto Hatch Eggs",
   CurrentValue = false,
   Callback = function(Value) AutoHatch = Value end,
})

MainTab:CreateDropdown({
   Name = "Select Egg Type",
   Options = {"Basic", "Common", "Rare", "Epic", "Legendary"},
   CurrentOption = {"Basic"},
   Callback = function(Option) SelectedEgg = Option[1] end,
})

-- Optimized Functional Loops

-- 1. Fixed Auto Train
task.spawn(function()
    while task.wait(0.001) do
        if AutoTrain then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    -- Tool Equip Force
                    local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or char:FindFirstChildOfClass("Tool")
                    if tool then
                        if tool.Parent ~= char then tool.Parent = char end
                        tool:Activate()
                    end
                end
                
                -- Fires game click remotes dynamically
                for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                    if v:IsA("RemoteEvent") and (v.Name:lower():find("click") or v.Name:lower():find("train") or v.Name:lower():find("addstrength")) then
                        v:FireServer()
                    end
                end
            end)
        end
    end
end)

-- 2. Fixed Auto Pull Sword
task.spawn(function()
    while task.wait(0.05) do
        if AutoPull then
            pcall(function()
                -- Interacts with all Proximity Prompts automatically
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        fireproximityprompt(prompt)
                    end
                end
                
                -- Remote Trigger
                for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                    if v:IsA("RemoteEvent") and (v.Name:lower():find("pull") or v.Name:lower():find("sword")) then
                        v:FireServer()
                    end
                end
            end)
        end
    end
end)

-- 3. Fixed Auto Rebirth
task.spawn(function()
    while task.wait(0.5) do
        if AutoRebirth then
            pcall(function()
                for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                    if v:IsA("RemoteEvent") and v.Name:lower():find("rebirth") then
                        v:FireServer()
                    end
                end
            end)
        end
    end
end)

-- 4. Fixed Auto Hatch
task.spawn(function()
    while task.wait(0.2) do
        if AutoHatch then
            pcall(function()
                for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                    if v:IsA("RemoteEvent") and (v.Name:lower():find("hatch") or v.Name:lower():find("open") or v.Name:lower():find("egg")) then
                        v:FireServer(SelectedEgg)
                    end
                end
            end)
        end
    end
end)

Rayfield:Notify({
   Title = "Features Updated",
   Content = "Auto-Farm functionality is now active!",
   Duration = 4,
})
