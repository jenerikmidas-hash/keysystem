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
local flyEnabled = false
local noclipEnabled = false
local sharkTrackEnabled = false
local playerTrackEnabled = false

local tracked = {}
local trackedBoats = {}
local trackedPlayers = {}
local isMinimized = false

-- Panel Size Settings
local normalSize = UDim2.new(0, 600, 0, 450)
local normalPos = UDim2.new(0.5, -300, 0.5, -225)

local forceMouseUnlock = false
local aimbotTargetShark = nil

local flyBv = nil
local flyGyro = nil
local flySpeed = 50

-- Original Lighting Backups
local origAmbient = Lighting.Ambient
local origOutdoorAmbient = Lighting.OutdoorAmbient
local origClockTime = Lighting.ClockTime
local origFogEnd = Lighting.FogEnd
local origGlobalShadows = Lighting.GlobalShadows

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
mainStroke.Color = Color3.fromRGB(180, 40, 40)
mainStroke.Parent = mainFrame

mainFrame.Parent = screenGui
screenGui.Parent = playerGui

-- Top Bar UI
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 38)
topBar.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
topBar.BorderSizePixel = 0
topBar.ZIndex = 20
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = topBar

local topFiller = Instance.new("Frame")
topFiller.Size = UDim2.new(1, 0, 0, 10)
topFiller.Position = UDim2.new(0, 0, 1, -10)
topFiller.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
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
-- TAB SYSTEM AND LAYOUT
-- ===============================================
local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0, 150, 1, -38)
leftPanel.Position = UDim2.new(0, 0, 0, 38)
leftPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
leftPanel.BorderSizePixel = 0
leftPanel.ZIndex = 20
leftPanel.Parent = mainFrame
Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 8)

local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(1, -155, 1, -43)
rightPanel.Position = UDim2.new(0, 150, 0, 38)
rightPanel.BackgroundTransparency = 1
rightPanel.ZIndex = 20
rightPanel.Parent = mainFrame

local tabListLayout = Instance.new("UIListLayout")
tabListLayout.Padding = UDim.new(0, 5)
tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabListLayout.Parent = leftPanel
local tabPad = Instance.new("UIPadding")
tabPad.PaddingTop = UDim.new(0, 10)
tabPad.PaddingLeft = UDim.new(0, 10)
tabPad.PaddingRight = UDim.new(0, 10)
tabPad.Parent = leftPanel

local function createTabContent()
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 2
    scroll.Visible = false
    scroll.BorderSizePixel = 0
    scroll.ZIndex = 11
    scroll.Parent = rightPanel
    
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 8)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = scroll
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, 10)
    p.PaddingLeft = UDim.new(0, 5)
    p.PaddingRight = UDim.new(0, 10)
    p.Parent = scroll
    
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, l.AbsoluteContentSize.Y + 20)
    end)
    return scroll
end

local sharkContent = createTabContent()
local survContent = createTabContent()
local setnContent = createTabContent()
sharkContent.Visible = true
local currentTab = sharkContent

local function makeTabBtn(text, targetContent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = targetContent == currentTab and Color3.fromRGB(40, 40, 55) or Color3.fromRGB(20, 20, 30)
    btn.Text = text
    btn.TextColor3 = targetContent == currentTab and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 160)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.ZIndex = 21
    btn.Parent = leftPanel
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        for _, child in ipairs(leftPanel:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
                child.TextColor3 = Color3.fromRGB(150, 150, 160)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        sharkContent.Visible = false
        survContent.Visible = false
        setnContent.Visible = false
        targetContent.Visible = true
        currentTab = targetContent
    end)
    return btn
end

makeTabBtn("🦈 Shark", sharkContent)
makeTabBtn("🏃 Survivor", survContent)
makeTabBtn("⚙️ Settings", setnContent)

-- ===============================================
-- UI COMPONENT FACTORIES
-- ===============================================
local function makePillRow(parent, labelText)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 40)
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
    pillBg.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
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

local function makeActionRow(parent, labelText, btnText, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 40)
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

-- ===============================================
-- POPULATING TABS
-- ===============================================

-- SHARK TAB
local espPill = makePillRow(sharkContent, "Shark Box ESP")
local mousePill = makePillRow(sharkContent, "Force Mouse Unlock")
local boatPill = makePillRow(sharkContent, "Boats Box ESP")
local playerPill = makePillRow(sharkContent, "Players Box ESP")
local sharkTrackPill = makePillRow(sharkContent, "Shark Track")

