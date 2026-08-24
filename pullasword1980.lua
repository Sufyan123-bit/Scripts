-- Pull a Sword - Full Auto-Farm & Auto-Fight Script
-- Powered by Rayfield UI Library

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Pull a Sword | Auto-Farm & Combat",
   LoadingTitle = "Loading Auto-Fight & Remotes...",
   LoadingSubtitle = "by Chiniot-EX",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Auto Farm", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)

-- Toggles
local AutoTrain = false
local AutoPull = false
local AutoRebirth = false
local AutoHatch = false
local AutoFight = false
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

-- Main Automation Toggles
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

-- Combat Tab Toggles
CombatTab:CreateToggle({
   Name = "Auto Fight / Auto Attack",
   CurrentValue = false,
   Callback = function(Value) AutoFight = Value end,
})

-- 1. Auto Train
task.spawn(function()
    while task.wait(0.001) do
        if AutoTrain then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or char:FindFirstChildOfClass("Tool")
                    if tool then
                        if tool.Parent ~= char then tool.Parent = char end
                        tool:Activate()
                    end
                end
                
                for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                    if v:IsA("RemoteEvent") and (v.Name:lower():find("click") or v.Name:lower():find("train") or v.Name:lower():find("addstrength")) then
                        v:FireServer()
                    end
                end
            end)
        end
    end
end)

-- 2. Auto Pull Sword
task.spawn(function()
    while task.wait(0.05) do
        if AutoPull then
            pcall(function()
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        fireproximityprompt(prompt)
                    end
                end
                
                for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                    if v:IsA("RemoteEvent") and (v.Name:lower():find("pull") or v.Name:lower():find("sword")) then
                        v:FireServer()
                    end
                end
            end)
        end
    end
end)

-- 3. Auto Rebirth
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

-- 4. Auto Hatch
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

-- 5. NEW: Auto Fight Feature Loop
task.spawn(function()
    while task.wait(0.1) do
        if AutoFight then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    -- Attack Tool Equip
                    local weapon = LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or char:FindFirstChildOfClass("Tool")
                    if weapon and weapon.Parent ~= char then weapon.Parent = char end
                    if weapon then weapon:Activate() end

                    -- Fight Remotes Trigger
                    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                        if v:IsA("RemoteEvent") and (v.Name:lower():find("fight") or v.Name:lower():find("attack") or v.Name:lower():find("boss") or v.Name:lower():find("battle")) then
                            v:FireServer()
                        end
                    end
                end
            end)
        end
    end
end)

Rayfield:Notify({
   Title = "Auto-Fight Added!",
   Content = "Check the Combat tab to toggle Auto-Fight.",
   Duration = 4,
})
