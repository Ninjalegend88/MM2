--// MM2 Ultimate Suite | Credits: the invisible man
--// Key System & Anti-Cheat Bypass Included

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Anti-Cheat Bypass Layer
local OldNamecall
local OldIndex
local mt = getrawmetatable(game)
setreadonly(mt, false)

OldNamecall = hookfunction(mt.__namecall, newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" then
        return warn("[AC Bypass] Kick intercepted and blocked.")
    end
    return OldNamecall(self, ...)
end))

OldIndex = hookfunction(mt.__index, newcclosure(function(self, key)
    if self == LocalPlayer and key == "Kick" then
        return function() warn("[AC Bypass] Kick function spoofed.") end
    end
    return OldIndex(self, key)
end))

--// Spoof WalkSpeed/JumpPower checks
local OldHumanoidIndex
OldHumanoidIndex = hookfunction(mt.__index, newcclosure(function(self, key)
    if typeof(self) == "Instance" and self:IsA("Humanoid") then
        if key == "WalkSpeed" then return 16 end
        if key == "JumpPower" then return 50 end
    end
    return OldHumanoidIndex(self, key)
end))

--// Rayfield UI Loader
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Key System Window
local KeyWindow = Rayfield:CreateWindow({
    Name = "MM2 Suite | Authentication",
    LoadingTitle = "MM2 Ultimate",
    LoadingSubtitle = "by the invisible man",
    ConfigurationSaving = {
        Enabled = false,
    },
    KeySystem = true,
    KeySettings = {
        Title = "Enter Access Key",
        Subtitle = "Key Required",
        Note = "Contact the invisible man for access",
        FileName = "MM2Key",
        SaveKey = false,
        GrabKeyFromSite = false,
        Key = {"Zkiller"}
    }
})

--// Main Window (loads after key)
local Window = Rayfield:CreateWindow({
    Name = "MM2 Ultimate Suite",
    LoadingTitle = "MM2 Ultimate",
    LoadingSubtitle = "by the invisible man",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MM2Suite",
        FileName = "MM2Config"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false
})

--// Player Info Header (Top Right Avatar + Username)
local PlayerInfoSection = Window:CreateTab("Player Info", 4483345998)
local PlayerInfoParagraph = PlayerInfoSection:CreateParagraph("Welcome", "Loading player data...")

--// Avatar & Username Display
local function UpdatePlayerHeader()
    local userId = LocalPlayer.UserId
    local username = LocalPlayer.Name
    local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"

    PlayerInfoParagraph:Set("Welcome, " .. username, "User ID: " .. userId)

    --// Create ScreenGui for top-right avatar if not exists
    local existingGui = LocalPlayer.PlayerGui:FindFirstChild("MM2AvatarDisplay")
    if existingGui then existingGui:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MM2AvatarDisplay"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 140, 0, 60)
    frame.Position = UDim2.new(1, -150, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(0, 50, 0, 50)
    avatarImage.Position = UDim2.new(0, 5, 0, 5)
    avatarImage.BackgroundTransparency = 1
    avatarImage.Image = avatarUrl
    avatarImage.Parent = frame

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = avatarImage

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 80, 0, 25)
    nameLabel.Position = UDim2.new(0, 60, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = username
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 80, 0, 20)
    statusLabel.Position = UDim2.new(0, 60, 0, 30)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "✓ Authorized"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = frame
end

UpdatePlayerHeader()

--// State Variables
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
local KillAll_Enabled = false
local RevealRoles_Enabled = false
local GrabGun_Enabled = false

local ESP_Objects = {}
local Fly_Connection = nil
local Noclip_Connection = nil
local Aimbot_Connection = nil

--// Utility Functions
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

local function GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function IsPlayerAlive(player)
    local char = GetCharacter(player)
    local hum = GetHumanoid(char)
    return hum and hum.Health > 0
end

--// ESP System
local function CreateESP(player)
    if player == LocalPlayer then return end

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
            objects.Billboard.Enabled = false
        else
            objects.Billboard.Enabled = true
            objects.Billboard.Adornee = head
            objects.HealthLabel.Text = "HP: " .. math.floor(hum.Health)
            objects.NameLabel.TextColor3 = ESP_Color

            --// MM2 Role Colors
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
                objects.NameLabel.Text = player.Name
            end
        end
    end