local secLbl = Instance.new("TextLabel")
secLbl.Size = UDim2.new(1, 0, 0, 20)
secLbl.BackgroundTransparency = 1
secLbl.Text = " DETECTED SHARK PLAYERS"
secLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
secLbl.TextSize = 10
secLbl.Font = Enum.Font.GothamBold
secLbl.TextXAlignment = Enum.TextXAlignment.Left
secLbl.ZIndex = 11
secLbl.Parent = sharkContent

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 0, 220)
scrollFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ZIndex = 11
scrollFrame.Parent = sharkContent
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

-- SURVIVOR TAB
local playerTrackPill = makePillRow(survContent, "Player Track")
local aimPill = makePillRow(survContent, "Aimbot")
local flyPill = makePillRow(survContent, "Fly")
local noclipPill = makePillRow(survContent, "Noclip")

local heliBtn, heliStroke = makeActionRow(survContent, "Teleport Helicopter", "TELEPORT", function()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local floor = nil
    pcall(function() floor = workspace.Chinook.Collisions.Interior.Floor end)
    if floor and floor:IsA("BasePart") then
        char.HumanoidRootPart.CFrame = floor.CFrame + Vector3.new(0, 4, 0)
    end
end)

local chestBtn, chestStroke = makeActionRow(survContent, "Teleport Chest", "TELEPORT", function()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local floor = nil
    pcall(function() floor = workspace.Chest.Chest.Main end)
    if floor and floor:IsA("BasePart") then
        char.HumanoidRootPart.CFrame = floor.CFrame * CFrame.new(4, 2, 0)
    end
end)

-- SETTINGS TAB
local brightPill = makePillRow(setnContent, "Full Bright")

local flySpeedRow = Instance.new("Frame")
flySpeedRow.Size = UDim2.new(1, 0, 0, 60)
flySpeedRow.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
flySpeedRow.BorderSizePixel = 0
flySpeedRow.ZIndex = 11
flySpeedRow.Parent = setnContent
Instance.new("UICorner", flySpeedRow).CornerRadius = UDim.new(0, 8)

local fsLbl = Instance.new("TextLabel")
fsLbl.Size = UDim2.new(1, -20, 0, 20)
fsLbl.Position = UDim2.new(0, 15, 0, 10)
fsLbl.BackgroundTransparency = 1
fsLbl.Text = "Fly Speed: 50"
fsLbl.TextColor3 = Color3.fromRGB(160, 160, 175)
fsLbl.TextSize = 13
fsLbl.Font = Enum.Font.Gotham
fsLbl.TextXAlignment = Enum.TextXAlignment.Left
fsLbl.ZIndex = 12
fsLbl.Parent = flySpeedRow

local fsSliderBg = Instance.new("Frame")
fsSliderBg.Size = UDim2.new(1, -30, 0, 6)
fsSliderBg.Position = UDim2.new(0, 15, 0, 38)
fsSliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
fsSliderBg.ZIndex = 12
fsSliderBg.Parent = flySpeedRow
Instance.new("UICorner", fsSliderBg).CornerRadius = UDim.new(1, 0)

local fsSliderFill = Instance.new("Frame")
fsSliderFill.Size = UDim2.new(0.25, 0, 1, 0)
fsSliderFill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
fsSliderFill.ZIndex = 13
fsSliderFill.Parent = fsSliderBg
Instance.new("UICorner", fsSliderFill).CornerRadius = UDim.new(1, 0)

local fsSliderKnob = Instance.new("Frame")
fsSliderKnob.Size = UDim2.new(0, 16, 0, 16)
fsSliderKnob.Position = UDim2.new(0.25, -8, 0.5, -8)
fsSliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fsSliderKnob.ZIndex = 14
fsSliderKnob.Parent = fsSliderBg
Instance.new("UICorner", fsSliderKnob).CornerRadius = UDim.new(1, 0)

local fsBtn = Instance.new("TextButton")
fsBtn.Size = UDim2.new(1, 0, 1, 0)
fsBtn.BackgroundTransparency = 1
fsBtn.Text = ""
fsBtn.ZIndex = 15
fsBtn.Parent = fsSliderBg

local sliderDragging = false
fsBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local relativeX = math.clamp(input.Position.X - fsSliderBg.AbsolutePosition.X, 0, fsSliderBg.AbsoluteSize.X)
        local ratio = relativeX / fsSliderBg.AbsoluteSize.X
        fsSliderFill.Size = UDim2.new(ratio, 0, 1, 0)
        fsSliderKnob.Position = UDim2.new(ratio, -8, 0.5, -8)
        flySpeed = math.floor(10 + (ratio * 190)) -- Range: 10 to 200
        fsLbl.Text = "Fly Speed: " .. tostring(flySpeed)
    end
