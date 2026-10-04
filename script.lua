--[[
    JOY_ALER V5.6
    Full Bright + FPS Boost + FPS Counter
    Teleport + Fly GUI
    Roblox Studio / LocalScript
]]

--// SERVICES
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// PLAYER
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// CLEAN OLD GUI
local oldGui = PlayerGui:FindFirstChild("JoyxAler")
if oldGui then
	oldGui:Destroy()
end

local oldTeleport = PlayerGui:FindFirstChild("JoyxAler_Teleport")
if oldTeleport then
	oldTeleport:Destroy()
end

local oldFly = PlayerGui:FindFirstChild("JoyxAler_Fly")
if oldFly then
	oldFly:Destroy()
end

--==================================================
-- STATE
--==================================================

local brightOn = false
local boostOn = false
local fpsCounterOn = false
local isLocked = false

local teleportGui = nil
local flyGui = nil

local originalLighting = nil
local originalAtmosphereEnabled = nil

local originalParticles = {}
local originalParts = {}
local originalDecals = {}
local originalPostEffects = {}

--==================================================
-- MAIN SCREEN GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "JoyxAler"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

--==================================================
-- FPS COUNTER
--==================================================

local fpsCounter = Instance.new("TextLabel")
fpsCounter.Name = "FPSCounter"
fpsCounter.Size = UDim2.new(0, 140, 0, 35)
fpsCounter.Position = UDim2.new(0.5, -70, 0.02, 0)
fpsCounter.BackgroundTransparency = 1
fpsCounter.Text = "FPS: 60"
fpsCounter.TextColor3 = Color3.fromRGB(80, 220, 120)
fpsCounter.Font = Enum.Font.GothamBold
fpsCounter.TextSize = 22
fpsCounter.Visible = false
fpsCounter.ZIndex = 100
fpsCounter.Parent = gui

local frameCount = 0
local lastFPSUpdate = os.clock()

RunService.RenderStepped:Connect(function()
	frameCount += 1

	if os.clock() - lastFPSUpdate >= 1 then
		if fpsCounterOn then
			local fps = frameCount

			fpsCounter.Text = "FPS: " .. fps

			if fps >= 60 then
				fpsCounter.TextColor3 = Color3.fromRGB(80, 220, 120)
			elseif fps >= 30 then
				fpsCounter.TextColor3 = Color3.fromRGB(255, 200, 80)
			else
				fpsCounter.TextColor3 = Color3.fromRGB(255, 80, 80)
			end
		end

		frameCount = 0
		lastFPSUpdate = os.clock()
	end
end)

--==================================================
-- MAIN PANEL
--==================================================

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.new(0, 300, 0, 360)
panel.Position = UDim2.new(0.5, -150, 0.5, -180)
panel.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
panel.BorderSizePixel = 2
panel.BorderColor3 = Color3.fromRGB(0, 160, 255)
panel.Visible = false
panel.ZIndex = 10
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel

--==================================================
-- PANEL BACKGROUND
--==================================================

local panelBg = Instance.new("ImageLabel")
panelBg.Name = "PanelBg"
panelBg.Size = UDim2.new(1, 0, 1, 0)
panelBg.BackgroundTransparency = 1
panelBg.Image = "rbxassetid://93486653982011"
panelBg.ScaleType = Enum.ScaleType.Crop
panelBg.ImageTransparency = 0.35
panelBg.ZIndex = 10
panelBg.Parent = panel

local panelBgCorner = Instance.new("UICorner")
panelBgCorner.CornerRadius = UDim.new(0, 12)
panelBgCorner.Parent = panelBg

--==================================================
-- TITLE BAR
--==================================================

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 80, 140)
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 20
titleBar.Parent = panel

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local dragArea = Instance.new("TextButton")
dragArea.Size = UDim2.new(1, -85, 0, 45)
dragArea.BackgroundTransparency = 1
dragArea.Text = ""
dragArea.AutoButtonColor = false
dragArea.ZIndex = 21
dragArea.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -85, 0, 45)
title.BackgroundTransparency = 1
title.Text = "⚡ JoyxAler V5.6"
title.TextColor3 = Color3.fromRGB(0, 220, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Center
title.ZIndex = 22
title.Parent = titleBar

--==================================================
-- MINIMIZE
--==================================================

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 35, 0, 35)
minBtn.Position = UDim2.new(1, -75, 0, 5)
minBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 22
minBtn.ZIndex = 23
minBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minBtn

--==================================================
-- CLOSE
--==================================================

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.ZIndex = 23
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

