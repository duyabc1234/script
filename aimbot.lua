-- [[ SERVICES ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- [[ BIẾN HỆ THỐNG ]]
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local LockedTarget = nil

-- [[ CẤU HÌNH ]]
local Settings = {
    AimbotEnabled = true,
    TeamCheck = false,
    AliveCheck = true,
    WallCheck = true,
    Fov = 150,
    MaxDistance = 1000,
    TargetPart = "Head",
    -- Cấu hình ESP
    EspEnabled = false,
    EspBox = false,
    EspLine = false,
    EspName = false
}

-- [[ TẠO VÒNG TRÒN FOV ]]
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "Gemini_Script_Gui"
screenGui.ResetOnSpawn = false

local circle = Instance.new("Frame", screenGui)
circle.Size = UDim2.new(0, Settings.Fov * 2, 0, Settings.Fov * 2)
circle.AnchorPoint = Vector2.new(0.5, 0.5)
circle.BackgroundTransparency = 1
Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", circle)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 2

-- [[ HÀM KIỂM TRA TƯỜNG ]]
local function IsVisible(targetPart)
    local char = player.Character
    if not char or not targetPart then return false end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char, camera, targetPart.Parent}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position), params)
    return result == nil
end

-- [[ HÀM TÌM MỤC TIÊU ]]
local function GetBestTarget()
    local mouseLoc = UserInputService:GetMouseLocation()
    local closestTarget = nil
    local shortestDist = Settings.Fov

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild(Settings.TargetPart) then
            if Settings.TeamCheck and v.Team == player.Team then continue end
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if Settings.AliveCheck and hum and hum.Health <= 0 then continue end

            local part = v.Character[Settings.TargetPart]
            local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
            
            if onScreen then
                if Settings.WallCheck and not IsVisible(part) then continue end
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mouseLoc).Magnitude
                if dist < shortestDist then
                    closestTarget = v
                    shortestDist = dist
                end
            end
        end
    end
    return closestTarget
end

-- [[ LOGIC AIMBOT & FOV ]]
RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    circle.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
    circle.Visible = Settings.AimbotEnabled

    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and Settings.AimbotEnabled then
        if not LockedTarget or not LockedTarget.Parent or not LockedTarget.Character or not LockedTarget.Character:FindFirstChild(Settings.TargetPart) or (Settings.AliveCheck and LockedTarget.Character.Humanoid.Health <= 0) then
            LockedTarget = GetBestTarget()
        end

        if LockedTarget and LockedTarget.Character and LockedTarget.Character:FindFirstChild(Settings.TargetPart) then
            local targetPart = LockedTarget.Character[Settings.TargetPart]
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
            stroke.Color = Color3.fromRGB(255, 0, 0) -- Đỏ khi đang khóa
        end
    else
        LockedTarget = nil
        stroke.Color = Color3.fromRGB(255, 255, 255) -- Trắng khi chờ
    end
end)

-- [[ HỆ THỐNG ESP ]]
local function CreateESP(p)
    if p == player then return end
    local Box = Drawing.new("Square")
    local Line = Drawing.new("Line")
    local Text = Drawing.new("Text")

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and Settings.EspEnabled then
            local root = p.Character.HumanoidRootPart
            local head = p.Character:FindFirstChild("Head")
            if not head then return end
            
            local pos, onScreen = camera:WorldToViewportPoint(root.Position)
            local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))

            if onScreen then
                local height = math.abs(pos.Y - headPos.Y) * 2
                local width = height / 1.5

                Box.Visible = Settings.EspBox
                Box.Size = Vector2.new(width, height)
                Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                Box.Color = Color3.new(1,0,0)
                Box.Thickness = 1

                Line.Visible = Settings.EspLine
                Line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                Line.To = Vector2.new(pos.X, pos.Y)
                Line.Color = Color3.new(1,0,0)

                Text.Visible = Settings.EspName
                Text.Text = p.Name
                Text.Position = Vector2.new(pos.X, pos.Y - (height/2) - 20)
                Text.Size = 16
                Text.Center = true
                Text.Outline = true
                Text.Color = Color3.new(1,1,1)
            else
                Box.Visible = false; Line.Visible = false; Text.Visible = false
            end
        else
            Box.Visible = false; Line.Visible = false; Text.Visible = false
            if not p.Parent then 
                Box:Remove(); Line:Remove(); Text:Remove(); connection:Disconnect() 
            end
        end
    end)
end

for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- [[ MENU ĐIỀU KHIỂN ]]
local MainFrame = Instance.new("Frame", screenGui)
MainFrame.Size = UDim2.new(0, 180, 0, 220)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Cho phép kéo menu

