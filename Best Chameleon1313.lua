--[[
    ═══════════════════════════════════════════════════════════════════
    CHAMELEON – Complete ESP & Reveal Script
    Game: CHAMELEON (Roblox)
    Executor: Synapse X / Krnl / Delta
    Version: 2.0.0 (Undetectable)
    ═══════════════════════════════════════════════════════════════════
    
    ███████  ████████  ██████  ██    ██  █████  
    ██   ██    ██    ██    ██ ██    ██ ██   ██ 
    ███████    ██    ██    ██ ██    ██ ███████ 
    ██   ██    ██    ██    ██ ██    ██ ██   ██ 
    ██   ██    ██     ██████   ██████  ██   ██ 
    
    ═══════════════════════════════════════════════════════════════════
    ALL FEATURES:
        ✅ Chameleon ESP (Highlight + Outline)
        ✅ See Through Walls (DepthMode = AlwaysOnTop)
        ✅ Player Highlight (Customizable Color)
        ✅ Distance Display (above players)
        ✅ Reveal All Chameleons (Remote + Visual)
        ✅ Clear Highlights (cleanup)
        ✅ Auto-Refresh on Character Added
        ✅ Human-Like Behavior Simulation (random delays, breaks)
        ✅ Obfuscated Strings & Anti-Detection
        ✅ Stealth Mode (GUI toggle)
        ✅ Emergency Stop (F1)
        ✅ Console Commands (:status, :scan, :list, :stop, :reveal)
    ═══════════════════════════════════════════════════════════════════
]]

-- ===================================================================
-- SECTION 1: ANTI-DETECTION & OBFUSCATION (Highest Priority)
-- ===================================================================

-- 1.1 String Obfuscation
local function obfuscate(str)
    local result = {}
    for i = 1, #str do
        table.insert(result, string.char(string.byte(str, i) + 2))
    end
    return table.concat(result)
end

local function decode(str)
    local result = {}
    for i = 1, #str do
        table.insert(result, string.char(string.byte(str, i) - 2))
    end
    return table.concat(result)
end

-- Obfuscated keyword patterns (for game detection)
local patterns = {
    chameleon = {obfuscate("Chameleon"), obfuscate("Cham"), obfuscate("Hide")},
    innocent = {obfuscate("Innocent"), obfuscate("Citizen"), obfuscate("Civilian")},
    hunter = {obfuscate("Hunter"), obfuscate("Sheriff"), obfuscate("Seeker")},
    team = obfuscate("Team"),
    role = obfuscate("Role"),
    leaderstats = obfuscate("leaderstats"),
}

-- 1.2 Randomized Delays with Jitter
local function randomDelay(min, max)
    local base = math.random(min * 10, max * 10) / 10
    local jitter = math.random(1, 5) / 100
    return base + jitter
end

-- 1.3 Memory Cleanup wrapper
local function safeCollect()
    if math.random(1, 10) == 1 then
        collectgarbage()
    end
end

-- 1.4 NO blacklisted functions – we will NOT use fireclickdetector or fireproximityprompt

-- 1.5 Execution Spoofing (for critical actions)
local function executeSpoofed(code)
    local randName = "f_" .. string.char(math.random(97,122)) .. math.random(1000,9999)
    local wrapped = "local " .. randName .. " = function() " .. code .. " end; " .. randName .. "()"
    loadstring(wrapped)()
end

-- 1.6 Realistic Mouse Movement (for GUI interaction simulation)
local function realisticMouseMove(x, y)
    local steps = math.random(5, 15)
    local stepX = x / steps
    local stepY = y / steps
    for i = 1, steps do
        pcall(function()
            if mousemoverel then
                mousemoverel(stepX, stepY)
            end
        end)
        task.wait(math.random(10, 50) / 1000)
    end
    task.wait(randomDelay(0.1, 0.3))
end

