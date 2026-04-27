--[[
    SMUGGLING SYSTEM v1.3
    Toggle Menu: [K]
    Features: Improved UI, Intro Instructions, Optimized Farm
]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local fireproximityprompt = fireproximityprompt

local AUTO_FARM_ENABLED = false
local MENU_VISIBLE = false -- Hidden until intro is closed
local CURRENT_LANG = "EN"

-- Utility: Safe Get CoreGui
local function getParent()
    local success, _ = pcall(function() return CoreGui.Name end)
    if success then return CoreGui end
    return Player:WaitForChild("PlayerGui")
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SmugglingSystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getParent()

-- MOBILE TOGGLE BUTTON (ADDED)
local MobileToggle = Instance.new("TextButton")
MobileToggle.Name = "MobileToggle"
MobileToggle.Size = UDim2.new(0, 50, 0, 50)
MobileToggle.Position = UDim2.new(0, 10, 0.5, -25)
MobileToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MobileToggle.Text = "S"
MobileToggle.Font = Enum.Font.GothamBold
MobileToggle.TextSize = 20
MobileToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MobileToggle.Parent = ScreenGui

Instance.new("UICorner", MobileToggle).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", MobileToggle).Color = Color3.fromRGB(60, 60, 70)

-- Draggable Logic for Mobile Button
local mDragging, mDragInput, mDragStart, mStartPos
MobileToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mDragging = true
        mDragStart = input.Position
        mStartPos = MobileToggle.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and mDragging then
        local delta = input.Position - mDragStart
        MobileToggle.Position = UDim2.new(mStartPos.X.Scale, mStartPos.X.Offset + delta.X, mStartPos.Y.Scale, mStartPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mDragging = false
    end
end)

-- INTRO SCREEN
local IntroFrame = Instance.new("CanvasGroup")
IntroFrame.Name = "IntroFrame"
IntroFrame.Size = UDim2.new(0, 400, 0, 320)
IntroFrame.Position = UDim2.new(0.5, -200, 0.5, -160)
IntroFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
IntroFrame.BorderSizePixel = 0
IntroFrame.Parent = ScreenGui

Instance.new("UICorner", IntroFrame).CornerRadius = UDim.new(0, 20)
local IntroStroke = Instance.new("UIStroke", IntroFrame)
IntroStroke.Color = Color3.fromRGB(200, 200, 200)
IntroStroke.Thickness = 2

local IntroTitle = Instance.new("TextLabel")
IntroTitle.Size = UDim2.new(1, 0, 0, 60)
IntroTitle.Text = "INSTRUCTIONS"
IntroTitle.Font = Enum.Font.GothamBold
IntroTitle.TextSize = 24
IntroTitle.TextColor3 = Color3.fromRGB(30, 30, 30)
IntroTitle.BackgroundTransparency = 1
IntroTitle.Parent = IntroFrame

local IntroText = Instance.new("TextLabel")
IntroText.Size = UDim2.new(0.9, 0, 0, 160)
IntroText.Position = UDim2.new(0.05, 0, 0, 60)
IntroText.TextWrapped = true
IntroText.Font = Enum.Font.Gotham
IntroText.TextSize = 16
IntroText.TextColor3 = Color3.fromRGB(60, 60, 60)
IntroText.BackgroundTransparency = 1
IntroText.TextXAlignment = Enum.TextXAlignment.Left
IntroText.TextYAlignment = Enum.TextYAlignment.Top
IntroText.Parent = IntroFrame

local EN_TEXT = [[To make the auto farm work correctly, follow these steps:

1. Spawn your car.
2. Get inside the car.
3. Activate the Auto Farm.
4. Do not touch anything while it's running.
5. Deactivate it when the auto farm sells your money in the laundry.]]

local ES_TEXT = [[Para que el auto farm funcione correctamente, sigue estos pasos:

1. Aparece tu carro.
2. Súbete al carro.
3. Activa el Auto Farm.
4. No toques nada mientras está funcionando.
5. Desactívalo cuando el auto farm venda tu dinero en la laundry.]]

IntroText.Text = EN_TEXT

local TranslateBtn = Instance.new("TextButton")
TranslateBtn.Size = UDim2.new(0, 120, 0, 40)
TranslateBtn.Position = UDim2.new(0.05, 0, 0.82, 0)
TranslateBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
TranslateBtn.Text = "Translate (ES)"
TranslateBtn.Font = Enum.Font.GothamBold
TranslateBtn.TextSize = 14
TranslateBtn.TextColor3 = Color3.fromRGB(50, 50, 50)
TranslateBtn.Parent = IntroFrame
Instance.new("UICorner", TranslateBtn).CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 120, 0, 40)
CloseBtn.Position = UDim2.new(0.65, 0, 0.82, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CloseBtn.Text = "Close"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = IntroFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- MAIN MENU
local MainFrame = Instance.new("CanvasGroup")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 260) -- Increased height for KeyInfo
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(40, 40, 50)
MainStroke.Thickness = 2

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 60, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 16)

