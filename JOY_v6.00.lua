--==================================================
-- JOY_ALER V6.0
-- UI + FLY CAMERA 3D
-- LocalScript
-- StarterPlayer > StarterPlayerScripts
--==================================================

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- REMOVE OLD GUI
--==================================================

for _, name in ipairs({
	"JoyxAler",
	"JoyxAler_Teleport",
	"JoyxAler_Fly",
	"ESP"
}) do
	local old = playerGui:FindFirstChild(name)
		or game.CoreGui:FindFirstChild(name)

	if old then
		old:Destroy()
	end
end

--==================================================
-- STATES
--==================================================

local brightOn = false
local boostOn = false
local fpsCounterOn = false
local espOn = false
local noclipOn = false
local flyActive = false

local teleportGui = nil
local flyGui = nil

local espThread = nil
local espConnectionAdded = nil
local espConnectionRemoved = nil
local NoclipConnection = nil
local flyConnection = nil
local flyBodyVelocity = nil
local flyBodyGyro = nil

local originalLighting = {}
local originalParticles = {}
local originalDecals = {}
local originalParts = {}
local originalPostEffects = {}

_G.FriendColor = Color3.fromRGB(0, 0, 255)
_G.EnemyColor = Color3.fromRGB(255, 0, 0)
_G.UseTeamColor = true

--==================================================
-- COLORS
--==================================================

local BG = Color3.fromRGB(5, 8, 18)
local BG2 = Color3.fromRGB(8, 12, 25)
local PANEL = Color3.fromRGB(9, 13, 27)

local CYAN = Color3.fromRGB(0, 180, 210)
local CYAN_DARK = Color3.fromRGB(0, 70, 90)

local PURPLE = Color3.fromRGB(145, 55, 210)
local PURPLE_DARK = Color3.fromRGB(55, 25, 80)

local PINK = Color3.fromRGB(210, 45, 135)
local GREEN = Color3.fromRGB(25, 150, 90)

local TEXT = Color3.fromRGB(225, 235, 245)
local MUTED = Color3.fromRGB(125, 145, 165)

local BUTTON = Color3.fromRGB(17, 25, 43)
local BUTTON_HOVER = Color3.fromRGB(23, 38, 60)

--==================================================
-- YOUTUBE
--==================================================

local YOUTUBE_URL =
	"https://youtube.com/@joyxyter?si=Xq_LkpTT98T3_ICL"

--==================================================
-- SESSION TIMER
--==================================================

local scriptStartTime = tick()

local function formatTime(seconds)
	seconds = math.floor(seconds)

	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60

	return string.format(
		"%02d:%02d:%02d",
		hours,
		minutes,
		secs
	)
end

--==================================================
-- MAIN GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "JoyxAler"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 99999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

--==================================================
-- FPS LABEL
--==================================================

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Name = "FPS"
fpsLabel.Size = UDim2.new(0, 110, 0, 30)
fpsLabel.Position = UDim2.new(0.5, -55, 0, 5)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = CYAN
fpsLabel.TextStrokeTransparency = 0.5
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 17
fpsLabel.Text = "FPS: --"
fpsLabel.Visible = false
fpsLabel.Parent = gui

local frames = 0
local lastFPSUpdate = tick()

RunService.RenderStepped:Connect(function()
	frames += 1

	if tick() - lastFPSUpdate >= 1 then
		fpsLabel.Text = "FPS: " .. tostring(frames)
		frames = 0
		lastFPSUpdate = tick()
	end
end)

--==================================================
-- MAIN PANEL
--==================================================

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.new(0, 560, 0, 410)
panel.Position = UDim2.new(0.5, -280, 0.53, -205)
panel.BackgroundColor3 = BG
panel.BorderSizePixel = 1
panel.BorderColor3 = CYAN_DARK
panel.Visible = false
panel.Active = true
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(0, 105, 125)
panelStroke.Thickness = 1
panelStroke.Transparency = 0.25
panelStroke.Parent = panel

--==================================================
-- TITLE BAR
--==================================================

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 43)
titleBar.BackgroundColor3 = Color3.fromRGB(7, 14, 28)
titleBar.BorderSizePixel = 0
titleBar.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 130, 1, 0)
title.Position = UDim2.new(0, 13, 0, 0)
title.BackgroundTransparency = 1
title.Text = "◈ JOY_ALER"
title.TextColor3 = CYAN
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

--==================================================
-- DEVELOPER TEXT
--==================================================

local developerLabel = Instance.new("TextLabel")
developerLabel.Size = UDim2.new(0, 190, 1, 0)
developerLabel.Position = UDim2.new(0.5, -95, 0, 0)
developerLabel.BackgroundTransparency = 1
developerLabel.Text = "Developer Joy  yt_@JoyXyter"
developerLabel.TextColor3 = Color3.fromRGB(170, 190, 205)
developerLabel.Font = Enum.Font.GothamBold
developerLabel.TextSize = 10
developerLabel.TextXAlignment = Enum.TextXAlignment.Center
developerLabel.Parent = titleBar

local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(0, 45, 1, 0)
versionLabel.Position = UDim2.new(1, -295, 0, 0)
versionLabel.BackgroundTransparency = 1
versionLabel.Text = "V6.0"
versionLabel.TextColor3 = MUTED
versionLabel.Font = Enum.Font.Gotham
versionLabel.TextSize = 10
versionLabel.Parent = titleBar

--==================================================
-- MINIMIZE
--==================================================

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 34, 0, 31)
minimize.Position = UDim2.new(1, -250, 0, 6)
minimize.BackgroundColor3 = Color3.fromRGB(20, 35, 55)
minimize.BorderSizePixel = 0
minimize.Text = "-"
minimize.TextColor3 = TEXT
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 20
minimize.Parent = titleBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 5)
minimizeCorner.Parent = minimize

--==================================================
-- YOUTUBE BUTTON
--==================================================

local youtubeBtn = Instance.new("TextButton")
youtubeBtn.Size = UDim2.new(0, 58, 0, 31)
youtubeBtn.Position = UDim2.new(1, -210, 0, 6)
youtubeBtn.BackgroundColor3 = Color3.fromRGB(150, 25, 35)
youtubeBtn.BorderSizePixel = 0
youtubeBtn.Text = "YOUTUBE"
youtubeBtn.TextColor3 = TEXT
youtubeBtn.Font = Enum.Font.GothamBold
youtubeBtn.TextSize = 8
youtubeBtn.Parent = titleBar

local youtubeCorner = Instance.new("UICorner")
youtubeCorner.CornerRadius = UDim.new(0, 5)
youtubeCorner.Parent = youtubeBtn

youtubeBtn.Activated:Connect(function()
	pcall(function()
		GuiService:OpenBrowserWindow(YOUTUBE_URL)
	end)
end)

--==================================================
-- SUBSCRIBE FOR SUPPORT
--==================================================