end

--// Hitbox Expander
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

--// Silent Aim System
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

--// Hook Silent Aim into mouse
local OldMouseHit
local function SetupSilentAim()
    local mouse = LocalPlayer:GetMouse()
    OldMouseHit = hookfunction(getrawmetatable(mouse).__index, newcclosure(function(self, key)
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
        return OldMouseHit(self, key)
    end))
end

--// Fly System
local function ToggleFly()
    if Fly_Enabled then
        local char = GetCharacter(LocalPlayer)
        local root = GetRootPart(char)
        if not root then return end

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "MM2FlyVelocity"
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Parent = root

        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "MM2FlyGyro"
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 10000
        bodyGyro.Parent = root

        Fly_Connection = RunService.RenderStepped:Connect(function()
            if not Fly_Enabled then return end
            local char = GetCharacter(LocalPlayer)
            local root = GetRootPart(char)
            local bv = root and root:FindFirstChild("MM2FlyVelocity")
            local bg = root and root:FindFirstChild("MM2FlyGyro")

            if bv and bg then
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

                bv.Velocity = moveDir
                bg.CFrame = camCF
            end
        end)
    else
        if Fly_Connection then
            Fly_Connection:Disconnect()
            Fly_Connection = nil
        end
        local char = GetCharacter(LocalPlayer)
        local root = GetRootPart(char)
        if root then
            local bv = root:FindFirstChild("MM2FlyVelocity")
            local bg = root:FindFirstChild("MM2FlyGyro")
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
    end
end

--// Noclip System
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
        if Noclip_Connection then
            Noclip_Connection:Disconnect()
            Noclip_Connection = nil
        end
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

--// Speed & Jump Changer
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

--// Aimbot System
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
        if Aimbot_Connection then
            Aimbot_Connection:Disconnect()
            Aimbot_Connection = nil
        end
    end
end

--// Kill All System
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

--// MM2 Grab Gun System
local function GrabGun()
    local gunDrop = Workspace:FindFirstChild("GunDrop")
    if gunDrop and gunDrop:IsA("BasePart") then
        local char = GetCharacter(LocalPlayer)
        local root = GetRootPart(char)
        if root then
            root.CFrame = gunDrop.CFrame + Vector3.new(0, 3, 0)
            wait(0.5)
            --// Simulate pickup
            local touchInterest = gunDrop:FindFirstChild("TouchInterest")
            if touchInterest then
                firetouchinterest(root, gunDrop, 0)
                firetouchinterest(root, gunDrop, 1)
            end
        end
    end
end

--// UI Tabs
local CombatTab = Window:CreateTab("Combat", 4483345998)
local MovementTab = Window:CreateTab("Movement", 4483345998)
local VisualsTab = Window:CreateTab("Visuals", 4483345998)
local MM2Tab = Window:CreateTab("MM2 Specific", 4483345998)
local SettingsTab = Window:CreateTab("Settings", 4483345998)

--// Combat Tab
CombatTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Flag = "SilentAimToggle",
    Callback = function(Value)
        SilentAim_Enabled = Value
        if Value then SetupSilentAim() end
    end,
})

CombatTab:CreateSlider({
    Name = "Silent Aim FOV",
    Range = {50, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 150,
    Flag = "SilentAimFOV",
    Callback = function(Value)
        SilentAim_FOV = Value
    end,
})

CombatTab:CreateDropdown({
    Name = "Silent Aim Target",
    Options = {"Head", "Torso", "HumanoidRootPart", "LeftArm", "RightArm", "LeftLeg", "RightLeg"},
    CurrentOption = "Head",
    Flag = "SilentAimPart",
    Callback = function(Option)
        SilentAim_BodyPart = Option
    end,
})

CombatTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        Aimbot_Enabled = Value
        ToggleAimbot()
    end,
})

CombatTab:CreateDropdown({
    Name = "Aimbot Target",
    Options = {"Head", "Torso", "HumanoidRootPart", "LeftArm", "RightArm", "LeftLeg", "RightLeg"},
    CurrentOption = "Head",
    Flag = "AimbotPart",
    Callback = function(Option)
        Aimbot_BodyPart = Option
    end,
})