local SidebarFill = Instance.new("Frame") -- To hide corner on right side of sidebar
SidebarFill.Size = UDim2.new(0, 10, 1, 0)
SidebarFill.Position = UDim2.new(1, -10, 0, 0)
SidebarFill.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
SidebarFill.BorderSizePixel = 0
SidebarFill.Parent = Sidebar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0, 50)
Title.Position = UDim2.new(0, 60, 0, 0)
Title.Text = "SYSTEM"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -80, 1, -60)
ContentFrame.Position = UDim2.new(0, 70, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local FarmButton = Instance.new("TextButton")
FarmButton.Size = UDim2.new(1, 0, 0, 50)
FarmButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
FarmButton.Text = "AUTO FARM: OFF"
FarmButton.Font = Enum.Font.GothamBold
FarmButton.TextSize = 16
FarmButton.TextColor3 = Color3.fromRGB(255, 80, 80)
FarmButton.Parent = ContentFrame
Instance.new("UICorner", FarmButton).CornerRadius = UDim.new(0, 12)

-- KEY INFO LABEL (ADDED)
local KeyInfo = Instance.new("TextLabel")
KeyInfo.Size = UDim2.new(1, 0, 0, 30)
KeyInfo.Position = UDim2.new(0, 0, 0, 130)
KeyInfo.Text = "Press [K] to toggle menu"
KeyInfo.Font = Enum.Font.Gotham
KeyInfo.TextSize = 12
KeyInfo.TextColor3 = Color3.fromRGB(180, 180, 180)
KeyInfo.BackgroundTransparency = 1
KeyInfo.Parent = ContentFrame

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, 0, 0, 30)
SliderLabel.Position = UDim2.new(0, 0, 0, 60)
SliderLabel.Text = "Next Update: Custom Sliders"
SliderLabel.Font = Enum.Font.Gotham
SliderLabel.TextSize = 12
SliderLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Parent = ContentFrame

-- Draggable Logic for Main Menu
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Function to toggle menu
local function toggleMenu()
    MENU_VISIBLE = not MENU_VISIBLE
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.4), {GroupTransparency = MENU_VISIBLE and 0 or 1}):Play()
    if not MENU_VISIBLE then
        task.delay(0.4, function() if not MENU_VISIBLE then MainFrame.Visible = false end end)
    end
end

-- Button Actions
TranslateBtn.MouseButton1Click:Connect(function()
    if CURRENT_LANG == "EN" then
        CURRENT_LANG = "ES"
        IntroText.Text = ES_TEXT
        IntroTitle.Text = "INSTRUCCIONES"
        TranslateBtn.Text = "Translate (EN)"
        CloseBtn.Text = "Cerrar"
    else
        CURRENT_LANG = "EN"
        IntroText.Text = EN_TEXT
        IntroTitle.Text = "INSTRUCTIONS"
        TranslateBtn.Text = "Translate (ES)"
        CloseBtn.Text = "Close"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(IntroFrame, TweenInfo.new(0.5), {GroupTransparency = 1}):Play()
    task.delay(0.5, function()
        IntroFrame.Visible = false
        toggleMenu()
    end)
end)

MobileToggle.MouseButton1Click:Connect(toggleMenu)

-- Helper Functions
local function getPath(root, ...)
    local current = root
    for _, name in ipairs({...}) do
        if not (current and typeof(current) == "Instance") then return nil end
        current = current:FindFirstChild(name)
    end
    return current
end

local function getVehicle(part)
    local current = part
    while current and current ~= workspace do
        if current:IsA("Model") and (current:FindFirstChildOfClass("VehicleSeat") or current:FindFirstChildOfClass("DriveSeat")) then
            return current
        end
        current = current.Parent
    end
    return nil
end

