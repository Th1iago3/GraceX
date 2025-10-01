-- Define toggles and values
local toggles = {
    BoostParticles = true,
    AutoLevers = true,
    DestroyEntities = true,
    DestroyEyeGui = true,
    DestroySmileGui = true,
    DestroyGoatPort = true,
    AutoSprint = false,
    PlayersESP = false,
    EntitiesESP = false,
    FullBright = false,
    GodMode = true,
    WalkSpeed = 16,  -- Default walk speed
    JumpPower = 50   -- Default jump power
}

-- Expanded entity names for GodMode and ESP
local entityNames = {
    "eye", "elkman", "Rush", "Worm", "eyePrime", "Carnation", "Slight", "Slugfish", "Heed",
    "Dozer", "Sorrow", "GOATMAN", "Litany", "Doppel", "Rue", "Kookoo", "Doombringer",
    "Zomber", "TEH EPIK DUCK", "Mime", "DRAIN", "Ire", "PIHSROW", "Parasite", "Shadow",
    "Ambush", "Halt", "Seek", "Figure", "Screech", "Timothy", "Glitch", "Dupe", "Void"
    -- Added more potential entities from similar games like Doors for completeness
}

-- Services
local workspace = game:GetService("Workspace")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local uis = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local lighting = game:GetService("Lighting")
local vim = game:GetService("VirtualInputManager")
local runService = game:GetService("RunService")

-- Connections and loops
if toggles.BoostParticles then
    workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("ParticleEmitter") then
            descendant.Rate = descendant.Rate * 10
        end
    end)
end

workspace.DescendantAdded:Connect(function(descendant)
    if toggles.AutoLevers and descendant.Name == "base" and descendant:IsA("BasePart") then
        if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            descendant.Position = localPlayer.Character.HumanoidRootPart.Position
            game.StarterGui:SetCore("SendNotification", {
                Title = "levers moved",
                Text = "door has been opened",
                Duration = 3
            })
        end
    end
end)

local entityConn = workspace.DescendantAdded:Connect(function(descendant)
    if table.find(entityNames, descendant.Name) then
        if toggles.EntitiesESP then
            -- ESP handled separately
        elseif toggles.DestroyEntities or toggles.GodMode then
            descendant:Destroy()
        end
    end
end)

-- Loops for GUIs
spawn(function()
    while true do
        if toggles.DestroyEyeGui then
            local eyeGui = localPlayer.PlayerGui:FindFirstChild("eyegui")
            if eyeGui then eyeGui:Destroy() end
        end
        task.wait(0.1)
    end
end)

spawn(function()
    while true do
        local smileGui = localPlayer.PlayerGui:FindFirstChild("smilegui")
        if smileGui then smileGui:Destroy() end
        task.wait(0.1)
    end
end)

spawn(function()
    while true do
        local goatPort = localPlayer.PlayerGui:FindFirstChild("GOATPORT")
        if goatPort then goatPort:Destroy() end
        task.wait(0.1)
    end
end)

-- GodMode: Additional invincibility
if toggles.GodMode then
    localPlayer.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        hum.HealthChanged:Connect(function(health)
            if health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end)
    end)
    if localPlayer.Character then
        local hum = localPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.Health = hum.MaxHealth
        end
    end
end

-- ESP functions with BillboardGui for canvas-like ESP
local espFolders = {
    Players = Instance.new("Folder", localPlayer.PlayerGui),
    Entities = Instance.new("Folder", localPlayer.PlayerGui)
}
espFolders.Players.Name = "PlayersESP"
espFolders.Entities.Name = "EntitiesESP"

local function createESP(adorn, color, isPlayer)
    local bb = Instance.new("BillboardGui")
    bb.Adornee = adorn
    bb.Size = UDim2.new(0, 200, 0, 50)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = isPlayer and espFolders.Players or espFolders.Entities

    local frame = Instance.new("Frame", bb)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1

    local nameLabel = Instance.new("TextLabel", frame)
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = color
    nameLabel.Text = adorn.Name
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.Code

    local distLabel = Instance.new("TextLabel", frame)
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = color
    distLabel.TextSize = 12
    distLabel.Font = Enum.Font.Code

    -- Update distance
    runService.RenderStepped:Connect(function()
        if bb.Adornee and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (bb.Adornee.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
            distLabel.Text = "Distance: " .. math.floor(dist) .. " studs"
        else
            bb:Destroy()
        end
    end)

    -- For players, add items if inventory accessible
    if isPlayer and adorn.Parent:FindFirstChild("Backpack") then
        local items = ""
        for _, tool in ipairs(adorn.Parent.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                items = items .. tool.Name .. ", "
            end
        end
        if items ~= "" then
            local itemsLabel = Instance.new("TextLabel", frame)
            itemsLabel.Size = UDim2.new(1, 0, 0.5, 0)
            itemsLabel.Position = UDim2.new(0, 0, 1, 0)
            itemsLabel.BackgroundTransparency = 1
            itemsLabel.TextColor3 = color
            itemsLabel.Text = "Items: " .. items:sub(1, -3)
            itemsLabel.TextSize = 10
            itemsLabel.Font = Enum.Font.Code
            bb.Size = UDim2.new(0, 200, 0, 75)
        end
    end

    return bb
end

local playerESPs = {}
local playerESPConns = {}

local function togglePlayersESP(on)
    if on then
        for _, p in ipairs(players:GetPlayers()) do
            if p ~= localPlayer and p.Character then
                local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Head")
                if root then
                    playerESPs[p] = createESP(root, Color3.fromRGB(0, 255, 0), true)
                end
            end
        end
        playerESPConns.added = players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function(char)
                local root = char:WaitForChild("HumanoidRootPart") or char:WaitForChild("Head")
                playerESPs[p] = createESP(root, Color3.fromRGB(0, 255, 0), true)
            end)
        end)
    else
        for _, esp in pairs(playerESPs) do
            if esp then esp:Destroy() end
        end
        playerESPs = {}
        if playerESPConns.added then playerESPConns.added:Disconnect() end
    end