CombatTab:CreateSlider({
    Name = "Aimbot Smoothness",
    Range = {0.01, 1},
    Increment = 0.01,
    Suffix = "",
    CurrentValue = 0.15,
    Flag = "AimbotSmooth",
    Callback = function(Value)
        Aimbot_Smoothness = Value
    end,
})

CombatTab:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(Value)
        Hitbox_Enabled = Value
        if Value then
            ExpandHitboxes()
        else
            ResetHitboxes()
        end
    end,
})

CombatTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {2, 20},
    Increment = 0.5,
    Suffix = " studs",
    CurrentValue = 5,
    Flag = "HitboxSize",
    Callback = function(Value)
        Hitbox_Size = Value
        if Hitbox_Enabled then ExpandHitboxes() end
    end,
})

--// Movement Tab
MovementTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        Fly_Enabled = Value
        ToggleFly()
    end,
})

MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 5,
    Suffix = " speed",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        Fly_Speed = Value
    end,
})

MovementTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        Noclip_Enabled = Value
        ToggleNoclip()
    end,
})

MovementTab:CreateToggle({
    Name = "Speed Changer",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(Value)
        SpeedChanger_Enabled = Value
        UpdateSpeedAndJump()
    end,
})

MovementTab:CreateSlider({
    Name = "Speed Value",
    Range = {16, 300},
    Increment = 5,
    Suffix = " walkspeed",
    CurrentValue = 100,
    Flag = "SpeedValue",
    Callback = function(Value)
        SpeedValue = Value
        if SpeedChanger_Enabled then UpdateSpeedAndJump() end
    end,
})

MovementTab:CreateToggle({
    Name = "Jump Power Changer",
    CurrentValue = false,
    Flag = "JumpToggle",
    Callback = function(Value)
        JumpChanger_Enabled = Value
        UpdateSpeedAndJump()
    end,
})

MovementTab:CreateSlider({
    Name = "Jump Power Value",
    Range = {50, 300},
    Increment = 5,
    Suffix = " jumppower",
    CurrentValue = 100,
    Flag = "JumpValue",
    Callback = function(Value)
        JumpValue = Value
        if JumpChanger_Enabled then UpdateSpeedAndJump() end
    end,
})

--// Visuals Tab
VisualsTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        ESP_Enabled = Value
        if Value then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    CreateESP(player)
                end
            end
        else
            for player, _ in pairs(ESP_Objects) do
                RemoveESP(player)
            end
        end
    end,
})

VisualsTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 255, 255),
    Flag = "ESPColor",
    Callback = function(Value)
        ESP_Color = Value
    end,
})

--// MM2 Specific Tab
MM2Tab:CreateToggle({
    Name = "Reveal Roles (Killer/Sheriff/Innocent)",
    CurrentValue = false,
    Flag = "RevealRolesToggle",
    Callback = function(Value)
        RevealRoles_Enabled = Value
    end,
})

MM2Tab:CreateButton({
    Name = "Grab Gun",
    Callback = function()
        GrabGun()
    end,
})

MM2Tab:CreateButton({
    Name = "Kill All",
    Callback = function()
        KillAll()
    end,
})

--// Settings Tab
SettingsTab:CreateParagraph("Credits", "Made by the invisible man\nMM2 Ultimate Suite v1.0")

--// Player Added/Removing
Players.PlayerAdded:Connect(function(player)
    if ESP_Enabled then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

--// Main Loop
RunService.RenderStepped:Connect(function()
    if ESP_Enabled then
        UpdateESP()
    end

    if Hitbox_Enabled then
        ExpandHitboxes()
    end

    if SpeedChanger_Enabled or JumpChanger_Enabled then
        UpdateSpeedAndJump()
    end
end)

--// Character Respawn Handler
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    if Fly_Enabled then
        ToggleFly()
        ToggleFly()
    end
    if Noclip_Enabled then
        ToggleNoclip()
        ToggleNoclip()
    end
    UpdateSpeedAndJump()
end)

Rayfield:LoadConfiguration()
print("[MM2 Suite] Loaded successfully | by the invisible man")