end)

local authorLbl = Instance.new("TextLabel")
authorLbl.Size = UDim2.new(1, 0, 0, 30)
authorLbl.BackgroundTransparency = 1
authorLbl.Text = "Creator: MidasHUB"
authorLbl.TextColor3 = Color3.fromRGB(100, 100, 120)
authorLbl.TextSize = 13
authorLbl.Font = Enum.Font.GothamBold
authorLbl.ZIndex = 11
authorLbl.Parent = setnContent

local authorSubLbl = Instance.new("TextLabel")
authorSubLbl.Size = UDim2.new(1, 0, 0, 30)
authorSubLbl.BackgroundTransparency = 1
authorSubLbl.Text = "If you like the script, please like it on rscripts.net"
authorSubLbl.TextColor3 = Color3.fromRGB(100, 100, 120)
authorSubLbl.TextSize = 11
authorSubLbl.Font = Enum.Font.Gotham
authorSubLbl.ZIndex = 11
authorSubLbl.Parent = setnContent

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

local function trackModel(model)
    if tracked[model] then 
        return 
    end
    local owner = getOwner(model)
    
    local selBox
    if boxEspEnabled then
        selBox = createSelectionBox(model, BOX_COLOR)
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
    barBg.Size = UDim2.new(1, -150, 0, 6)
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
    distCardLbl.Size = UDim2.new(0, 140, 0, 14)
    distCardLbl.Position = UDim2.new(0, 68, 0, 60)
    distCardLbl.BackgroundTransparency = 1
    distCardLbl.Text = "-- studs"
    distCardLbl.TextColor3 = Color3.fromRGB(150, 150, 165)
    distCardLbl.TextSize = 10
    distCardLbl.Font = Enum.Font.Gotham
    distCardLbl.TextXAlignment = Enum.TextXAlignment.Left
    distCardLbl.ZIndex = 13
    distCardLbl.Parent = card
    
    local lockBtn = Instance.new("TextButton")
    lockBtn.Size = UDim2.new(0, 70, 0, 24)
    lockBtn.Position = UDim2.new(1, -80, 0.5, -12)
    lockBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    lockBtn.Text = "AIM LOCK"
    lockBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
    lockBtn.TextSize = 9
    lockBtn.Font = Enum.Font.GothamBold
    lockBtn.ZIndex = 13
    lockBtn.Parent = card
    Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0, 6)
    
    local lockStroke = Instance.new("UIStroke")
    lockStroke.Thickness = 1
    lockStroke.Color = Color3.fromRGB(80, 80, 100)
    lockStroke.Parent = lockBtn
    
    lockBtn.MouseButton1Click:Connect(function()
        if aimbotTargetShark == model then
            aimbotTargetShark = nil
            lockStroke.Color = Color3.fromRGB(80, 80, 100)
            lockBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
        else
            aimbotTargetShark = model
            for _, d in pairs(tracked) do
                if d.lockStroke then d.lockStroke.Color = Color3.fromRGB(80, 80, 100) end
                if d.lockBtn then d.lockBtn.TextColor3 = Color3.fromRGB(200, 200, 220) end
            end
            lockStroke.Color = Color3.fromRGB(255, 50, 50)
            lockBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    
    tracked[model] = {
        selBox = selBox, card = card, distCardLbl = distCardLbl, 
        ownerCardLbl = ownerCardLbl, lockStroke = lockStroke, lockBtn = lockBtn
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
    if d.card then 
        d.card:Destroy() 
    end
    if aimbotTargetShark == model then
        aimbotTargetShark = nil
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
    local targetBgColor = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    PlayerTweenService:Create(pill.knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
    PlayerTweenService:Create(pill.pillBg, TweenInfo.new(0.2), {BackgroundColor3 = targetBgColor}):Play()
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
        else
            if data.selBox then 
                data.selBox:Destroy()
                data.selBox = nil 
            end
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
        Lighting.GlobalShadows = false
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
        Lighting.GlobalShadows = origGlobalShadows
    end
end)

mousePill.btn.MouseButton1Click:Connect(function()
    forceMouseUnlock = not forceMouseUnlock
    updatePillVisual(mousePill, forceMouseUnlock)
end)

flyPill.btn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    updatePillVisual(flyPill, flyEnabled)
    
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    if flyEnabled then
        flyBv = Instance.new("BodyVelocity")
        flyBv.Velocity = Vector3.new(0, 0, 0)
        flyBv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBv.Parent = hrp
        
        flyGyro = Instance.new("BodyGyro")
        flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyGyro.P = 10000
        flyGyro.D = 50
        flyGyro.Parent = hrp
    else
        if flyBv then flyBv:Destroy() end
        if flyGyro then flyGyro:Destroy() end
    end
end)

noclipPill.btn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    updatePillVisual(noclipPill, noclipEnabled)
end)