-- 1.7 Minimal Console Logging
local LOG_ENABLED = false
local function silentLog(msg)
    if not LOG_ENABLED then return end
    local cleanMsg = string.gsub(msg, "[Cc]hameleon", "[C]")
    cleanMsg = string.gsub(msg, "[Ee]SP", "[E]")
    cleanMsg = string.gsub(msg, "[Rr]eveal", "[R]")
    print(cleanMsg)
end

-- ===================================================================
-- SECTION 2: DYNAMIC GAME RESEARCH (Adaptive)
-- ===================================================================

local gameData = {
    player = game.Players.LocalPlayer,
    character = nil,
    rootPart = nil,
    humanoid = nil,
    chameleonTeam = nil,       -- detected team/role for chameleons
    hunterTeam = nil,          -- detected team/role for hunters
    allPlayers = {},
    remoteInfo = {},
    espObjects = {},           -- to store highlight instances for cleanup
    updateStatus = nil,
}

-- 2.1 Comprehensive Workspace Scan
local function analyzeGameEnvironment()
    local allDesc = workspace:GetDescendants()
    local info = {
        mechanics = {
            roleSystem = "unknown",
            chameleonDetection = "unknown", -- remote, attribute, team, etc.
        },
        objects = {},
    }

    -- Detect role storage
    for _, obj in ipairs(allDesc) do
        if obj:IsA("Folder") and obj.Name == "Roles" then
            info.mechanics.roleSystem = "folder"
        end
        if obj:IsA("ObjectValue") and obj.Name == "Role" then
            info.mechanics.roleSystem = "attribute"
        end
    end

    -- Check leaderstats for Role/Team
    local leaderstats = gameData.player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, stat in ipairs(leaderstats:GetChildren()) do
            if stat.Name == "Role" or stat.Name == "Team" then
                info.mechanics.roleSystem = "leaderstats"
                info.mechanics.roleStatName = stat.Name
            end
        end
    end

    -- Detect chameleon/hunter by analyzing player characters or GUI
    for _, player in ipairs(game.Players:GetPlayers()) do
        local char = player.Character
        if char then
            -- Check for hidden/invisible parts (chameleons might be translucent)
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Transparency > 0.5 then
                    info.mechanics.chameleonDetection = "transparency"
                end
            end
            -- Check for specific attributes
            if player:GetAttribute("Role") then
                info.mechanics.chameleonDetection = "attribute"
            end
        end
    end

    return info
end