local function safeTeleport(pos)
    local Character = Player.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local TargetEntity = Character
    
    if Humanoid and Humanoid.SeatPart then
        TargetEntity = getVehicle(Humanoid.SeatPart) or Humanoid.SeatPart.Parent
    end

    local function clearVelocity(entity)
        if entity:IsA("Model") then
            local primary = entity.PrimaryPart or entity:FindFirstChildWhichIsA("BasePart")
            if primary then
                primary.AssemblyLinearVelocity = Vector3.new(0,0,0)
                primary.AssemblyAngularVelocity = Vector3.new(0,0,0)
            end
        elseif entity:IsA("BasePart") then
            entity.AssemblyLinearVelocity = Vector3.new(0,0,0)
            entity.AssemblyAngularVelocity = Vector3.new(0,0,0)
        end
    end

    clearVelocity(TargetEntity)
    local currentRotation = TargetEntity:GetPivot().Rotation
    TargetEntity:PivotTo(CFrame.new(pos + Vector3.new(0, 3, 0)) * currentRotation)
    
    task.wait(0.1)
    clearVelocity(TargetEntity)
end

local function firePrompt(prompt, amount)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    amount = amount or 1
    for i = 1, amount do
        if not AUTO_FARM_ENABLED then break end
        pcall(function()
            if fireproximityprompt then
                fireproximityprompt(prompt)
            else
                prompt:InputBegan(Enum.UserInputType.MouseButton1)
                task.wait(0.1)
                prompt:InputEnded(Enum.UserInputType.MouseButton1)
            end
        end)
        task.wait(0.85)
    end
end

-- Auto Farm Core
local function runAutoFarm()
    while AUTO_FARM_ENABLED do
        -- 1. Buy Items (Unified TP)
        local watchModel = getPath(workspace, "Smuggling", "Items", "Fake Watch", "Main")
        local bagModel = getPath(workspace, "Smuggling", "Items", "Fake Designer Bag", "Main")
        local sarsModel = getPath(workspace, "Smuggling", "Items", "Sarsaparilla", "Main")
        
        local firstItem = watchModel or bagModel or sarsModel
        if firstItem then
            safeTeleport(firstItem:GetPivot().Position)
            task.wait(1.5)
        end

        if AUTO_FARM_ENABLED then
            local prompt = watchModel and getPath(watchModel, "PromptAtt", "SmugglePurchasePrompt")
            if prompt then firePrompt(prompt, 3) end
        end
        if AUTO_FARM_ENABLED then
            local prompt = bagModel and getPath(bagModel, "PromptAtt", "SmugglePurchasePrompt")
            if prompt then firePrompt(prompt, 3) end
        end
        if AUTO_FARM_ENABLED then
            local prompt = sarsModel and getPath(sarsModel, "PromptAtt", "SmugglePurchasePrompt")
            if prompt then firePrompt(prompt, 4) end
        end

        if not AUTO_FARM_ENABLED then break end
        task.wait(1)

        -- 2. Sell Sequence
        local gym = getPath(workspace, "Smuggling", "Props", "Sell", "Gymbro")
        if gym then
            safeTeleport(gym:GetPivot().Position)
            task.wait(0.8)
        end
        
        local sellPromptArea = getPath(workspace, "Smuggling", "Sell", "Prompt")
        local sellPrompt = sellPromptArea and sellPromptArea:FindFirstChild("SmuggleSellPrompt")
        if sellPromptArea and sellPrompt then
            safeTeleport(sellPromptArea:GetPivot().Position)
            task.wait(0.5)
            firePrompt(sellPrompt, 1)
        end
        
        if not AUTO_FARM_ENABLED then break end
        task.wait(1)

        -- 3. Laundering
        local laundFolder = getPath(workspace, "Smuggling", "Props", "Laundering")
        if laundFolder then
            local children = laundFolder:GetChildren()
            local target = children[4]
            if target then
                safeTeleport(target:GetPivot().Position)
                task.wait(0.5)
                local nearest = nil
                for _, p in pairs(workspace:GetDescendants()) do
                    if p:IsA("ProximityPrompt") and (p:IsDescendantOf(target) or (p.Parent:IsA("BasePart") and (p.Parent.Position - target:GetPivot().Position).Magnitude < 10)) then
                        nearest = p
                        break
                    end
                end
                if nearest then
                    firePrompt(nearest, 1)
                end
            end
        end
        
        task.wait(2)
    end
end

FarmButton.MouseButton1Click:Connect(function()
    AUTO_FARM_ENABLED = not AUTO_FARM_ENABLED
    FarmButton.Text = "AUTO FARM: " .. (AUTO_FARM_ENABLED and "ON" or "OFF")
    FarmButton.TextColor3 = AUTO_FARM_ENABLED and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    
    if AUTO_FARM_ENABLED then
        task.spawn(runAutoFarm)
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K and MainFrame.Visible then
        toggleMenu()
    end
end)

print("[SYSTEM] Loaded. Instructions active.")