--==================================================
-- STATUS
--==================================================

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.new(0, 10, 0, 55)
status.BackgroundTransparency = 1
status.Font = Enum.Font.GothamBold
status.TextSize = 12
status.Text = "Bright: OFF | Boost: OFF | FPS: OFF"
status.TextColor3 = Color3.fromRGB(150, 200, 255)
status.ZIndex = 20
status.Parent = panel

--==================================================
-- BUTTON CREATOR
--==================================================

local function createButton(name, position, text)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(1, -20, 0, 40)
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(0, 90, 160)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 15
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.AutoButtonColor = false
	button.ZIndex = 20
	button.Parent = panel

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = button

	return button
end

local brightBtn = createButton(
	"BrightButton",
	UDim2.new(0, 10, 0, 90),
	"🔦 Full Bright — OFF ❌"
)

local fpsBoostBtn = createButton(
	"FPSBoostButton",
	UDim2.new(0, 10, 0, 140),
	"⚡ FPS Boost — OFF ❌"
)

local showFpsBtn = createButton(
	"ShowFPSButton",
	UDim2.new(0, 10, 0, 190),
	"📊 Show FPS — OFF ❌"
)

local flyMainBtn = createButton(
	"FlyButton",
	UDim2.new(0, 10, 0, 240),
	"🕊️ FLY GUI — BUKA"
)

flyMainBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 70)

local teleportBtn = createButton(
	"TeleportButton",
	UDim2.new(0, 10, 0, 290),
	"📍 Teleport — BUKA"
)

teleportBtn.BackgroundColor3 = Color3.fromRGB(110, 70, 0)

--==================================================
-- MINI BUTTON
--==================================================

local miniFrame = Instance.new("Frame")
miniFrame.Name = "MiniFrame"
miniFrame.Size = UDim2.new(0, 70, 0, 70)
miniFrame.Position = UDim2.new(0.5, -35, 0.85, -35)
miniFrame.BackgroundTransparency = 1
miniFrame.Visible = false
miniFrame.ZIndex = 50
miniFrame.Parent = gui

local miniBtn = Instance.new("ImageButton")
miniBtn.Size = UDim2.new(1, 0, 1, 0)
miniBtn.BackgroundTransparency = 1
miniBtn.Image = "rbxassetid://88411271061839"
miniBtn.Active = true
miniBtn.ZIndex = 51
miniBtn.Parent = miniFrame

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(1, 0)
miniCorner.Parent = miniBtn

local lockBtn = Instance.new("TextButton")
lockBtn.Size = UDim2.new(0, 24, 0, 24)
lockBtn.Position = UDim2.new(1, -26, 1, -26)
lockBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 120)
lockBtn.Text = "🔓"
lockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
lockBtn.Font = Enum.Font.GothamBold
lockBtn.TextSize = 12
lockBtn.Visible = false
lockBtn.ZIndex = 52
lockBtn.Parent = miniFrame

local lockCorner = Instance.new("UICorner")
lockCorner.CornerRadius = UDim.new(1, 0)
lockCorner.Parent = lockBtn

--==================================================
-- LOADING SCREEN
--==================================================

local loadingScreen = Instance.new("Frame")
loadingScreen.Name = "LoadingScreen"
loadingScreen.Size = UDim2.new(0, 340, 0, 150)
loadingScreen.Position = UDim2.new(0.5, -170, 0.5, -75)
loadingScreen.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
loadingScreen.BorderSizePixel = 2
loadingScreen.BorderColor3 = Color3.fromRGB(0, 160, 255)
loadingScreen.ZIndex = 100
loadingScreen.Parent = gui

local loadingCorner = Instance.new("UICorner")
loadingCorner.CornerRadius = UDim.new(0, 16)
loadingCorner.Parent = loadingScreen

local loadingBg = Instance.new("ImageLabel")
loadingBg.Size = UDim2.new(1, 0, 1, 0)
loadingBg.BackgroundTransparency = 1
loadingBg.Image = "rbxassetid://93486653982011"
loadingBg.ScaleType = Enum.ScaleType.Crop
loadingBg.ImageTransparency = 0.4
loadingBg.ZIndex = 100
loadingBg.Parent = loadingScreen

local loadingBgCorner = Instance.new("UICorner")
loadingBgCorner.CornerRadius = UDim.new(0, 16)
loadingBgCorner.Parent = loadingBg

local loadingTitle = Instance.new("TextLabel")
loadingTitle.Size = UDim2.new(1, 0, 0, 40)
loadingTitle.Position = UDim2.new(0, 0, 0, 10)
loadingTitle.BackgroundTransparency = 1
loadingTitle.Text = "⚡ JoyxAler V5.6"
loadingTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
loadingTitle.Font = Enum.Font.GothamBold
loadingTitle.TextSize = 24
loadingTitle.ZIndex = 101
loadingTitle.Parent = loadingScreen

