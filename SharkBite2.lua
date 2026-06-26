local ProtectionConfig = {

    SecretKey = "31",
    
    HubName = "MIDASHUB"
}

if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return
end

-------------------------------------------------------------------------------
-- 👇 YOUR MAIN SCRIPT CODE STARTS HERE 👇
-------------------------------------------------------------------------------

print(ProtectionConfig.HubName .. " Loaded Successfully!")


-- ===============================================
-- SERVICES AND GLOBAL SETTINGS
-- ===============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PlayerTweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local sharksFolder = workspace:WaitForChild("Sharks", 15)
local boatsFolder = workspace:WaitForChild("Boats", 15)

local SHARK_TEAM = "Shark"
local MAX_DIST = 10000
local BOX_COLOR = Color3.fromRGB(255, 55, 55)
local BOAT_COLOR = Color3.fromRGB(55, 255, 55)
local PLAYER_COLOR = Color3.fromRGB(255, 215, 0)

-- Feature State Variables
local boxEspEnabled = false
local aimbotEnabled = false
local boatEspEnabled = false
local playerEspEnabled = false
local fullBrightEnabled = false

local tracked = {}
local trackedBoats = {}
local trackedPlayers = {}
local isMinimized = false

-- Panel Size Settings
local normalSize = UDim2.new(0, 390, 0, 590)
local normalPos = UDim2.new(0.5, -195, 0.5, -295)

-- Original Lighting Backups
local origAmbient = Lighting.Ambient
local origOutdoorAmbient = Lighting.OutdoorAmbient
local origClockTime = Lighting.ClockTime
local origFogEnd = Lighting.FogEnd

-- RGB Color Loop Helper Function
local function getRainbowColor(speed)
    local frequency = speed or 0.4
    local cTime = tick()
    return Color3.fromHSV((cTime * frequency) % 1, 0.85, 1)
end

-- ===============================================
-- MAIN SCREEN GUI SETUP
-- ===============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MidasHubSharkRGB"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- ===============================================
-- MIDASHUB INTRO SCREEN
-- ===============================================
local introFrame = Instance.new("Frame")
introFrame.Name = "IntroFrame"
introFrame.Size = UDim2.new(1, 0, 1, 0)
introFrame.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
introFrame.ZIndex = 100
introFrame.Parent = screenGui

local introBgG = Instance.new("UIGradient")
introBgG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 5, 5)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(6, 6, 10)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 15))
})
introBgG.Rotation = 45
introBgG.Parent = introFrame

-- AÇILIŞ EKRANI METİNLERİ VE YÜKLEME BARININ ARKASINA EKLENEN MERKEZ PANEL
local introCenterFrame = Instance.new("Frame")
introCenterFrame.Name = "IntroCenterFrame"
introCenterFrame.Size = UDim2.new(0, 650, 0, 350)
introCenterFrame.Position = UDim2.new(0.5, -325, 0.5, -175)
introCenterFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
introCenterFrame.BorderSizePixel = 0
introCenterFrame.ZIndex = 100
introCenterFrame.Parent = introFrame

local introCenterCorner = Instance.new("UICorner")
introCenterCorner.CornerRadius = UDim.new(0, 12)
introCenterCorner.Parent = introCenterFrame

local introCenterStroke = Instance.new("UIStroke")
introCenterStroke.Thickness = 2.5
introCenterStroke.Parent = introCenterFrame

-- MIDASHUB TITLE (Merkez Panele Bağlandı)
local midasTitle = Instance.new("TextLabel")
midasTitle.Size = UDim2.new(1, 0, 0, 50)
midasTitle.Position = UDim2.new(0, 0, 0.2, -25)
midasTitle.BackgroundTransparency = 1
midasTitle.Text = "🦈 MIDASHUB 🦈"
midasTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
midasTitle.TextSize = 46
midasTitle.Font = Enum.Font.GothamBlack
midasTitle.ZIndex = 101
midasTitle.Parent = introCenterFrame

local midasStroke = Instance.new("UIStroke")
midasStroke.Thickness = 2.5
midasStroke.Parent = midasTitle

-- SUBTITLE (Merkez Panele Bağlandı)
local subTitle = Instance.new("TextLabel")
subTitle.Size = UDim2.new(1, 0, 0, 30)
subTitle.Position = UDim2.new(0, 0, 0.4, 0)
subTitle.BackgroundTransparency = 1
subTitle.Text = "Shark Bite 2 OP Script"
subTitle.TextColor3 = Color3.fromRGB(200, 200, 220)
subTitle.TextSize = 18
subTitle.Font = Enum.Font.GothamBold
subTitle.ZIndex = 101
subTitle.Parent = introCenterFrame

