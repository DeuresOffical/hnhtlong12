--[[ 
    PROJECT: hnhtlong.10th3 PRIVATE SYSTEM
    LOGIC: Universal Silent Aim (Averiias, Stefanuk12, xaxa) - 100% ORIGINAL LOGIC
    STATUS: NO KEY - FULL ACCESS
]]--

if not game:IsLoaded() then 
    game.Loaded:Wait()
end

if not syn or not protectgui then
    getgenv().protectgui = function() end
end

-- // --- GIỮ NGUYÊN SETTINGS GỐC ---
local SilentAimSettings = {
    Enabled = false,
    ClassName = "hnhtlong.10th3 - Private",
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

getgenv().SilentAimSettings = SilentAimSettings
local MainFileName = "UniversalSilentAim"
local SelectedFile, FileToSave = "", ""

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local FindFirstChild = game.FindFirstChild
local RenderStepped = RunService.RenderStepped
local GetMouseLocation = UserInputService:GetMouseLocation()

local ValidTargetParts = {"Head", "HumanoidRootPart"}
local PredictionAmount = 0.165

-- // --- DRAWING (GIỮ NGUYÊN) ---
local mouse_box = Drawing.new("Square")
mouse_box.Visible = false 
mouse_box.ZIndex = 999 
mouse_box.Color = Color3.fromRGB(54, 57, 241)
mouse_box.Thickness = 20 
mouse_box.Size = Vector2.new(20, 20)
mouse_box.Filled = true 

local fov_circle = Drawing.new("Circle")
fov_circle.Thickness = 1
fov_circle.NumSides = 100
fov_circle.Radius = 180
fov_circle.Filled = false
fov_circle.Visible = false
fov_circle.ZIndex = 999
fov_circle.Transparency = 1
fov_circle.Color = Color3.fromRGB(54, 57, 241)

local ExpectedArguments = {
    FindPartOnRayWithIgnoreList = { ArgCountRequired = 3, Args = {"Instance", "Ray", "table", "boolean", "boolean"} },
    FindPartOnRayWithWhitelist = { ArgCountRequired = 3, Args = {"Instance", "Ray", "table", "boolean"} },
    FindPartOnRay = { ArgCountRequired = 2, Args = {"Instance", "Ray", "Instance", "boolean", "boolean"} },
    Raycast = { ArgCountRequired = 3, Args = {"Instance", "Vector3", "Vector3", "RaycastParams"} }
}

-- // --- FUNCTIONS LOGIC (GIỮ NGUYÊN 100%) ---
function CalculateChance(Percentage)
    Percentage = math.floor(Percentage)
    local chance = math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100) / 100
    return chance <= Percentage / 100
end

local function getPositionOnScreen(Vector)
    local Vec3, OnScreen = Camera:WorldToScreenPoint(Vector)
    return Vector2.new(Vec3.X, Vec3.Y), OnScreen
end

local function ValidateArguments(Args, RayMethod)
    local Matches = 0
    if #Args < RayMethod.ArgCountRequired then return false end
    for Pos, Argument in next, Args do
        if typeof(Argument) == RayMethod.Args[Pos] then Matches = Matches + 1 end
    end
    return Matches >= RayMethod.ArgCountRequired
end

local function getDirection(Origin, Position) return (Position - Origin).Unit * 1000 end
local function getMousePosition() return UserInputService:GetMouseLocation() end

local function IsPlayerVisible(Player)
    local PlayerCharacter = Player.Character
    local LocalPlayerCharacter = LocalPlayer.Character
    if not (PlayerCharacter or LocalPlayerCharacter) then return end 
    local PlayerRoot = FindFirstChild(PlayerCharacter, Library.Options.TargetPart.Value) or FindFirstChild(PlayerCharacter, "HumanoidRootPart")
    if not PlayerRoot then return end 
    local CastPoints, IgnoreList = {PlayerRoot.Position, LocalPlayerCharacter, PlayerCharacter}, {LocalPlayerCharacter, PlayerCharacter}
    local ObscuringObjects = #Camera:GetPartsObscuringTarget(CastPoints, IgnoreList)
    return ObscuringObjects == 0
end