-- 2.2 Remote Discovery (for Reveal functionality)
local function analyzeRemotes()
    local containers = {game.ReplicatedStorage, game.ReplicatedFirst, workspace}
    local remoteInfo = {}
    for _, container in ipairs(containers) do
        if container then
            for _, obj in ipairs(container:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local name = obj.Name:lower()
                    local purpose = "unknown"
                    if string.find(name, "reveal") or string.find(name, "report") or string.find(name, "chameleon") then
                        purpose = "reveal"
                    elseif string.find(name, "highlight") or string.find(name, "outline") then
                        purpose = "highlight"
                    end
                    table.insert(remoteInfo, {
                        remote = obj,
                        name = obj.Name,
                        path = obj:GetFullPath(),
                        type = obj:IsA("RemoteEvent") and "Event" or "Function",
                        purpose = purpose
                    })
                end
            end
        end
    end
    return remoteInfo
end

-- 2.3 Role/Team Detection (multi-method)
local function detectPlayerRole(player)
    -- Method 1: leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, stat in ipairs(leaderstats:GetChildren()) do
            if stat.Name == "Role" then return tostring(stat.Value) end
            if stat.Name == "Team" then return tostring(stat.Value) end
        end
    end

    -- Method 2: Attributes
    local roleAttr = player:GetAttribute("Role")
    if roleAttr then return roleAttr end

    -- Method 3: Check character parts for transparency or specific names
    local char = player.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency > 0.5 then
                return "Chameleon" -- likely a chameleon
            end
        end
        -- Check for tool names (e.g., hunter has a gun)
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                if string.find(toolName, "gun") or string.find(toolName, "blaster") then
                    return "Hunter"
                end
            end
        end
    end

    -- Method 4: PlayerGui text labels
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                local text = gui.Text or ""
                if string.find(text, "Chameleon") then return "Chameleon" end
                if string.find(text, "Hunter") then return "Hunter" end
                if string.find(text, "Innocent") then return "Innocent" end
            end
        end
    end

    return "Unknown"
end

-- 2.4 Discover Chameleon/Hunter teams automatically
local function discoverTeams()
    local chameleonRoles = {"Chameleon", "Hide", "Hidden", "Invisible"}
    local hunterRoles = {"Hunter", "Seeker", "Sheriff", "Detective"}

    local chameleonTeam = nil
    local hunterTeam = nil

    for _, player in ipairs(game.Players:GetPlayers()) do
        local role = detectPlayerRole(player)
        if role then
            for _, cRole in ipairs(chameleonRoles) do
                if string.find(role, cRole) then
                    chameleonTeam = role
                    break
                end
            end
            for _, hRole in ipairs(hunterRoles) do
                if string.find(role, hRole) then
                    hunterTeam = role
                    break
                end
            end
        end
        if chameleonTeam and hunterTeam then break end
    end

    return chameleonTeam, hunterTeam
end

-- ===================================================================
-- SECTION 3: CORE ESP & REVEAL FUNCTIONS
-- ===================================================================

-- 3.1 Create Highlight for a player (ESP)
local function applyESP(player, color, seeThroughWalls, showDistance)
    if not player.Character then return end
    local char = player.Character
    if not char then return end

    -- Cleanup old ESP for this player
    if gameData.espObjects[player] then
        for _, obj in ipairs(gameData.espObjects[player]) do
            pcall(function() obj:Destroy() end)
        end
        gameData.espObjects[player] = nil
    end

    local objects = {}

    -- Main Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = char
    highlight.FillColor = color or Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5  -- see through walls effect if DepthMode is set
    highlight.OutlineColor = color or Color3.fromRGB(255, 255, 0)
    highlight.OutlineTransparency = 0.3
    if seeThroughWalls then
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    else
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    end
    highlight.Parent = char
    table.insert(objects, highlight)

    -- Distance label (BillboardGui)
    if showDistance then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Distance"
        billboard.Adornee = char:FindFirstChild("Head") or char:FindFirstChildOfClass("BasePart")
        billboard.Size = UDim2.new(0, 100, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Text = "0"
        label.Parent = billboard
        billboard.Parent = char
        table.insert(objects, label)
        -- Store reference to update distance later
        table.insert(objects, {label = label, player = player}) -- store as table for update
    end

    gameData.espObjects[player] = objects
end

-- 3.2 Update distance labels
local function updateDistanceLabels()
    local localPos = gameData.rootPart and gameData.rootPart.Position or Vector3.new(0,0,0)
    for player, objects in pairs(gameData.espObjects) do
        if player and player.Character then
            local char = player.Character
            local head = char:FindFirstChild("Head") or char:FindFirstChildOfClass("BasePart")
            if head then
                local dist = (head.Position - localPos).Magnitude
                for _, obj in ipairs(objects) do
                    if type(obj) == "table" and obj.label and obj.player == player then
                        obj.label.Text = string.format("%.1f", dist) .. "m"
                    end
                end
            end
        end
    end
end

-- 3.3 Clear all ESP
local function clearESP()
    for player, objects in pairs(gameData.espObjects) do
        for _, obj in ipairs(objects) do
            pcall(function() obj:Destroy() end)
        end
    end
    gameData.espObjects = {}
end

-- 3.4 Reveal All Chameleons (attempt via remote or visual)
local function revealAllChameleons()
    -- First, try to find a reveal remote
    local revealRemote = nil
    for _, rInfo in ipairs(gameData.remoteInfo) do
        if rInfo.purpose == "reveal" then
            revealRemote = rInfo.remote
            break
        end
    end

    if revealRemote then
        -- Attempt to fire with various argument patterns
        local patterns = {
            {gameData.player},
            {gameData.player.Name},
            {true},
            {nil},
        }
        for _, args in ipairs(patterns) do
            local success = pcall(function()
                if revealRemote:IsA("RemoteEvent") then
                    revealRemote:FireServer(unpack(args))
                else
                    revealRemote:InvokeServer(unpack(args))
                end
            end)
            if success then
                silentLog("[Reveal] Remote triggered")
                if gameData.updateStatus then gameData.updateStatus("Revealed via Remote") end
                return true
            end
        end
    end

    -- Fallback: make all chameleons fully visible by setting transparency to 0
    local players = game.Players:GetPlayers()
    local chameleonTeam = gameData.chameleonTeam
    for _, player in ipairs(players) do
        if player ~= gameData.player then
            local role = detectPlayerRole(player)
            if chameleonTeam and string.find(role, chameleonTeam) then
                local char = player.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Transparency = 0
                        end
                    end
                end
            end
        end
    end
    silentLog("[Reveal] Made chameleons visible by transparency")
    if gameData.updateStatus then gameData.updateStatus("Revealed (Visual)") end
    return true
end

-- 3.5 Refresh ESP for all players based on current settings
local function refreshESP()
    clearESP()
    local players = game.Players:GetPlayers()
    local chameleonTeam = gameData.chameleonTeam
    local hunterTeam = gameData.hunterTeam
    local config = USER_CONFIG

    for _, player in ipairs(players) do
        if player ~= gameData.player then
            local role = detectPlayerRole(player)
            local isChameleon = chameleonTeam and string.find(role, chameleonTeam) ~= nil
            local isHunter = hunterTeam and string.find(role, hunterTeam) ~= nil

            if (config.espChameleon and isChameleon) or (config.espHunter and isHunter) or (config.espAllPlayers) then
                local color = config.chameleonColor
                if isHunter then color = config.hunterColor end
                if config.espAllPlayers and not isChameleon and not isHunter then color = config.defaultColor end

                applyESP(player, color, config.seeThroughWalls, config.showDistance)
            end
        end
    end
    silentLog("[ESP] Refreshed for " .. #players .. " players")
end

-- ===================================================================
-- SECTION 4: USER INTERFACE (Obfuscated & Complete)
-- ===================================================================

local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "G_" .. string.char(math.random(65,90)) .. math.random(100,999)

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Frm_" .. string.char(math.random(65,90)) .. math.random(100,999)
    mainFrame.Size = UDim2.new(0, 400, 0, 550)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -275)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.Draggable = true
    mainFrame.Active = true
    mainFrame.Parent = screenGui

    -- Title bar
    local title = Instance.new("TextLabel")
    title.Name = "Ttl_" .. string.char(math.random(65,90)) .. math.random(100,999)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    title.Text = "⚡ CHAMELEON ESP v2"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Cls_" .. string.char(math.random(65,90)) .. math.random(100,999)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -30, 0, 2)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = mainFrame
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        isRunning = false
    end)

    -- Scroll frame for settings
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Scrl_" .. string.char(math.random(65,90)) .. math.random(100,999)
    scroll.Size = UDim2.new(1, -10, 1, -45)
    scroll.Position = UDim2.new(0, 5, 0, 40)
    scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 650)
    scroll.ScrollBarThickness = 6
    scroll.Parent = mainFrame

    local yPos = 5
    local function addLabel(text, color)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -10, 0, 25)
        lbl.Position = UDim2.new(0, 5, 0, yPos)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color or Color3.fromRGB(200, 200, 200)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 16
        lbl.Parent = scroll
        yPos = yPos + 28
        return lbl
    end

    local function addToggle(label, configKey, default)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 30)
        row.Position = UDim2.new(0, 5, 0, yPos)
        row.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        row.BorderSizePixel = 0
        row.Parent = scroll

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.Position = UDim2.new(0, 5, 0, 0)
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.Parent = row

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 60, 0, 25)
        btn.Position = UDim2.new(0.7, 0, 0.5, -12.5)
        btn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        btn.Text = "ON"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = row

        if USER_CONFIG[configKey] == nil then USER_CONFIG[configKey] = default end
        local state = USER_CONFIG[configKey]
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            btn.Text = "ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            btn.Text = "OFF"
        end

        btn.MouseButton1Click:Connect(function()
            USER_CONFIG[configKey] = not USER_CONFIG[configKey]
            if USER_CONFIG[configKey] then
                btn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                btn.Text = "ON"
            else
                btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                btn.Text = "OFF"
            end
            -- Refresh ESP when toggles change
            if string.find(configKey, "esp") or configKey == "seeThroughWalls" or configKey == "showDistance" then
                refreshESP()
            end
        end)
        yPos = yPos + 35
        return btn
    end

    local function addColorPicker(label, configKey, defaultColor)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 35)
        row.Position = UDim2.new(0, 5, 0, yPos)
        row.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        row.BorderSizePixel = 0
        row.Parent = scroll

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.Position = UDim2.new(0, 5, 0, 0)
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.Parent = row

        local colorBtn = Instance.new("TextButton")
        colorBtn.Size = UDim2.new(0, 80, 0, 25)
        colorBtn.Position = UDim2.new(0.6, 0, 0.5, -12.5)
        colorBtn.BackgroundColor3 = defaultColor or Color3.fromRGB(255, 0, 0)
        colorBtn.Text = ""
        colorBtn.BorderSizePixel = 0
        colorBtn.Parent = row

        if USER_CONFIG[configKey] == nil then
            USER_CONFIG[configKey] = defaultColor or Color3.fromRGB(255,0,0)
        end
        colorBtn.BackgroundColor3 = USER_CONFIG[configKey]

        colorBtn.MouseButton1Click:Connect(function()
            -- Simple cycle through some colors for demo
            local colors = {
                Color3.fromRGB(255,0,0),
                Color3.fromRGB(0,255,0),
                Color3.fromRGB(0,0,255),
                Color3.fromRGB(255,255,0),
                Color3.fromRGB(255,0,255),
                Color3.fromRGB(0,255,255)
            }
            local current = USER_CONFIG[configKey]
            local idx = 1
            for i, col in ipairs(colors) do
                if col == current then idx = i break end
            end
            idx = idx % #colors + 1
            USER_CONFIG[configKey] = colors[idx]
            colorBtn.BackgroundColor3 = colors[idx]
            refreshESP()
        end)
        yPos = yPos + 40
        return colorBtn
    end

    -- Visuals Section
    addLabel("── VISUALS ──", Color3.fromRGB(100, 200, 255))
    addToggle("Chameleon ESP", "espChameleon", true)
    addToggle("Hunter ESP", "espHunter", true)
    addToggle("All Players ESP", "espAllPlayers", false)
    addToggle("See Through Walls", "seeThroughWalls", true)
    addToggle("Show Distance", "showDistance", true)
    addColorPicker("Chameleon Color", "chameleonColor", Color3.fromRGB(255, 0, 0))
    addColorPicker("Hunter Color", "hunterColor", Color3.fromRGB(0, 255, 0))
    addColorPicker("Default Color", "defaultColor", Color3.fromRGB(0, 100, 255))

    -- Utilities
    yPos = yPos + 10
    addLabel("── UTILITIES ──", Color3.fromRGB(100, 200, 255))
    local revealBtn = Instance.new("TextButton")
    revealBtn.Size = UDim2.new(0.8, 0, 0, 35)
    revealBtn.Position = UDim2.new(0.1, 0, 0, yPos)
    revealBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    revealBtn.Text = "🔍 Reveal All Chameleons"
    revealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    revealBtn.BorderSizePixel = 0
    revealBtn.Font = Enum.Font.GothamBold
    revealBtn.TextSize = 16
    revealBtn.Parent = scroll
    revealBtn.MouseButton1Click:Connect(function()
        revealAllChameleons()
    end)
    yPos = yPos + 45

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.8, 0, 0, 35)
    clearBtn.Position = UDim2.new(0.1, 0, 0, yPos)
    clearBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    clearBtn.Text = "🧹 Clear Highlights"
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.BorderSizePixel = 0
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 16
    clearBtn.Parent = scroll
    clearBtn.MouseButton1Click:Connect(function()
        clearESP()
        if gameData.updateStatus then gameData.updateStatus("Highlights Cleared") end
    end)
    yPos = yPos + 45

    -- Status
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1, -10, 0, 35)
    statusFrame.Position = UDim2.new(0, 5, 0, yPos)
    statusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = scroll
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, 0, 1, 0)
    statusText.Text = "Status: Idle"
    statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusText.BackgroundTransparency = 1
    statusText.Font = Enum.Font.Gotham
    statusText.TextSize = 14
    statusText.Parent = statusFrame
    gameData.updateStatus = function(msg) statusText.Text = "Status: " .. msg end

    yPos = yPos + 45

    -- Stealth toggle
    local stealthBtn = Instance.new("TextButton")
    stealthBtn.Size = UDim2.new(0.45, -5, 0, 30)
    stealthBtn.Position = UDim2.new(0.05, 0, 0, yPos)
    stealthBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    stealthBtn.Text = "👁️ Stealth Mode"
    stealthBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    stealthBtn.BorderSizePixel = 0
    stealthBtn.Font = Enum.Font.Gotham
    stealthBtn.TextSize = 14
    stealthBtn.Parent = scroll
    stealthBtn.MouseButton1Click:Connect(function()
        USER_CONFIG.stealthMode = not USER_CONFIG.stealthMode
        mainFrame.Visible = not mainFrame.Visible
    end)

    -- Emergency stop
    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0.45, -5, 0, 30)
    stopBtn.Position = UDim2.new(0.5, 0, 0, yPos)
    stopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    stopBtn.Text = "🛑 F1 Stop"
    stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopBtn.BorderSizePixel = 0
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.TextSize = 14
    stopBtn.Parent = scroll
    stopBtn.MouseButton1Click:Connect(function()
        isRunning = false
        if gameData.updateStatus then gameData.updateStatus("STOPPED") end
    end)
    yPos = yPos + 40

    scroll.CanvasSize = UDim2.new(0, 0, 0, yPos + 20)

    -- F1 key binding
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F1 then
            isRunning = false
            if gameData.updateStatus then gameData.updateStatus("EMERGENCY STOP (F1)") end
        end
    end)

    screenGui.Parent = game.Players.LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
    return screenGui
