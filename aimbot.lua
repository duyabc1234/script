-- [[ HARD LOCK V14 - FINAL OBFUSCATED + NOTIFY ]]
local _0x52 = game; 
local _0x1a = _0x52.GetService;
local _0x4c = _0x1a(_0x52, string.char(80, 108, 97, 121, 101, 114, 115));
local _0x72 = _0x1a(_0x52, string.char(82, 117, 110, 83, 101, 114, 118, 105, 99, 101));
local _0x69 = _0x1a(_0x52, string.char(85, 115, 101, 114, 73, 110, 112, 117, 116, 83, 101, 114, 118, 105, 99, 101));
local _0x56 = _0x1a(_0x52, string.char(86, 105, 114, 116, 117, 97, 108, 73, 110, 112, 117, 116, 77, 97, 110, 97, 103, 101, 114));
local _0x21 = _0x4c.LocalPlayer; 
local _0x88 = workspace.CurrentCamera;

-- [[ CẤU CƠ CHẾ ]]
local _0xL = { _A = false, _S = false, _F = false, _NC = false, _SP = false, _E = true, _FS = 70, _CP = 0.8 }
local _0xV = { 
    _EB = true, _AA = false, _RD = 0.35, _SS = 0.02, _FV = 300, 
    _TP = string.char(72, 101, 97, 100), 
    _TA = string.char(84, 101, 97, 109, 73, 68), 
    _SM = 1 
}
local _0xT, _0xLS, _0xRH, _0xBV, _0xBG = nil, 0, 0, nil, nil;
local _0xESP = {}

-- [[ HÀM HỆ THỐNG ]]
local function _0xPH() 
    if _0xBG then _0xBG:Destroy() _0xBG = nil end 
    if _0xBV then _0xBV:Destroy() _0xBV = nil end
    pcall(function() _0x21.Character.Humanoid.PlatformStand = false end)
end

local function _0xFL()
    local _c = _0x21.Character; local _r = _c and _c:FindFirstChild(string.char(72, 117, 109, 97, 110, 111, 105, 100, 82, 111, 111, 116, 80, 97, 114, 116))
    if _r then 
        _0xPH(); _0xBG = Instance.new(string.char(66, 111, 100, 121, 71, 121, 114, 111), _r)
        _0xBG.P = 9e4; _0xBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9); _0xBG.CFrame = _r.CFrame
        _0xBV = Instance.new(string.char(66, 111, 100, 121, 86, 101, 108, 111, 99, 105, 116, 121), _r)
        _0xBV.Velocity = Vector3.new(0,0,0); _0xBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        _c.Humanoid.PlatformStand = true 
    end
end

local function _0xEE(_p) 
    if _p == _0x21 then return end 
    local _b = Drawing.new(string.char(83, 113, 117, 97, 114, 101)) _b.Thickness = 1; _b.Filled = false
    local _t = Drawing.new(string.char(76, 105, 110, 101)) _t.Thickness = 1
    _0xESP[_p] = {B = _b, T = _t} 
end
for _, v in pairs(_0x4c:GetPlayers()) do _0xEE(v) end
_0x4c.PlayerAdded:Connect(_0xEE)

local function _0xVIS(_p)
    local _c = _0x21.Character; if not _c or not _p then return false end
    local _rp = RaycastParams.new(); _rp.FilterDescendantsInstances = {_c, _0x88, _p.Parent}; _rp.FilterType = Enum.RaycastFilterType.Exclude
    return workspace:Raycast(_0x88.CFrame.Position, _p.Position - _0x88.CFrame.Position, _rp) == nil
end