-- STATUS LABEL (Merkez Panele Bağlandı)
local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, 0, 0, 30)
statusLbl.Position = UDim2.new(0, 0, 0.55, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Loading RGB Core Systems..."
statusLbl.TextColor3 = Color3.fromRGB(240, 240, 255)
statusLbl.TextSize = 14
statusLbl.Font = Enum.Font.GothamBold
statusLbl.ZIndex = 101
statusLbl.Parent = introCenterFrame

-- LOADING BAR BACKGROUND (Merkez Panele Bağlandı)
local loadBarBg = Instance.new("Frame")
loadBarBg.Size = UDim2.new(0, 340, 0, 8)
loadBarBg.Position = UDim2.new(0.5, -170, 0.75, 0)
loadBarBg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
loadBarBg.BorderSizePixel = 0
loadBarBg.ZIndex = 101
loadBarBg.Parent = introCenterFrame

local loadBarBgCorner = Instance.new("UICorner")
loadBarBgCorner.CornerRadius = UDim.new(1, 0)
loadBarBgCorner.Parent = loadBarBg

-- LOADING BAR FILL
local loadBarFill = Instance.new("Frame")
loadBarFill.Size = UDim2.new(0, 0, 1, 0)
loadBarFill.BorderSizePixel = 0
loadBarFill.ZIndex = 102
loadBarFill.Parent = loadBarBg

local loadBarFillCorner = Instance.new("UICorner")
loadBarFillCorner.CornerRadius = UDim.new(1, 0)
loadBarFillCorner.Parent = loadBarFill

local barGlow = Instance.new("UIStroke")
barGlow.Thickness = 1.5
barGlow.Parent = loadBarFill

-- START BUTTON (Merkez Panele Bağlandı)
local readyBtn = Instance.new("TextButton")
readyBtn.Size = UDim2.new(0, 190, 0, 48)
readyBtn.Position = UDim2.new(0.5, -95, 0.75, 0)
readyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
readyBtn.Text = "LAUNCH"
readyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
readyBtn.TextSize = 16
readyBtn.Font = Enum.Font.GothamBold
readyBtn.Visible = false
readyBtn.ClipsDescendants = true
readyBtn.ZIndex = 105
readyBtn.Parent = introCenterFrame

local readyCorner = Instance.new("UICorner")
readyCorner.CornerRadius = UDim.new(0, 8)
readyCorner.Parent = readyBtn

local readyStroke = Instance.new("UIStroke")
readyStroke.Thickness = 2
readyStroke.Parent = readyBtn

-- ===============================================
-- MAIN PANEL SETUP
-- ===============================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = normalSize
mainFrame.Position = normalPos
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.ZIndex = 10

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2.5
mainStroke.Parent = mainFrame

mainFrame.Parent = screenGui
screenGui.Parent = playerGui

-- Top Bar UI
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 38)
topBar.BorderSizePixel = 0
topBar.ZIndex = 20
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = topBar

local topFiller = Instance.new("Frame")
topFiller.Size = UDim2.new(1, 0, 0, 10)
topFiller.Position = UDim2.new(0, 0, 1, -10)
topFiller.BorderSizePixel = 0
topFiller.ZIndex = 20
topFiller.Parent = topBar

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -110, 1, 0)
titleLbl.Position = UDim2.new(0, 12, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "MIDASHUB - Shark Bite 2"
titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLbl.TextSize = 14
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 21
titleLbl.Parent = topBar

local btnContainer = Instance.new("Frame")
btnContainer.Size = UDim2.new(0, 60, 1, 0)
btnContainer.Position = UDim2.new(1, -70, 0, 0)
btnContainer.BackgroundTransparency = 1
btnContainer.ZIndex = 21
btnContainer.Parent = topBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
minimizeBtn.Position = UDim2.new(0, 0, 0.5, -13)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 16
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.ZIndex = 22
minimizeBtn.Parent = btnContainer

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(0, 32, 0.5, -13)
closeBtn.BackgroundColor3 = Color3.fromRGB(210, 40, 40)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 13
closeBtn.Font = Enum.Font.GothamBold
closeBtn.ZIndex = 22
closeBtn.Parent = btnContainer

local clsCorner = Instance.new("UICorner")
clsCorner.CornerRadius = UDim.new(0, 6)
clsCorner.Parent = closeBtn

-- ===============================================
-- UI INTERACTION AND DRAGGING SYSTEMS
-- ===============================================
local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        local tInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        PlayerTweenService:Create(mainFrame, tInfo, {Position = targetPos}):Play()
        if not isMinimized then
            normalPos = targetPos
        end
    end
end)