local function AddButton(text, pos, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.MouseButton1Click:Connect(callback)
    return btn
end

AddButton("Aimbot: ON/OFF", UDim2.new(0.05, 0, 0.1, 0), function() Settings.AimbotEnabled = not Settings.AimbotEnabled end)
AddButton("Toggle ESP", UDim2.new(0.05, 0, 0.3, 0), function() Settings.EspEnabled = not Settings.EspEnabled end)
AddButton("Show Box", UDim2.new(0.05, 0, 0.5, 0), function() Settings.EspBox = not Settings.EspBox end)
AddButton("Show Name", UDim2.new(0.05, 0, 0.7, 0), function() Settings.EspName = not Settings.EspName end)

-- [[ PHÍM TẮT ĐIỀU KHIỂN ]]
UserInputService.InputBegan:Connect(function(input, processed)
    -- Nhấn P để ẩn/hiện Menu
    if input.KeyCode == Enum.KeyCode.P then 
        MainFrame.Visible = not MainFrame.Visible 
    end

    -- Kiểm tra tổ hợp CTRL + ALT
    local isCtrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
    local isAlt = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)

    if isCtrl and isAlt then
        Settings.AimbotEnabled = not Settings.AimbotEnabled
        -- Nháy màu vòng tròn FOV để báo hiệu
        circle.BackgroundColor3 = Settings.AimbotEnabled and Color3.new(0,1,0) or Color3.new(1,0,0)
        circle.BackgroundTransparency = 0.8
        task.wait(0.1)
        circle.BackgroundTransparency = 1
    end
end)

print("Script Loaded! [P] Menu | [Ctrl + Alt] Toggle Aimbot")








-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- BIẾN HỆ THỐNG
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CẤU HÌNH ESP (Mặc định tắt)
local Settings = {
	Enabled = false,
	Box = false,
	Line = false,
	Name = false,
	Color = Color3.fromRGB(255, 0, 0)
}

-- ==========================================
-- 1. TẠO GUI ĐIỀU KHIỂN (MENU)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESPGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 250)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true -- Có thể kéo menu đi chỗ khác
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "ESP MENU"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Parent = MainFrame

-- Hàm tạo Button nhanh
local function CreateToggleButton(name, pos, settingKey)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0.8, 0, 0, 35)
	btn.Position = pos
	btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	btn.Text = name .. ": OFF"
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Parent = MainFrame

	btn.MouseButton1Click:Connect(function()
		Settings[settingKey] = not Settings[settingKey]
		btn.Text = name .. ": " .. (Settings[settingKey] and "ON" or "OFF")
		btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
	end)
end

CreateToggleButton("Master ESP", UDim2.new(0.1, 0, 0.2, 0), "Enabled")
CreateToggleButton("Show Box", UDim2.new(0.1, 0, 0.4, 0), "Box")
CreateToggleButton("Show Line", UDim2.new(0.1, 0, 0.6, 0), "Line")
CreateToggleButton("Show Name", UDim2.new(0.1, 0, 0.8, 0), "Name")

-- ==========================================
-- 2. LOGIC VẼ ESP
-- ==========================================
local function CreateESP(player)
	if player == LocalPlayer then return end

	local Box = Drawing.new("Square")
	local Line = Drawing.new("Line")
	local Text = Drawing.new("Text")

	local function Update()
		local connection
		connection = RunService.RenderStepped:Connect(function()
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and Settings.Enabled then
				local root = player.Character.HumanoidRootPart
				local head = player.Character:FindFirstChild("Head")
				local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
				local headPos, _ = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))

				if onScreen then
					local height = math.abs(pos.Y - headPos.Y) * 2
					local width = height / 1.5

					-- Vẽ Box
					Box.Visible = Settings.Box
					Box.Size = Vector2.new(width, height)
					Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
					Box.Color = Settings.Color
					Box.Thickness = 1
					Box.Filled = false

					-- Vẽ Line
					Line.Visible = Settings.Line
					Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
					Line.To = Vector2.new(pos.X, pos.Y + (height / 2))
					Line.Color = Settings.Color
					Line.Thickness = 1

					-- Vẽ Name
					Text.Visible = Settings.Name
					Text.Text = player.Name
					Text.Size = 18
					Text.Center = true
					Text.Outline = true
					Text.Position = Vector2.new(pos.X, pos.Y - (height / 2) - 20)
					Text.Color = Color3.new(1, 1, 1)
				else
					Box.Visible = false
					Line.Visible = false
					Text.Visible = false
				end
			else
				Box.Visible = false
				Line.Visible = false
				Text.Visible = false
				if not player.Parent then
					Box:Remove()
					Line:Remove()
					Text:Remove()
					connection:Disconnect()
				end
			end
		end)
	end
	coroutine.wrap(Update)()
end

-- Kích hoạt cho người chơi
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

-- Phím tắt ẩn/hiện Menu (Phím Insert hoặc P)
UserInputService.InputBegan:Connect(function(input, chat)
	if chat then return end
	if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.P then
		MainFrame.Visible = not MainFrame.Visible
	end
end)
