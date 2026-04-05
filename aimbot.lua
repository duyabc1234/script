-- [[ SERVICES ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

-- [[ BIẾN HỆ THỐNG ]]
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local LastShootTime = 0 
local RightClickHoldTime = 0 
local LockedTarget = nil 

-- BIẾN TÍNH NĂNG MỚI
local AutoAimEnabled = false 
local AutoShootEnabled = false 
local InstantShoot = false -- Biến mới: Bắn ngay lập tức

-- Biến tính năng bổ sung
local Flying = false
local SpeedEnabled = false
local NoClip = false
local EspEnabled = true
local BV, BG 
local FlySpeed = 70
local CFrameSpeedPower = 0.8

-- Cấu hình
local Settings = {
    AimbotEnabled = true,
    AimAll = false,
    AimReadyDelay = 0.35,
    ShootSpeed = 0.02,
    Fov = 300, 
    TargetPart = "Head",
    TeamAttribute = "TeamID",
    GuiVisible = true,
    Smoothing = 1 
}

-- ==========================================
-- [[ HỆ THỐNG VẬT LÝ & HỒI SINH ]]
-- ==========================================
local function CleanPhysics()
    if BG then BG:Destroy(); BG = nil end
    if BV then BV:Destroy(); BV = nil end
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character.Humanoid.PlatformStand = false
    end
end

local function EnableFly()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if root and hum then
        CleanPhysics()
        BG = Instance.new("BodyGyro", root)
        BG.P = 9e4; BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9); BG.CFrame = root.CFrame
        BV = Instance.new("BodyVelocity", root)
        BV.Velocity = Vector3.new(0,0,0); BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        hum.PlatformStand = true
    end
end

player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if Flying then EnableFly() end
    local hum = char:WaitForChild("Humanoid")
    hum.Died:Connect(function() CleanPhysics() end)
end)

-- ==========================================
-- [[ HỆ THỐNG ESP ]]
-- ==========================================
local ESP_Table = {}
local function CreateESP(v)
    if v == player then return end
    local Box = Drawing.new("Square")
    Box.Thickness = 1; Box.Filled = false
    local Tracer = Drawing.new("Line")
    Tracer.Thickness = 1
    ESP_Table[v] = {Box = Box, Tracer = Tracer}
end
for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(v)
    if ESP_Table[v] then ESP_Table[v].Box:Remove(); ESP_Table[v].Tracer:Remove(); ESP_Table[v] = nil end
end)

-- ==========================================
-- [[ GIAO DIỆN (GUI) ]]
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HardLock_V14_Final"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 320)
MainFrame.Position = UDim2.new(0.8, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true; MainFrame.Draggable = true 
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35); Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Title.TextColor3 = Color3.new(1,1,1); Title.Text = "HARD LOCK V14 MOD"; Title.Font = Enum.Font.GothamBold

local InfoLabel = Instance.new("TextLabel", MainFrame)
InfoLabel.Size = UDim2.new(1, 0, 0, 270); InfoLabel.Position = UDim2.new(0, 0, 0, 40)
InfoLabel.BackgroundTransparency = 1; InfoLabel.TextColor3 = Color3.new(0.8,0.8,0.8)
InfoLabel.Font = Enum.Font.Gotham; InfoLabel.TextSize = 11; InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

local function UpdateGUI()
    MainFrame.Visible = Settings.GuiVisible
    InfoLabel.Text = string.format([[
  [F] Hard Lock: %s
  [I] Auto Shoot: %s
  [L] Mode: %s
  [K] Target: %s
  [U] Aimbot: %s
  [J] ESP: %s
  [E] Fly: %s (%d)
  [C] NoClip: %s
  [V] Speed: %s
  [P] Hide Menu
  ---
  HP Check: ON
  Target: %s]], 
    AutoAimEnabled and "ON" or "OFF", 
    AutoShootEnabled and "ON" or "OFF",
    InstantShoot and "INSTANT" or "DELAY (0.3s)",
    Settings.AimAll and "ALL" or "TEAM",
    Settings.AimbotEnabled and "ON" or "OFF",
    EspEnabled and "ON" or "OFF",
    Flying and "ON" or "OFF", FlySpeed,
    NoClip and "ON" or "OFF", SpeedEnabled and "ON" or "OFF",
    LockedTarget and LockedTarget.Name or "None")
end

-- ==========================================
-- [[ LOGIC TÌM MỤC TIÊU ]]
-- ==========================================
local function IsVisible(targetPart)
    local char = player.Character
    if not char or not targetPart then return false end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char, camera, targetPart.Parent}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local res = workspace:Raycast(camera.CFrame.Position, targetPart.Position - camera.CFrame.Position, params)
    return res == nil
end

local function GetBestTarget()
    local mouseLoc = UserInputService:GetMouseLocation()
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local closest, maxP = nil, -1 
    local myTeam = tostring(player:GetAttribute(Settings.TeamAttribute))

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild(Settings.TargetPart) then
            local targetTeam = tostring(v:GetAttribute(Settings.TeamAttribute))
            if not Settings.AimAll and targetTeam == myTeam then continue end
            
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            
            local part = v.Character[Settings.TargetPart]
            if IsVisible(part) then
                local pos, onS = camera:WorldToViewportPoint(part.Position)
                if onS then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
                    if mouseDist <= Settings.Fov then
                        local worldDist = (part.Position - myRoot.Position).Magnitude
                        local p = (1 / (mouseDist + 1)) * 5000 + (1 / (worldDist + 1)) * 10000 
                        if p > maxP then maxP = p; closest = v end
                    end
                end
            end
        end
    end
    return closest