local function toggleMinimize()
    isMinimized = not isMinimized
    local targetSize
    local targetPos
    
    if isMinimized then
        minimizeBtn.Text = "+"
        titleLbl.Text = "🦈 MIDASHUB"
        targetSize = UDim2.new(0, 220, 0, 38)
        targetPos = mainFrame.Position
    else
        minimizeBtn.Text = "-"
        titleLbl.Text = "MIDASHUB - Shark Bite 2"
        targetSize = normalSize
        targetPos = normalPos
    end
    
    local tInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    PlayerTweenService:Create(mainFrame, tInfo, {
        Size = targetSize,
        Position = targetPos
    }):Play()
end
minimizeBtn.MouseButton1Click:Connect(toggleMinimize)

local function createConfirmPopup()
    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0, 260, 0, 130)
    popup.Position = UDim2.new(0.5, -130, 0.5, -65)
    popup.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    popup.ZIndex = 50
    popup.Parent = screenGui
    
    local pStroke = Instance.new("UIStroke")
    pStroke.Thickness = 2
    pStroke.Parent = popup
    
    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(0, 12)
    pCorner.Parent = popup
    
    local popupRGB = RunService.RenderStepped:Connect(function()
        if popup and popup.Parent then
            pStroke.Color = getRainbowColor(0.8)
        end
    end)
    
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, 0, 0, 50)
    msg.Position = UDim2.new(0, 0, 0, 15)
    msg.BackgroundTransparency = 1
    msg.Text = "Are you sure you want\nto close?"
    msg.TextColor3 = Color3.fromRGB(255, 230, 230)
    msg.TextSize = 13
    msg.Font = Enum.Font.GothamBold
    msg.ZIndex = 51
    msg.Parent = popup
    
    local yesBtn = Instance.new("TextButton")
    yesBtn.Size = UDim2.new(0, 90, 0, 30)
    yesBtn.Position = UDim2.new(0.15, 0, 0.65, 0)
    yesBtn.BackgroundColor3 = Color3.fromRGB(210, 40, 40)
    yesBtn.Text = "Yes"
    yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    yesBtn.Font = Enum.Font.GothamBold
    yesBtn.ZIndex = 51
    yesBtn.Parent = popup
    Instance.new("UICorner", yesBtn).CornerRadius = UDim.new(0, 6)
    
    local noBtn = Instance.new("TextButton")
    noBtn.Size = UDim2.new(0, 90, 0, 30)
    noBtn.Position = UDim2.new(0.55, 0, 0.65, 0)
    noBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    noBtn.Text = "No"
    noBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    noBtn.Font = Enum.Font.GothamBold
    noBtn.ZIndex = 51
    noBtn.Parent = popup
    Instance.new("UICorner", noBtn).CornerRadius = UDim.new(0, 6)
    
    yesBtn.MouseButton1Click:Connect(function()
        playerEspEnabled = false
        popupRGB:Disconnect()
        screenGui:Destroy()
    end)
    
    noBtn.MouseButton1Click:Connect(function()
        popupRGB:Disconnect()
        popup:Destroy()
    end)
end
closeBtn.MouseButton1Click:Connect(createConfirmPopup)

