--[[ 
    PROJECT: hnhtlong.10th3 PRIVATE SYSTEM
    LOGIC: Universal Silent Aim (Averiias, Stefanuk12, xaxa)
    FIXED FOR: XENO EXECUTOR & ALL OTHERS
    STATUS: NO KEY - FULL ACCESS
]]--

if not game:IsLoaded() then 
    game.Loaded:Wait()
end

-- Fix protectgui cho các Executor đời mới
if not getgenv().protectgui then
    getgenv().protectgui = function(gui) end
end

local SilentAimSettings = {
    Enabled = false,
    ClassName = "hnhtlong.10th3 | Private",
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

-- Sửa lỗi biến nil từ bản gốc
getgenv().SilentAimSettings = SilentAimSettings

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Drawing Objects (FOV & Target Square)
local mouse_box = Drawing.new("Square")
mouse_box.Visible = false 
mouse_box.ZIndex = 999 
mouse_box.Color = Color3.fromRGB(54, 57, 241)
mouse_box.Thickness = 2 
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

-- // --- LOGIC FUNCTIONS (GIỮ NGUYÊN GỐC) ---
function CalculateChance(Percentage)
    Percentage = math.floor(Percentage)
    local chance = math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100) / 100
    return chance <= Percentage / 100
end

local function getPositionOnScreen(Vector)
    local Vec3, OnScreen = Camera:WorldToScreenPoint(Vector)
    return Vector2.new(Vec3.X, Vec3.Y), OnScreen
end

local function getDirection(Origin, Position)
    return (Position - Origin).Unit * 1000
end

-- // --- KHỞI TẠO UI LINORIA ---
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
Library:SetWatermark("hnhtlong.10th3 | Universal")

local Window = Library:CreateWindow({Title = 'hnhtlong.10th3 | Silent Aim', Center = true, AutoShow = true, TabPadding = 8})
local GeneralTab = Window:AddTab("General")

local MainBOX = GeneralTab:AddLeftTabbox("Main") do
    local Main = MainBOX:AddTab("Settings")
    Main:AddToggle("aim_Enabled", {Text = "Enabled", Default = false}):AddKeyPicker("SA_Key", {Default = "RightAlt", Mode = "Toggle", Text = "Silent Aim Toggle"})
    Main:AddToggle("TeamCheck", {Text = "Team Check", Default = false})
    Main:AddToggle("VisibleCheck", {Text = "Visible Check", Default = false})
    Main:AddDropdown("TargetPart", {Text = "Target Part", Default = "HumanoidRootPart", Values = {"Head", "HumanoidRootPart", "Random"}})
    Main:AddDropdown("Method", {Text = "Silent Aim Method", Default = "Raycast", Values = {"Raycast","FindPartOnRay","Mouse.Hit/Target"}})
    Main:AddSlider('HitChance', {Text = 'Hit chance', Default = 100, Min = 0, Max = 100, Rounding = 1})
end

local VisualsBOX = GeneralTab:AddLeftTabbox("Visuals") do
    local Visuals = VisualsBOX:AddTab("FOV & Visuals")
    Visuals:AddToggle("Visible", {Text = "Show FOV Circle"}):AddColorPicker("Color", {Default = Color3.fromRGB(54, 57, 241)})
    Visuals:AddSlider("Radius", {Text = "FOV Radius", Min = 0, Max = 500, Default = 130})
    Visuals:AddToggle("MousePosition", {Text = "Show Target Square"})
end

local MiscTab = GeneralTab:AddLeftTabbox("Misc") do
    local Pred = MiscTab:AddTab("Prediction")
    Pred:AddToggle("Prediction", {Text = "Movement Prediction"})
    Pred:AddSlider("Amount", {Text = "Prediction Amount", Min = 0.165, Max = 1, Default = 0.165, Rounding = 3})
end