local progressBg = Instance.new("Frame")
progressBg.Size = UDim2.new(1, -40, 0, 18)
progressBg.Position = UDim2.new(0, 20, 0, 65)
progressBg.BackgroundColor3 = Color3.fromRGB(0, 60, 110)
progressBg.ZIndex = 101
progressBg.Parent = loadingScreen

local progressBgCorner = Instance.new("UICorner")
progressBgCorner.CornerRadius = UDim.new(1, 0)
progressBgCorner.Parent = progressBg

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
progressBar.ZIndex = 102
progressBar.Parent = progressBg

local progressCorner = Instance.new("UICorner")
progressCorner.CornerRadius = UDim.new(1, 0)
progressCorner.Parent = progressBar

local percentText = Instance.new("TextLabel")
percentText.Size = UDim2.new(1, 0, 0, 30)
percentText.Position = UDim2.new(0, 0, 0, 100)
percentText.BackgroundTransparency = 1
percentText.Text = "0%"
percentText.TextColor3 = Color3.fromRGB(255, 255, 255)
percentText.Font = Enum.Font.GothamBold
percentText.TextSize = 18
percentText.ZIndex = 101
percentText.Parent = loadingScreen

--==================================================
-- LOADING
--==================================================

task.spawn(function()
	for i = 1, 100 do
		if not loadingScreen.Parent then
			return
		end

		percentText.Text = i .. "%"
		progressBar.Size = UDim2.new(i / 100, 0, 1, 0)

		task.wait(0.02)
	end

	task.wait(0.25)

	loadingScreen.Visible = false
	miniFrame.Visible = true

	print("JoyxAler V5.6 loaded successfully.")
end)

--==================================================
-- SAVE LIGHTING
--==================================================

local function saveLighting()
	if originalLighting then
		return
	end

	originalLighting = {
		Brightness = Lighting.Brightness,
		ClockTime = Lighting.ClockTime,
		ExposureCompensation = Lighting.ExposureCompensation,
		GlobalShadows = Lighting.GlobalShadows,
		FogStart = Lighting.FogStart,
		FogEnd = Lighting.FogEnd
	}

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

	if atmosphere then
		originalAtmosphereEnabled = atmosphere.Enabled
	end
end

--==================================================
-- FULL BRIGHT
--==================================================

local function setBright(state)
	brightOn = state

	if state then
		saveLighting()

		Lighting.Brightness = 1.8
		Lighting.ClockTime = 12.5
		Lighting.ExposureCompensation = 0.2
		Lighting.GlobalShadows = false
		Lighting.FogStart = 0
		Lighting.FogEnd = 1000000

		local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

		if atmosphere then
			atmosphere.Enabled = false
		end
	else
		if originalLighting then
			Lighting.Brightness = originalLighting.Brightness
			Lighting.ClockTime = originalLighting.ClockTime
			Lighting.ExposureCompensation = originalLighting.ExposureCompensation
			Lighting.GlobalShadows = originalLighting.GlobalShadows
			Lighting.FogStart = originalLighting.FogStart
			Lighting.FogEnd = originalLighting.FogEnd
		end

		local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

		if atmosphere and originalAtmosphereEnabled ~= nil then
			atmosphere.Enabled = originalAtmosphereEnabled
		end
	end
end

-- Keep Full Bright active
task.spawn(function()
	while gui.Parent do
		task.wait(0.5)

		if brightOn then
			Lighting.Brightness = 1.8
			Lighting.ClockTime = 12.5
			Lighting.ExposureCompensation = 0.2
			Lighting.GlobalShadows = false
			Lighting.FogStart = 0
			Lighting.FogEnd = 1000000

			local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

			if atmosphere then
				atmosphere.Enabled = false
			end
		end
	end
end)

--==================================================
-- FPS BOOST
--==================================================

local postEffectTypes = {
	"BlurEffect",
	"BloomEffect",
	"SunRaysEffect",
	"DepthOfFieldEffect",
	"ColorCorrectionEffect"
}

local function applyBoost(obj)
	if not obj:IsDescendantOf(Workspace) then
		return
	end

	-- Particles
	if obj:IsA("ParticleEmitter")
		or obj:IsA("Trail")
		or obj:IsA("Beam")
		or obj:IsA("Smoke")
		or obj:IsA("Fire")
		or obj:IsA("Sparkles") then

		if originalParticles[obj] == nil then
			originalParticles[obj] = obj.Enabled
			obj.Enabled = false
		end

		return
	end

	-- Parts
	if obj:IsA("BasePart") then
		if originalParts[obj] == nil then
			originalParts[obj] = {
				CastShadow = obj.CastShadow,
				Material = obj.Material,
				Reflectance = obj.Reflectance
			}

			obj.CastShadow = false
			obj.Material = Enum.Material.SmoothPlastic
			obj.Reflectance = 0
		end

		return
	end

	-- Decals / Textures
	if obj:IsA("Decal") or obj:IsA("Texture") then
		if originalDecals[obj] == nil then
			originalDecals[obj] = obj.Transparency
			obj.Transparency = math.clamp(obj.Transparency + 0.1, 0, 1)
		end
	end
