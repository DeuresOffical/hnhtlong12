--[[ 
    PROJECT: hnhtlong.10th3 PRIVATE
    FIXED: LOGIN FLOW, UI SCALING, VARIABLE SCOPE
    KEY: hnhtlong
]]--

if not game:IsLoaded() then game.Loaded:Wait() end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local Key = "hnhtlong"

-- // --- HÀM CHỨA TOÀN BỘ LOGIC SILENT AIM (FIXED) ---
function StartMainScript()
    -- Khởi tạo lại biến nội bộ để tránh lỗi nil
    local Toggles = Library.Toggles
    local Options = Library.Options
    
    local SilentAimSettings = {
        Enabled = true,
        TeamCheck = false,
        VisibleCheck = false, 
        TargetPart = "HumanoidRootPart",
        SilentAimMethod = "Raycast",
        FOVRadius = 130,
        FOVVisible = true,
        HitChance = 100
    }

    local Camera = workspace.CurrentCamera
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    -- Visuals (FOV)
    local fov_circle = Drawing.new("Circle")
    fov_circle.Thickness = 1
    fov_circle.NumSides = 100
    fov_circle.Radius = 130
    fov_circle.Visible = false
    fov_circle.Color = Color3.fromRGB(54, 57, 241)

    -- Logic lấy mục tiêu
    local function getClosestPlayer()
        local Closest, DistanceToMouse = nil, math.huge
        for _, Player in next, Players:GetPlayers() do
            if Player == LocalPlayer then continue end
            if Toggles.TeamCheck and Toggles.TeamCheck.Value and Player.Team == LocalPlayer.Team then continue end
            if not Player.Character or not Player.Character:FindFirstChild("Humanoid") or Player.Character.Humanoid.Health <= 0 then continue end
            
            local Root = Player.Character:FindFirstChild("HumanoidRootPart")
            if not Root then continue end
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            if not OnScreen then continue end

            local Distance = (UserInputService:GetMouseLocation() - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
            if Distance <= (Options.Radius and Options.Radius.Value or 130) and Distance < DistanceToMouse then
                Closest = Player.Character:FindFirstChild(Options.TargetPart and Options.TargetPart.Value or "HumanoidRootPart") or Root
                DistanceToMouse = Distance
            end
        end
        return Closest
    end

    -- Tạo Window Menu Chính
    local Window = Library:CreateWindow({ Title = 'hnhtlong.10th3 | Universal Silent Aim', Center = true, AutoShow = true })
    local GeneralTab = Window:AddTab("Main")
    
    local MainGroup = GeneralTab:AddLeftGroupbox("Combat")
    MainGroup:AddToggle("aim_Enabled", {Text = "Silent Aim Active", Default = true}):AddKeyPicker("SA_Key", {Default = "RightAlt", Mode = "Toggle", Text = "Silent Aim"})
    MainGroup:AddToggle("TeamCheck", {Text = "Team Check", Default = false})
    MainGroup:AddToggle("VisibleCheck", {Text = "Wall Check", Default = false})
    MainGroup:AddDropdown("TargetPart", {Text = "Target Part", Default = "HumanoidRootPart", Values = {"Head", "HumanoidRootPart"}})
    MainGroup:AddSlider('HitChance', {Text = 'Hit Chance', Default = 100, Min = 0, Max = 100, Rounding = 0})

    local VisualsGroup = GeneralTab:AddRightGroupbox("Visuals")
    VisualsGroup:AddToggle("Visible", {Text = "Show FOV", Default = true}):AddColorPicker("Color", {Default = Color3.fromRGB(54, 57, 241)})
    VisualsGroup:AddSlider("Radius", {Text = "FOV Radius", Min = 0, Max = 500, Default = 130})

    -- Render Loop
    RunService.RenderStepped:Connect(function()
        if Toggles.Visible and Toggles.Visible.Value then
            fov_circle.Visible = true
            fov_circle.Position = UserInputService:GetMouseLocation()
            fov_circle.Radius = Options.Radius.Value
            fov_circle.Color = Options.Color.Value
        else
            fov_circle.Visible = false
        end
    end)

    -- Hooking Metamethod
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
        local Method = getnamecallmethod()
        local Args = {...}
        if not checkcaller() and Toggles.aim_Enabled and Toggles.aim_Enabled.Value then
            if Method == "Raycast" or Method == "FindPartOnRay" then
                local HitPart = getClosestPlayer()
                if HitPart and (math.random(0, 100) <= Options.HitChance.Value) then
                    if Method == "Raycast" then Args[3] = (HitPart.Position - Args[2]).Unit * 1000
                    else Args[2] = Ray.new(Args[2].Origin, (HitPart.Position - Args[2].Origin).Unit * 1000) end
                    return oldNamecall(unpack(Args))
                end
            end
        end
        return oldNamecall(...)
    end))

    Library:Notify("hnhtlong.10th3: Menu Loaded Successfully!", 3)
end

-- // --- GUI AUTH (FIXED UI) ---
local KeyWindow = Library:CreateWindow({ Title = 'hnhtlong.10th3 | Auth', Center = true, AutoShow = true, Resizable = false })
local KeyTab = KeyWindow:AddTab('Verification')
local KeyGroup = KeyTab:AddLeftGroupbox('Access Required')

KeyGroup:AddInput('KeyInput', { Default = '', Text = 'Access Key', Placeholder = '...' })

KeyGroup:AddButton('Login', function()
    -- Sử dụng trực tiếp từ Library.Options để tránh lỗi nil
    if Library.Options.KeyInput.Value == Key then
        Library:Notify("Key Correct!", 2)
        KeyWindow:Unload()
        task.wait(0.2)
        StartMainScript() -- Kích hoạt menu chính
    else
        Library:Notify("Invalid Key!", 3)
    end
end)

-- Info
local InfoGroup = KeyTab:AddRightGroupbox('Info')
InfoGroup:AddLabel("Dev: hnhtlong.10th3")
InfoGroup:AddButton('Copy Contact', function() setclipboard("https://konect.gg/hnhtlong") end)

Library:SetWatermark('hnhtlong.10th3 | Private')