local supportBtn = Instance.new("TextButton")
supportBtn.Size = UDim2.new(0, 72, 0, 31)
supportBtn.Position = UDim2.new(1, -148, 0, 6)
supportBtn.BackgroundColor3 = Color3.fromRGB(85, 35, 115)
supportBtn.BorderSizePixel = 0
supportBtn.Text = "SUBSCRIBE"
supportBtn.TextColor3 = TEXT
supportBtn.Font = Enum.Font.GothamBold
supportBtn.TextSize = 8
supportBtn.Parent = titleBar

local supportCorner = Instance.new("UICorner")
supportCorner.CornerRadius = UDim.new(0, 5)
supportCorner.Parent = supportBtn

supportBtn.Activated:Connect(function()
	pcall(function()
		GuiService:OpenBrowserWindow(YOUTUBE_URL)
	end)
end)

--==================================================
-- SETTINGS
--==================================================

local settingsBtn = Instance.new("TextButton")
settingsBtn.Size = UDim2.new(0, 34, 0, 31)
settingsBtn.Position = UDim2.new(1, -71, 0, 6)
settingsBtn.BackgroundColor3 = Color3.fromRGB(25, 30, 55)
settingsBtn.BorderSizePixel = 0
settingsBtn.Text = "⚙"
settingsBtn.TextColor3 = Color3.fromRGB(180, 120, 255)
settingsBtn.Font = Enum.Font.GothamBold
settingsBtn.TextSize = 16
settingsBtn.Parent = titleBar

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 5)
settingsCorner.Parent = settingsBtn

--==================================================
-- CLOSE
--==================================================

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 34, 0, 31)
close.Position = UDim2.new(1, -34, 0, 6)
close.BackgroundColor3 = Color3.fromRGB(75, 22, 45)
close.BorderSizePixel = 0
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 150, 180)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = close

--==================================================
-- SETTINGS POPUP
--==================================================

local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(0, 180, 0, 175)
settingsFrame.Position = UDim2.new(1, -190, 0, 48)
settingsFrame.BackgroundColor3 = Color3.fromRGB(8, 13, 27)
settingsFrame.BorderSizePixel = 1
settingsFrame.BorderColor3 = PURPLE
settingsFrame.Visible = false
settingsFrame.ZIndex = 50
settingsFrame.Parent = panel

local settingsCorner2 = Instance.new("UICorner")
settingsCorner2.CornerRadius = UDim.new(0, 7)
settingsCorner2.Parent = settingsFrame

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, -20, 0, 30)
settingsTitle.Position = UDim2.new(0, 10, 0, 5)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "⚙ PANEL SIZE"
settingsTitle.TextColor3 = CYAN
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextSize = 12
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.ZIndex = 51
settingsTitle.Parent = settingsFrame

local function createSizeButton(text, y)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -20, 0, 32)
	b.Position = UDim2.new(0, 10, 0, y)
	b.BackgroundColor3 = BUTTON
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = TEXT
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.ZIndex = 51
	b.Parent = settingsFrame

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 5)
	c.Parent = b

	return b
end

local smallSizeBtn = createSizeButton("SMALL", 38)
local normalSizeBtn = createSizeButton("NORMAL", 75)
local largeSizeBtn = createSizeButton("LARGE", 112)

--==================================================
-- PANEL SIZE
--==================================================

local currentPanelSize = "NORMAL"

local panelSizes = {
	SMALL = Vector2.new(510, 370),
	NORMAL = Vector2.new(560, 410),
	LARGE = Vector2.new(620, 455)
}

local function setPanelSize(sizeName)
	local size = panelSizes[sizeName]

	if not size then
		return
	end

	currentPanelSize = sizeName

	panel.Size = UDim2.new(0, size.X, 0, size.Y)

	panel.Position = UDim2.new(
		0.5,
		-size.X / 2,
		0.53,
		-size.Y / 2
	)

	settingsFrame.Visible = false
end

smallSizeBtn.Activated:Connect(function()
	setPanelSize("SMALL")
end)

normalSizeBtn.Activated:Connect(function()
	setPanelSize("NORMAL")
end)

largeSizeBtn.Activated:Connect(function()
	setPanelSize("LARGE")
end)

settingsBtn.Activated:Connect(function()
	settingsFrame.Visible = not settingsFrame.Visible
end)

--==================================================
-- INFO HEADER
--==================================================

local infoHeader = Instance.new("Frame")
infoHeader.Size = UDim2.new(1, -18, 0, 48)
infoHeader.Position = UDim2.new(0, 9, 0, 50)
infoHeader.BackgroundColor3 = Color3.fromRGB(8, 18, 32)
infoHeader.BorderSizePixel = 1
infoHeader.BorderColor3 = Color3.fromRGB(0, 65, 85)
infoHeader.Parent = panel

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 6)
headerCorner.Parent = infoHeader

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -145, 0, 22)
status.Position = UDim2.new(0, 10, 0, 4)
status.BackgroundTransparency = 1
status.Text = "● SYSTEM ONLINE  •  READY"
status.TextColor3 = Color3.fromRGB(70, 220, 180)
status.Font = Enum.Font.GothamBold
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = infoHeader

local runtimeLabel = Instance.new("TextLabel")
runtimeLabel.Size = UDim2.new(1, -145, 0, 18)
runtimeLabel.Position = UDim2.new(0, 10, 0, 26)
runtimeLabel.BackgroundTransparency = 1
runtimeLabel.Text = "SESSION : 00:00:00"
runtimeLabel.TextColor3 = MUTED
runtimeLabel.Font = Enum.Font.Gotham
runtimeLabel.TextSize = 10
runtimeLabel.TextXAlignment = Enum.TextXAlignment.Left
runtimeLabel.Parent = infoHeader

local refreshInfo = Instance.new("TextButton")
refreshInfo.Size = UDim2.new(0, 125, 0, 32)
refreshInfo.Position = UDim2.new(1, -135, 0, 8)
refreshInfo.BackgroundColor3 = Color3.fromRGB(10, 65, 85)
refreshInfo.BorderSizePixel = 0
refreshInfo.Text = "↻ REFRESH"
refreshInfo.TextColor3 = TEXT
refreshInfo.Font = Enum.Font.GothamBold
refreshInfo.TextSize = 10
refreshInfo.Parent = infoHeader

local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0, 5)
refreshCorner.Parent = refreshInfo

--==================================================
-- BODY
--==================================================

local body = Instance.new("Frame")
body.Size = UDim2.new(1, -18, 1, -108)
body.Position = UDim2.new(0, 9, 0, 105)
body.BackgroundTransparency = 1
body.Parent = panel

--==================================================
-- SIDE MENU
--==================================================

local side = Instance.new("Frame")
side.Size = UDim2.new(0, 92, 1, 0)
side.BackgroundColor3 = Color3.fromRGB(6, 12, 25)
side.BorderSizePixel = 1
side.BorderColor3 = Color3.fromRGB(0, 55, 75)
side.Parent = body

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 6)
sideCorner.Parent = side

