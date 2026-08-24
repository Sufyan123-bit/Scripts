-- Pull a Sword & Steal an Egg Custom UI Script
-- Powered by Rayfield UI Library

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Steal an Egg / Pull a Sword",
   LoadingTitle = "Loading Automation GUI...",
   LoadingSubtitle = "by Chiniot-EX",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "PullASwordConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = true
   },
   KeySystem = false
})

-- Main Tab
local MainTab = Window:CreateTab("Automation", 4483362458) -- Title Icon

-- Variables / States
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

-- Anti-AFK Setup
LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

-- 1. Auto Train / Clicker Toggle
local TrainToggle = MainTab:CreateToggle({
   Name = "Auto Train / Clicker",
   CurrentValue = false,
   Flag = "AutoTrainFlag",
   Callback = function(Value)
      AutoTrain = Value
   end,
})

-- 2. Auto Pull Sword Toggle
local PullToggle = MainTab:CreateToggle({
   Name = "Auto Pull Sword",
   CurrentValue = false,
   Flag = "AutoPullFlag",
   Callback = function(Value)
      AutoPull = Value
   end,
})

-- 3. Auto Rebirth Toggle
local RebirthToggle = MainTab:CreateToggle({
   Name = "Auto Rebirth",
   CurrentValue = false,
   Flag = "AutoRebirthFlag",
   Callback = function(Value)
      AutoRebirth = Value
   end,
})

-- 4. Auto Hatch Eggs Toggle
local HatchToggle = MainTab:CreateToggle({
   Name = "Auto Hatch Eggs",
   CurrentValue = false,
   Flag = "AutoHatchFlag",
   Callback = function(Value)
      AutoHatch = Value
   end,
})

-- Egg Selector Dropdown
local EggDropdown = MainTab:CreateDropdown({
   Name = "Select Egg Type",
   Options = {"Basic", "Forest", "Desert", "Ocean", "Magma"},
   CurrentOption = {"Basic"},
   MultipleOptions = false,
   Flag = "EggSelectFlag",
   Callback = function(Option)
      SelectedEgg = Option[1]
   end,
})

-- Background Loops Execution

-- Loop 1: Auto Train (Input Simulation & Remote Fallback)
task.spawn(function()
    while task.wait(0.01) do
        if AutoTrain then
            pcall(function()
                local Character = LocalPlayer.Character
                if Character then
                    local Tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or Character:FindFirstChildOfClass("Tool")
                    if Tool and Tool.Parent ~= Character then
                        Tool.Parent = Character
                    end
                end
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                
                local Rem = ReplicatedStorage:FindFirstChild("Train") or (ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Click"))
                if Rem then Rem:FireServer() end
            end)
        end
    end
end)

-- Loop 2: Auto Pull
task.spawn(function()
    while task.wait(0.1) do
        if AutoPull then
            pcall(function()
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.ActionText:lower():find("pull") then
                        fireproximityprompt(prompt)
                    end
                end
                local Rem = ReplicatedStorage:FindFirstChild("PullSword") or (ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Pull"))
                if Rem then Rem:FireServer() end
            end)
        end
    end
end)

-- Loop 3: Auto Rebirth
task.spawn(function()
    while task.wait(1) do
        if AutoRebirth then
            pcall(function()
                local Rem = ReplicatedStorage:FindFirstChild("Rebirth") or (ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Rebirth"))
                if Rem then Rem:FireServer() end
            end)
        end
    end
end)

-- Loop 4: Auto Hatch
task.spawn(function()
    while task.wait(0.5) do
        if AutoHatch then
            pcall(function()
                local Rem = ReplicatedStorage:FindFirstChild("OpenEgg") or ReplicatedStorage:FindFirstChild("BuyEgg") or (ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Hatch"))
                if Rem then Rem:FireServer(SelectedEgg, 1) end
            end)
        end
    end
end)

Rayfield:Notify({
   Title = "GUI Loaded!",
   Content = "Steal an Egg / Pull a Sword Script Ready.",
   Duration = 5,
   Image = 4483362458,
})
