--// MM2 Ultimate Suite | Credits: the invisible man
--// Key: Zkiller
--// Bulletproof Version - Compatible with all executors

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Safe function wrapper
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[MM2 Suite] SafeCall error: " .. tostring(result))
    end
    return success, result
end

--// Anti-Cheat Bypass (Optional - won't crash if unsupported)
SafeCall(function()
    local mt = getrawmetatable and getrawmetatable(game)
    if not mt then return end
    if setreadonly then setreadonly(mt, false) end

    local oldNamecall = mt.__namecall
    mt.__namecall = function(self, ...)
        local method = getnamecallmethod and getnamecallmethod() or ""
        if method == "Kick" or method == "kick" then
            return warn("[AC] Kick blocked")
        end
        return oldNamecall(self, ...)
    end

    local oldIndex = mt.__index
    mt.__index = function(self, key)
        if self == LocalPlayer and key == "Kick" then
            return function() end
        end
        if typeof(self) == "Instance" and self:IsA("Humanoid") then
            if key == "WalkSpeed" then return 16 end
            if key == "JumpPower" then return 50 end
        end
        return oldIndex(self, key)
    end
end)

--// ===================== UI SYSTEM =====================
--// Try Rayfield first, fall back to custom UI if it fails
local Rayfield = nil
local UseCustomUI = false