sharkTrackPill.btn.MouseButton1Click:Connect(function()
    sharkTrackEnabled = not sharkTrackEnabled
    updatePillVisual(sharkTrackPill, sharkTrackEnabled)
end)

playerTrackPill.btn.MouseButton1Click:Connect(function()
    playerTrackEnabled = not playerTrackEnabled
    updatePillVisual(playerTrackPill, playerTrackEnabled)
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

local tracers = {}
local function updateTracer(id, p1, p2, color)
    local tracer = tracers[id]
    if not tracer then
        tracer = Instance.new("CylinderHandleAdornment")
        tracer.Name = "Tracer_" .. id
        tracer.Radius = 0.15
        tracer.AlwaysOnTop = true
        tracer.ZIndex = 10
        tracer.Adornee = workspace.Terrain
        tracer.Parent = screenGui
        tracers[id] = tracer
    end
    
    if p1 and p2 then
        local dist = (p2 - p1).Magnitude
        tracer.CFrame = CFrame.lookAt(p1, p2) * CFrame.new(0, 0, -dist/2)
        tracer.Height = dist
        tracer.Color3 = color
        tracer.Visible = true
    else
        tracer.Visible = false
    end
end

RunService.Stepped:Connect(function()
    if noclipEnabled and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local rainbowColor = getRainbowColor(0.2)
    local slowRainbowColor = getRainbowColor(0.1) -- AÇILIŞ PANELİ İÇİN YAVAŞ, AKICI VE GÖZ YORMAYAN ÖZEL HIZ
    
    if introFrame and introFrame.Parent then
        loadBarFill.BackgroundColor3 = rainbowColor
        barGlow.Color = rainbowColor
        midasStroke.Color = rainbowColor
        
        -- AÇILIŞ MERKEZ PANELİNİN ÇİZGİSİNİ YAVAŞ RENK AKIŞIYLA RENKLENDİRME
        if introCenterStroke then
            introCenterStroke.Color = slowRainbowColor
        end
    end


    if forceMouseUnlock then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    end
    
    if flyEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and flyBv and flyGyro then
        local cam = workspace.CurrentCamera
        local speed = flySpeed
        local moveVec = Vector3.new(0,0,0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVec = moveVec + cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVec = moveVec - cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVec = moveVec - cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVec = moveVec + cam.CFrame.RightVector
        end
        
        if moveVec.Magnitude > 0 then
            moveVec = moveVec.Unit * speed
        end
        
        flyBv.Velocity = moveVec
        flyGyro.CFrame = cam.CFrame
    end

    -- Render Distance Optimization Loop Fix
    if fullBrightEnabled then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.ClockTime = 12
        Lighting.FogEnd = 999999
        Lighting.GlobalShadows = false
        for _, fx in ipairs(Lighting:GetDescendants()) do
            if fx:IsA("Atmosphere") then
                fx:Destroy()
            end
        end
    end

    for model, data in pairs(tracked) do
        local dist = getDistance(model)
        data.distCardLbl.Text = tostring(dist) .. " studs"
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

    -- TRACERS LOGIC
    local localHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    for _, t in pairs(tracers) do
        t.Visible = false
    end
    
    if localHrp then
        if sharkTrackEnabled then
            for model, _ in pairs(tracked) do
                local tHrp = getPrimary(model)
                if tHrp then
                    updateTracer("Shark_"..model.Name, localHrp.Position, tHrp.Position, Color3.fromRGB(255, 0, 0))
                end
            end
        end
        
        if playerTrackEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    updateTracer("Player_"..p.Name, localHrp.Position, p.Character.HumanoidRootPart.Position, Color3.fromRGB(0, 255, 0))
                end
            end
        end
    end
end)

-- Aimbot Camera Tracking Thread
RunService:UnbindFromRenderStep("SharkAimbotTask")
RunService:BindToRenderStep("SharkAimbotTask", Enum.RenderPriority.Camera.Value + 1, function()
    if aimbotEnabled and player.Character and player.Character:FindFirstChildOfClass("Tool") then
        local targetShark = aimbotTargetShark
        if not targetShark or not getPrimary(targetShark) then
            targetShark = getClosestShark()
        end
        
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