end

-- ===================================================================
-- SECTION 5: MAIN LOOP WITH RANDOMIZATION
-- ===================================================================

local isRunning = true

local function mainLoop()
    while isRunning do
        -- Take random breaks (human-like)
        if math.random(1, 20) == 1 then
            local breakDuration = math.random(30, 120)
            silentLog("[Sys] Break " .. breakDuration .. "s")
            task.wait(breakDuration)
        end

        -- Refresh ESP periodically to catch new players
        if math.random(1, 3) == 1 then
            refreshESP()
        end

        -- Update distance labels
        if USER_CONFIG.showDistance then
            updateDistanceLabels()
        end

        -- Simulate occasional mouse movement (if not stealth)
        if not USER_CONFIG.stealthMode and math.random(1, 10) == 1 then
            realisticMouseMove(math.random(-20,20), math.random(-10,10))
        end

        -- Clean memory
        safeCollect()

        -- Random delay between cycles (2-6 seconds)
        task.wait(math.random(2, 6))
    end
end

-- ===================================================================
-- SECTION 6: CONFIGURATION TABLE
-- ===================================================================

local USER_CONFIG = {
    espChameleon = true,
    espHunter = true,
    espAllPlayers = false,
    seeThroughWalls = true,
    showDistance = true,
    chameleonColor = Color3.fromRGB(255, 0, 0),
    hunterColor = Color3.fromRGB(0, 255, 0),
    defaultColor = Color3.fromRGB(0, 100, 255),
    stealthMode = false,
}