local sideTitle = Instance.new("TextLabel")
sideTitle.Size = UDim2.new(1, 0, 0, 28)
sideTitle.BackgroundTransparency = 1
sideTitle.Text = "MENU"
sideTitle.TextColor3 = MUTED
sideTitle.Font = Enum.Font.GothamBold
sideTitle.TextSize = 10
sideTitle.Parent = side

local function createTab(text, y)
	local tab = Instance.new("TextButton")

	tab.Size = UDim2.new(1, -10, 0, 48)
	tab.Position = UDim2.new(0, 5, 0, y)
	tab.BackgroundColor3 = BUTTON
	tab.BorderSizePixel = 0
	tab.Text = text
	tab.TextColor3 = TEXT
	tab.Font = Enum.Font.GothamBold
	tab.TextSize = 11
	tab.Parent = side

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 5)
	c.Parent = tab

	return tab
end

local infoTab = createTab("INFO", 35)
local fpsTab = createTab("FPS", 88)
local playerTab = createTab("PLAYER", 141)
local mscTab = createTab("MSC", 194)

--==================================================
-- INFO PAGE
--==================================================

local infoPage = Instance.new("Frame")
infoPage.Size = UDim2.new(1, -102, 1, 0)
infoPage.Position = UDim2.new(0, 102, 0, 0)
infoPage.BackgroundColor3 = Color3.fromRGB(6, 12, 24)
infoPage.BorderSizePixel = 1
infoPage.BorderColor3 = Color3.fromRGB(0, 55, 75)
infoPage.Parent = body

local infoPageCorner = Instance.new("UICorner")
infoPageCorner.CornerRadius = UDim.new(0, 6)
infoPageCorner.Parent = infoPage

local infoTitle = Instance.new("TextLabel")
infoTitle.Size = UDim2.new(1, -20, 0, 32)
infoTitle.Position = UDim2.new(0, 10, 0, 8)
infoTitle.BackgroundTransparency = 1
infoTitle.Text = "SYSTEM INFO"
infoTitle.TextColor3 = CYAN
infoTitle.Font = Enum.Font.GothamBold
infoTitle.TextSize = 17
infoTitle.TextXAlignment = Enum.TextXAlignment.Left
infoTitle.Parent = infoPage

local infoHint = Instance.new("TextLabel")
infoHint.Size = UDim2.new(1, -20, 0, 22)
infoHint.Position = UDim2.new(0, 10, 0, 38)
infoHint.BackgroundTransparency = 1
infoHint.Text = "ALL MODULES • READY TO USE"
infoHint.TextColor3 = Color3.fromRGB(80, 190, 170)
infoHint.Font = Enum.Font.GothamBold
infoHint.TextSize = 10
infoHint.TextXAlignment = Enum.TextXAlignment.Left
infoHint.Parent = infoPage

local statusList = Instance.new("ScrollingFrame")
statusList.Size = UDim2.new(1, -20, 1, -72)
statusList.Position = UDim2.new(0, 10, 0, 65)
statusList.BackgroundTransparency = 1
statusList.BorderSizePixel = 0
statusList.ScrollBarThickness = 3
statusList.CanvasSize = UDim2.new(0, 0, 0, 0)
statusList.Parent = infoPage

local statusLayout = Instance.new("UIListLayout")
statusLayout.Padding = UDim.new(0, 5)
statusLayout.Parent = statusList

local function makeStatusLabel(text)
	local label = Instance.new("TextLabel")

	label.Size = UDim2.new(1, -4, 0, 31)
	label.BackgroundColor3 = Color3.fromRGB(10, 22, 38)
	label.BorderSizePixel = 1
	label.BorderColor3 = Color3.fromRGB(20, 55, 75)

	label.Text = text
	label.TextColor3 = TEXT
	label.Font = Enum.Font.GothamBold
	label.TextSize = 10
	label.TextXAlignment = Enum.TextXAlignment.Left

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = label

	label.Parent = statusList

	return label
end

local brightStatus = makeStatusLabel("  FULL BRIGHT        • READY TO USE")
local boostStatus = makeStatusLabel("  FPS BOOST          • READY TO USE")
local fpsStatus = makeStatusLabel("  FPS COUNTER        • READY TO USE")
local espStatus = makeStatusLabel("  ESP PLAYER         • READY TO USE")
local noclipStatus = makeStatusLabel("  NOCLIP             • READY TO USE")
local flyStatus = makeStatusLabel("  FLY                • READY TO USE")
local teleportStatus = makeStatusLabel("  TELEPORT           • READY TO USE")

--==================================================
-- FEATURE PAGE
--==================================================

local featurePage = Instance.new("Frame")
featurePage.Size = UDim2.new(1, -102, 1, 0)
featurePage.Position = UDim2.new(0, 102, 0, 0)
featurePage.BackgroundColor3 = Color3.fromRGB(6, 12, 24)
featurePage.BorderSizePixel = 1
featurePage.BorderColor3 = Color3.fromRGB(0, 55, 75)
featurePage.Visible = false
featurePage.Parent = body

local featurePageCorner = Instance.new("UICorner")
featurePageCorner.CornerRadius = UDim.new(0, 6)
featurePageCorner.Parent = featurePage

local featureTitle = Instance.new("TextLabel")
featureTitle.Size = UDim2.new(1, -20, 0, 34)
featureTitle.Position = UDim2.new(0, 10, 0, 6)
featureTitle.BackgroundTransparency = 1
featureTitle.Text = "FPS"
featureTitle.TextColor3 = CYAN
featureTitle.Font = Enum.Font.GothamBold
featureTitle.TextSize = 17
featureTitle.TextXAlignment = Enum.TextXAlignment.Left
featureTitle.Parent = featurePage

local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Size = UDim2.new(1, -18, 1, -48)
contentScroll.Position = UDim2.new(0, 9, 0, 42)
contentScroll.BackgroundTransparency = 1
contentScroll.BorderSizePixel = 0
contentScroll.ScrollBarThickness = 4
contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
contentScroll.Parent = featurePage

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0, 170, 0, 52)
grid.CellPadding = UDim2.new(0, 7, 0, 7)
grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
grid.VerticalAlignment = Enum.VerticalAlignment.Top
grid.Parent = contentScroll

--==================================================
-- BUTTON CREATOR
--==================================================

local function createFeatureButton(text, color)
	local btn = Instance.new("TextButton")

	btn.Size = UDim2.new(0, 170, 0, 52)
	btn.BackgroundColor3 = color
	btn.BorderSizePixel = 1
	btn.BorderColor3 = Color3.fromRGB(40, 85, 105)

	btn.Text = text
	btn.TextColor3 = TEXT
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 10

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	btn.Parent = contentScroll

	return btn
end

