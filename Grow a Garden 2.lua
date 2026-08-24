-- Grow a Garden 2 - AFK Automation Script
-- Note: Replace "BuySeed", "PlantSeed", "SellHarvest" with your game's actual RemoteEvent names if needed.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Config Settings
local Settings = {
    AutoBuySeeds = true,
    AutoPlant = true,
    AutoSell = true,
    SelectedSeed = "BasicSeed", -- Apne game ke seed ka exact naam likhein
    BuyInterval = 5,           -- Seconds
    PlantInterval = 2,
    SellInterval = 3
}

-- Remote References (Game ke Remotes Folder ke mutabiq adjust karein)
local Remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage

-- 1. Auto Buy Seeds Function
task.spawn(function()
    while task.wait(Settings.BuyInterval) do
        if Settings.AutoBuySeeds then
            pcall(function()
                -- Remote call to purchase seeds from shop
                Remotes:FindFirstChild("BuySeed"):FireServer(Settings.SelectedSeed, 10)
                print("[Auto Buy]: Purchased seeds successfully!")
            end)
        end
    end
end)

-- 2. Auto Plant Function
task.spawn(function()
    while task.wait(Settings.PlantInterval) do
        if Settings.AutoPlant then
            pcall(function()
                -- Finds empty plots and plants selected seed
                local Plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("GardenPlots")
                if Plots then
                    for _, plot in pairs(Plots:GetChildren()) do
                        if plot:FindFirstChild("Owner") and plot.Owner.Value == LocalPlayer then
                            if plot:FindFirstChild("IsEmpty") and plot.IsEmpty.Value == true then
                                Remotes:FindFirstChild("PlantSeed"):FireServer(plot, Settings.SelectedSeed)
                                print("[Auto Plant]: Planted seed on plot " .. plot.Name)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 3. Auto Sell Harvest Function
task.spawn(function()
    while task.wait(Settings.SellInterval) do
        if Settings.AutoSell then
            pcall(function()
                -- Triggers sell event for all harvested crops in inventory
                Remotes:FindFirstChild("SellHarvest"):FireServer()
                print("[Auto Sell]: All crops sold!")
            end)
        end
    end
end)

print("Grow a Garden 2 Script Loaded Successfully!")
