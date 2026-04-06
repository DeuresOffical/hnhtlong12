--[[
    AUTHOR: hnhtlong.10th3
    PROJECT: VIP Silent Aim Custom
    KEY: hnhtlong
    CONTACT: https://konect.gg/hnhtlong
]]--

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local Key = "hnhtlong"

-- // System Notifications
local function Notify(title, content)
    Library:Notify({
        Title = title,
        Content = content,
        Duration = 3
    })
end

-- // --- AUTHENTICATION SYSTEM ---
local KeyWindow = Library:CreateWindow({ Title = 'hnhtlong.10th3 | Verification', Center = true, AutoShow = true })
local KeyTab = KeyWindow:AddTab('Auth')
local KeyGroup = KeyTab:AddLeftGroupbox('System Access')

KeyGroup:AddInput('KeyInput', { Default = '', Text = 'Enter Key', Placeholder = 'Key: hnhtlong' })

KeyGroup:AddButton('Login', function()
    if Library.Options.KeyInput.Value == Key then
        Notify("Success", "Loading hnhtlong.10th3 Private Script...")
        KeyWindow:Unload()
        StartMainScript()
    else
        Notify("Error", "Invalid Key!")
    end
end)

-- // --- MAIN SCRIPT EXECUTION ---
function StartMainScript()
    -- Variables & Settings
    local SilentAimSettings = {
        Enabled = false,
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
    
    local Toggles = Library.Toggles
    local Options = Library.Options

    local ValidTargetParts = {"Head", "HumanoidRootPart"}

    -- Visuals (Drawing API)
    local mouse_box = Drawing.new("Square")
    mouse_box.Visible = false; mouse_box.ZIndex = 999; mouse_box.Color = Color3.fromRGB(54, 57, 241); mouse_box.Thickness = 2; mouse_box.Size = Vector2.new(15, 15); mouse_box.Filled = false 

    local fov_circle = Drawing.new("Circle")
    fov_circle.Thickness = 1; fov_circle.NumSides = 100; fov_circle.Radius = 180; fov_circle.Visible = false; fov_circle.Color = Color3.fromRGB(54, 57, 241)

    -- Logic Functions
    local function CalculateChance(Percentage)
        return (math.random(0, 100) <= Percentage)
    end

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
            if Distance <= (Options.Radius.Value or 180) and Distance < DistanceToMouse then
                Closest = (Options.TargetPart.Value == "Random" and Character[ValidTargetParts[math.random(1, #ValidTargetParts)]] or Character:FindFirstChild(Options.TargetPart.Value) or Root)
                DistanceToMouse = Distance
            end
        end
        return Closest
    end

    -- // --- UI SETUP ---
    local Window = Library:CreateWindow({Title = 'hnhtlong.10th3 | Universal Silent Aim', Center = true, AutoShow = true})
    local GeneralTab = Window:AddTab("General")
    local InfoTab = Window:AddTab("Information")

    -- Combat Settings
    local MainBOX = GeneralTab:AddLeftTabbox("Main")
    local Main = MainBOX:AddTab("Combat")
    Main:AddToggle("aim_Enabled", {Text = "Enabled"}):AddKeyPicker("aim_Key", {Default = "RightAlt", SyncToggleState = true, Mode = "Toggle", Text = "Toggle Silent Aim"})
    Main:AddToggle("TeamCheck", {Text = "Team Check"})
    Main:AddToggle("VisibleCheck", {Text = "Visible Check"})
    Main:AddDropdown("TargetPart", {Text = "Target Part", Default = "HumanoidRootPart", Values = {"Head", "HumanoidRootPart", "Random"}})
    Main:AddDropdown("Method", {Text = "Method", Default = "Raycast", Values = {"Raycast", "FindPartOnRay", "Mouse.Hit/Target"}})
    Main:AddSlider('HitChance', {Text = 'Hit Chance', Default = 100, Min = 0, Max = 100, Rounding = 0, Suffix = "%"})

    -- Visuals Settings
    local VisualsGroup = GeneralTab:AddLeftGroupbox("Visuals")
    VisualsGroup:AddToggle("Visible", {Text = "Show FOV"}):AddColorPicker("Color", {Default = Color3.fromRGB(54, 57, 241)})
    VisualsGroup:AddSlider("Radius", {Text = "FOV Radius", Min = 0, Max = 500, Default = 130})
    VisualsGroup:AddToggle("MousePosition", {Text = "Show Target Square"})

    -- Prediction Settings
    local MiscGroup = GeneralTab:AddRightGroupbox("Miscellaneous")
    MiscGroup:AddToggle("Prediction", {Text = "Prediction"})
    MiscGroup:AddSlider("Amount", {Text = "Prediction Amount", Min = 0.1, Max = 1, Default = 0.165, Rounding = 3})

    -- Information Tab
    local CreditsGroup = InfoTab:AddLeftGroupbox("Credits")
    CreditsGroup:AddLabel("Developer: hnhtlong.10th3")
    CreditsGroup:AddButton('Copy Contact Link', function()
        setclipboard("https://konect.gg/hnhtlong")
        Notify("System", "Copied to clipboard!")
    end)

    -- // --- RENDER & HOOKS ---
    RunService.RenderStepped:Connect(function()
        if Toggles.aim_Enabled.Value and Toggles.MousePosition.Value then
            local Target = getClosestPlayer()
            if Target then
                local RootPos, OnScreen = Camera:WorldToViewportPoint(Target.Position)
                mouse_box.Visible = OnScreen
                mouse_box.Position = Vector2.new(RootPos.X, RootPos.Y)
            else mouse_box.Visible = false end
        else mouse_box.Visible = false end

        if Toggles.Visible.Value then
            fov_circle.Visible = true
            fov_circle.Color = Options.Color.Value
            fov_circle.Position = UserInputService:GetMouseLocation()
            fov_circle.Radius = Options.Radius.Value
        else fov_circle.Visible = false end
    end)

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