end

local entityESPs = {}
local entityESPConn

local function toggleEntitiesESP(on)
    if on then
        -- Existing entities
        for _, desc in ipairs(workspace:GetDescendants()) do
            if table.find(entityNames, desc.Name) then
                local root = desc:FindFirstChild("HumanoidRootPart") or desc:FindFirstChild("Head") or desc
                entityESPs[desc] = createESP(root, Color3.fromRGB(255, 0, 0), false)
            end
        end
        -- New ones
        entityESPConn = workspace.DescendantAdded:Connect(function(desc)
            if table.find(entityNames, desc.Name) then
                local root = desc:FindFirstChild("HumanoidRootPart") or desc:FindFirstChild("Head") or desc
                entityESPs[desc] = createESP(root, Color3.fromRGB(255, 0, 0), false)
            end
        end)
    else
        for _, esp in pairs(entityESPs) do
            if esp then esp:Destroy() end
        end
        entityESPs = {}
        if entityESPConn then entityESPConn:Disconnect() end
    end
end

-- Full bright function
local originalLighting = {
    Brightness = lighting.Brightness,
    FogEnd = lighting.FogEnd,
    GlobalShadows = lighting.GlobalShadows,
    Ambient = lighting.Ambient
}

local function toggleFullBright(on)
    if on then
        lighting.Brightness = 2
        lighting.FogEnd = 100000
        lighting.GlobalShadows = false
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        lighting.Brightness = originalLighting.Brightness
        lighting.FogEnd = originalLighting.FogEnd
        lighting.GlobalShadows = originalLighting.GlobalShadows
        lighting.Ambient = originalLighting.Ambient
    end
end

-- Humanoid updates
local function updateHumanoid()
    local char = localPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        hum.WalkSpeed = toggles.WalkSpeed
        hum.JumpPower = toggles.JumpPower
    end
end

localPlayer.CharacterAdded:Connect(updateHumanoid)
if localPlayer.Character then updateHumanoid() end

-- GUI Setup with black and red theme, stripes
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GraceScriptGui"
screenGui.Enabled = false  -- Start closed
screenGui.Parent = localPlayer.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0.4, 0, 0.6, 0)
mainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)  -- Black
mainFrame.BackgroundTransparency = 0.3  -- Glassmorph
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 15)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Transparency = 0.4
uiStroke.Color = Color3.fromRGB(255, 0, 0)  -- Red
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Parent = mainFrame

local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(50, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30))
})
uiGradient.Rotation = 45  -- Stripes effect
uiGradient.Parent = mainFrame

-- Title bar
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "GraceX - @0xffff00"
titleLabel.TextColor3 = Color3.fromRGB(255, 0, 0)  -- Red
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.Parent = mainFrame

-- Draggable
local dragging = false
local dragStart = nil
local startPos = nil

titleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleLabel.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

uis.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Tab bar
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 50)
tabFrame.Position = UDim2.new(0, 0, 0, 50)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Parent = tabFrame

local tabs = {"Main", "ESP", "Misc"}
local contentFrames = {}

for _, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1/#tabs, 0, 1, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 0, 0)  -- Dark red
    tabButton.BackgroundTransparency = 0.5
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.Font = Enum.Font.GothamBold
    tabButton.Parent = tabFrame

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 10)
    tabCorner.Parent = tabButton

    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Size = UDim2.new(1, 0, 1, -100)
    contentFrame.Position = UDim2.new(0, 0, 0, 100)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ScrollBarThickness = 8
    contentFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
    contentFrame.Visible = false
    contentFrame.Parent = mainFrame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = contentFrame

    contentFrames[tabName] = contentFrame

    tabButton.MouseButton1Click:Connect(function()
        for _, cf in pairs(contentFrames) do
            cf.Visible = false
        end
        contentFrame.Visible = true
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        tweenService:Create(contentFrame, tweenInfo, {CanvasPosition = Vector2.new(0, 0)}):Play()
    end)
end

contentFrames["Main"].Visible = true