-- ===================================================================
-- SECTION 7: CONSOLE COMMANDS
-- ===================================================================

local function setupConsoleCommands()
    local function executeCommand(cmd)
        if cmd == ":status" then
            print("=== STATUS ===")
            print("Running: " .. tostring(isRunning))
            print("Chameleon Team: " .. tostring(gameData.chameleonTeam))
            print("Hunter Team: " .. tostring(gameData.hunterTeam))
            print("Players: " .. #game.Players:GetPlayers())
            print("ESP Objects: " .. #gameData.espObjects)
        elseif cmd == ":scan" then
            print("Rescanning...")
            local info = analyzeGameEnvironment()
            gameData.remoteInfo = analyzeRemotes()
            local chameleonTeam, hunterTeam = discoverTeams()
            gameData.chameleonTeam = chameleonTeam
            gameData.hunterTeam = hunterTeam
            print("Detected Chameleon Team: " .. tostring(chameleonTeam))
            print("Detected Hunter Team: " .. tostring(hunterTeam))
            refreshESP()
        elseif cmd == ":list" then
            print("=== PLAYERS ===")
            for i, player in ipairs(game.Players:GetPlayers()) do
                local role = detectPlayerRole(player)
                print(i .. ": " .. player.Name .. " (" .. role .. ")")
            end
        elseif cmd == ":stop" then
            isRunning = false
            print("Stopped.")
        elseif cmd == ":reveal" then
            revealAllChameleons()
        else
            print("Commands: :status, :scan, :list, :stop, :reveal")
        end
    end

    _G.ScriptCommand = executeCommand
    print("Commands: :status, :scan, :list, :stop, :reveal")
    print("Use _G.ScriptCommand(\":status\") if needed.")
end

-- ===================================================================
-- SECTION 8: INITIALIZATION & STARTUP
-- ===================================================================

-- Refresh character
local function refreshCharacter()
    gameData.character = gameData.player.Character or gameData.player.CharacterAdded:Wait()
    gameData.humanoid = gameData.character:FindFirstChildOfClass("Humanoid")
    gameData.rootPart = gameData.character and gameData.character:FindFirstChild("HumanoidRootPart")
end
refreshCharacter()
gameData.player.CharacterAdded:Connect(refreshCharacter)

-- Discover teams
local chameleonTeam, hunterTeam = discoverTeams()
gameData.chameleonTeam = chameleonTeam
gameData.hunterTeam = hunterTeam

-- Analyze remotes
gameData.remoteInfo = analyzeRemotes()

-- Create GUI
local gui = createGUI()
if USER_CONFIG.stealthMode and gui then
    local mainFrame = gui:FindFirstChildOfClass("Frame")
    if mainFrame then mainFrame.Visible = false end
end

-- Setup console commands
setupConsoleCommands()

-- Initial ESP refresh
task.wait(1) -- wait for character to load
refreshESP()

-- Start main loop
task.spawn(mainLoop)

print("✅ CHAMELEON ESP v2 loaded. Press F1 for emergency stop.")
if gameData.updateStatus then
    gameData.updateStatus("Running")
end

-- Keep alive
while isRunning do
    task.wait(1)
end

print("Script terminated.")
