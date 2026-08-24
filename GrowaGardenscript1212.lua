-- Grow a Garden 2 - Universal Interaction Script
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Toggle Settings
_G.AutoPlant = true
_G.AutoSell = true

-- 1. Auto Plant (Equips seed tool & triggers proximity prompts nearby)
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoPlant then
            pcall(function()
                -- Auto equip seeds from Backpack
                for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if item:IsA("Tool") and (item.Name:lower():find("seed") or item.Name:lower():find("plant")) then
                        item.Parent = Character
                    end
                end
                
                -- Trigger plant interaction prompts
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and (prompt.ObjectText:lower():find("plant") or prompt.ActionText:lower():find("plant")) then
                        if (HumanoidRootPart.Position - prompt.Parent.Position).Magnitude < 15 then
                            fireproximityprompt(prompt)
                        end
                    end
                end
            end)
        end
    end
end)

-- 2. Auto Sell (Teleports/Interacts with Sell Zone or Triggers Sell Prompts)
task.spawn(function()
    while task.wait(1) do
        if _G.AutoSell then
            pcall(function()
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and (prompt.ObjectText:lower():find("sell") or prompt.ActionText:lower():find("sell")) then
                        fireproximityprompt(prompt)
                    end
                end
            end)
        end
    end
end)

print("Universal Script Loaded!")
