--[[
    REMASTERED BY: hnhtlong.10th3
    PROJECT: VIP PRIVATE SILENT AIM
    KEY: hnhtlong
    CONTACT: https://konect.gg/hnhtlong
]]--

-- // --- INITIALIZATION ---
if not game:IsLoaded() then game.Loaded:Wait() end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local Key = "hnhtlong"

-- // --- LOGIN SYSTEM ---
local KeyWindow = Library:CreateWindow({ Title = 'hnhtlong.10th3 | Login System', Center = true, AutoShow = true })
local KeyTab = KeyWindow:AddTab('Auth')
local KeyGroup = KeyTab:AddLeftGroupbox('Verification')

KeyGroup:AddInput('KeyInput', { Default = '', Text = 'Access Key', Placeholder = 'Key: hnhtlong' })

KeyGroup:AddButton('Login', function()
    if Library.Options.KeyInput.Value == Key then
        Library:Notify("Success! Starting hnhtlong.10th3 Private...", 3)
        KeyWindow:Unload()
        ExecuteMainScript()
    else
        Library:Notify("Invalid Key! Please check again.", 3)
    end
end)

-- // --- MAIN SCRIPT LOGIC (GỘP TOÀN BỘ TỪ DANG CAP VKL & AVERIIAS) ---
function ExecuteMainScript()
    local SilentAimSettings = {
        Enabled = false,
        TeamCheck = false,
        VisibleCheck = false, 
        TargetPart = "HumanoidRootPart",
        SilentAimMethod = "Raycast",
        FOVRadius = 130,
        FOVVisible = false,
        HitChance = 100,
        PredictionAmount = 0.165
    }

    local Camera = workspace.CurrentCamera
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()
    
    local Toggles = Library.Toggles
    local Options = Library.Options

    -- Visuals
    local fov_circle = Drawing.new("Circle")
    fov_circle.Thickness = 1
    fov_circle.NumSides = 100
    fov_circle.Radius = 130
    fov_circle.Visible = false
    fov_circle.Color = Color3.fromRGB(54, 57, 241)

    local mouse_box = Drawing.new("Square")
    mouse_box.Visible = false
    mouse_box.ZIndex = 999
    mouse_box.Color = Color3.fromRGB(54, 57, 241)
    mouse_box.Thickness = 2
    mouse_box.Size = Vector2.new(15, 15)

    -- Logic Functions
    local function IsPlayerVisible(Player)
        local Character = Player.Character
        if not Character or not LocalPlayer.Character then return false end
        local Root = Character:FindFirstChild("HumanoidRootPart")
        if not Root then return false end
        local Parts = Camera:GetPartsObscuringTarget({Root.Position}, {LocalPlayer.Character, Character})
        return #Parts == 0
    end

    local function getClosestPlayer()
        local Closest, DistanceToMouse = nil, math.huge
        for _, Player in next, Players:GetPlayers() do
            if Player == LocalPlayer then continue end
            if Toggles.TeamCheck.Value and Player.Team == LocalPlayer.Team then continue end
            local Character = Player.Character
            if not Character or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then continue end
            if Toggles.VisibleCheck.Value and not IsPlayerVisible(Player) then continue end

            local Root = Character:FindFirstChild("HumanoidRootPart")
            if not Root then continue end
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            if not OnScreen then continue end

            local Distance = (UserInputService:GetMouseLocation() - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
            if Distance <= Options.Radius.Value and Distance < DistanceToMouse then
                Closest = Character:FindFirstChild(Options.TargetPart.Value) or Root
                DistanceToMouse = Distance
            end
        end
        return Closest
    end

    -- // --- UI CREATION ---
    local Window = Library:CreateWindow({Title = 'hnhtlong.10th3 | Universal Silent Aim', Center = true, AutoShow = true})
    local GeneralTab = Window:AddTab("General")
    local InfoTab = Window:AddTab("Information")

    local Main = GeneralTab:AddLeftGroupbox("Combat")
    Main:AddToggle("aim_Enabled", {Text = "Enabled"}):AddKeyPicker("aim_Key", {Default = "RightAlt", SyncToggleState = true, Mode = "Toggle", Text = "Silent Aim"})
    Main:AddToggle("TeamCheck", {Text = "Team Check"})
    Main:AddToggle("VisibleCheck", {Text = "Visible Check"})
    Main:AddDropdown("TargetPart", {Text = "Target Part", Default = "HumanoidRootPart", Values = {"Head", "HumanoidRootPart"}})
    Main:AddDropdown("Method", {Text = "Method", Default = "Raycast", Values = {"Raycast", "FindPartOnRay", "Mouse.Hit/Target"}})
    Main:AddSlider('HitChance', {Text = 'Hit Chance', Default = 100, Min = 0, Max = 100, Rounding = 0, Suffix = "%"})

    local VisualsGrp = GeneralTab:AddLeftGroupbox("Visuals")
    VisualsGrp:AddToggle("Visible", {Text = "Show FOV"}):AddColorPicker("Color", {Default = Color3.fromRGB(54, 57, 241)})
    VisualsGrp:AddSlider("Radius", {Text = "FOV Radius", Min = 0, Max = 500, Default = 130})
    VisualsGrp:AddToggle("ShowTarget", {Text = "Show Target Square"})

    local Misc = GeneralTab:AddRightGroupbox("Miscellaneous")
    Misc:AddToggle("Prediction", {Text = "Prediction"})
    Misc:AddSlider("Amount", {Text = "Prediction Amount", Min = 0.1, Max = 1, Default = 0.165, Rounding = 3})

    local InfoGroup = InfoTab:AddLeftGroupbox("Contact")
    InfoGroup:AddLabel("Dev: hnhtlong.10th3")
    InfoGroup:AddButton("Copy Konect Link", function()
        setclipboard("https://konect.gg/hnhtlong")
        Library:Notify("Copied to clipboard!", 2)
    end)

    -- // --- EXECUTION LOOP ---
    RunService.RenderStepped:Connect(function()
        if Toggles.Visible.Value then
            fov_circle.Visible = true
            fov_circle.Color = Options.Color.Value
            fov_circle.Position = UserInputService:GetMouseLocation()
            fov_circle.Radius = Options.Radius.Value
        else fov_circle.Visible = false end

        if Toggles.aim_Enabled.Value and Toggles.ShowTarget.Value then
            local Target = getClosestPlayer()
            if Target then
                local Pos, OnScreen = Camera:WorldToViewportPoint(Target.Position)
                mouse_box.Visible = OnScreen
                mouse_box.Position = Vector2.new(Pos.X, Pos.Y)
            else mouse_box.Visible = false end
        else mouse_box.Visible = false end
    end)

    -- Hooks
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
        local Method = getnamecallmethod()
        local Args = {...}
        if Toggles.aim_Enabled.Value and not checkcaller() and (math.random(0, 100) <= Options.HitChance.Value) then
            if Method == Options.Method.Value then
                local HitPart = getClosestPlayer()
                if HitPart then
                    if Method == "Raycast" then
                        Args[3] = (HitPart.Position - Args[2]).Unit * 1000
                    elseif Method == "FindPartOnRay" then
                        Args[2] = Ray.new(Args[2].Origin, (HitPart.Position - Args[2].Origin).Unit * 1000)
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