end

local function setBoost(state)
	boostOn = state

	if state then
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 1000000

		for _, effectName in ipairs(postEffectTypes) do
			local effect = Lighting:FindFirstChildOfClass(effectName)

			if effect then
				if originalPostEffects[effect] == nil then
					originalPostEffects[effect] = effect.Enabled
				end

				effect.Enabled = false
			end
		end

		for _, obj in ipairs(Workspace:GetDescendants()) do
			applyBoost(obj)
		end
	else
		for obj, value in pairs(originalParticles) do
			if obj and obj.Parent then
				pcall(function()
					obj.Enabled = value
				end)
			end
		end

		table.clear(originalParticles)

		for obj, value in pairs(originalParts) do
			if obj and obj.Parent then
				pcall(function()
					obj.CastShadow = value.CastShadow
					obj.Material = value.Material
					obj.Reflectance = value.Reflectance
				end)
			end
		end

		table.clear(originalParts)

		for obj, value in pairs(originalDecals) do
			if obj and obj.Parent then
				pcall(function()
					obj.Transparency = value
				end)
			end
		end

		table.clear(originalDecals)

		for obj, value in pairs(originalPostEffects) do
			if obj and obj.Parent then
				pcall(function()
					obj.Enabled = value
				end)
			end
		end

		table.clear(originalPostEffects)
	end
end

--==================================================
-- UPDATE UI
--==================================================

local function updateUI()
	status.Text = string.format(
		"🔦 Bright: %s   |   ⚡ Boost: %s   |   📊 FPS: %s",
		brightOn and "ON ✅" or "OFF ❌",
		boostOn and "ON ✅" or "OFF ❌",
		fpsCounterOn and "ON ✅" or "OFF ❌"
	)

	brightBtn.Text = brightOn
		and "🔦 Full Bright — ON ✅"
		or "🔦 Full Bright — OFF ❌"

	brightBtn.BackgroundColor3 = brightOn
		and Color3.fromRGB(0, 130, 200)
		or Color3.fromRGB(0, 90, 160)

	fpsBoostBtn.Text = boostOn
		and "⚡ FPS Boost — ON ✅"
		or "⚡ FPS Boost — OFF ❌"

	fpsBoostBtn.BackgroundColor3 = boostOn
		and Color3.fromRGB(0, 130, 200)
		or Color3.fromRGB(0, 90, 160)

	showFpsBtn.Text = fpsCounterOn
		and "📊 Show FPS — ON ✅"
		or "📊 Show FPS — OFF ❌"

	showFpsBtn.BackgroundColor3 = fpsCounterOn
		and Color3.fromRGB(0, 130, 200)
		or Color3.fromRGB(0, 90, 160)
end

--==================================================
-- DRAG
--==================================================

local function makeDraggable(dragObject, objectToMove)
	local dragging = false
	local dragStart
	local startPosition

	dragObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPosition = objectToMove.Position
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if isLocked and objectToMove == miniFrame then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local delta = input.Position - dragStart

		objectToMove.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)
end

makeDraggable(dragArea, panel)
makeDraggable(miniBtn, miniFrame)

--==================================================
-- LOCK
--==================================================

lockBtn.MouseButton1Click:Connect(function()
	isLocked = not isLocked

	if isLocked then
		lockBtn.Text = "🔒"
		lockBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 60)
	else
		lockBtn.Text = "🔓"
		lockBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 120)
	end
end)

miniBtn.MouseEnter:Connect(function()
	lockBtn.Visible = true
end)

miniBtn.MouseLeave:Connect(function()
	task.delay(1, function()
		if miniFrame.Parent then
			lockBtn.Visible = false
		end
	end)
end)

--==================================================
-- MAIN BUTTONS
--==================================================

brightBtn.MouseButton1Click:Connect(function()
	setBright(not brightOn)
	updateUI()
end)

fpsBoostBtn.MouseButton1Click:Connect(function()
	setBoost(not boostOn)
	updateUI()
end)

showFpsBtn.MouseButton1Click:Connect(function()
	fpsCounterOn = not fpsCounterOn
	fpsCounter.Visible = fpsCounterOn

	updateUI()
end)

