--// FAST RUN MENU - ROBLOX STUDIO
--// LocalScript -> StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")

local player = Players.LocalPlayer

local NORMAL_SPEED = 16
local MAX_SPEED = 9999
local DEFAULT_SPEED = 100

local enabled = false
local currentSpeed = DEFAULT_SPEED

--==================================================
-- CHARACTER
--==================================================

local humanoid

local function getHumanoid()
	local character = player.Character or player.CharacterAdded:Wait()
	return character:WaitForChild("Humanoid")
end

local function applySpeed()
	if not humanoid or humanoid.Parent == nil then
		humanoid = getHumanoid()
	end

	if enabled then
		humanoid.WalkSpeed = currentSpeed
	else
		humanoid.WalkSpeed = NORMAL_SPEED
	end
end

player.CharacterAdded:Connect(function(character)
	humanoid = character:WaitForChild("Humanoid")

	task.wait(0.1)
	applySpeed()
end)

humanoid = getHumanoid()

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "FastRunMenu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--==================================================
-- LOGO BUTTON
--==================================================

local logo = Instance.new("TextButton")
logo.Name = "Logo"
logo.Size = UDim2.fromOffset(60, 60)
logo.Position = UDim2.new(0, 20, 0.5, -30)
logo.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
logo.Text = "⚡"
logo.TextSize = 30
logo.TextColor3 = Color3.fromRGB(255, 255, 255)
logo.Font = Enum.Font.GothamBold
logo.Parent = gui

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(1, 0)
logoCorner.Parent = logo

local logoStroke = Instance.new("UIStroke")
logoStroke.Thickness = 2
logoStroke.Color = Color3.fromRGB(255, 255, 255)
logoStroke.Parent = logo

--==================================================
-- MAIN MENU
--==================================================

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(330, 230)
frame.Position = UDim2.new(0, 90, 0.5, -115)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Visible = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Thickness = 2
frameStroke.Color = Color3.fromRGB(70, 70, 70)
frameStroke.Parent = frame

--==================================================
-- TITLE
--==================================================

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 45)
title.Position = UDim2.fromOffset(10, 5)
title.BackgroundTransparency = 1
title.Text = "⚡ FAST RUN"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.Parent = frame

--==================================================
-- SPEED TEXT
--==================================================

local speedText = Instance.new("TextLabel")
speedText.Size = UDim2.new(1, -20, 0, 35)
speedText.Position = UDim2.fromOffset(10, 50)
speedText.BackgroundTransparency = 1
speedText.Text = "Tốc độ: " .. currentSpeed
speedText.TextColor3 = Color3.fromRGB(255, 255, 255)
speedText.TextSize = 18
speedText.Font = Enum.Font.Gotham
speedText.Parent = frame

--==================================================
-- SPEED INPUT
--==================================================

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, -40, 0, 42)
speedBox.Position = UDim2.fromOffset(20, 90)
speedBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
speedBox.PlaceholderText = "Nhập tốc độ 16 - 9999"
speedBox.Text = tostring(DEFAULT_SPEED)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
speedBox.TextSize = 17
speedBox.Font = Enum.Font.Gotham
speedBox.ClearTextOnFocus = false
speedBox.Parent = frame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 8)
boxCorner.Parent = speedBox

--==================================================
-- APPLY SPEED
--==================================================

local applyButton = Instance.new("TextButton")
applyButton.Size = UDim2.new(1, -40, 0, 42)
applyButton.Position = UDim2.fromOffset(20, 140)
applyButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
applyButton.Text = "ÁP DỤNG TỐC ĐỘ"
applyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
applyButton.TextSize = 16
applyButton.Font = Enum.Font.GothamBold
applyButton.Parent = frame

local applyCorner = Instance.new("UICorner")
applyCorner.CornerRadius = UDim.new(0, 8)
applyCorner.Parent = applyButton

--==================================================
-- TOGGLE
--==================================================

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -40, 0, 38)
toggle.Position = UDim2.fromOffset(20, 187)
toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggle.Text = "FAST RUN: OFF"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.TextSize = 16
toggle.Font = Enum.Font.GothamBold
toggle.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggle

--==================================================
-- APPLY BUTTON
--==================================================

applyButton.MouseButton1Click:Connect(function()

	local number = tonumber(speedBox.Text)

	if not number then
		speedBox.Text = tostring(currentSpeed)
		return
	end

	number = math.floor(number)

	if number < 16 then
		number = 16
	end

	if number > MAX_SPEED then
		number = MAX_SPEED
	end

	currentSpeed = number

	speedBox.Text = tostring(currentSpeed)
	speedText.Text = "Tốc độ: " .. currentSpeed

	applySpeed()
end)

--==================================================
-- TOGGLE BUTTON
--==================================================

toggle.MouseButton1Click:Connect(function()

	enabled = not enabled

	if enabled then
		toggle.Text = "FAST RUN: ON"
		toggle.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
	else
		toggle.Text = "FAST RUN: OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end

	applySpeed()
end)

--==================================================
-- LOGO OPEN / CLOSE
--==================================================

logo.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

--==================================================
-- ENTER = APPLY
--==================================================

speedBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		applyButton:Activate()
	end
end)