-- ===============================================
-- PILL TOGGLE FACTORY
-- ===============================================
local function makePillRow(parent, yPos, labelText)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -16, 0, 40)
    row.Position = UDim2.new(0, 8, 0, yPos)
    row.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    row.BorderSizePixel = 0
    row.ZIndex = 11
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -110, 1, 0)
    lbl.Position = UDim2.new(0, 15, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(160, 160, 175)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 12
    lbl.Parent = row
    
    local pillBg = Instance.new("Frame")
    pillBg.Size = UDim2.new(0, 58, 0, 28)
    pillBg.Position = UDim2.new(1, -66, 0.5, -14)
    pillBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    pillBg.BorderSizePixel = 0
    pillBg.ZIndex = 12
    pillBg.Parent = row
    Instance.new("UICorner", pillBg).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = UDim2.new(0, 3, 0.5, -11)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 13
    knob.Parent = pillBg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 14
    btn.Parent = pillBg
    
    return { pillBg = pillBg, knob = knob, btn = btn, lbl = lbl }
end

local espPill = makePillRow(mainFrame, 46, "Shark Box ESP")
local aimPill = makePillRow(mainFrame, 92, "Aimbot")
local boatPill = makePillRow(mainFrame, 138, "Boats Box ESP")
local playerPill = makePillRow(mainFrame, 184, "Players Box ESP")
-- ===============================================
-- ADDITIONAL FEATURE ROWS (FULLBRIGHT)
-- ===============================================
local brightPill = makePillRow(mainFrame, 230, "Full Bright")

-- Action Button Row Factory
local function makeActionRow(parent, yPos, labelText, btnText, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -16, 0, 40)
    row.Position = UDim2.new(0, 8, 0, yPos)
    row.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    row.BorderSizePixel = 0
    row.ZIndex = 11
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -140, 1, 0)
    lbl.Position = UDim2.new(0, 15, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(160, 160, 175)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 12
    lbl.Parent = row
    
    local actBtn = Instance.new("TextButton")
    actBtn.Size = UDim2.new(0, 125, 0, 28)
    actBtn.Position = UDim2.new(1, -133, 0.5, -14)
    actBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    actBtn.Text = btnText
    actBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    actBtn.TextSize = 9
    actBtn.Font = Enum.Font.GothamBold
    actBtn.ZIndex = 13
    actBtn.Parent = row
    Instance.new("UICorner", actBtn).CornerRadius = UDim.new(0, 6)
    
    local bStroke = Instance.new("UIStroke")
    bStroke.Thickness = 1.5
    bStroke.Color = Color3.fromRGB(60, 60, 65)
    bStroke.Parent = actBtn
    
    actBtn.MouseButton1Click:Connect(callback)
    return actBtn, bStroke
end

-- Event Chest Teleport - DISABLED (Preserved Visually)
local chestBtn, chestStroke = makeActionRow(mainFrame, 276, "1000 Teeth Chest", "DISABLED", function()
    -- Kept completely empty for future developments
end)


-- Manual Input and Reset Box Factory
local function makeInputAndResetRow(parent, yPos, labelText, defaultValue, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -16, 0, 40)
    row.Position = UDim2.new(0, 8, 0, yPos)
    row.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    row.BorderSizePixel = 0
    row.ZIndex = 11
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -160, 1, 0)
    lbl.Position = UDim2.new(0, 15, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(160, 160, 175)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 12
    lbl.Parent = row
    
    local boxBg = Instance.new("Frame")
    boxBg.Size = UDim2.new(0, 54, 0, 28)
    boxBg.Position = UDim2.new(1, -100, 0.5, -14)
    boxBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    boxBg.BorderSizePixel = 0
    boxBg.ZIndex = 12
    boxBg.Parent = row
    Instance.new("UICorner", boxBg).CornerRadius = UDim.new(0, 6)
    
    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(80, 80, 100)
    bStroke.Thickness = 1
    bStroke.Parent = boxBg
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, 0, 1, 0)
    textBox.BackgroundTransparency = 1
    textBox.Text = tostring(defaultValue)
    textBox.TextColor3 = Color3.fromRGB(255, 230, 100)
    textBox.TextSize = 13
    textBox.Font = Enum.Font.GothamBold
    textBox.ClearTextOnFocus = false
    textBox.ZIndex = 13
    textBox.Parent = boxBg
    
    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(0, 36, 0, 28)
    resetBtn.Position = UDim2.new(1, -42, 0.5, -14)
    resetBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
    resetBtn.Text = "RST"
    resetBtn.TextColor3 = Color3.fromRGB(255, 220, 220)
    resetBtn.TextSize = 11
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.ZIndex = 13
    resetBtn.Parent = row
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 6)
    
    textBox.FocusLost:Connect(function()
        local val = tonumber(textBox.Text)
        if val then 
            callback(val) 
        else 
            textBox.Text = tostring(defaultValue) 
        end
    end)
    
    resetBtn.MouseButton1Click:Connect(function()
        textBox.Text = tostring(defaultValue)
        callback(defaultValue)
    end)
end


local divider = Instance.new("Frame")
divider.Size = UDim2.new(1,-16,0,1)
divider.Position = UDim2.new(0,8,0,320)
divider.BackgroundColor3 = Color3.fromRGB(70,70,70)
divider.BorderSizePixel = 0
divider.Parent = mainFrame

-- PANEL LIST LABELS
local secLbl = Instance.new("TextLabel")
secLbl.Size = UDim2.new(1, -16, 0, 20)
secLbl.Position = UDim2.new(0, 8, 0, 330)
secLbl.BackgroundTransparency = 1
secLbl.Text = "DETECTED SHARK PLAYERS"
secLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
secLbl.TextSize = 10
secLbl.Font = Enum.Font.GothamBold
secLbl.TextXAlignment = Enum.TextXAlignment.Left
secLbl.ZIndex = 11
secLbl.Parent = mainFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -16, 1, -360)
scrollFrame.Position = UDim2.new(0, 8, 0, 352)
scrollFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ZIndex = 11
scrollFrame.Parent = mainFrame
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 8)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

local listPad = Instance.new("UIPadding")
listPad.PaddingTop = UDim.new(0, 6)
listPad.PaddingLeft = UDim.new(0, 6)
listPad.PaddingRight = UDim.new(0, 6)
listPad.Parent = scrollFrame

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
end)

-- ===============================================
-- ALGORITHMIC METHODS
-- ===============================================
local function getOwner(model)
    local ownerVal = model:FindFirstChild("PlayerOwner")
    if ownerVal and ownerVal:IsA("ObjectValue") and ownerVal.Value then
        local ref = ownerVal.Value
        if ref:IsA("Player") then 
            return ref 
        end
        local byName = Players:FindFirstChild(ref.Name)
        if byName then 
            return byName 
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Team and p.Team.Name == SHARK_TEAM then
            if string.find(model.Name, p.Name, 1, true) then 
                return p 
            end
        end
    end
    return "AI"