local function getClosestPlayer()
    if not Library.Options.TargetPart.Value then return end
    local Closest, DistanceToMouse
    for _, Player in next, Players:GetPlayers() do
        if Player == LocalPlayer then continue end
        if Library.Toggles.TeamCheck.Value and Player.Team == LocalPlayer.Team then continue end
        local Character = Player.Character
        if not Character then continue end
        if Library.Toggles.VisibleCheck.Value and not IsPlayerVisible(Player) then continue end
        local HumanoidRootPart = FindFirstChild(Character, "HumanoidRootPart")
        local Humanoid = FindFirstChild(Character, "Humanoid")
        if not HumanoidRootPart or not Humanoid or (Humanoid and Humanoid.Health <= 0) then continue end
        local ScreenPosition, OnScreen = getPositionOnScreen(HumanoidRootPart.Position)
        if not OnScreen then continue end
        local Distance = (getMousePosition() - ScreenPosition).Magnitude
        if Distance <= (DistanceToMouse or Library.Options.Radius.Value or 2000) then
            Closest = ((Library.Options.TargetPart.Value == "Random" and Character[ValidTargetParts[math.random(1, #ValidTargetParts)]]) or Character[Library.Options.TargetPart.Value])
            DistanceToMouse = Distance
        end
    end
    return Closest
end

-- // --- UI GIAO DIỆN (CHỈ ĐỔI TÊN) ---
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
Library:SetWatermark("hnhtlong.10th3 | Private")

local Window = Library:CreateWindow({Title = 'hnhtlong.10th3 | Universal Silent Aim', Center = true, AutoShow = true, TabPadding = 8})
local GeneralTab = Window:AddTab("General")

local MainBOX = GeneralTab:AddLeftTabbox("Main") do
    local Main = MainBOX:AddTab("Main Settings")
    Main:AddToggle("aim_Enabled", {Text = "Enabled"}):AddKeyPicker("aim_Enabled_KeyPicker", {Default = "RightAlt", SyncToggleState = true, Mode = "Toggle", Text = "Enabled", NoUI = false});
    
    Main:AddToggle("TeamCheck", {Text = "Team Check", Default = SilentAimSettings.TeamCheck})
    Main:AddToggle("VisibleCheck", {Text = "Visible Check", Default = SilentAimSettings.VisibleCheck})
    Main:AddDropdown("TargetPart", {AllowNull = true, Text = "Target Part", Default = SilentAimSettings.TargetPart, Values = {"Head", "HumanoidRootPart", "Random"}})
    Main:AddDropdown("Method", {AllowNull = true, Text = "Silent Aim Method", Default = SilentAimSettings.SilentAimMethod, Values = {"Raycast","FindPartOnRay","FindPartOnRayWithWhitelist","FindPartOnRayWithIgnoreList","Mouse.Hit/Target"}})
    Main:AddSlider('HitChance', {Text = 'Hit chance', Default = 100, Min = 0, Max = 100, Rounding = 1})
end

local FieldOfViewBOX = GeneralTab:AddLeftTabbox("Field Of View") do
    local Main = FieldOfViewBOX:AddTab("Visuals")
    Main:AddToggle("Visible", {Text = "Show FOV Circle"}):AddColorPicker("Color", {Default = Color3.fromRGB(54, 57, 241)})
    Main:AddSlider("Radius", {Text = "FOV Circle Radius", Min = 0, Max = 500, Default = 130, Rounding = 0})
    Main:AddToggle("MousePosition", {Text = "Show Silent Aim Target"}):AddColorPicker("MouseVisualizeColor", {Default = Color3.fromRGB(54, 57, 241)})
end

local MiscTab = GeneralTab:AddLeftTabbox("Miscellaneous") do
    local Pred = MiscTab:AddTab("Prediction")
    Pred:AddToggle("Prediction", {Text = "Mouse.Hit/Target Prediction"})
    Pred:AddSlider("Amount", {Text = "Prediction Amount", Min = 0.165, Max = 1, Default = 0.165, Rounding = 3})
end

-- // --- RENDER STEPPED (GIỮ NGUYÊN) ---
RunService.RenderStepped:Connect(function()
    if Library.Toggles.MousePosition.Value and Library.Toggles.aim_Enabled.Value then
        local target = getClosestPlayer()
        if target then 
            local Root = target.Parent:FindFirstChild("PrimaryPart") or target
            local RootToViewportPoint, IsOnScreen = Camera:WorldToViewportPoint(Root.Position)
            mouse_box.Visible = IsOnScreen
            mouse_box.Position = Vector2.new(RootToViewportPoint.X, RootToViewportPoint.Y)
        else 
            mouse_box.Visible = false 
        end
    else
        mouse_box.Visible = false
    end
    
    if Library.Toggles.Visible.Value then 
        fov_circle.Visible = true
        fov_circle.Color = Library.Options.Color.Value
        fov_circle.Position = getMousePosition()
        fov_circle.Radius = Library.Options.Radius.Value
    else
        fov_circle.Visible = false
    end
end)

-- // --- HOOKS (GIỮ NGUYÊN 100%) ---
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local Method = getnamecallmethod()
    local Arguments = {...}
    local self = Arguments[1]
    local chance = CalculateChance(Library.Options.HitChance.Value)
    if Library.Toggles.aim_Enabled.Value and self == workspace and not checkcaller() and chance == true then
        local HitPart = getClosestPlayer()
        if HitPart then
            if Method == "FindPartOnRayWithIgnoreList" and Library.Options.Method.Value == Method then
                local A_Ray = Arguments[2]
                Arguments[2] = Ray.new(A_Ray.Origin, getDirection(A_Ray.Origin, HitPart.Position))
                return oldNamecall(unpack(Arguments))
            elseif Method == "FindPartOnRayWithWhitelist" and Library.Options.Method.Value == Method then
                local A_Ray = Arguments[2]
                Arguments[2] = Ray.new(A_Ray.Origin, getDirection(A_Ray.Origin, HitPart.Position))
                return oldNamecall(unpack(Arguments))
            elseif (Method == "FindPartOnRay" or Method == "findPartOnRay") and Library.Options.Method.Value:lower() == Method:lower() then
                local A_Ray = Arguments[2]
                Arguments[2] = Ray.new(A_Ray.Origin, getDirection(A_Ray.Origin, HitPart.Position))
                return oldNamecall(unpack(Arguments))
            elseif Method == "Raycast" and Library.Options.Method.Value == Method then
                Arguments[3] = getDirection(Arguments[2], HitPart.Position)
                return oldNamecall(unpack(Arguments))
            end
        end
    end
    return oldNamecall(...)
end))

local oldIndex = nil 
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, Index)
    if self == Mouse and not checkcaller() and Library.Toggles.aim_Enabled.Value and Library.Options.Method.Value == "Mouse.Hit/Target" then
        local HitPart = getClosestPlayer()
        if HitPart then
            if Index == "Target" or Index == "target" then return HitPart
            elseif Index == "Hit" or Index == "hit" then 
                return ((Library.Toggles.Prediction.Value and (HitPart.CFrame + (HitPart.Velocity * Library.Options.Amount.Value))) or HitPart.CFrame)
            end
        end
    end
    return oldIndex(self, Index)
end))

Library:Notify("hnhtlong.10th3: Logic Loaded!", 3)
