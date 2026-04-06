--[[
    Script: Universal Silent Aim - hnhtlong.10th3 Edition
    Author: hnhtlong.10th3
    Key: hnhtlong
    Contact: https://konect.gg/hnhtlong
]]--

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local Key = "hnhtlong"

-- // Notification Function
local function Notify(title, content, duration)
    Library:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3
    })
end

-- // Initial Key System UI
local KeyWindow = Library:CreateWindow({ Title = 'hnhtlong.10th3 | Login System', Center = true, AutoShow = true })
local KeyTab = KeyWindow:AddTab('Authentication')
local KeyGroup = KeyTab:AddLeftGroupbox('Xác thực người dùng')

KeyGroup:AddInput('KeyInput', { Default = '', Text = 'Nhập Access Key', Placeholder = 'Gợi ý: hnhtlong' })
KeyGroup:AddButton('Đăng nhập', function()
    if Library.Options.KeyInput.Value == Key then
        Notify("Thành công", "Chào mừng hnhtlong.10th3 quay trở lại!", 3)
        KeyWindow:Unload() 
        StartMainScript() 
    else
        Notify("Thất bại", "Sai mật khẩu rồi, vui lòng thử lại!", 3)
    end
end)

function StartMainScript()
    -- // Variables & Settings
    local SilentAimSettings = {
        Enabled = false,
        ClassName = "hnhtlong.10th3 - Universal Silent Aim",
        ToggleKey = "RightAlt",
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

    local MainFileName = "UniversalSilentAim"
    local Camera = workspace.CurrentCamera
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local GuiService = game:GetService("GuiService")
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")

    local LocalPlayer = Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()
    local Toggles = Library.Toggles
    local Options = Library.Options

    local ValidTargetParts = {"Head", "HumanoidRootPart"}
    local PredictionAmount = 0.165

    -- // Visuals (Drawing API)
    local mouse_box = Drawing.new("Square")
    mouse_box.Visible = false
    mouse_box.ZIndex = 999 
    mouse_box.Color = Color3.fromRGB(54, 57, 241)
    mouse_box.Thickness = 2 
    mouse_box.Size = Vector2.new(20, 20)
    mouse_box.Filled = false 

    local fov_circle = Drawing.new("Circle")
    fov_circle.Thickness = 1
    fov_circle.NumSides = 100
    fov_circle.Radius = 180
    fov_circle.Filled = false
    fov_circle.Visible = false
    fov_circle.Color = Color3.fromRGB(54, 57, 241)

    -- // Logic Functions
    local function CalculateChance(Percentage)
        local chance = math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100) / 100
        return chance <= math.floor(Percentage) / 100
    end

    local function getPositionOnScreen(Vector)
        local Vec3, OnScreen = Camera:WorldToScreenPoint(Vector)
        return Vector2.new(Vec3.X, Vec3.Y), OnScreen
    end

    local function getDirection(Origin, Position)
        return (Position - Origin).Unit * 1000
    end

    local function IsPlayerVisible(Player)
        local PlayerCharacter = Player.Character
        local LocalPlayerCharacter = LocalPlayer.Character
        if not (PlayerCharacter or LocalPlayerCharacter) then return false end 
        local PlayerRoot = PlayerCharacter:FindFirstChild("HumanoidRootPart")
        if not PlayerRoot then return false end 
        local CastPoints = {PlayerRoot.Position, LocalPlayerCharacter, PlayerCharacter}
        local ObscuringObjects = #Camera:GetPartsObscuringTarget(CastPoints, {LocalPlayerCharacter, PlayerCharacter})
        return ObscuringObjects == 0
    end

    local function getClosestPlayer()
        if not Options.TargetPart then return end
        local Closest, DistanceToMouse
        for _, Player in next, Players:GetPlayers() do
            if Player == LocalPlayer then continue end
            if Toggles.TeamCheck.Value and Player.Team == LocalPlayer.Team then continue end
            local Character = Player.Character
            if not Character or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then continue end
            if Toggles.VisibleCheck.Value and not IsPlayerVisible(Player) then continue end

            local Root = Character:FindFirstChild("HumanoidRootPart")
            if not Root then continue end
            local ScreenPos, OnScreen = getPositionOnScreen(Root.Position)
            if not OnScreen then continue end

            local Distance = (UserInputService:GetMouseLocation() - ScreenPos).Magnitude
            if Distance <= (DistanceToMouse or Options.Radius.Value or 180) then
                Closest = (Options.TargetPart.Value == "Random" and Character[ValidTargetParts[math.random(1, #ValidTargetParts)]] or Character[Options.TargetPart.Value])
                DistanceToMouse = Distance
            end
        end
        return Closest
    end

    -- // UI Setup
    local Window = Library:CreateWindow({Title = 'hnhtlong.10th3 | Universal Silent Aim', Center = true, AutoShow = true})
    local GeneralTab = Window:AddTab("General")
    local InfoTab = Window:AddTab("Information")

    -- Information Tab
    local InfoGroup = InfoTab:AddLeftGroupbox("Credits")
    InfoGroup:AddLabel("Developer: hnhtlong.10th3")
    InfoGroup:AddLabel("Version: 1.0.2")
    InfoGroup:AddButton("Copy Contact (Konect)", function()
        setclipboard("https://konect.gg/hnhtlong")
        Notify("System", "Đã sao chép link hnhtlong vào bộ nhớ tạm!", 2)
    end)

    -- Main Settings
    local MainBOX = GeneralTab:AddLeftTabbox("Main")
    local Main = MainBOX:AddTab("Combat")
    Main:AddToggle("aim_Enabled", {Text = "Kích hoạt Silent Aim"}):AddKeyPicker("aim_Key", {Default = "RightAlt", SyncToggleState = true, Mode = "Toggle", Text = "Enabled"})
    Main:AddToggle("TeamCheck", {Text = "Kiểm tra Team", Default = false})
    Main:AddToggle("VisibleCheck", {Text = "Kiểm tra Tầm nhìn", Default = false})
    Main:AddDropdown("TargetPart", {Text = "Vùng ngắm", Default = "HumanoidRootPart", Values = {"Head", "HumanoidRootPart", "Random"}})
    Main:AddDropdown("Method", {Text = "Phương thức", Default = "Raycast", Values = {"Raycast","FindPartOnRay","Mouse.Hit/Target"}})
    Main:AddSlider('HitChance', {Text = 'Tỉ lệ trúng (%)', Default = 100, Min = 0, Max = 100, Rounding = 1})

    -- FOV Settings
    local VisualsGroup = GeneralTab:AddLeftGroupbox("Visuals")
    VisualsGroup:AddToggle("Visible", {Text = "Hiện vòng FOV"}):AddColorPicker("Color", {Default = Color3.fromRGB(54, 57, 241)})
    VisualsGroup:AddSlider("Radius", {Text = "Bán kính FOV", Min = 0, Max = 500, Default = 130, Rounding = 0})
    VisualsGroup:AddToggle("MousePosition", {Text = "Hiện mục tiêu khóa"})

    -- Prediction
    local MiscGroup = GeneralTab:AddRightGroupbox("Miscellaneous")
    MiscGroup:AddToggle("Prediction", {Text = "Dự đoán di chuyển (Prediction)"})
    MiscGroup:AddSlider("Amount", {Text = "Độ nhạy Prediction", Min = 0.1, Max = 1, Default = 0.165, Rounding = 3})

    -- // Render Loop
    RunService.RenderStepped:Connect(function()
        if Toggles.aim_Enabled.Value and Toggles.MousePosition.Value then
            local Target = getClosestPlayer()
            if Target then
                local RootPos, OnScreen = Camera:WorldToViewportPoint(Target.Position)
                mouse_box.Visible = OnScreen
                mouse_box.Position = Vector2.new(RootPos.X, RootPos.Y)
            else
                mouse_box.Visible = false
            end
        else
            mouse_box.Visible = false
        end

        if Toggles.Visible.Value then
            fov_circle.Visible = true
            fov_circle.Color = Options.Color.Value
            fov_circle.Position = UserInputService:GetMouseLocation()
            fov_circle.Radius = Options.Radius.Value
        else
            fov_circle.Visible = false
        end
    end)

    -- // Metamethod Hooks
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
        local Method = getnamecallmethod()
        local Args = {...}
        local self = Args[1]
        
        if Toggles.aim_Enabled.Value and self == workspace and not checkcaller() and CalculateChance(Options.HitChance.Value) then
            if Method == Options.Method.Value then
                local HitPart = getClosestPlayer()
                if HitPart then
                    if Method == "Raycast" then
                        Args[3] = getDirection(Args[2], HitPart.Position)
                    elseif Method == "FindPartOnRay" then
                        Args[2] = Ray.new(Args[2].Origin, getDirection(Args[2].Origin, HitPart.Position))
                    end
                    return oldNamecall(unpack(Args))
                end
            end
        end
        return oldNamecall(...)
    end))

    local oldIndex
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, Index)
        if self == Mouse and not checkcaller() and Toggles.aim_Enabled.Value and Options.Method.Value == "Mouse.Hit/Target" then
            local HitPart = getClosestPlayer()
            if HitPart then
                if Index == "Target" or Index == "target" then return HitPart end
                if Index == "Hit" or Index == "hit" then 
                    return Toggles.Prediction.Value and (HitPart.CFrame + (HitPart.Velocity * Options.Amount.Value)) or HitPart.CFrame
                end
            end
        end
        return oldIndex(self, Index)
    end))
end