--==================================================
-- FEATURE BUTTONS
--==================================================

local brightBtn = createFeatureButton(
	"FULL BRIGHT — OFF",
	BUTTON
)

local boostBtn = createFeatureButton(
	"FPS BOOST — OFF",
	BUTTON
)

local fpsBtn = createFeatureButton(
	"SHOW FPS — OFF",
	BUTTON
)

local flyMainBtn = createFeatureButton(
	"FLY GUI — BUKA",
	Color3.fromRGB(20, 85, 65)
)

local noclipBtn = createFeatureButton(
	"NOCLIP — OFF",
	PURPLE_DARK
)

local tpMainBtn = createFeatureButton(
	"TELEPORT — BUKA",
	Color3.fromRGB(85, 55, 20)
)

local espBtn = createFeatureButton(
	"ESP PLAYER — OFF",
	BUTTON
)

--==================================================
-- CATEGORY SYSTEM
--==================================================

local categoryButtons = {
	FPS = {
		brightBtn,
		boostBtn,
		fpsBtn
	},

	PLAYER = {
		flyMainBtn,
		noclipBtn,
		tpMainBtn
	},

	MSC = {
		espBtn
	}
}

local function hideAllFeatureButtons()
	for _, button in ipairs({
		brightBtn,
		boostBtn,
		fpsBtn,
		flyMainBtn,
		noclipBtn,
		tpMainBtn,
		espBtn
	}) do
		button.Visible = false
	end
end

local function setTabColor(tab, selected)
	if selected then
		tab.BackgroundColor3 = Color3.fromRGB(0, 75, 95)
		tab.TextColor3 = CYAN
	else
		tab.BackgroundColor3 = BUTTON
		tab.TextColor3 = TEXT
	end
end

local function showInfoPage()
	infoPage.Visible = true
	featurePage.Visible = false

	setTabColor(infoTab, true)
	setTabColor(fpsTab, false)
	setTabColor(playerTab, false)
	setTabColor(mscTab, false)
end

local function showCategory(category)
	infoPage.Visible = false
	featurePage.Visible = true

	hideAllFeatureButtons()

	featureTitle.Text = category

	for _, button in ipairs(categoryButtons[category]) do
		button.Visible = true
	end

	setTabColor(infoTab, false)
	setTabColor(fpsTab, category == "FPS")
	setTabColor(playerTab, category == "PLAYER")
	setTabColor(mscTab, category == "MSC")

	task.defer(function()
		contentScroll.CanvasSize = UDim2.new(
			0,
			0,
			0,
			grid.AbsoluteContentSize.Y + 20
		)
	end)
end

infoTab.Activated:Connect(showInfoPage)

fpsTab.Activated:Connect(function()
	showCategory("FPS")
end)

playerTab.Activated:Connect(function()
	showCategory("PLAYER")
end)

mscTab.Activated:Connect(function()
	showCategory("MSC")
end)

--==================================================
-- DRAG SYSTEM
--==================================================

local function makeDraggable(object, handle)
	handle = handle or object

	local dragging = false
	local startPosition
	local startMouse

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			startMouse = input.Position
			startPosition = object.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		) then

			local delta = input.Position - startMouse

			object.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end)
end

makeDraggable(panel, titleBar)

--==================================================
-- UPDATE INFO
--==================================================

local function updateInfo()

	brightStatus.Text =
		"  FULL BRIGHT        • "
		.. (brightOn and "ON" or "READY TO USE")

	boostStatus.Text =
		"  FPS BOOST          • "
		.. (boostOn and "ON" or "READY TO USE")

	fpsStatus.Text =
		"  FPS COUNTER        • "
		.. (fpsCounterOn and "ON" or "READY TO USE")

	espStatus.Text =
		"  ESP PLAYER         • "
		.. (espOn and "ON" or "READY TO USE")

	noclipStatus.Text =
		"  NOCLIP             • "
		.. (noclipOn and "ON" or "READY TO USE")

	flyStatus.Text =
		"  FLY                • "
		.. (flyActive and "ON" or "READY TO USE")

	teleportStatus.Text =
		"  TELEPORT           • "
		.. (teleportGui and "OPEN" or "READY TO USE")

	task.defer(function()
		statusList.CanvasSize = UDim2.new(
			0,
			0,
			0,
			statusLayout.AbsoluteContentSize.Y + 10
		)
	end)
end

--==================================================
-- RUNTIME LOOP
--==================================================

task.spawn(function()
	while gui.Parent do
		local elapsed = tick() - scriptStartTime

		runtimeLabel.Text =
			"SESSION : " .. formatTime(elapsed)

		updateInfo()

		task.wait(1)
	end
end)

--==================================================
-- FULL BRIGHT
--==================================================

local function setFullBright(enabled)
	brightOn = enabled

	if enabled then

		originalLighting = {
			Brightness = Lighting.Brightness,
			ClockTime = Lighting.ClockTime,
			FogEnd = Lighting.FogEnd,
			GlobalShadows = Lighting.GlobalShadows,
			ExposureCompensation = Lighting.ExposureCompensation
		}

		Lighting.Brightness = 3
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.ExposureCompensation = 1

		brightBtn.Text = "FULL BRIGHT — ON"
		brightBtn.BackgroundColor3 = GREEN

	else

		if originalLighting.Brightness ~= nil then
			Lighting.Brightness = originalLighting.Brightness
		end

		if originalLighting.ClockTime ~= nil then
			Lighting.ClockTime = originalLighting.ClockTime
		end

		if originalLighting.FogEnd ~= nil then
			Lighting.FogEnd = originalLighting.FogEnd
		end

		if originalLighting.GlobalShadows ~= nil then
			Lighting.GlobalShadows = originalLighting.GlobalShadows
		end

		if originalLighting.ExposureCompensation ~= nil then
			Lighting.ExposureCompensation =
				originalLighting.ExposureCompensation
		end

		brightBtn.Text = "FULL BRIGHT — OFF"
		brightBtn.BackgroundColor3 = BUTTON
	end

	updateInfo()
end

brightBtn.Activated:Connect(function()
	setFullBright(not brightOn)
end)

--==================================================
-- FPS BOOST
--==================================================