local function _0xGET()
    local _m = _0x69:GetMouseLocation(); local _root = _0x21.Character and _0x21.Character:FindFirstChild(string.char(72, 117, 109, 97, 110, 111, 105, 100, 82, 111, 111, 116, 80, 97, 114, 116))
    if not _root then return end local _cl, _mp = nil, -1
    local _myt = tostring(_0x21:GetAttribute(_0xV._TA))
    for _, v in pairs(_0x4c:GetPlayers()) do
        if v ~= _0x21 and v.Character and v.Character:FindFirstChild(_0xV._TP) then
            local _tt = tostring(v:GetAttribute(_0xV._TA))
            if not _0xV._AA and _tt == _myt then continue end
            local _h = v.Character:FindFirstChildOfClass(string.char(72, 117, 109, 97, 110, 111, 105, 100))
            if _h and _h.Health > 0 and _0xVIS(v.Character[_0xV._TP]) then
                local _ps, _os = _0x88:WorldToViewportPoint(v.Character[_0xV._TP].Position)
                if _os then
                    local _d = (Vector2.new(_ps.X, _ps.Y) - _m).Magnitude
                    if _d <= _0xV._FV then 
                        local _wd = (v.Character[_0xV._TP].Position - _root.Position).Magnitude
                        local _p = (1/(_d+1))*5000 + (1/(_wd+1))*10000; if _p > _mp then _mp = _p; _cl = v end 
                    end
                end
            end
        end
    end return _cl
end

-- [[ GIAO DIỆN RAYFIELD ]]
local _RY = loadstring(game:HttpGet(string.char(104, 116, 116, 112, 115, 58, 47, 47, 115, 105, 114, 105, 117, 115, 46, 109, 101, 110, 117, 47, 114, 97, 121, 102, 105, 101, 108, 100)))()
local _W = _RY:CreateWindow({Name = "HARD LOCK V14 [HP+TEAM]", LoadingTitle = "System Encrypted", ConfigurationSaving = {Enabled = false}})
local _M = _W:CreateTab("Main"); local _V = _W:CreateTab("Visuals"); local _P = _W:CreateTab("Physic")

-- Hàm hiện thông báo góc màn hình
local function _0xNOTI(_title, _state)
    _RY:Notify({
        Title = _title,
        Content = _state and "Trạng thái: BẬT (ON)" or "Trạng thái: TẮT (OFF)",
        Duration = 2.5,
        Image = 4483362458,
    })
end

_M:CreateToggle({Name = "Hard Lock (F)", CurrentValue = false, Callback = function(v) _0xL._A = v end})
_M:CreateToggle({Name = "Auto Shoot (I)", CurrentValue = false, Callback = function(v) _0xL._S = v end})
_M:CreateToggle({Name = "Aim All (K)", CurrentValue = false, Callback = function(v) _0xV._AA = v; _0xT = nil end})
_P:CreateToggle({Name = "Fly (E)", CurrentValue = false, Callback = function(v) _0xL._F = v; if v then _0xFL() else _0xPH() end end})
_P:CreateToggle({Name = "NoClip (C)", CurrentValue = false, Callback = function(v) _0xL._NC = v end})
_P:CreateToggle({Name = "Speed (V)", CurrentValue = false, Callback = function(v) _0xL._SP = v end})
_V:CreateToggle({Name = "ESP (J)", CurrentValue = true, Callback = function(v) _0xL._E = v end})