end

local function getPrimary(model)
    return model.PrimaryPart or model:FindFirstChildOfClass("BasePart")
end

local function getDistance(model)
    local char = player.Character
    if not char then 
        return 99999 
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local prim = getPrimary(model)
    if not hrp or not prim then 
        return 99999 
    end
    return math.floor((hrp.Position - prim.Position).Magnitude)
end

local function getBarData(dist)
    local ratio = math.clamp(1 - (dist / 1500), 0, 1)
    local r = math.clamp(math.floor(510 * ratio), 0, 255)
    local g = math.clamp(math.floor(510 * (1 - ratio)), 0, 255)
    return ratio, Color3.fromRGB(r, g, 40)
end

local function getClosestShark()
    local closestModel = nil
    local shortestDist = MAX_DIST
    for model, _ in pairs(tracked) do
        local dist = getDistance(model)
        if dist < shortestDist then
            shortestDist = dist
            closestModel = model
        end
    end
    return closestModel
end

local function createSelectionBox(model, color)
    local box = Instance.new("SelectionBox")
    box.Name = "_HackBox"
    box.Color3 = color
    box.LineThickness = 0.06
    box.SurfaceColor3 = color
    box.SurfaceTransparency = 0.92
    box.Adornee = model
    box.Parent = workspace
    return box
end