local function setFPSBoost(enabled)
	boostOn = enabled

	if enabled then

		for _, object in ipairs(Workspace:GetDescendants()) do

			if object:IsA("ParticleEmitter")
				or object:IsA("Trail")
				or object:IsA("Beam") then

				if originalParticles[object] == nil then
					originalParticles[object] = object.Enabled
				end

				object.Enabled = false
			end

			if object:IsA("Decal")
				or object:IsA("Texture") then

				if originalDecals[object] == nil then
					originalDecals[object] = object.Transparency
				end

				object.Transparency = 1
			end

			if object:IsA("BasePart") then

				if originalParts[object] == nil then
					originalParts[object] = {
						Material = object.Material,
						CastShadow = object.CastShadow
					}
				end

				object.Material = Enum.Material.SmoothPlastic
				object.CastShadow = false
			end
		end

		for _, effect in ipairs(Lighting:GetChildren()) do
			if effect:IsA("PostEffect") then

				if originalPostEffects[effect] == nil then
					originalPostEffects[effect] = effect.Enabled
				end

				effect.Enabled = false
			end
		end

		boostBtn.Text = "FPS BOOST — ON"
		boostBtn.BackgroundColor3 = GREEN

	else

		for object, value in pairs(originalParticles) do
			if object and object.Parent then
				object.Enabled = value
			end
		end

		for object, value in pairs(originalDecals) do
			if object and object.Parent then
				object.Transparency = value
			end
		end

		for object, value in pairs(originalParts) do
			if object and object.Parent then
				object.Material = value.Material
				object.CastShadow = value.CastShadow
			end
		end

		for effect, value in pairs(originalPostEffects) do
			if effect and effect.Parent then
				effect.Enabled = value
			end
		end

		table.clear(originalParticles)
		table.clear(originalDecals)
		table.clear(originalParts)
		table.clear(originalPostEffects)

		boostBtn.Text = "FPS BOOST — OFF"
		boostBtn.BackgroundColor3 = BUTTON
	end

	updateInfo()
end

boostBtn.Activated:Connect(function()
	setFPSBoost(not boostOn)
end)

--==================================================
-- FPS COUNTER
--==================================================

fpsBtn.Activated:Connect(function()

	fpsCounterOn = not fpsCounterOn

	fpsLabel.Visible = fpsCounterOn

	if fpsCounterOn then
		fpsBtn.Text = "SHOW FPS — ON"
		fpsBtn.BackgroundColor3 = GREEN
	else
		fpsBtn.Text = "SHOW FPS — OFF"
		fpsBtn.BackgroundColor3 = BUTTON
	end

	updateInfo()
end)

--==================================================
-- NOCLIP
--==================================================

local function setNoclip(enabled)
	noclipOn = enabled

	if enabled then

		if NoclipConnection then
			return
		end

		NoclipConnection = RunService.Stepped:Connect(function()

			local character = player.Character

			if not character then
				return
			end

			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)

	else

		if NoclipConnection then
			NoclipConnection:Disconnect()
			NoclipConnection = nil
		end

		local character = player.Character

		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart")
					and part.Name ~= "HumanoidRootPart" then

					part.CanCollide = true
				end
			end
		end
	end

	updateInfo()
end

noclipBtn.Activated:Connect(function()

	setNoclip(not noclipOn)

	if noclipOn then
		noclipBtn.Text = "NOCLIP — ON"
		noclipBtn.BackgroundColor3 =
			Color3.fromRGB(120, 40, 180)

		status.Text = "NOCLIP AKTIF"
	else
		noclipBtn.Text = "NOCLIP — OFF"
		noclipBtn.BackgroundColor3 =
			PURPLE_DARK

		status.Text = "NOCLIP DIMATIKAN"
	end

	task.delay(1.2, function()
		if gui.Parent then
			status.Text = "● SYSTEM ONLINE  •  READY"
		end
	end)
end)

--==================================================
-- ESP
--==================================================

local function removeAllESP()

	for _, object in ipairs(Workspace:GetDescendants()) do

		if object:IsA("Highlight")
			and object.Name == "ESP_Highlight" then

			object:Destroy()
		end
	end
end

local function stopESP()

	espOn = false

	if espThread then
		task.cancel(espThread)
		espThread = nil
	end

	if espConnectionAdded then
		espConnectionAdded:Disconnect()
		espConnectionAdded = nil
	end

	if espConnectionRemoved then
		espConnectionRemoved:Disconnect()
		espConnectionRemoved = nil
	end

	removeAllESP()

	espBtn.Text = "ESP PLAYER — OFF"
	espBtn.BackgroundColor3 = BUTTON

	status.Text = "ESP DIMATIKAN"

	updateInfo()

	task.delay(1.2, function()
		if gui.Parent then
			status.Text = "● SYSTEM ONLINE  •  READY"
		end
	end)
end

local function startESP()

	if espOn then
		return
	end

	espOn = true

	removeAllESP()

	local function addESPForPlayer(targetPlayer)

		local function setupCharacter(character)

			if not espOn then
				return
			end

			if not character then
				return
			end

			if character:FindFirstChild("ESP_Highlight") then
				return
			end

			local highlight = Instance.new("Highlight")

			highlight.Name = "ESP_Highlight"
			highlight.Adornee = character
			highlight.DepthMode =
				Enum.HighlightDepthMode.AlwaysOnTop
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 0

			local color

			if _G.UseTeamColor then
				color = targetPlayer.TeamColor.Color
			else
				if targetPlayer.TeamColor == player.TeamColor then
					color = _G.FriendColor
				else
					color = _G.EnemyColor
				end
			end

			highlight.OutlineColor = color
			highlight.Parent = character
		end

		if targetPlayer.Character then
			setupCharacter(targetPlayer.Character)
		end

		targetPlayer.CharacterAdded:Connect(function(character)

			task.wait(0.2)

			if espOn then
				setupCharacter(character)
			end
		end)

		targetPlayer.CharacterRemoving:Connect(function(character)

			if character then

				local highlight =
					character:FindFirstChild("ESP_Highlight")

				if highlight then
					highlight:Destroy()
				end
			end
		end)
	end

	for _, targetPlayer in ipairs(Players:GetPlayers()) do

		if targetPlayer ~= player then

			task.spawn(function()
				addESPForPlayer(targetPlayer)
			end)
		end
	end

	espConnectionAdded =
		Players.PlayerAdded:Connect(function(targetPlayer)

			task.wait(0.5)

			if espOn then
				addESPForPlayer(targetPlayer)
			end
		end)

	espConnectionRemoved =
		Players.PlayerRemoving:Connect(function()

			if espOn then

				task.delay(0.2, function()

					if espOn then
						status.Text =
							"● SYSTEM ONLINE  •  READY"
					end
				end)
			end
		end)

	espBtn.Text = "ESP PLAYER — ON"
	espBtn.BackgroundColor3 = GREEN

	status.Text = "ESP AKTIF"

	updateInfo()

	task.delay(1.5, function()

		if espOn and gui.Parent then
			status.Text =
				"● SYSTEM ONLINE  •  READY"
		end
	end)
end

espBtn.Activated:Connect(function()

	if espOn then
		stopESP()
	else
		startESP()
	end
end)

--==================================================
-- TELEPORT GUI
--==================================================