minBtn.MouseButton1Click:Connect(function()
	panel.Visible = false
	miniFrame.Visible = true
end)

miniBtn.MouseButton1Click:Connect(function()
	if not isLocked then
		panel.Visible = true
		miniFrame.Visible = false
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

--==================================================
-- TELEPORT GUI
--==================================================

local function createTeleportGUI()

	local tg = Instance.new("ScreenGui")
	tg.Name = "JoyxAler_Teleport"
	tg.ResetOnSpawn = false
	tg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	tg.Parent = PlayerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 280, 0, 350)
	frame.Position = UDim2.new(0.5, -140, 0.5, -175)
	frame.BackgroundColor3 = Color3.fromRGB(30, 25, 20)
	frame.BorderSizePixel = 2
	frame.BorderColor3 = Color3.fromRGB(160, 120, 0)
	frame.ZIndex = 10
	frame.Parent = tg

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local titleTp = Instance.new("TextLabel")
	titleTp.Size = UDim2.new(1, 0, 0, 45)
	titleTp.BackgroundColor3 = Color3.fromRGB(80, 60, 0)
	titleTp.Text = "📍 Teleport ke Pemain"
	titleTp.TextColor3 = Color3.new(1, 1, 1)
	titleTp.Font = Enum.Font.GothamBold
	titleTp.TextSize = 16
	titleTp.ZIndex = 11
	titleTp.Parent = frame

	local titleCornerTp = Instance.new("UICorner")
	titleCornerTp.CornerRadius = UDim.new(0, 12)
	titleCornerTp.Parent = titleTp

	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, -20, 1, -100)
	scrollFrame.Position = UDim2.new(0, 10, 0, 50)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 8
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.ZIndex = 11
	scrollFrame.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
	layout.Parent = scrollFrame

	local closeTp = Instance.new("TextButton")
	closeTp.Size = UDim2.new(1, -20, 0, 40)
	closeTp.Position = UDim2.new(0, 10, 1, -45)
	closeTp.BackgroundColor3 = Color3.fromRGB(120, 40, 0)
	closeTp.Text = "Tutup"
	closeTp.TextColor3 = Color3.new(1, 1, 1)
	closeTp.Font = Enum.Font.GothamBold
	closeTp.TextSize = 14
	closeTp.ZIndex = 12
	closeTp.Parent = frame

	local closeCornerTp = Instance.new("UICorner")
	closeCornerTp.CornerRadius = UDim.new(0, 8)
	closeCornerTp.Parent = closeTp

	local function refreshList()

		for _, child in ipairs(scrollFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		for _, player in ipairs(Players:GetPlayers()) do

			if player ~= LocalPlayer then

				local button = Instance.new("TextButton")
				button.Size = UDim2.new(1, 0, 0, 40)
				button.BackgroundColor3 = Color3.fromRGB(60, 50, 40)
				button.Text = "➡️ " .. player.Name
				button.TextColor3 = Color3.new(1, 1, 1)
				button.Font = Enum.Font.GothamBold
				button.TextSize = 14
				button.ZIndex = 12
				button.Parent = scrollFrame

				local buttonCorner = Instance.new("UICorner")
				buttonCorner.CornerRadius = UDim.new(0, 6)
				buttonCorner.Parent = button

				button.MouseButton1Click:Connect(function()

					local myCharacter = LocalPlayer.Character
					local targetCharacter = player.Character

					if not myCharacter or not targetCharacter then
						return
					end

					local targetRoot =
						targetCharacter:FindFirstChild("HumanoidRootPart")

					if not targetRoot then
						return
					end

					myCharacter:PivotTo(
						targetRoot.CFrame + Vector3.new(0, 3, 0)
					)
				end)
			end
		end

		scrollFrame.CanvasSize = UDim2.new(
			0,
			0,
			0,
			layout.AbsoluteContentSize.Y + 5
		)
	end

	refreshList()

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scrollFrame.CanvasSize = UDim2.new(
			0,
			0,
			0,
			layout.AbsoluteContentSize.Y + 5
		)
	end)

	local playerAddedConnection
	local playerRemovingConnection

	playerAddedConnection = Players.PlayerAdded:Connect(function()
		task.wait(0.2)

		if tg.Parent then
			refreshList()
		end
	end)

	playerRemovingConnection = Players.PlayerRemoving:Connect(function()
		task.wait(0.2)

		if tg.Parent then
			refreshList()
		end
	end)

	closeTp.MouseButton1Click:Connect(function()

		if playerAddedConnection then
			playerAddedConnection:Disconnect()
		end

		if playerRemovingConnection then
			playerRemovingConnection:Disconnect()
		end

		tg:Destroy()
		teleportGui = nil

		teleportBtn.Text = "📍 Teleport — BUKA"
		teleportBtn.BackgroundColor3 = Color3.fromRGB(110, 70, 0)
	end)

	return tg