local function createBillboard(model, owner)
    local prim = getPrimary(model)
    if not prim then 
        return nil 
    end
    
    local bb = Instance.new("BillboardGui")
    bb.Name = "_SharkBB"
    bb.Size = UDim2.new(0, 180, 0, 64)
    bb.StudsOffset = Vector3.new(2, 4, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = prim
    bb.Parent = workspace
    
    local sharkLbl = Instance.new("TextLabel")
    sharkLbl.Size = UDim2.new(1, 0, 0, 28)
    sharkLbl.BackgroundTransparency = 1
    sharkLbl.Text = "🦈 " .. model.Name
    sharkLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
    sharkLbl.TextSize = 14
    sharkLbl.Font = Enum.Font.GothamBold
    sharkLbl.Parent = bb
    
    local ownerBbLbl = Instance.new("TextLabel")
    ownerBbLbl.Size = UDim2.new(1, 0, 0, 20)
    ownerBbLbl.Position = UDim2.new(0, 0, 0, 28)
    ownerBbLbl.BackgroundTransparency = 1
    ownerBbLbl.Text = owner == "AI" and "🤖 AI" or ("👤 " .. owner.Name)
    ownerBbLbl.TextColor3 = Color3.fromRGB(255, 210, 210)
    ownerBbLbl.TextSize = 11
    ownerBbLbl.Font = Enum.Font.Gotham
    ownerBbLbl.Parent = bb
    
    local distBbLbl = Instance.new("TextLabel")
    distBbLbl.Size = UDim2.new(1, 0, 0, 16)
    distBbLbl.Position = UDim2.new(0, 0, 0, 48)
    distBbLbl.BackgroundTransparency = 1
    distBbLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    distBbLbl.TextSize = 10
    distBbLbl.Font = Enum.Font.Gotham
    distBbLbl.Parent = bb
    
    return bb, sharkLbl, distBbLbl, ownerBbLbl
end

local function trackModel(model)
    if tracked[model] then 
        return 
    end
    local owner = getOwner(model)
    
    local selBox, bb, sharkBbLbl, distBbLbl, ownerBbLbl
    if boxEspEnabled then
        selBox = createSelectionBox(model, BOX_COLOR)
        bb, sharkBbLbl, distBbLbl, ownerBbLbl = createBillboard(model, owner)
    end
    
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -8, 0, 75)
    card.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    card.BorderSizePixel = 0
    card.ZIndex = 12
    card.Parent = scrollFrame
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    local cStroke = Instance.new("UIStroke")
    cStroke.Color = Color3.fromRGB(255, 50, 50)
    cStroke.Thickness = 1
    cStroke.Transparency = 0.5
    cStroke.Parent = card
    
    local iconBox = Instance.new("Frame")
    iconBox.Size = UDim2.new(0, 46, 0, 46)
    iconBox.Position = UDim2.new(0, 10, 0.5, -23)
    iconBox.BackgroundColor3 = Color3.fromRGB(140, 20, 20)
    iconBox.BorderSizePixel = 0
    iconBox.ZIndex = 13
    iconBox.Parent = card
    Instance.new("UICorner", iconBox).CornerRadius = UDim.new(0, 8)
    
    local ibl = Instance.new("TextLabel")
    ibl.Size = UDim2.new(1, 0, 1, 0)
    ibl.BackgroundTransparency = 1
    ibl.Text = "🦈"
    ibl.TextSize = 24
    ibl.ZIndex = 14
    ibl.Parent = iconBox

    local modelNameLbl = Instance.new("TextLabel")
    modelNameLbl.Size = UDim2.new(1, -150, 0, 22)
    modelNameLbl.Position = UDim2.new(0, 68, 0, 10)
    modelNameLbl.BackgroundTransparency = 1
    modelNameLbl.Text = model.Name
    modelNameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    modelNameLbl.TextSize = 14
    modelNameLbl.Font = Enum.Font.GothamBold
    modelNameLbl.TextXAlignment = Enum.TextXAlignment.Left
    modelNameLbl.ZIndex = 13
    modelNameLbl.Parent = card
    
    local ownerCardLbl = Instance.new("TextLabel")
    ownerCardLbl.Size = UDim2.new(1, -150, 0, 16)
    ownerCardLbl.Position = UDim2.new(0, 68, 0, 30)
    ownerCardLbl.BackgroundTransparency = 1
    
    local ownerText = owner == "AI" and "🤖 AI (Bot)" or ("👑 SHARK: " .. owner.Name)
    ownerCardLbl.Text = ownerText
    ownerCardLbl.TextColor3 = owner == "AI" and Color3.fromRGB(200, 110, 110) or Color3.fromRGB(255, 70, 70)
    ownerCardLbl.TextSize = 11
    ownerCardLbl.Font = Enum.Font.GothamBold
    ownerCardLbl.TextXAlignment = Enum.TextXAlignment.Left
    ownerCardLbl.ZIndex = 13
    ownerCardLbl.Parent = card
    
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -150, 0, 8)
    barBg.Position = UDim2.new(0, 68, 0, 50)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    barBg.ZIndex = 13
    barBg.Parent = card
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
    
    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    barFill.ZIndex = 14
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
    
    local distCardLbl = Instance.new("TextLabel")
    distCardLbl.Size = UDim2.new(0, 100, 0, 14)
    distCardLbl.Position = UDim2.new(0, 68, 0, 60)
    distCardLbl.BackgroundTransparency = 1
    distCardLbl.Text = "-- studs"
    distCardLbl.TextColor3 = Color3.fromRGB(150, 150, 165)
    distCardLbl.TextSize = 10
    distCardLbl.Font = Enum.Font.Gotham
    distCardLbl.TextXAlignment = Enum.TextXAlignment.Left
    distCardLbl.ZIndex = 13
    distCardLbl.Parent = card
    
    local boxBadgeBg = Instance.new("Frame")
    boxBadgeBg.Size = UDim2.new(0, 64, 0, 24)
    boxBadgeBg.Position = UDim2.new(1, -74, 0.5, -12)
    boxBadgeBg.BackgroundColor3 = Color3.fromRGB(70, 28, 28)
    boxBadgeBg.ZIndex = 13
    boxBadgeBg.Parent = card
    Instance.new("UICorner", boxBadgeBg).CornerRadius = UDim.new(0, 6)
    
    local boxBadgeLbl = Instance.new("TextLabel")
    boxBadgeLbl.Size = UDim2.new(1, 0, 1, 0)
    boxBadgeLbl.BackgroundTransparency = 1
    boxBadgeLbl.Text = "ESP X"
    boxBadgeLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    boxBadgeLbl.TextSize = 10
    boxBadgeLbl.Font = Enum.Font.GothamBold
    boxBadgeLbl.ZIndex = 14
    boxBadgeLbl.Parent = boxBadgeBg
    
    tracked[model] = {
        selBox = selBox, billboard = bb, sharkBbLbl = sharkBbLbl, distBbLbl = distBbLbl, ownerBbLbl = ownerBbLbl,
        card = card, barFill = barFill, distCardLbl = distCardLbl, ownerCardLbl = ownerCardLbl, boxBadgeBg = boxBadgeBg, boxBadgeLbl = boxBadgeLbl
    }
end

local function untrackModel(model)
    local d = tracked[model]
    if not d then 
        return 
    end
    if d.selBox then 
        d.selBox:Destroy() 
    end
    if d.billboard then 
        d.billboard:Destroy() 
    end
    if d.card then 
        d.card:Destroy() 
    end
    tracked[model] = nil
end

local function trackBoat(model)
    if trackedBoats[model] then 
        return 
    end
    local box = nil
    if boatEspEnabled then 
        box = createSelectionBox(model, BOAT_COLOR) 
    end
    trackedBoats[model] = { selBox = box }
end

local function untrackBoat(model)
    if trackedBoats[model] then 
        if trackedBoats[model].selBox then 
            trackedBoats[model].selBox:Destroy() 
        end 
        trackedBoats[model] = nil 
    end