local function createTeleportGUI()

	if teleportGui then

		teleportGui:Destroy()
		teleportGui = nil

		updateInfo()

		return
	end

	local tg = Instance.new("ScreenGui")
	tg.Name = "JoyxAler_Teleport"
	tg.ResetOnSpawn = false
	tg.DisplayOrder = 100000
	tg.Parent = playerGui

	teleportGui = tg

	local frame = Instance.new("Frame")

	frame.Size = UDim2.new(0, 300, 0, 380)
	frame.Position = UDim2.new(0.5, -150, 0.5, -190)
	frame.BackgroundColor3 = BG2
	frame.BorderSizePixel = 1
	frame.BorderColor3 = CYAN
	frame.Active = true
	frame.Parent = tg

	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(0, 8)
	fc.Parent = frame

	local top = Instance.new("TextLabel")

	top.Size = UDim2.new(1, -45, 0, 45)
	top.BackgroundColor3 = Color3.fromRGB(12, 30, 42)
	top.Text = "TELEPORT"
	top.TextColor3 = CYAN
	top.Font = Enum.Font.GothamBold
	top.TextSize = 17
	top.Parent = frame

	local closeTp = Instance.new("TextButton")

	closeTp.Size = UDim2.new(0, 45, 0, 45)
	closeTp.Position = UDim2.new(1, -45, 0, 0)
	closeTp.BackgroundColor3 = Color3.fromRGB(70, 20, 40)
	closeTp.Text = "X"
	closeTp.TextColor3 = Color3.fromRGB(255, 150, 180)
	closeTp.Font = Enum.Font.GothamBold
	closeTp.TextSize = 16
	closeTp.Parent = frame

	local refreshBtn = Instance.new("TextButton")

	refreshBtn.Size = UDim2.new(0, 90, 0, 35)
	refreshBtn.Position = UDim2.new(1, -100, 0, 50)
	refreshBtn.BackgroundColor3 = Color3.fromRGB(10, 70, 90)
	refreshBtn.Text = "REFRESH"
	refreshBtn.TextColor3 = TEXT
	refreshBtn.Font = Enum.Font.GothamBold
	refreshBtn.TextSize = 11
	refreshBtn.Parent = frame

	local scroll = Instance.new("ScrollingFrame")

	scroll.Size = UDim2.new(1, -20, 0, 255)
	scroll.Position = UDim2.new(0, 10, 0, 95)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 4
	scroll.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
	layout.Parent = scroll

	local function refreshList()

		for _, child in ipairs(scroll:GetChildren()) do

			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		local myCharacter = player.Character

		local myRoot = myCharacter
			and myCharacter:FindFirstChild("HumanoidRootPart")

		for _, target in ipairs(Players:GetPlayers()) do

			if target ~= player then

				local button = Instance.new("TextButton")

				button.Size =
					UDim2.new(1, -5, 0, 42)

				button.BackgroundColor3 =
					BUTTON

				local distanceText = " [--m]"

				if myRoot
					and target.Character
					and target.Character:FindFirstChild("HumanoidRootPart") then

					local targetRoot =
						target.Character.HumanoidRootPart

					local distance =
						(myRoot.Position
							- targetRoot.Position).Magnitude

					distanceText =
						string.format(
							" [%.0fm]",
							distance
						)
				end

				button.Text =
					target.Name .. distanceText

				button.TextColor3 = TEXT
				button.Font = Enum.Font.GothamBold
				button.TextSize = 11
				button.Parent = scroll

				button.Activated:Connect(function()

					local character =
						player.Character

					if not character then

						status.Text =
							"KARAKTER TIDAK ADA!"

						return
					end

					local targetCharacter =
						target.Character

					if not targetCharacter then

						status.Text =
							target.Name
							.. " TIDAK DITEMUKAN!"

						return
					end

					local targetRoot =
						targetCharacter:FindFirstChild(
							"HumanoidRootPart"
						)

					if not targetRoot then

						status.Text =
							"LOKASI TIDAK ADA!"

						return
					end

					status.Text =
						"TELEPORT KE "
						.. target.Name

					character:PivotTo(
						targetRoot.CFrame
						+ Vector3.new(0, 2.5, 0)
					)

					task.delay(1, function()

						if gui.Parent then
							status.Text =
								"● SYSTEM ONLINE  •  READY"
						end
					end)
				end)
			end
		end

		task.defer(function()

			scroll.CanvasSize = UDim2.new(
				0,
				0,
				0,
				layout.AbsoluteContentSize.Y + 10
			)
		end)
	end

	refreshBtn.Activated:Connect(function()

		refreshList()

		status.Text = "DAFTAR DIPERBARUI"

		task.delay(1.5, function()

			if gui.Parent then
				status.Text =
					"● SYSTEM ONLINE  •  READY"
			end
		end)
	end)

	local playerAddedConnection =
		Players.PlayerAdded:Connect(refreshList)

	local playerRemovingConnection =
		Players.PlayerRemoving:Connect(refreshList)

	closeTp.Activated:Connect(function()

		playerAddedConnection:Disconnect()
		playerRemovingConnection:Disconnect()

		tg:Destroy()

		teleportGui = nil

		updateInfo()
	end)

	makeDraggable(frame, top)

	refreshList()
	updateInfo()
end

tpMainBtn.Activated:Connect(createTeleportGUI)

--==================================================
-- FLY
-- CAMERA 3D + UP/DOWN
--==================================================

local function stopFly()

	flyActive = false

	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end

	if flyBodyVelocity then
		flyBodyVelocity:Destroy()
		flyBodyVelocity = nil
	end

	if flyBodyGyro then
		flyBodyGyro:Destroy()
		flyBodyGyro = nil
	end

	local character = player.Character

	if character then

		local humanoid =
			character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.PlatformStand = false
			humanoid.AutoRotate = true
		end
	end

	updateInfo()
end