-- [[ VÒNG LẶP CHÍNH ]]
_0x72.RenderStepped:Connect(function()
    local _c = _0x21.Character; local _r = _c and _c:FindFirstChild(string.char(72, 117, 109, 97, 110, 111, 105, 100, 82, 111, 111, 116, 80, 97, 114, 116))
    local _myt = tostring(_0x21:GetAttribute(_0xV._TA))

    -- ESP Logic
    for p, d in pairs(_0xESP) do
        if _0xL._E and p.Character and p.Character:FindFirstChild(string.char(72, 117, 109, 97, 110, 111, 105, 100, 82, 111, 111, 116, 80, 97, 114, 116)) and p.Character.Humanoid.Health > 0 then
            local _ps, _os = _0x88:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if _os then
                d.B.Visible = true; d.B.Size = Vector2.new(2000/_ps.Z, 3000/_ps.Z); d.B.Position = Vector2.new(_ps.X - d.B.Size.X/2, _ps.Y - d.B.Size.Y/2)
                d.T.Visible = true; d.T.From = Vector2.new(_0x88.ViewportSize.X/2, _0x88.ViewportSize.Y); d.T.To = Vector2.new(_ps.X, _ps.Y)
                local _tt = tostring(p:GetAttribute(_0xV._TA)); local _col = (_tt == _myt) and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                d.B.Color = _col; d.T.Color = _col
            else d.B.Visible = false; d.T.Visible = false end
        else d.B.Visible = false; d.T.Visible = false end
    end

    -- Aim & Shoot Logic
    if (_0xL._A or _0x69:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) and _0xV._EB then
        if _0xRH == 0 then _0xRH = tick() end
        if _0xT then 
            local _h = _0xT.Character and _0xT.Character:FindFirstChildOfClass(string.char(72, 117, 109, 97, 110, 111, 105, 100))
            if not _h or _h.Health <= 0 or not _0xVIS(_0xT.Character[_0xV._TP]) then _0xT = nil end
        end
        if not _0xT then _0xT = _0xGET() end
        if _0xT and _0xT.Character then
            _0x88.CFrame = _0x88.CFrame:Lerp(CFrame.new(_0x88.CFrame.Position, _0xT.Character[_0xV._TP].Position), _0xV._SM)
            if _0xL._S and (tick()-_0xRH) >= _0xV._RD and (tick()-_0xLS) >= _0xV._SS then
                _0xLS = tick(); _0x56:SendMouseButtonEvent(_0x88.ViewportSize.X/2, _0x88.ViewportSize.Y/2, 0, true, game, 0)
                task.wait(0.01) _0x56:SendMouseButtonEvent(_0x88.ViewportSize.X/2, _0x88.ViewportSize.Y/2, 0, false, game, 0)
            end
        end
    else _0xRH = 0; if not _0xL._A then _0xT = nil end end

    -- Physics (Fly/Speed/NoClip)
    if _0xL._F and _0xBV and _0xBG and _r then
        local _d = Vector3.new(0,0,0)
        if _0x69:IsKeyDown(Enum.KeyCode.W) then _d = _d + _0x88.CFrame.LookVector end
        if _0x69:IsKeyDown(Enum.KeyCode.S) then _d = _d - _0x88.CFrame.LookVector end
        if _0x69:IsKeyDown(Enum.KeyCode.A) then _d = _d - _0x88.CFrame.RightVector end
        if _0x69:IsKeyDown(Enum.KeyCode.D) then _d = _d + _0x88.CFrame.RightVector end
        _0xBV.Velocity = _d.Unit * _0xL._FS; if _d.Magnitude == 0 then _0xBV.Velocity = Vector3.new(0,0,0) end
        _0xBG.CFrame = _0x88.CFrame
    end
    if _0xL._SP and _r and not _0xL._F then _r.CFrame = _r.CFrame + (_c.Humanoid.MoveDirection * _0xL._CP) end
    if _0xL._NC and _c then for _, p in pairs(_c:GetDescendants()) do if p:IsA(string.char(66, 97, 115, 101, 80, 97, 114, 116)) then p.CanCollide = false end end end
end)

-- [[ HOTKEYS SYNC + NOTIFY ]]
_0x69.InputBegan:Connect(function(_i, _p)
    if _p then return end
    local _k = _i.KeyCode
    if _k == Enum.KeyCode.F then 
        _0xL._A = not _0xL._A; _0xNOTI("Auto Lock", _0xL._A)
    elseif _k == Enum.KeyCode.I then 
        _0xL._S = not _0xL._S; _0xNOTI("Auto Shoot", _0xL._S)
    elseif _k == Enum.KeyCode.K then 
        _0xV._AA = not _0xV._AA; _0xT = nil; _0xNOTI("Aim All Mode", _0xV._AA)
    elseif _k == Enum.KeyCode.E then 
        _0xL._F = not _0xL._F; if _0xL._F then _0xFL() else _0xPH() end; _0xNOTI("Fly Mode", _0xL._F)
    elseif _k == Enum.KeyCode.C then 
        _0xL._NC = not _0xL._NC; _0xNOTI("NoClip", _0xL._NC)
    elseif _k == Enum.KeyCode.V then 
        _0xL._SP = not _0xL._SP; _0xNOTI("Speed Power", _0xL._SP)
    elseif _k == Enum.KeyCode.J then 
        _0xL._E = not _0xL._E; _0xNOTI("ESP Visuals", _0xL._E) 
    end
end)