end

local function updatePillVisual(pill, state)
    local targetPos = state and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
    local targetColor = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 165)
    PlayerTweenService:Create(pill.knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
    pill.lbl.TextColor3 = targetColor
end

-- ===============================================
-- ACTIVE TOGGLE TRIGGERS
-- ===============================================
espPill.btn.MouseButton1Click:Connect(function()
    boxEspEnabled = not boxEspEnabled
    updatePillVisual(espPill, boxEspEnabled)
    for model, data in pairs(tracked) do
        if boxEspEnabled then
            if not data.selBox then 
                data.selBox = createSelectionBox(model, BOX_COLOR) 
            end
            if not data.billboard then 
                data.billboard, data.sharkBbLbl, data.distBbLbl, data.ownerBbLbl = createBillboard(model, getOwner(model)) 
            end
            data.boxBadgeBg.BackgroundColor3 = Color3.fromRGB(22, 120, 22)
            data.boxBadgeLbl.Text = "ESP V"
        else
            if data.selBox then 
                data.selBox:Destroy()
                data.selBox = nil 
            end
            if data.billboard then 
                data.billboard:Destroy()
                data.billboard = nil 
            end
            data.boxBadgeBg.BackgroundColor3 = Color3.fromRGB(70, 28, 28)
            data.boxBadgeLbl.Text = "ESP X"
        end
    end
end)

aimPill.btn.MouseButton1Click:Connect(function() 
    aimbotEnabled = not aimbotEnabled
    updatePillVisual(aimPill, aimbotEnabled) 
end)

boatPill.btn.MouseButton1Click:Connect(function()
    boatEspEnabled = not boatEspEnabled
    updatePillVisual(boatPill, boatEspEnabled)
    for model, data in pairs(trackedBoats) do
        if boatEspEnabled then 
            if not data.selBox then 
                data.selBox = createSelectionBox(model, BOAT_COLOR) 
            end
        else 
            if data.selBox then 
                data.selBox:Destroy()
                data.selBox = nil 
            end 
        end
    end
end)

playerPill.btn.MouseButton1Click:Connect(function()
    playerEspEnabled = not playerEspEnabled
    updatePillVisual(playerPill, playerEspEnabled)
    if not playerEspEnabled then 
        for char, box in pairs(trackedPlayers) do 
            if box then 
                box:Destroy() 
            end 
        end 
        trackedPlayers = {} 
    end
end)

-- FullBright Trigger
brightPill.btn.MouseButton1Click:Connect(function()
    fullBrightEnabled = not fullBrightEnabled
    updatePillVisual(brightPill, fullBrightEnabled)
    if fullBrightEnabled then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.ClockTime = 12
        Lighting.FogEnd = 999999
        -- Clear sky fog filters safely
        for _, fx in ipairs(Lighting:GetDescendants()) do
            if fx:IsA("Atmosphere") or fx:IsA("Sky") or fx:IsA("Clouds") then
                fx:Destroy()
            end
        end
    else
        Lighting.Ambient = origAmbient
        Lighting.OutdoorAmbient = origOutdoorAmbient
        Lighting.ClockTime = origClockTime
        Lighting.FogEnd = origFogEnd
    end
end)

-- Folder Track Event Connections
if sharksFolder then
    for _, child in ipairs(sharksFolder:GetChildren()) do 
        if child:IsA("Model") then 
            trackModel(child) 
        end 
    end
    sharksFolder.ChildAdded:Connect(function(child) 
        if child:IsA("Model") then 
            task.wait(0.5)
            trackModel(child) 
        end 
    end)
    sharksFolder.ChildRemoved:Connect(untrackModel)
end

if boatsFolder then
    for _, child in ipairs(boatsFolder:GetChildren()) do 
        if child:IsA("Model") then 
            trackBoat(child) 
        end 
    end
    boatsFolder.ChildAdded:Connect(function(child) 
        if child:IsA("Model") then 
            task.wait(0.5)
            trackBoat(child) 
        end 
    end)
    boatsFolder.ChildRemoved:Connect(untrackBoat)
end

-- ===============================================
-- CORE RGB ENGINE AND SYSTEM LOOP
-- ===============================================
RunService.RenderStepped:Connect(function()
    local rainbowColor = getRainbowColor(0.5)
    local slowRainbowColor = getRainbowColor(0.15) -- AÇILIŞ PANELİ İÇİN YAVAŞ, AKICI VE GÖZ YORMAYAN ÖZEL HIZ
    
    if introFrame and introFrame.Parent then
        loadBarFill.BackgroundColor3 = rainbowColor
        barGlow.Color = rainbowColor
        midasStroke.Color = rainbowColor
        
        -- AÇILIŞ MERKEZ PANELİNİN ÇİZGİSİNİ YAVAŞ RENK AKIŞIYLA RENKLENDİRME
        if introCenterStroke then
            introCenterStroke.Color = slowRainbowColor
        end
    end
    
    if mainFrame.Visible then
        mainStroke.Color = rainbowColor
        topBar.BackgroundColor3 = rainbowColor
        topFiller.BackgroundColor3 = rainbowColor
        scrollFrame.ScrollBarImageColor3 = rainbowColor
        readyStroke.Color = rainbowColor
        
        espPill.pillBg.BackgroundColor3 = boxEspEnabled and rainbowColor or Color3.fromRGB(45, 45, 55)
        aimPill.pillBg.BackgroundColor3 = aimbotEnabled and rainbowColor or Color3.fromRGB(45, 45, 55)
        boatPill.pillBg.BackgroundColor3 = boatEspEnabled and rainbowColor or Color3.fromRGB(45, 45, 55)
        playerPill.pillBg.BackgroundColor3 = playerEspEnabled and rainbowColor or Color3.fromRGB(45, 45, 55)
        brightPill.pillBg.BackgroundColor3 = fullBrightEnabled and rainbowColor or Color3.fromRGB(45, 45, 55)
    end

    -- Render Distance Optimization Loop Fix
    if fullBrightEnabled then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.ClockTime = 12
        Lighting.FogEnd = 999999
        for _, fx in ipairs(Lighting:GetDescendants()) do
            if fx:IsA("Atmosphere") then
                fx:Destroy()
            end
        end
    end

    for model, data in pairs(tracked) do
        local dist = getDistance(model)
        local ratio, bColor = getBarData(dist)
        data.barFill.Size = UDim2.new(ratio, 0, 1, 0)
        data.barFill.BackgroundColor3 = bColor
        data.distCardLbl.Text = tostring(dist) .. " studs"
        if data.distBbLbl then 
            data.distBbLbl.Text = "📍 " .. tostring(dist) .. " studs" 
        end
    end
    
    if playerEspEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not trackedPlayers[p.Character] then 
                    trackedPlayers[p.Character] = createSelectionBox(p.Character, PLAYER_COLOR) 
                end
            end
        end
        for char, box in pairs(trackedPlayers) do 
            if not char or not char.Parent then 
                if box then 
                    box:Destroy() 
                end 
                trackedPlayers[char] = nil 
            end 
        end
    end
end)

-- Aimbot Camera Tracking Thread
RunService:UnbindFromRenderStep("SharkAimbotTask")
RunService:BindToRenderStep("SharkAimbotTask", Enum.RenderPriority.Camera.Value + 1, function()
    if aimbotEnabled and player.Character and player.Character:FindFirstChildOfClass("Tool") then
        local targetShark = getClosestShark()
        if targetShark and getPrimary(targetShark) then
            workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, getPrimary(targetShark).Position)
        end
    end
end)