local function createFlyGUI()

	if flyGui then

		stopFly()

		flyGui:Destroy()
		flyGui = nil

		updateInfo()

		return
	end

	local fg = Instance.new("ScreenGui")
	fg.Name = "JoyxAler_Fly"
	fg.ResetOnSpawn = false
	fg.DisplayOrder = 100001
	fg.Parent = playerGui

	flyGui = fg

	local frame = Instance.new("Frame")

	frame.Position = UDim2.new(0.02, 0, 0.35, 0)
	frame.Size = UDim2.new(0, 300, 0, 95)
	frame.BackgroundColor3 = Color3.fromRGB(12, 25, 32)
	frame.BorderColor3 = CYAN
	frame.BorderSizePixel = 1
	frame.Active = true
	frame.Parent = fg

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 7)
	frameCorner.Parent = frame

	local up = Instance.new("TextButton")
	up.Parent = frame
	up.BackgroundColor3 = Color3.fromRGB(30, 150, 105)
	up.Size = UDim2.new(0, 55, 0, 35)
	up.Position = UDim2.new(0, 5, 0, 5)
	up.Text = "UP"
	up.TextColor3 = Color3.new(1, 1, 1)
	up.Font = Enum.Font.GothamBold
	up.TextSize = 11

	local down = Instance.new("TextButton")
	down.Parent = frame
	down.BackgroundColor3 = Color3.fromRGB(120, 110, 30)
	down.Size = UDim2.new(0, 55, 0, 35)
	down.Position = UDim2.new(0, 5, 0, 50)
	down.Text = "DOWN"
	down.TextColor3 = Color3.new(1, 1, 1)
	down.Font = Enum.Font.GothamBold
	down.TextSize = 11

	local titleFly = Instance.new("TextLabel")
	titleFly.Parent = frame
	titleFly.BackgroundColor3 = Color3.fromRGB(110, 35, 115)
	titleFly.Position = UDim2.new(0, 65, 0, 5)
	titleFly.Size = UDim2.new(0, 110, 0, 35)
	titleFly.Text = "FLY GUI V3"
	titleFly.TextColor3 = TEXT
	titleFly.Font = Enum.Font.GothamBold
	titleFly.TextSize = 11

	local minus = Instance.new("TextButton")
	minus.Parent = frame
	minus.BackgroundColor3 = Color3.fromRGB(20, 90, 105)
	minus.Position = UDim2.new(0, 65, 0, 50)
	minus.Size = UDim2.new(0, 55, 0, 35)
	minus.Text = "-"
	minus.TextColor3 = TEXT
	minus.Font = Enum.Font.GothamBold
	minus.TextSize = 15

	local speedLabel = Instance.new("TextLabel")
	speedLabel.Parent = frame
	speedLabel.BackgroundColor3 = Color3.fromRGB(90, 45, 20)
	speedLabel.Position = UDim2.new(0, 125, 0, 50)
	speedLabel.Size = UDim2.new(0, 55, 0, 35)
	speedLabel.Text = "1"
	speedLabel.TextColor3 = TEXT
	speedLabel.Font = Enum.Font.GothamBold
	speedLabel.TextSize = 11

	local plus = Instance.new("TextButton")
	plus.Parent = frame
	plus.BackgroundColor3 = Color3.fromRGB(70, 55, 130)
	plus.Position = UDim2.new(0, 185, 0, 50)
	plus.Size = UDim2.new(0, 55, 0, 35)
	plus.Text = "+"
	plus.TextColor3 = TEXT
	plus.Font = Enum.Font.GothamBold
	plus.TextSize = 15

	local onof = Instance.new("TextButton")
	onof.Parent = frame
	onof.BackgroundColor3 = Color3.fromRGB(110, 90, 25)
	onof.Position = UDim2.new(0, 185, 0, 5)
	onof.Size = UDim2.new(0, 55, 0, 35)
	onof.Text = "FLY"
	onof.TextColor3 = TEXT
	onof.Font = Enum.Font.GothamBold
	onof.TextSize = 11

	local closeFly = Instance.new("TextButton")
	closeFly.Parent = frame
	closeFly.BackgroundColor3 = Color3.fromRGB(75, 20, 40)
	closeFly.Size = UDim2.new(0, 45, 0, 35)
	closeFly.Position = UDim2.new(1, -50, 0, 5)
	closeFly.Text = "X"
	closeFly.TextSize = 16
	closeFly.TextColor3 = Color3.fromRGB(255, 150, 180)

	local speedValue = 1
	local upHeld = false
	local downHeld = false

	makeDraggable(frame, titleFly)

	up.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			upHeld = true
		end
	end)

	up.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			upHeld = false
		end
	end)

	down.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			downHeld = true
		end
	end)

	down.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			downHeld = false
		end
	end)

	onof.Activated:Connect(function()

		if flyActive then

			stopFly()

			onof.Text = "FLY"
			onof.BackgroundColor3 =
				Color3.fromRGB(110, 90, 25)

			return
		end

		local character = player.Character

		if not character then
			return
		end

		local humanoid =
			character:FindFirstChildOfClass("Humanoid")

		local root =
			character:FindFirstChild("HumanoidRootPart")

		if not humanoid or not root then
			return
		end

		flyActive = true

		humanoid.PlatformStand = false
		humanoid.AutoRotate = false

		flyBodyGyro = Instance.new("BodyGyro")
		flyBodyGyro.P = 90000
		flyBodyGyro.D = 1000
		flyBodyGyro.MaxTorque =
			Vector3.new(9e9, 9e9, 9e9)
		flyBodyGyro.CFrame =
			root.CFrame
		flyBodyGyro.Parent = root

		flyBodyVelocity = Instance.new("BodyVelocity")
		flyBodyVelocity.P = 9000
		flyBodyVelocity.MaxForce =
			Vector3.new(9e9, 9e9, 9e9)
		flyBodyVelocity.Velocity =
			Vector3.zero
		flyBodyVelocity.Parent = root

		onof.Text = "FLY ON"
		onof.BackgroundColor3 =
			Color3.fromRGB(25, 150, 90)

		updateInfo()

		flyConnection =
			RunService.RenderStepped:Connect(function()

				if not flyActive then
					return
				end

				if not character.Parent
					or not root.Parent
					or not humanoid.Parent then

					stopFly()
					return
				end

				local camera =
					Workspace.CurrentCamera

				if not camera then
					return
				end

				local moveDirection =
					humanoid.MoveDirection

				local velocity =
					Vector3.zero

				local look =
					camera.CFrame.LookVector

				local right =
					camera.CFrame.RightVector

				local flatForward =
					Vector3.new(
						look.X,
						0,
						look.Z
					)

				local flatRight =
					Vector3.new(
						right.X,
						0,
						right.Z
					)

				if flatForward.Magnitude < 0.001 then

					local rootLook =
						root.CFrame.LookVector

					flatForward =
						Vector3.new(
							rootLook.X,
							0,
							rootLook.Z
						)
				end

				if flatForward.Magnitude < 0.001 then
					flatForward =
						Vector3.new(0, 0, -1)
				else
					flatForward =
						flatForward.Unit
				end

				if flatRight.Magnitude < 0.001 then
					flatRight =
						Vector3.new(1, 0, 0)
				else
					flatRight =
						flatRight.Unit
				end

				if moveDirection.Magnitude > 0.01 then

					local forwardInput =
						moveDirection:Dot(flatForward)

					local rightInput =
						moveDirection:Dot(flatRight)

					local cameraMovement =
						(look * forwardInput)
						+
						(flatRight * rightInput)

					if cameraMovement.Magnitude > 0.01 then

						velocity =
							cameraMovement.Unit
							* (50 * speedValue)
					end
				end

				if upHeld then
					velocity += Vector3.new(
						0,
						50 * speedValue,
						0
					)
				end

				if downHeld then
					velocity -= Vector3.new(
						0,
						50 * speedValue,
						0
					)
				end

				if flyBodyVelocity then
					flyBodyVelocity.Velocity =
						velocity
				end

				if flyBodyGyro then

					local flatLook =
						Vector3.new(
							look.X,
							0,
							look.Z
						)

					if flatLook.Magnitude > 0.001 then

						flyBodyGyro.CFrame =
							CFrame.lookAt(
								root.Position,
								root.Position + flatLook.Unit
							)
					end
				end
			end)
	end)

	plus.Activated:Connect(function()

		speedValue += 1

		speedLabel.Text =
			tostring(speedValue)
	end)

	minus.Activated:Connect(function()

		if speedValue > 1 then

			speedValue -= 1

			speedLabel.Text =
				tostring(speedValue)
		end
	end)

	closeFly.Activated:Connect(function()

		stopFly()

		fg:Destroy()
		flyGui = nil

		updateInfo()
	end)

	updateInfo()