end

-- ==========================================
-- [[ VÒNG LẶP CHÍNH ]]
-- ==========================================
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    -- ESP
    local myTeam = tostring(player:GetAttribute(Settings.TeamAttribute))
    for p, draw in pairs(ESP_Table) do
        local tChar = p.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
        if EspEnabled and tRoot and tHum and tHum.Health > 0 then
            local pos, visible = camera:WorldToViewportPoint(tRoot.Position)
            if visible then
                draw.Box.Visible = true; draw.Box.Size = Vector2.new(2000 / pos.Z, 3000 / pos.Z)
                draw.Box.Position = Vector2.new(pos.X - draw.Box.Size.X / 2, pos.Y - draw.Box.Size.Y / 2)
                draw.Tracer.Visible = true; draw.Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y); draw.Tracer.To = Vector2.new(pos.X, pos.Y)
                local targetTeam = tostring(p:GetAttribute(Settings.TeamAttribute))
                local color = (targetTeam == myTeam) and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                draw.Box.Color = color; draw.Tracer.Color = color
            else draw.Box.Visible = false; draw.Tracer.Visible = false end
        else draw.Box.Visible = false; draw.Tracer.Visible = false end
    end

    -- AIMBOT & AUTO SHOOT
    local IsAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or AutoAimEnabled
    
    if IsAiming and Settings.AimbotEnabled then
        if RightClickHoldTime == 0 then RightClickHoldTime = tick() end
        
        if LockedTarget then
            local tHum = LockedTarget.Character and LockedTarget.Character:FindFirstChildOfClass("Humanoid")
            if not tHum or tHum.Health <= 0 or not IsVisible(LockedTarget.Character[Settings.TargetPart]) then
                LockedTarget = nil
            end
        end

        if not LockedTarget then LockedTarget = GetBestTarget() end
        
        if LockedTarget and LockedTarget.Character then
            local targetPart = LockedTarget.Character[Settings.TargetPart]
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, targetPart.Position), Settings.Smoothing)
            
            -- LOGIC BẮN TỰ ĐỘNG
            if AutoShootEnabled then
                local canShoot = false
                if InstantShoot then
                    -- Bắn ngay lập tức không chờ
                    canShoot = (tick() - LastShootTime) >= Settings.ShootSpeed
                else
                    -- Bắn có độ trễ 0.3s sau khi nhắm
                    canShoot = (tick() - RightClickHoldTime) >= Settings.AimReadyDelay and (tick() - LastShootTime) >= Settings.ShootSpeed
                end

                if canShoot then
                    LastShootTime = tick()
                    VirtualInputManager:SendMouseButtonEvent(camera.ViewportSize.X/2, camera.ViewportSize.Y/2, 0, true, game, 0)
                    task.wait(0.01)
                    VirtualInputManager:SendMouseButtonEvent(camera.ViewportSize.X/2, camera.ViewportSize.Y/2, 0, false, game, 0)
                end
            end
        end
    else 
        RightClickHoldTime = 0
        if not AutoAimEnabled then LockedTarget = nil end 
    end

    -- FLY & SPEED
    if Flying and BV and BG and root then
        local dir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end
        BV.Velocity = dir.Unit * FlySpeed
        if dir.Magnitude == 0 then BV.Velocity = Vector3.new(0,0,0) end
        BG.CFrame = camera.CFrame
    end
    if SpeedEnabled and root and hum and not Flying and hum.MoveDirection.Magnitude > 0 then
        root.CFrame = root.CFrame + (hum.MoveDirection * CFrameSpeedPower)
    end
    if NoClip and char then
        for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
    end
end)

-- [[ HOTKEYS ]]
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.F then AutoAimEnabled = not AutoAimEnabled; LockedTarget = nil
    elseif key == Enum.KeyCode.I then AutoShootEnabled = not AutoShootEnabled
    elseif key == Enum.KeyCode.L then InstantShoot = not InstantShoot -- Phím L để đổi chế độ bắn
    elseif key == Enum.KeyCode.U then Settings.AimbotEnabled = not Settings.AimbotEnabled
    elseif key == Enum.KeyCode.K then Settings.AimAll = not Settings.AimAll; LockedTarget = nil
    elseif key == Enum.KeyCode.P then Settings.GuiVisible = not Settings.GuiVisible
    elseif key == Enum.KeyCode.J then EspEnabled = not EspEnabled
    elseif key == Enum.KeyCode.E then 
        Flying = not Flying
        if Flying then EnableFly() else CleanPhysics() end
    elseif key == Enum.KeyCode.C then NoClip = not NoClip
    elseif key == Enum.KeyCode.V then SpeedEnabled = not SpeedEnabled
    elseif key == Enum.KeyCode.Plus or key == Enum.KeyCode.Equals then FlySpeed += 10
    elseif key == Enum.KeyCode.Minus then FlySpeed = math.max(10, FlySpeed - 10)
    end
    UpdateGUI()
end)

UpdateGUI()