-- ===============================================
-- 10-SECOND CINEMATIC ANIMATION & BOOT LOADER
-- ===============================================
task.spawn(function()
    local startTime = os.clock()
    local duration = 10
    local statusMessages = {
        {0.0, "🌈 Synchronizing MIDASHUB Drivers..."},
        {2.5, "🦈 Optimizing Shark Detection Cards..."},
        {5.0, "⚡ Setting Up Camera Lock Engine..."},
        {7.5, "🛠️ Connecting Protection Layers..."},
        {9.3, "✨ System Active! Panel Ready."}
    }
    
    while true do
        local elapsed = os.clock() - startTime
        local progress = math.clamp(elapsed / duration, 0, 1)
        loadBarFill.Size = UDim2.new(progress, 0, 1, 0)
        
        for _, msgData in ipairs(statusMessages) do 
            if elapsed >= msgData[1] then 
                statusLbl.Text = msgData[2] 
            end 
        end
        if progress >= 1 then 
            break 
        end
        task.wait()
    end
    
    loadBarBg:Destroy()
    statusLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLbl.Text = "MIDASHUB is Ready to Launch!"
    readyBtn.Visible = true
    readyBtn.Size = UDim2.new(0, 0, 0, 48)
    readyBtn.Position = UDim2.new(0.5, 0, 0.75, 0)
    
    local bTween = PlayerTweenService:Create(readyBtn, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 190, 0, 48), 
        Position = UDim2.new(0.5, -95, 0.75, 0)
    })
    bTween:Play()
end)

readyBtn.MouseButton1Click:Connect(function()
    local fadeTween = PlayerTweenService:Create(introFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Position = UDim2.new(0, 0, -1, 0)
    })
    fadeTween:Play()
    fadeTween.Completed:Wait()
    introFrame:Destroy()
    
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Visible = true
    
    PlayerTweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = normalSize, 
        Position = normalPos
    }):Play()
end)