end

teleportBtn.MouseButton1Click:Connect(function()

	if teleportGui then

		teleportGui:Destroy()
		teleportGui = nil

		teleportBtn.Text = "📍 Teleport — BUKA"
		teleportBtn.BackgroundColor3 = Color3.fromRGB(110, 70, 0)

	else

		teleportGui = createTeleportGUI()

		teleportBtn.Text = "📍 Teleport — TUTUP"
		teleportBtn.BackgroundColor3 = Color3.fromRGB(150, 90, 0)
	end
end)

--==================================================
-- FLY GUI
--==================================================

local flyActive = false
local flySpeed = 50
local flyUp = false
local flyDown = false

local flyBodyVelocity = nil
local flyBodyGyro = nil

local flyConnection = nil

--==================================================
-- STOP FLY
--==================================================

local function stopFly()

	flyActive = false
	flyUp = false
	flyDown = false

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

	local character = LocalPlayer.Character

	if character then

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.PlatformStand = false
			humanoid.AutoRotate = true
		end
	end
end

--==================================================
-- START FLY
--==================================================

local function startFly()

	local character = LocalPlayer.Character

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

	stopFly()

	flyActive = true

	humanoid.PlatformStand = true
	humanoid.AutoRotate = false

	flyBodyVelocity = Instance.new("BodyVelocity")
	flyBodyVelocity.Name = "JoyxAler_FlyVelocity"
	flyBodyVelocity.MaxForce = Vector3.new(
		1000000,
		1000000,
		1000000
	)
	flyBodyVelocity.P = 50000
	flyBodyVelocity.Velocity = Vector3.zero
	flyBodyVelocity.Parent = root

	flyBodyGyro = Instance.new("BodyGyro")
	flyBodyGyro.Name = "JoyxAler_FlyGyro"
	flyBodyGyro.MaxTorque = Vector3.new(
		1000000,
		1000000,
		1000000
	)
	flyBodyGyro.P = 50000
	flyBodyGyro.CFrame = root.CFrame
	flyBodyGyro.Parent = root

	flyConnection = RunService.RenderStepped:Connect(function()

		if not flyActive then
			return
		end

		if not root.Parent or humanoid.Health <= 0 then
			stopFly()
			return
		end

		local camera = Workspace.CurrentCamera

		if not camera then
			return
		end

		local look = camera.CFrame.LookVector
		local right = camera.CFrame.RightVector
		local moveDirection = humanoid.MoveDirection

		local velocity = Vector3.zero

		-- Forward/backward mengikuti arah kamera,
		-- termasuk pitch kamera (lihat atas/bawah).
		if moveDirection.Magnitude > 0.05 then

			local flatLook = Vector3.new(
				look.X,
				0,
				look.Z
			)

			local flatRight = Vector3.new(
				right.X,
				0,
				right.Z
			)

			if flatLook.Magnitude > 0.01 then
				flatLook = flatLook.Unit
			end

			if flatRight.Magnitude > 0.01 then
				flatRight = flatRight.Unit
			end

			local forwardAmount =
				moveDirection:Dot(flatLook)

			local rightAmount =
				moveDirection:Dot(flatRight)

			velocity += look * forwardAmount
			velocity += flatRight * rightAmount

			if velocity.Magnitude > 0.01 then
				velocity = velocity.Unit * flySpeed
			end
		end

		-- Tombol UP
		if flyUp then
			velocity += Vector3.new(
				0,
				flySpeed,
				0
			)
		end

		-- Tombol DOWN
		if flyDown then
			velocity -= Vector3.new(
				0,
				flySpeed,
				0
			)
		end

		flyBodyVelocity.Velocity = velocity

		-- Karakter mengikuti arah kamera
		flyBodyGyro.CFrame = CFrame.lookAt(
			root.Position,
			root.Position + look
		)
	end)
end

--==================================================
-- CREATE FLY GUI
--==================================================