SafeCall(function()
    Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not Rayfield then
    warn("[MM2 Suite] Rayfield failed to load, using custom UI fallback")
    UseCustomUI = true
end

--// Custom UI Fallback (always works, no external dependencies)
local CustomUI = {}
local CustomElements = {}

function CustomUI:CreateWindow(config)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MM2CustomUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer.PlayerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.Thickness = 2
    stroke.Parent = mainFrame

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -50, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = config.Name or "MM2 Ultimate Suite"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 16
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        screenGui.Enabled = not screenGui.Enabled
    end)

    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 120, 1, -40)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame

    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -120, 1, -40)
    contentContainer.Position = UDim2.new(0, 120, 0, 40)
    contentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = mainFrame

    local tabList = Instance.new("UIListLayout")
    tabList.Padding = UDim.new(0, 5)
    tabList.Parent = tabContainer

    local tabs = {}
    local activeTab = nil

    local windowObj = {
        MainFrame = mainFrame,
        TabContainer = tabContainer,
        ContentContainer = contentContainer,
        Tabs = tabs
    }

    function windowObj:CreateTab(name, icon)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, -10, 0, 35)
        tabBtn.Position = UDim2.new(0, 5, 0, 0)
        tabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        tabBtn.Text = name
        tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabBtn.TextSize = 13
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.Parent = tabContainer

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = tabBtn

        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.Visible = false
        tabContent.Parent = contentContainer

        local contentList = Instance.new("UIListLayout")
        contentList.Padding = UDim.new(0, 8)
        contentList.Parent = tabContent

        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingLeft = UDim.new(0, 10)
        contentPadding.PaddingRight = UDim.new(0, 10)
        contentPadding.PaddingTop = UDim.new(0, 10)
        contentPadding.PaddingBottom = UDim.new(0, 10)
        contentPadding.Parent = tabContent

        local tabObj = {
            Button = tabBtn,
            Content = tabContent,
            Elements = {}
        }

        tabBtn.MouseButton1Click:Connect(function()
            if activeTab then
                activeTab.Content.Visible = false
                activeTab.Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                activeTab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            activeTab = tabObj
            tabContent.Visible = true
            tabBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        if not activeTab then
            tabBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tabContent.Visible = true
            activeTab = tabObj
        end

        table.insert(tabs, tabObj)
        return tabObj
    end

    return windowObj
end

function CustomUI:CreateToggle(tab, config)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.BorderSizePixel = 0
    frame.Parent = tab.Content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, -40, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 24)
    toggleBtn.Position = UDim2.new(1, -60, 0.5, -12)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleBtn.Text = "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = frame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleBtn

    local enabled = config.CurrentValue or false

    local function updateToggle()
        if enabled then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            toggleBtn.Text = "ON"
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            toggleBtn.Text = "OFF"
        end
        if config.Callback then
            config.Callback(enabled)
        end
    end

    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateToggle()
    end)

    table.insert(tab.Elements, {Type = "Toggle", Value = function() return enabled end, Set = function(v) enabled = v updateToggle() end})
    return tab.Elements[#tab.Elements]
end

function CustomUI:CreateSlider(tab, config)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.BorderSizePixel = 0
    frame.Parent = tab.Content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = config.Name .. ": " .. config.CurrentValue
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -20, 0, 8)
    sliderBar.Position = UDim2.new(0, 10, 0, 35)
    sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = frame

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = sliderBar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill

    local value = config.CurrentValue or config.Range[1]
    local min, max = config.Range[1], config.Range[2]
    local increment = config.Increment or 1

    local function updateSlider(inputX)
        local relativeX = math.clamp((inputX - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        local rawValue = min + (relativeX * (max - min))
        value = math.floor((rawValue / increment) + 0.5) * increment
        value = math.clamp(value, min, max)
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        label.Text = config.Name .. ": " .. value
        if config.Callback then config.Callback(value) end
    end

    local dragging = false
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)

    table.insert(tab.Elements, {Type = "Slider", Value = function() return value end})
    return tab.Elements[#tab.Elements]
end

function CustomUI:CreateButton(tab, config)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = config.Name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = tab.Content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if config.Callback then config.Callback() end
    end)

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end)

    table.insert(tab.Elements, {Type = "Button"})
    return tab.Elements[#tab.Elements]
end

function CustomUI:CreateDropdown(tab, config)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.BorderSizePixel = 0
    frame.Parent = tab.Content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, -40, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(0, 120, 0, 28)
    dropBtn.Position = UDim2.new(1, -130, 0.5, -14)
    dropBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dropBtn.Text = config.CurrentOption or config.Options[1]
    dropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropBtn.TextSize = 12
    dropBtn.Font = Enum.Font.Gotham
    dropBtn.Parent = frame

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropBtn

    local selected = config.CurrentOption or config.Options[1]

    dropBtn.MouseButton1Click:Connect(function()
        local currentIdx = table.find(config.Options, selected) or 1
        local nextIdx = currentIdx % #config.Options + 1
        selected = config.Options[nextIdx]
        dropBtn.Text = selected
        if config.Callback then config.Callback(selected) end
    end)

    table.insert(tab.Elements, {Type = "Dropdown", Value = function() return selected end})
    return tab.Elements[#tab.Elements]
end

function CustomUI:CreateParagraph(tab, config)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.BorderSizePixel = 0
    frame.Parent = tab.Content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 20)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = config.Title or ""
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local content = Instance.new("TextLabel")
    content.Size = UDim2.new(1, -20, 0, 20)
    content.Position = UDim2.new(0, 10, 0, 25)
    content.BackgroundTransparency = 1
    content.Text = config.Content or ""
    content.TextColor3 = Color3.fromRGB(200, 200, 200)
    content.TextSize = 12
    content.Font = Enum.Font.Gotham
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextWrapped = true
    content.Parent = frame

    table.insert(tab.Elements, {Type = "Paragraph"})
    return tab.Elements[#tab.Elements]
end

--// ===================== STATE VARIABLES =====================
local ESP_Enabled = false
local ESP_Color = Color3.fromRGB(255, 255, 255)
local Hitbox_Enabled = false
local Hitbox_Size = 5
local SilentAim_Enabled = false
local SilentAim_FOV = 150
local SilentAim_BodyPart = "Head"
local Fly_Enabled = false
local Fly_Speed = 50
local Noclip_Enabled = false
local SpeedChanger_Enabled = false
local SpeedValue = 100
local JumpChanger_Enabled = false
local JumpValue = 100
local Aimbot_Enabled = false
local Aimbot_BodyPart = "Head"
local Aimbot_Smoothness = 0.15
local RevealRoles_Enabled = false

local ESP_Objects = {}
local Fly_Connection = nil
local Noclip_Connection = nil
local Aimbot_Connection = nil

--// ===================== UTILITY =====================
local function GetCharacter(player)
    return player and player.Character
end

local function GetHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart(character)
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
end

local function GetHead(character)
    return character and character:FindFirstChild("Head")
end

local function IsPlayerAlive(player)
    local char = GetCharacter(player)
    local hum = GetHumanoid(char)
    return hum and hum.Health > 0
end

--// ===================== PLAYER OVERLAY =====================
local function CreatePlayerOverlay()
    local existing = LocalPlayer.PlayerGui:FindFirstChild("MM2PlayerOverlay")
    if existing then existing:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MM2PlayerOverlay"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = LocalPlayer.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 160, 0, 65)
    frame.Position = UDim2.new(1, -170, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 100)
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 50, 0, 50)
    avatar.Position = UDim2.new(0, 8, 0, 7)
    avatar.BackgroundTransparency = 1
    avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"
    avatar.Parent = frame

    local avCorner = Instance.new("UICorner")
    avCorner.CornerRadius = UDim.new(1, 0)
    avCorner.Parent = avatar

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 90, 0, 22)
    nameLabel.Position = UDim2.new(0, 65, 0, 8)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = LocalPlayer.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 15
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = frame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 90, 0, 18)
    statusLabel.Position = UDim2.new(0, 65, 0, 32)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "✓ Authorized"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = frame