-- Function to create toggle
local function createToggle(parent, name, key, default)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.BackgroundTransparency = 0.8
    toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggleFrame.Parent = parent

    local togCorner = Instance.new("UICorner")
    togCorner.CornerRadius = UDim.new(0, 8)
    togCorner.Parent = toggleFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 16
    label.Font = Enum.Font.Gotham
    label.Parent = toggleFrame

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0.3, 0, 1, 0)
    toggleButton.Position = UDim2.new(0.7, 0, 0, 0)
    toggleButton.BackgroundColor3 = default and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(50, 50, 50)
    toggleButton.Text = default and "On" or "Off"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = toggleFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = toggleButton

    toggleButton.MouseButton1Click:Connect(function()
        toggles[key] = not toggles[key]
        toggleButton.Text = toggles[key] and "On" or "Off"
        toggleButton.BackgroundColor3 = toggles[key] and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(50, 50, 50)
        -- Handlers
        if key == "AutoSprint" then
            if toggles[key] then
                vim:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
            else
                vim:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
            end
        elseif key == "PlayersESP" then
            togglePlayersESP(toggles[key])
        elseif key == "EntitiesESP" then
            toggleEntitiesESP(toggles[key])
        elseif key == "FullBright" then
            toggleFullBright(toggles[key])
        elseif key == "GodMode" then
            -- Already connected, but can add more if needed
        end
        -- Animation
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Bounce)
        tweenService:Create(toggleButton, tweenInfo, {Size = UDim2.new(0.32, 0, 1.05, 0)}):Play()
        wait(0.3)
        tweenService:Create(toggleButton, tweenInfo, {Size = UDim2.new(0.3, 0, 1, 0)}):Play()
    end)
end

-- Function to create slider
local function createSlider(parent, name, key, min, max, default)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 40)
    sliderFrame.BackgroundTransparency = 0.8
    sliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    sliderFrame.Parent = parent

    local slidCorner = Instance.new("UICorner")
    slidCorner.CornerRadius = UDim.new(0, 8)
    slidCorner.Parent = sliderFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 16
    label.Font = Enum.Font.Gotham
    label.Parent = sliderFrame

    local sliderBack = Instance.new("Frame")
    sliderBack.Size = UDim2.new(0.5, 0, 0.4, 0)
    sliderBack.Position = UDim2.new(0.5, 0, 0.3, 0)
    sliderBack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBack.Parent = sliderFrame

    local slidBackCorner = Instance.new("UICorner")
    slidBackCorner.CornerRadius = UDim.new(0, 10)
    slidBackCorner.Parent = sliderBack

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    sliderFill.Parent = sliderBack

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 10)
    fillCorner.Parent = sliderFill

    local sliding = false

    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
        end
    end)

    sliderBack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)

    uis.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position.X - sliderBack.AbsolutePosition.X
            local scale = math.clamp(delta / sliderBack.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + scale * (max - min))
            toggles[key] = val
            label.Text = name .. ": " .. val
            sliderFill.Size = UDim2.new(scale, 0, 1, 0)
            updateHumanoid()
        end
    end)
end

-- Add to Main tab
createToggle(contentFrames["Main"], "Boost Particles", "BoostParticles", toggles.BoostParticles)
createToggle(contentFrames["Main"], "Auto Levers", "AutoLevers", toggles.AutoLevers)
createToggle(contentFrames["Main"], "Destroy Entities", "DestroyEntities", toggles.DestroyEntities)
createToggle(contentFrames["Main"], "Destroy Eye Gui", "DestroyEyeGui", toggles.DestroyEyeGui)
createToggle(contentFrames["Main"], "Destroy Smile Gui", "DestroySmileGui", toggles.DestroySmileGui)
createToggle(contentFrames["Main"], "Destroy Goat Port", "DestroyGoatPort", toggles.DestroyGoatPort)
createToggle(contentFrames["Main"], "God Mode", "GodMode", toggles.GodMode)

-- Add to ESP tab
createToggle(contentFrames["ESP"], "Players ESP (Dist/Items)", "PlayersESP", toggles.PlayersESP)
createToggle(contentFrames["ESP"], "Entities ESP (Dist)", "EntitiesESP", toggles.EntitiesESP)

-- Add to Misc tab
createToggle(contentFrames["Misc"], "Auto Sprint", "AutoSprint", toggles.AutoSprint)
createSlider(contentFrames["Misc"], "Walk Speed", "WalkSpeed", 16, 200, toggles.WalkSpeed)
createSlider(contentFrames["Misc"], "Jump Power", "JumpPower", 50, 300, toggles.JumpPower)
createToggle(contentFrames["Misc"], "Full Bright", "FullBright", toggles.FullBright)

-- Toggle GUI with Right Shift
uis.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        screenGui.Enabled = not screenGui.Enabled
        if screenGui.Enabled then
            mainFrame.Position = UDim2.new(0.3, 0, -0.6, 0)  -- Start offscreen
            local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            tweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.3, 0, 0.2, 0)}):Play()
        else
            local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            tweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.3, 0, -0.6, 0)}):Play()
        end
    end
end)