local function createFlyGUI()

	local fg = Instance.new("ScreenGui")
	fg.Name = "JoyxAler_Fly"
	fg.ResetOnSpawn = false
	fg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	fg.Parent = PlayerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 230, 0, 145)
	frame.Position = UDim2.new(0.08, 0, 0.4, 0)
	frame.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
	frame.BorderSizePixel = 2
	frame.BorderColor3 = Color3.fromRGB(0, 200, 255)
	frame.Active = true
	frame.ZIndex = 20
	frame.Parent = fg

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 12)
	frameCorner.Parent = frame

	-- TITLE
	local flyTitle = Instance.new("TextLabel")
	flyTitle.Size = UDim2.new(1, -90, 0, 32)
	flyTitle.Position = UDim2.new(0, 45, 0, 0)
	flyTitle.BackgroundTransparency = 1
	flyTitle.Text = "🕊️ FLY GUI V3"
	flyTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
	flyTitle.Font = Enum.Font.GothamBold
	flyTitle.TextSize = 15
	flyTitle.ZIndex = 21
	flyTitle.Parent = frame

	-- CLOSE
	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 35, 0, 30)
	close.Position = UDim2.new(1, -40, 0, 2)
	close.BackgroundColor3 = Color3.fromRGB(150, 40, 50)
	close.Text = "✕"
	close.TextColor3 = Color3.new(1, 1, 1)
	close.Font = Enum.Font.GothamBold
	close.TextSize = 16
	close.ZIndex = 22
	close.Parent = frame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = close

	-- MINIMIZE
	local minimize = Instance.new("TextButton")
	minimize.Size = UDim2.new(0, 35, 0, 30)
	minimize.Position = UDim2.new(0, 5, 0, 2)
	minimize.BackgroundColor3 = Color3.fromRGB(60, 80, 110)
	minimize.Text = "−"
	minimize.TextColor3 = Color3.new(1, 1, 1)
	minimize.Font = Enum.Font.GothamBold
	minimize.TextSize = 20
	minimize.ZIndex = 22
	minimize.Parent = frame

	local minCorner2 = Instance.new("UICorner")
	minCorner2.CornerRadius = UDim.new(0, 6)
	minCorner2.Parent = minimize

	-- FLY ON/OFF
	local onOff = Instance.new("TextButton")
	onOff.Size = UDim2.new(0, 75, 0, 38)
	onOff.Position = UDim2.new(0, 78, 0, 35)
	onOff.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
	onOff.Text = "FLY OFF"
	onOff.TextColor3 = Color3.new(1, 1, 1)
	onOff.Font = Enum.Font.GothamBold
	onOff.TextSize = 14
	onOff.ZIndex = 22
	onOff.Parent = frame

	local onOffCorner = Instance.new("UICorner")
	onOffCorner.CornerRadius = UDim.new(0, 8)
	onOffCorner.Parent = onOff

	-- SPEED
	local speedLabel = Instance.new("TextLabel")
	speedLabel.Size = UDim2.new(0, 70, 0, 30)
	speedLabel.Position = UDim2.new(0, 80, 0, 78)
	speedLabel.BackgroundTransparency = 1
	speedLabel.Text = "Speed: 50"
	speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	speedLabel.Font = Enum.Font.GothamBold
	speedLabel.TextSize = 13
	speedLabel.ZIndex = 22
	speedLabel.Parent = frame

	-- MINUS
	local minus = Instance.new("TextButton")
	minus.Size = UDim2.new(0, 42, 0, 32)
	minus.Position = UDim2.new(0, 25, 0, 78)
	minus.BackgroundColor3 = Color3.fromRGB(70, 90, 130)
	minus.Text = "−"
	minus.TextColor3 = Color3.new(1, 1, 1)
	minus.Font = Enum.Font.GothamBold
	minus.TextSize = 20
	minus.ZIndex = 22
	minus.Parent = frame

	local minusCorner = Instance.new("UICorner")
	minusCorner.CornerRadius = UDim.new(0, 7)
	minusCorner.Parent = minus

	-- PLUS
	local plus = Instance.new("TextButton")
	plus.Size = UDim2.new(0, 42, 0, 32)
	plus.Position = UDim2.new(0, 163, 0, 78)
	plus.BackgroundColor3 = Color3.fromRGB(70, 130, 90)
	plus.Text = "+"
	plus.TextColor3 = Color3.new(1, 1, 1)
	plus.Font = Enum.Font.GothamBold
	plus.TextSize = 20
	plus.ZIndex = 22
	plus.Parent = frame

	local plusCorner = Instance.new("UICorner")
	plusCorner.CornerRadius = UDim.new(0, 7)
	plusCorner.Parent = plus

	-- UP
	local up = Instance.new("TextButton")
	up.Size = UDim2.new(0, 55, 0, 30)
	up.Position = UDim2.new(0, 10, 1, -38)
	up.BackgroundColor3 = Color3.fromRGB(50, 130, 200)
	up.Text = "▲ UP"
	up.TextColor3 = Color3.new(1, 1, 1)
	up.Font = Enum.Font.GothamBold
	up.TextSize = 12
	up.ZIndex = 22
	up.Parent = frame

	local upCorner = Instance.new("UICorner")
	upCorner.CornerRadius = UDim.new(0, 7)
	upCorner.Parent = up

	-- DOWN
	local down = Instance.new("TextButton")
	down.Size = UDim2.new(0, 65, 0, 30)
	down.Position = UDim2.new(1, -75, 1, -38)
	down.BackgroundColor3 = Color3.fromRGB(120, 80, 60)
	down.Text = "▼ DOWN"
	down.TextColor3 = Color3.new(1, 1, 1)
	down.Font = Enum.Font.GothamBold
	down.TextSize = 12
	down.ZIndex = 22
	down.Parent = frame

	local downCorner = Instance.new("UICorner")
	downCorner.CornerRadius = UDim.new(0, 7)
	downCorner.Parent = down

	-- DRAG
	makeDraggable(flyTitle, frame)

	-- Also allow dragging from empty frame area
	frame.InputBegan:Connect(function(input)

		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		-- buttons handle their own input
	end)

	--==================================================
	-- FLY TOGGLE
	--==================================================

	onOff.MouseButton1Click:Connect(function()

		if flyActive then

			stopFly()

			onOff.Text = "FLY OFF"
			onOff.BackgroundColor3 = Color3.fromRGB(100, 50, 50)

		else

			startFly()

			if flyActive then
				onOff.Text = "FLY ON"
				onOff.BackgroundColor3 = Color3.fromRGB(40, 150, 80)
			end
		end
	end)

	--==================================================
	-- SPEED -
	--==================================================

	minus.MouseButton1Click:Connect(function()

		flySpeed = math.max(10, flySpeed - 10)

		speedLabel.Text = "Speed: " .. flySpeed
	end)

	--==================================================
	-- SPEED +
	--==================================================

	plus.MouseButton1Click:Connect(function()

		flySpeed = math.min(200, flySpeed + 10)

		speedLabel.Text = "Speed: " .. flySpeed
	end)

	--==================================================
	-- UP
	--==================================================

	up.MouseButton1Down:Connect(function()
		flyUp = true
	end)

	up.MouseButton1Up:Connect(function()
		flyUp = false
	end)

	up.MouseLeave:Connect(function()
		flyUp = false
	end)

	--==================================================
	-- DOWN
	--==================================================

	down.MouseButton1Down:Connect(function()
		flyDown = true
	end)

	down.MouseButton1Up:Connect(function()
		flyDown = false
	end)

	down.MouseLeave:Connect(function()
		flyDown = false
	end)

	--==================================================
	-- MINIMIZE
	--==================================================

	local minimized = false

	minimize.MouseButton1Click:Connect(function()

		minimized = not minimized

		if minimized then

			for _, child in ipairs(frame:GetChildren()) do
				if child ~= flyTitle
					and child ~= close
					and child ~= minimize
					and child:IsA("GuiObject") then

					child.Visible = false
				end
			end

			frame.Size = UDim2.new(0, 230, 0, 35)
			minimize.Text = "+"

		else

			frame.Size = UDim2.new(0, 230, 0, 145)

			for _, child in ipairs(frame:GetChildren()) do
				if child ~= flyTitle
					and child ~= close
					and child ~= minimize
					and child:IsA("GuiObject") then

					child.Visible = true
				end
			end

			minimize.Text = "−"
		end
	end)

	--==================================================
	-- CLOSE
	--==================================================

	close.MouseButton1Click:Connect(function()

		stopFly()

		fg:Destroy()

		flyGui = nil

		flyMainBtn.Text = "🕊️ FLY GUI — BUKA"
		flyMainBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 70)
	end)

	return fg
end

--==================================================
-- FLY MAIN BUTTON
--==================================================

flyMainBtn.MouseButton1Click:Connect(function()

	if flyGui then

		stopFly()

		flyGui:Destroy()
		flyGui = nil

		flyMainBtn.Text = "🕊️ FLY GUI — BUKA"
		flyMainBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 70)

	else

		flyGui = createFlyGUI()

		flyMainBtn.Text = "🕊️ FLY GUI — TUTUP"
		flyMainBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 90)
	end
end)

--==================================================
-- CHARACTER RESPAWN
--==================================================

LocalPlayer.CharacterAdded:Connect(function()
	stopFly()
end)

--==================================================
-- INITIALIZE
--==================================================

updateUI()

print("================================")
print("⚡ JOY_ALER V5.6")
print("✅ GUI loaded")
print("✅ Full Bright ready")
print("✅ FPS Boost ready")
print("✅ FPS Counter ready")
print("✅ Teleport ready")
print("✅ Fly GUI ready")
print("================================")