end

CreatePlayerOverlay()

--// ===================== ESP SYSTEM =====================
local function CreateESP(player)
    if player == LocalPlayer then return end
    if ESP_Objects[player] then return end

    local char = GetCharacter(player)
    if not char then return end

    local head = GetHead(char)
    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MM2_ESP"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = ESP_Color
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboard

    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "Health"
    healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
    healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = "HP: 100"
    healthLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    healthLabel.TextStrokeTransparency = 0.5
    healthLabel.TextSize = 12
    healthLabel.Font = Enum.Font.Gotham
    healthLabel.Parent = billboard

    ESP_Objects[player] = {Billboard = billboard, NameLabel = nameLabel, HealthLabel = healthLabel}
end

local function RemoveESP(player)
    if ESP_Objects[player] then
        if ESP_Objects[player].Billboard then
            ESP_Objects[player].Billboard:Destroy()
        end
        ESP_Objects[player] = nil
    end
end

local function UpdateESP()
    for player, objects in pairs(ESP_Objects) do
        local char = GetCharacter(player)
        local hum = GetHumanoid(char)
        local head = GetHead(char)

        if not char or not hum or not head or hum.Health <= 0 then
            if objects.Billboard then objects.Billboard.Enabled = false end
        else
            if objects.Billboard then
                objects.Billboard.Enabled = true
                objects.Billboard.Adornee = head
                objects.HealthLabel.Text = "HP: " .. math.floor(hum.Health)

                if RevealRoles_Enabled then
                    local backpack = player:FindFirstChild("Backpack")
                    local hasKnife = backpack and (backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife"))
                    local hasGun = backpack and (backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun"))

                    if hasKnife then
                        objects.NameLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                        objects.NameLabel.Text = player.Name .. " [KILLER]"
                    elseif hasGun then
                        objects.NameLabel.TextColor3 = Color3.fromRGB(0, 100, 255)
                        objects.NameLabel.Text = player.Name .. " [SHERIFF]"
                    else
                        objects.NameLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                        objects.NameLabel.Text = player.Name .. " [INNOCENT]"
                    end
                else
                    objects.NameLabel.TextColor3 = ESP_Color
                    objects.NameLabel.Text = player.Name
                end
            end
        end
    end
end

--// ===================== HITBOX EXPANDER =====================
local function ExpandHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = GetCharacter(player)
            if char then
                local head = char:FindFirstChild("Head")
                if head and head:IsA("BasePart") then
                    head.Size = Vector3.new(Hitbox_Size, Hitbox_Size, Hitbox_Size)
                    head.Transparency = 0.7
                    head.Material = Enum.Material.Neon
                    head.Color = Color3.fromRGB(255, 0, 0)
                    head.CanCollide = false
                end
            end
        end
    end
end

local function ResetHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = GetCharacter(player)
            if char then
                local head = char:FindFirstChild("Head")
                if head and head:IsA("BasePart") then
                    head.Size = Vector3.new(2, 1, 1)
                    head.Transparency = 0
                    head.Material = Enum.Material.Plastic
                    head.Color = Color3.fromRGB(255, 255, 255)
                end
            end
        end
    end
end

--// ===================== SILENT AIM =====================
local function GetClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = SilentAim_FOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsPlayerAlive(player) then
            local char = GetCharacter(player)
            local targetPart = char and char:FindFirstChild(SilentAim_BodyPart)
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

--// ===================== FLY SYSTEM =====================
local function ToggleFly()
    if Fly_Enabled then
        local char = GetCharacter(LocalPlayer)
        local root = GetRootPart(char)
        if not root then return end

        local bv = Instance.new("BodyVelocity")
        bv.Name = "MM2FlyVel"
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = root

        local bg = Instance.new("BodyGyro")
        bg.Name = "MM2FlyGyro"
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.P = 10000
        bg.Parent = root

        Fly_Connection = RunService.RenderStepped:Connect(function()
            if not Fly_Enabled then return end
            local char2 = GetCharacter(LocalPlayer)
            local root2 = GetRootPart(char2)
            if not root2 then return end

            local bv2 = root2:FindFirstChild("MM2FlyVel")
            local bg2 = root2:FindFirstChild("MM2FlyGyro")
            if not bv2 or not bg2 then return end

            local camCF = Camera.CFrame
            local moveDir = Vector3.new(0, 0, 0)

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * Fly_Speed
            end

            bv2.Velocity = moveDir
            bg2.CFrame = camCF
        end)
    else
        if Fly_Connection then Fly_Connection:Disconnect() Fly_Connection = nil end
        local char = GetCharacter(LocalPlayer)
        local root = GetRootPart(char)
        if root then
            local bv = root:FindFirstChild("MM2FlyVel")
            local bg = root:FindFirstChild("MM2FlyGyro")
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
    end
end

--// ===================== NOCLIP =====================
local function ToggleNoclip()
    if Noclip_Enabled then
        Noclip_Connection = RunService.Stepped:Connect(function()
            if not Noclip_Enabled then return end
            local char = GetCharacter(LocalPlayer)
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if Noclip_Connection then Noclip_Connection:Disconnect() Noclip_Connection = nil end
        local char = GetCharacter(LocalPlayer)
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

--// ===================== SPEED & JUMP =====================
local function UpdateSpeedAndJump()
    local char = GetCharacter(LocalPlayer)
    local hum = GetHumanoid(char)
    if hum then
        if SpeedChanger_Enabled then
            hum.WalkSpeed = SpeedValue
        else
            hum.WalkSpeed = 16
        end
        if JumpChanger_Enabled then
            hum.JumpPower = JumpValue
        else
            hum.JumpPower = 50
        end
    end
end

--// ===================== AIMBOT =====================
local function GetClosestPlayerToCenter()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsPlayerAlive(player) then
            local char = GetCharacter(player)
            local targetPart = char and char:FindFirstChild(Aimbot_BodyPart)
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

local function ToggleAimbot()
    if Aimbot_Enabled then
        Aimbot_Connection = RunService.RenderStepped:Connect(function()
            if not Aimbot_Enabled then return end
            local target = GetClosestPlayerToCenter()
            if target then
                local char = GetCharacter(target)
                local part = char and char:FindFirstChild(Aimbot_BodyPart)
                if part then
                    local targetPos = part.Position + (part.Velocity * 0.05)
                    local camCF = Camera.CFrame
                    local smoothCF = camCF:Lerp(CFrame.new(camCF.Position, targetPos), Aimbot_Smoothness)
                    Camera.CFrame = smoothCF
                end
            end
        end)
    else
        if Aimbot_Connection then Aimbot_Connection:Disconnect() Aimbot_Connection = nil end
    end
end

--// ===================== KILL ALL =====================
local function KillAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = GetCharacter(player)
            local hum = GetHumanoid(char)
            if hum then
                hum.Health = 0
            end
        end
    end
end

--// ===================== GRAB GUN =====================
local function GrabGun()
    local gunDrop = Workspace:FindFirstChild("GunDrop")
    if gunDrop and gunDrop:IsA("BasePart") then
        local char = GetCharacter(LocalPlayer)
        local root = GetRootPart(char)
        if root then
            root.CFrame = gunDrop.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.5)
            local touchInterest = gunDrop:FindFirstChild("TouchInterest")
            if touchInterest and firetouchinterest then
                firetouchinterest(root, gunDrop, 0)
                firetouchinterest(root, gunDrop, 1)
            end
        end
    end
end

--// ===================== UI BUILDER =====================
local WindowObj = nil

if Rayfield and not UseCustomUI then
    --// Use Rayfield
    WindowObj = Rayfield:CreateWindow({
        Name = "MM2 Ultimate Suite",
        LoadingTitle = "MM2 Ultimate",
        LoadingSubtitle = "by the invisible man",
        ConfigurationSaving = {Enabled = true, FolderName = "MM2Suite", FileName = "MM2Config"},
        KeySystem = true,
        KeySettings = {
            Title = "Authentication Required",
            Subtitle = "Enter your access key",
            Note = "So uhm soon ill make a discord so yall can ask for things added and report bugs all made in 30 minutes btw",
            FileName = "MM2Key",
            SaveKey = false,
            GrabKeyFromSite = false,
            Key = {"Zkiller"}
        }
    })
else
    --// Use Custom UI Fallback
    WindowObj = CustomUI:CreateWindow({Name = "MM2 Ultimate Suite"})
    UseCustomUI = true
end

--// Helper to create UI elements based on which system is active
local function CreateToggle(tab, config)
    if UseCustomUI then
        return CustomUI:CreateToggle(tab, config)
    else
        return tab:CreateToggle(config)
    end
end

local function CreateSlider(tab, config)
    if UseCustomUI then
        return CustomUI:CreateSlider(tab, config)
    else
        return tab:CreateSlider(config)
    end
end

local function CreateButton(tab, config)
    if UseCustomUI then
        return CustomUI:CreateButton(tab, config)
    else
        return tab:CreateButton(config)
    end
end

local function CreateDropdown(tab, config)
    if UseCustomUI then
        return CustomUI:CreateDropdown(tab, config)
    else
        return tab:CreateDropdown(config)
    end
end

local function CreateParagraph(tab, config)
    if UseCustomUI then
        return CustomUI:CreateParagraph(tab, config)
    else
        return tab:CreateParagraph(config)
    end
end

--// ===================== TABS =====================
local CombatTab = WindowObj:CreateTab("Combat", 4483345998)
local MovementTab = WindowObj:CreateTab("Movement", 4483345998)
local VisualsTab = WindowObj:CreateTab("Visuals", 4483345998)
local MM2Tab = WindowObj:CreateTab("MM2 Specific", 4483345998)
local SettingsTab = WindowObj:CreateTab("Settings", 4483345998)

--// Combat Tab
CreateToggle(CombatTab, {
    Name = "Silent Aim",
    CurrentValue = false,
    Flag = "SilentAim",
    Callback = function(Value) SilentAim_Enabled = Value end
})

CreateSlider(CombatTab, {
    Name = "Silent Aim FOV",
    Range = {50, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 150,
    Flag = "SilentAimFOV",
    Callback = function(Value) SilentAim_FOV = Value end
})

CreateDropdown(CombatTab, {
    Name = "Silent Aim Target",
    Options = {"Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg"},
    CurrentOption = "Head",
    Flag = "SilentAimPart",
    Callback = function(Option) SilentAim_BodyPart = Option end
})

CreateToggle(CombatTab, {
    Name = "Aimbot",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(Value)
        Aimbot_Enabled = Value
        ToggleAimbot()
    end
})

CreateDropdown(CombatTab, {
    Name = "Aimbot Target",
    Options = {"Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg"},
    CurrentOption = "Head",
    Flag = "AimbotPart",
    Callback = function(Option) Aimbot_BodyPart = Option end
})

CreateSlider(CombatTab, {
    Name = "Aimbot Smoothness",
    Range = {0.01, 1},
    Increment = 0.01,
    Suffix = "",
    CurrentValue = 0.15,
    Flag = "AimbotSmooth",
    Callback = function(Value) Aimbot_Smoothness = Value end
})

CreateToggle(CombatTab, {
    Name = "Hitbox Expander",
    CurrentValue = false,
    Flag = "Hitbox",
    Callback = function(Value)
        Hitbox_Enabled = Value
        if Value then ExpandHitboxes() else ResetHitboxes() end
    end
})

CreateSlider(CombatTab, {
    Name = "Hitbox Size",
    Range = {2, 20},
    Increment = 0.5,
    Suffix = " studs",
    CurrentValue = 5,
    Flag = "HitboxSize",
    Callback = function(Value)
        Hitbox_Size = Value
        if Hitbox_Enabled then ExpandHitboxes() end
    end
})

--// Movement Tab
CreateToggle(MovementTab, {
    Name = "Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        Fly_Enabled = Value
        ToggleFly()
    end
})

CreateSlider(MovementTab, {
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value) Fly_Speed = Value end
})

CreateToggle(MovementTab, {
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Value)
        Noclip_Enabled = Value
        ToggleNoclip()
    end
})

CreateToggle(MovementTab, {
    Name = "Speed Changer",
    CurrentValue = false,
    Flag = "Speed",
    Callback = function(Value)
        SpeedChanger_Enabled = Value
        UpdateSpeedAndJump()
    end
})

CreateSlider(MovementTab, {
    Name = "Speed Value",
    Range = {16, 300},
    Increment = 5,
    Suffix = "",
    CurrentValue = 100,
    Flag = "SpeedValue",
    Callback = function(Value)
        SpeedValue = Value
        if SpeedChanger_Enabled then UpdateSpeedAndJump() end
    end
})

CreateToggle(MovementTab, {
    Name = "Jump Power Changer",
    CurrentValue = false,
    Flag = "Jump",
    Callback = function(Value)
        JumpChanger_Enabled = Value
        UpdateSpeedAndJump()
    end
})

CreateSlider(MovementTab, {
    Name = "Jump Power Value",
    Range = {50, 300},
    Increment = 5,
    Suffix = "",
    CurrentValue = 100,
    Flag = "JumpValue",
    Callback = function(Value)
        JumpValue = Value
        if JumpChanger_Enabled then UpdateSpeedAndJump() end
    end
})

--// Visuals Tab
CreateToggle(VisualsTab, {
    Name = "ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        ESP_Enabled = Value
        if Value then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then CreateESP(player) end
            end
        else
            for player, _ in pairs(ESP_Objects) do RemoveESP(player) end
        end
    end
})

--// MM2 Specific Tab
CreateToggle(MM2Tab, {
    Name = "Reveal Roles (Killer/Sheriff/Innocent)",
    CurrentValue = false,
    Flag = "RevealRoles",
    Callback = function(Value) RevealRoles_Enabled = Value end
})

CreateButton(MM2Tab, {
    Name = "Grab Gun",
    Callback = function() GrabGun() end
})

CreateButton(MM2Tab, {
    Name = "Kill All",
    Callback = function() KillAll() end
})

--// Settings Tab
CreateParagraph(SettingsTab, {
    Title = "Credits",
    Content = "MM2 Ultimate Suite v1.0\nMade by the invisible man"
})

--// ===================== EVENTS & LOOPS =====================
Players.PlayerAdded:Connect(function(player)
    if ESP_Enabled then CreateESP(player) end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

RunService.RenderStepped:Connect(function()
    if ESP_Enabled then UpdateESP() end
    if Hitbox_Enabled then ExpandHitboxes() end
    if SpeedChanger_Enabled or JumpChanger_Enabled then UpdateSpeedAndJump() end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Fly_Enabled then ToggleFly() ToggleFly() end
    if Noclip_Enabled then ToggleNoclip() ToggleNoclip() end
    UpdateSpeedAndJump()
end)

--// Silent Aim Hook
SafeCall(function()
    local mouse = LocalPlayer:GetMouse()
    local mt2 = getrawmetatable and getrawmetatable(mouse)
    if not mt2 then return end
    if setreadonly then setreadonly(mt2, false) end

    local oldMouseIndex = mt2.__index
    mt2.__index = function(self, key)
        if key == "Hit" and SilentAim_Enabled then
            local target = GetClosestPlayerToMouse()
            if target then
                local char = GetCharacter(target)
                local part = char and char:FindFirstChild(SilentAim_BodyPart)
                if part then
                    return CFrame.new(part.Position + (part.Velocity * 0.05))
                end
            end
        end
        return oldMouseIndex(self, key)
    end
end)

if Rayfield and not UseCustomUI then
    Rayfield:LoadConfiguration()
end

print("[MM2 Suite] Loaded successfully | by the invisible man")
