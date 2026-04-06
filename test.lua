--[[
    AUTHOR: hnhtlong.10th3
    LOGIC: Universal Silent Aim (Averiias Improved)
    KEY: hnhtlong
    UI STYLE: Minimalist Centered Rectangle
]]--

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local Key = "hnhtlong"

-- // --- GUI NHẬP KEY (NHỎ GỌN & GIỮA MÀN HÌNH) ---
local KeyWindow = Library:CreateWindow({
    Title = 'hnhtlong.10th3 | Auth',
    Center = true, 
    AutoShow = true,
    Resizable = false,
    MenuFadeTime = 0.2
})

local KeyTab = KeyWindow:AddTab('Verification')
local KeyGroup = KeyTab:AddLeftGroupbox('Access Required')

-- Xóa phần gợi ý Key (Placeholder trống)
KeyGroup:AddInput('KeyInput', {
    Default = '',
    Text = 'Access Key',
    Placeholder = '...', 
})

KeyGroup:AddButton('Login', function()
    if Library.Options.KeyInput.Value == Key then
        Library:Notify("Access Granted! Loading Logic...", 2)
        KeyWindow:Unload() -- Xóa bảng key ngay lập tức
        task.wait(0.1)
        StartUniversalSilentAim() -- Gọi hàm chạy logic chính
    else
        Library:Notify("Invalid Key! Please check again.", 3)
    end
end)

-- Thông tin cá nhân
local InfoGroup = KeyTab:AddRightGroupbox('Information')
InfoGroup:AddLabel("Dev: hnhtlong.10th3")
InfoGroup:AddButton('Copy Contact', function()
    setclipboard("https://konect.gg/hnhtlong")
    Library:Notify("Link copied!", 2)
end)

-- // --- HÀM CHỨA TOÀN BỘ LOGIC CỦA BẠN ---
function StartUniversalSilentAim()
    -- [BIẾN HỆ THỐNG]
    local SilentAimSettings = {
        Enabled = true,
        TeamCheck = false,
        VisibleCheck = false, 
        TargetPart = "HumanoidRootPart",
        SilentAimMethod = "Raycast",
        FOVRadius = 130,
        FOVVisible = false,
        ShowSilentAimTarget = false, 
        MouseHitPrediction = false,
        MouseHitPredictionAmount = 0.165,
        HitChance = 100
    }

    local Camera = workspace.CurrentCamera
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()

    -- [HÀM HỖ TRỢ LOGIC]
    local function getMousePosition() return UserInputService:GetMouseLocation() end

    local function IsPlayerVisible(Player)
        local Character = Player.Character
        if not Character or not LocalPlayer.Character then return end 
        local PlayerRoot = Character:FindFirstChild(SilentAimSettings.TargetPart) or Character:FindFirstChild("HumanoidRootPart")
        if not PlayerRoot then return end 
        local ObscuringObjects = #Camera:GetPartsObscuringTarget({PlayerRoot.Position}, {LocalPlayer.Character, Character})
        return ObscuringObjects == 0
    end

    local function getClosestPlayer()
        local Closest, DistanceToMouse = nil, math.huge
        for _, Player in next, Players:GetPlayers() do
            if Player == LocalPlayer then continue end
            if SilentAimSettings.TeamCheck and Player.Team == LocalPlayer.Team then continue end
            if not Player.Character or not Player.Character:FindFirstChild("Humanoid") or Player.Character.Humanoid.Health <= 0 then continue end
            if SilentAimSettings.VisibleCheck and not IsPlayerVisible(Player) then continue end

            local Root = Player.Character:FindFirstChild("HumanoidRootPart")
            if not Root then continue end
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            if not OnScreen then continue end

            local Distance = (getMousePosition() - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
            if Distance <= SilentAimSettings.FOVRadius and Distance < DistanceToMouse then
                Closest = Player.Character:FindFirstChild(SilentAimSettings.TargetPart) or Root
                DistanceToMouse = Distance
            end
        end
        return Closest
    end

    -- [GUI CHÍNH]
    local Window = Library:CreateWindow({Title = 'hnhtlong.10th3 | Universal Silent Aim', Center = true, AutoShow = true})
    local GeneralTab = Window:AddTab("General")
    
    local MainGroup = GeneralTab:AddLeftGroupbox("Main Logic")
    MainGroup:AddToggle("aim_Enabled", {Text = "Enabled", Default = true}):AddKeyPicker("aim_Key", {Default = "RightAlt", SyncToggleState = true, Mode = "Toggle", Text = "Silent Aim"})
    MainGroup:AddToggle("TeamCheck", {Text = "Team Check"}):OnChanged(function() SilentAimSettings.TeamCheck = Library.Toggles.TeamCheck.Value end)
    MainGroup:AddToggle("VisibleCheck", {Text = "Visible Check"}):OnChanged(function() SilentAimSettings.VisibleCheck = Library.Toggles.VisibleCheck.Value end)
    MainGroup:AddDropdown("TargetPart", {Text = "Target Part", Default = "HumanoidRootPart", Values = {"Head", "HumanoidRootPart"}}):OnChanged(function() SilentAimSettings.TargetPart = Library.Options.TargetPart.Value end)
    MainGroup:AddSlider('HitChance', {Text = 'Hit Chance', Default = 100, Min = 0, Max = 100, Rounding = 0}):OnChanged(function() SilentAimSettings.HitChance = Library.Options.HitChance.Value end)

    local VisualsGroup = GeneralTab:AddRightGroupbox("Visuals")
    VisualsGroup:AddToggle("Visible", {Text = "Show FOV"}):AddColorPicker("Color", {Default = Color3.fromRGB(54, 57, 241)}):OnChanged(function() SilentAimSettings.FOVVisible = Library.Toggles.Visible.Value end)
    VisualsGroup:AddSlider("Radius", {Text = "FOV Radius", Min = 0, Max = 500, Default = 130}):OnChanged(function() SilentAimSettings.FOVRadius = Library.Options.Radius.Value end)

    -- [RENDER LOOP & HOOKS]
    local fov_circle = Drawing.new("Circle")
    fov_circle.Thickness = 1
    fov_circle.NumSides = 100
    fov_circle.Radius = 130
    fov_circle.Color = Color3.fromRGB(54, 57, 241)

    RunService.RenderStepped:Connect(function()
        fov_circle.Visible = SilentAimSettings.FOVVisible
        if fov_circle.Visible then
            fov_circle.Position = getMousePosition()
            fov_circle.Radius = SilentAimSettings.FOVRadius
            fov_circle.Color = Library.Options.Color.Value
        end
    end)

    -- Hooking Metamethods
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
        local Method = getnamecallmethod()
        local Args = {...}
        if not checkcaller() and Library.Toggles.aim_Enabled.Value then
            if Method == "Raycast" then
                local HitPart = getClosestPlayer()
                if HitPart and (math.random(0, 100) <= SilentAimSettings.HitChance) then
                    Args[3] = (HitPart.Position - Args[2]).Unit * 1000
                    return oldNamecall(unpack(Args))
                end
            end
        end
        return oldNamecall(...)
    end))
    
    Library:Notify("hnhtlong.10th3: Logic Fully Injected!")
end

-- Watermark
Library:SetWatermark('hnhtlong.10th3 | Private')