end

flyMainBtn.Activated:Connect(createFlyGUI)

--==================================================
-- REFRESH INFO
--==================================================

refreshInfo.Activated:Connect(function()

	updateInfo()
	showInfoPage()

	status.Text = "INFO DIPERBARUI"

	task.delay(1.2, function()

		if gui.Parent then
			status.Text =
				"● SYSTEM ONLINE  •  READY"
		end
	end)
end)

--==================================================
-- RESET
--==================================================

local function resetAllInfo()

	setFullBright(false)
	setFPSBoost(false)

	if fpsCounterOn then

		fpsCounterOn = false

		fpsLabel.Visible = false

		fpsBtn.Text =
			"SHOW FPS — OFF"

		fpsBtn.BackgroundColor3 =
			BUTTON
	end

	if noclipOn then

		setNoclip(false)

		noclipBtn.Text =
			"NOCLIP — OFF"

		noclipBtn.BackgroundColor3 =
			PURPLE_DARK
	end

	if espOn then
		stopESP()
	end

	if teleportGui then

		teleportGui:Destroy()
		teleportGui = nil
	end

	if flyGui then

		stopFly()

		flyGui:Destroy()
		flyGui = nil
	end

	updateInfo()

	status.Text =
		"SEMUA DI-RESET"

	task.delay(1.5, function()

		if gui.Parent then
			status.Text =
				"● SYSTEM ONLINE  •  READY"
		end
	end)
end

--==================================================
-- MINI LOGO
--==================================================

local miniFrame = Instance.new("ImageButton")

miniFrame.Size =
	UDim2.new(0, 62, 0, 62)

miniFrame.Position =
	UDim2.new(0, 12, 0.78, 0)

miniFrame.BackgroundTransparency = 1
miniFrame.Image =
	"rbxassetid://94439212703311"

miniFrame.Visible = false
miniFrame.Active = true
miniFrame.Parent = gui

makeDraggable(miniFrame, miniFrame)

miniFrame.Activated:Connect(function()

	miniFrame.Visible = false
	panel.Visible = true
end)

--==================================================
-- MINIMIZE
--==================================================

minimize.Activated:Connect(function()

	settingsFrame.Visible = false
	panel.Visible = false
	miniFrame.Visible = true
end)

--==================================================
-- CLOSE
--==================================================

close.Activated:Connect(function()

	settingsFrame.Visible = false
	panel.Visible = false
	miniFrame.Visible = false
	fpsLabel.Visible = false

	if espOn then
		stopESP()
	end

	if noclipOn then
		setNoclip(false)
	end

	if flyGui then

		stopFly()

		flyGui:Destroy()
		flyGui = nil
	end

	if teleportGui then

		teleportGui:Destroy()
		teleportGui = nil
	end
end)

--==================================================
-- LOADING SCREEN
--==================================================

local loading = Instance.new("Frame")

loading.Size =
	UDim2.new(0, 310, 0, 140)

loading.Position =
	UDim2.new(0.5, -155, 0.5, -70)

loading.BackgroundColor3 =
	Color3.fromRGB(5, 9, 19)

loading.BorderSizePixel = 1
loading.BorderColor3 = CYAN
loading.Parent = gui

local loadingCorner = Instance.new("UICorner")
loadingCorner.CornerRadius = UDim.new(0, 8)
loadingCorner.Parent = loading

local loadingTitle = Instance.new("TextLabel")

loadingTitle.Size =
	UDim2.new(1, 0, 0, 38)

loadingTitle.Position =
	UDim2.new(0, 0, 0, 18)

loadingTitle.BackgroundTransparency = 1
loadingTitle.Text =
	"◈ JOY_ALER"

loadingTitle.TextColor3 = CYAN
loadingTitle.Font = Enum.Font.GothamBold
loadingTitle.TextSize = 18
loadingTitle.Parent = loading

local loadingSub = Instance.new("TextLabel")

loadingSub.Size =
	UDim2.new(1, 0, 0, 20)

loadingSub.Position =
	UDim2.new(0, 0, 0, 52)

loadingSub.BackgroundTransparency = 1
loadingSub.Text =
	"SYSTEM INITIALIZING..."

loadingSub.TextColor3 = MUTED
loadingSub.Font = Enum.Font.Gotham
loadingSub.TextSize = 10
loadingSub.Parent = loading

local percent = Instance.new("TextLabel")

percent.Size =
	UDim2.new(1, 0, 0, 25)

percent.Position =
	UDim2.new(0, 0, 0, 72)

percent.BackgroundTransparency = 1
percent.Text = "0%"
percent.TextColor3 =
	Color3.fromRGB(80, 210, 190)

percent.Font = Enum.Font.GothamBold
percent.TextSize = 12
percent.Parent = loading

local progressBackground = Instance.new("Frame")

progressBackground.Size =
	UDim2.new(1, -40, 0, 8)

progressBackground.Position =
	UDim2.new(0, 20, 0, 108)

progressBackground.BackgroundColor3 =
	Color3.fromRGB(18, 25, 38)

progressBackground.BorderSizePixel = 0
progressBackground.Parent = loading

local progressCorner = Instance.new("UICorner")
progressCorner.CornerRadius = UDim.new(1, 0)
progressCorner.Parent = progressBackground

local progressBar = Instance.new("Frame")

progressBar.Size =
	UDim2.new(0, 0, 1, 0)

progressBar.BackgroundColor3 =
	Color3.fromRGB(0, 150, 180)

progressBar.BorderSizePixel = 0
progressBar.Parent = progressBackground

local progressBarCorner = Instance.new("UICorner")
progressBarCorner.CornerRadius = UDim.new(1, 0)
progressBarCorner.Parent = progressBar

--==================================================
-- DEFAULT PAGE = INFO
--==================================================

hideAllFeatureButtons()
showInfoPage()
updateInfo()

--==================================================
-- LOADING
--==================================================

task.spawn(function()

	for i = 0, 100 do

		if not gui.Parent then
			return
		end

		percent.Text =
			tostring(i) .. "%"

		progressBar.Size =
			UDim2.new(i / 100, 0, 1, 0)

		task.wait(0.02)
	end

	task.wait(0.3)

	loading:Destroy()

	panel.Visible = true

	showInfoPage()
	updateInfo()
end)