-- // --- HÀM TÌM MỤC TIÊU ---
local function getClosestPlayer()
    if not Library.Options.TargetPart then return end
    local Closest, DistanceToMouse = nil, math.huge
    for _, Player in next, Players:GetPlayers() do
        if Player == LocalPlayer or (Library.Toggles.TeamCheck.Value and Player.Team == LocalPlayer.Team) then continue end
        local Character = Player.Character
        if not Character or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then continue end
        
        local TargetPartName = Library.Options.TargetPart.Value == "Random" and (math.random(1,2)==1 and "Head" or "HumanoidRootPart") or Library.Options.TargetPart.Value
        local TargetPart = Character:FindFirstChild(TargetPartName)
        if not TargetPart then continue end

        local ScreenPosition, OnScreen = getPositionOnScreen(TargetPart.Position)
        if not OnScreen then continue end

        local Distance = (UserInputService:GetMouseLocation() - ScreenPosition).Magnitude
        if Distance <= Library.Options.Radius.Value and Distance < DistanceToMouse then
            Closest = TargetPart
            DistanceToMouse = Distance
        end
    end
    return Closest
end

-- // --- RENDER LOOP ---
RunService.RenderStepped:Connect(function()
    -- Cập nhật FOV
    if Library.Toggles.Visible.Value then
        fov_circle.Visible = true
        fov_circle.Position = UserInputService:GetMouseLocation()
        fov_circle.Radius = Library.Options.Radius.Value
        fov_circle.Color = Library.Options.Color.Value
    else
        fov_circle.Visible = false
    end

    -- Cập nhật Square Target
    if Library.Toggles.MousePosition.Value and Library.Toggles.aim_Enabled.Value then
        local HitPart = getClosestPlayer()
        if HitPart then
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(HitPart.Position)
            mouse_box.Visible = OnScreen
            mouse_box.Position = Vector2.new(ScreenPos.X, ScreenPos.Y) - (mouse_box.Size / 2)
        else
            mouse_box.Visible = false
        end
    else
        mouse_box.Visible = false
    end
end)

-- // --- HOOKING METAMETHODS (XENO COMPATIBLE) ---
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local Method = getnamecallmethod()
    local Args = {...}
    if not checkcaller() and Library.Toggles.aim_Enabled.Value and CalculateChance(Library.Options.HitChance.Value) then
        local HitPart = getClosestPlayer()
        if HitPart then
            if Method == "Raycast" and Library.Options.Method.Value == "Raycast" then
                Args[3] = getDirection(Args[2], HitPart.Position)
                return oldNamecall(unpack(Args))
            elseif (Method == "FindPartOnRay" or Method == "findPartOnRay") and Library.Options.Method.Value == "FindPartOnRay" then
                Args[2] = Ray.new(Args[2].Origin, getDirection(Args[2].Origin, HitPart.Position))
                return oldNamecall(unpack(Args))
            end
        end
    end
    return oldNamecall(...)
end))

local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, Index)
    if self == Mouse and not checkcaller() and Library.Toggles.aim_Enabled.Value and Library.Options.Method.Value == "Mouse.Hit/Target" then
        local HitPart = getClosestPlayer()
        if HitPart then
            if Index == "Target" or Index == "target" then return HitPart
            elseif Index == "Hit" or Index == "hit" then 
                local CF = HitPart.CFrame
                if Library.Toggles.Prediction.Value then
                    CF = CF + (HitPart.Velocity * Library.Options.Amount.Value)
                end
                return CF
            end
        end
    end
    return oldIndex(self, Index)
end))

-- Info Tab
local InfoTab = Window:AddTab("Info")
local InfoGroup = InfoTab:AddLeftGroupbox("Credits")
InfoGroup:AddLabel("Dev: hnhtlong.10th3")
InfoGroup:AddButton("Copy Konect", function() setclipboard("https://konect.gg/hnhtlong") end)

Library:Notify("hnhtlong.10th3: System Ready for Xeno!", 4)
