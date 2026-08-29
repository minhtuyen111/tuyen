--========================================================
-- AUTO FARM ALL-IN-ONE
-- Luau - 1 FILE DUY NHẤT
-- Đặt tại:
-- StarterPlayer > StarterPlayerScripts
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

--========================================================
-- SETTINGS
--========================================================

local TELEPORT_RANGE = 300 -- tìm quái trong 300 studs
local SAFE_HEIGHT = 15     -- đứng cao hơn quái
local ATTACK_DELAY = 0.12  -- tốc độ Activate Tool
local SCAN_DELAY = 0.10

local AutoFarm = false
local AutoAttack = true

local Character
local Humanoid
local Root

local CurrentTarget = nil
local LastAttack = 0
local LastScan = 0

--========================================================
-- CHARACTER
--========================================================

local function SetupCharacter(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	Root = char:WaitForChild("HumanoidRootPart")
	CurrentTarget = nil
end

if Player.Character then
	SetupCharacter(Player.Character)
end

Player.CharacterAdded:Connect(function(char)
	task.wait(0.3)
	SetupCharacter(char)
end)

--========================================================
-- GUI
--========================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "AutoFarmGUI"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(350, 465)
Main.Position = UDim2.new(0, 25, 0.5, -230)
Main.BackgroundColor3 = Color3.fromRGB(17, 18, 24)
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(55, 58, 75)
Stroke.Thickness = 1
Stroke.Parent = Main

--========================================================
-- TITLE
--========================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 0, 45)
Title.Position = UDim2.fromOffset(15, 8)
Title.BackgroundTransparency = 1
Title.Text = "⚡  AUTO FARM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextSize = 23
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -30, 0, 20)
SubTitle.Position = UDim2.fromOffset(15, 45)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Luau • Debug Control Panel"
SubTitle.TextColor3 = Color3.fromRGB(140, 145, 160)
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.TextSize = 12
SubTitle.Font = Enum.Font.Gotham
SubTitle.Parent = Main

--========================================================
-- BUTTON FACTORY
--========================================================

local function MakeButton(y, text)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -30, 0, 39)
	Button.Position = UDim2.fromOffset(15, y)
	Button.BackgroundColor3 = Color3.fromRGB(45, 48, 62)
	Button.BorderSizePixel = 0
	Button.Text = text
	Button.TextColor3 = Color3.fromRGB(240, 240, 245)
	Button.TextSize = 14
	Button.Font = Enum.Font.GothamBold
	Button.Parent = Main

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 9)
	corner.Parent = Button

	return Button
end

local FarmButton = MakeButton(72, "AUTO FARM : OFF")
local AttackButton = MakeButton(118, "AUTO ATTACK : ON")

--========================================================
-- STATUS LABELS
--========================================================

local function MakeStatus(y, text)

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -30, 0, 25)
	Label.Position = UDim2.fromOffset(15, y)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(180, 185, 200)
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextSize = 13
	Label.Font = Enum.Font.Gotham
	Label.Parent = Main

	return Label
end

local TargetLabel = MakeStatus(170, "🎯 Target: NONE")
local DistanceLabel = MakeStatus(195, "📏 Distance: ---")
local MobLabel = MakeStatus(220, "👾 Mobs found: 0")
local TeleportLabel = MakeStatus(245, "🚀 Teleport: IDLE")
local PositionLabel = MakeStatus(270, "🛡 Position: IDLE")
local WeaponLabel = MakeStatus(295, "⚔ Weapon: NONE")
local AttackLabel = MakeStatus(320, "🔥 Attack: IDLE")

--========================================================
-- SETTINGS INFO
--========================================================

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -30, 0, 40)
Info.Position = UDim2.fromOffset(15, 347)
Info.BackgroundTransparency = 1
Info.Text =
	"Teleport Range: 300 studs   •   Safe Height: "
	.. tostring(SAFE_HEIGHT)
Info.TextColor3 = Color3.fromRGB(130, 135, 150)
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.TextSize = 11
Info.Font = Enum.Font.Gotham
Info.Parent = Main

--========================================================
-- DEBUG BOX
--========================================================

local DebugBox = Instance.new("TextLabel")
DebugBox.Size = UDim2.new(1, -30, 0, 55)
DebugBox.Position = UDim2.fromOffset(15, 390)
DebugBox.BackgroundColor3 = Color3.fromRGB(11, 12, 17)
DebugBox.BorderSizePixel = 0
DebugBox.Text = "DEBUG: Waiting..."
DebugBox.TextColor3 = Color3.fromRGB(170, 175, 190)
DebugBox.TextXAlignment = Enum.TextXAlignment.Left
DebugBox.TextYAlignment = Enum.TextYAlignment.Top
DebugBox.TextSize = 11
DebugBox.Font = Enum.Font.Code
DebugBox.TextWrapped = true
DebugBox.Parent = Main

local DebugCorner = Instance.new("UICorner")
DebugCorner.CornerRadius = UDim.new(0, 8)
DebugCorner.Parent = DebugBox

--========================================================
-- DRAG WINDOW
--========================================================

local Dragging = false
local DragStart
local StartPosition

local function UpdateDrag(input)

	local delta = input.Position - DragStart

	Main.Position =
		UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + delta.Y
		)
end

Title.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		Dragging = true
		DragStart = input.Position
		StartPosition = Main.Position

	end
end)

UserInputService.InputChanged:Connect(function(input)

	if Dragging then

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			UpdateDrag(input)

		end

	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		Dragging = false

	end
end)

--========================================================
-- COLORS
--========================================================

local function SetStatus(label, text, color)
	label.Text = text
	label.TextColor3 = color
end

local GREEN = Color3.fromRGB(90, 240, 125)
local RED = Color3.fromRGB(255, 85, 85)
local YELLOW = Color3.fromRGB(255, 205, 80)
local BLUE = Color3.fromRGB(90, 190, 255)
local WHITE = Color3.fromRGB(220, 220, 225)

--========================================================
-- MOB CHECK
--========================================================

local function IsMob(obj)

	if not obj:IsA("Model") then
		return false
	end

	if obj == Character then
		return false
	end

	local hum = obj:FindFirstChildOfClass("Humanoid")
	local root = obj:FindFirstChild("HumanoidRootPart")

	if not hum or not root then
		return false
	end

	if hum.Health <= 0 then
		return false
	end

	return true
end

--========================================================
-- FIND NEAREST MOB
--========================================================

local function FindNearestMob()

	if not Root then
		return nil, math.huge, 0
	end

	local nearest = nil
	local nearestDistance = TELEPORT_RANGE
	local mobCount = 0

	for _, obj in ipairs(workspace:GetDescendants()) do

		if IsMob(obj) then

			mobCount += 1

			local mobRoot =
				obj:FindFirstChild("HumanoidRootPart")

			if mobRoot then

				local distance =
					(Root.Position - mobRoot.Position).Magnitude

				if distance <= nearestDistance then

					nearest = obj
					nearestDistance = distance

				end
			end
		end
	end

	return nearest, nearestDistance, mobCount
end

--========================================================
-- TELEPORT + SAFE POSITION
--========================================================

local function MoveAboveMob(mob)

	if not Root then
		return false, "Player root missing"
	end

	if not mob then
		return false, "Target missing"
	end

	local mobRoot =
		mob:FindFirstChild("HumanoidRootPart")

	if not mobRoot then
		return false, "Mob root missing"
	end

	local targetPosition =
		mobRoot.Position
		+ Vector3.new(0, SAFE_HEIGHT, 0)

	-- Anchored để không bị Humanoid/physics giật xuống.
	Root.Anchored = true

	Root.CFrame =
		CFrame.lookAt(
			targetPosition,
			mobRoot.Position
		)

	return true, "Position locked"
end

--========================================================
-- AUTO ATTACK
--========================================================

local function AutoAttackNow()

	if not Character then
		return "NO_CHARACTER"
	end

	local tool =
		Character:FindFirstChildOfClass("Tool")

	if not tool then
		return "NO_TOOL"
	end

	local now = os.clock()

	if now - LastAttack < ATTACK_DELAY then
		return "WAIT"
	end

	LastAttack = now

	local success, errorMessage =
		pcall(function()
			tool:Activate()
		end)

	if success then
		return "ACTIVE"
	end

	return "ERROR: " .. tostring(errorMessage)
end

--========================================================
-- BUTTON: FARM
--========================================================

FarmButton.MouseButton1Click:Connect(function()

	AutoFarm = not AutoFarm

	if AutoFarm then

		FarmButton.Text = "AUTO FARM : ON"
		FarmButton.BackgroundColor3 =
			Color3.fromRGB(40, 150, 80)

	else

		FarmButton.Text = "AUTO FARM : OFF"
		FarmButton.BackgroundColor3 =
			Color3.fromRGB(145, 55, 55)

		if Root then
			Root.Anchored = false
		end

	end
end)

--========================================================
-- BUTTON: ATTACK
--========================================================

AttackButton.MouseButton1Click:Connect(function()

	AutoAttack = not AutoAttack

	if AutoAttack then

		AttackButton.Text = "AUTO ATTACK : ON"
		AttackButton.BackgroundColor3 =
			Color3.fromRGB(40, 150, 80)

	else

		AttackButton.Text = "AUTO ATTACK : OFF"
		AttackButton.BackgroundColor3 =
			Color3.fromRGB(145, 55, 55)

	end
end)

--========================================================
-- MAIN LOOP
--========================================================

task.spawn(function()

	while task.wait(0.05) do

		--============================================
		-- BASIC CHECK
		--============================================

		if not Character
			or not Root
			or not Humanoid then

			SetStatus(
				FarmButton,
				"AUTO FARM : CHARACTER ERROR",
				RED
			)

			DebugBox.Text =
				"DEBUG: Character / Humanoid / Root missing"

			continue
		end

		if Humanoid.Health <= 0 then

			SetStatus(
				TargetLabel,
				"🎯 Target: DEAD",
				RED
			)

			if Root then
				Root.Anchored = false
			end

			continue
		end

		--============================================
		-- WEAPON STATUS
		--============================================

		local tool =
			Character:FindFirstChildOfClass("Tool")

		if tool then

			SetStatus(
				WeaponLabel,
				"⚔ Weapon: " .. tool.Name,
				GREEN
			)

		else

			SetStatus(
				WeaponLabel,
				"⚔ Weapon: NONE",
				RED
			)

		end

		--============================================
		-- FARM OFF
		--============================================

		if not AutoFarm then

			SetStatus(
				TargetLabel,
				"🎯 Target: NONE",
				WHITE
			)

			SetStatus(
				TeleportLabel,
				"🚀 Teleport: OFF",
				WHITE
			)

			SetStatus(
				PositionLabel,
				"🛡 Position: OFF",
				WHITE
			)

			if Root then
				Root.Anchored = false
			end

			continue
		end

		--============================================
		-- SCAN MOBS
		--============================================

		local now = os.clock()

		if now - LastScan >= SCAN_DELAY then

			LastScan = now

			local target, distance, count =
				FindNearestMob()

			CurrentTarget = target

			SetStatus(
				MobLabel,
				"👾 Mobs found: " .. tostring(count),
				count > 0 and GREEN or YELLOW
			)

			--========================================
			-- TARGET FOUND
			--========================================

			if target then

				SetStatus(
					TargetLabel,
					"🎯 Target: " .. target.Name,
					BLUE
				)

				SetStatus(
					DistanceLabel,
					string.format(
						"📏 Distance: %.1f / %d",
						distance,
						TELEPORT_RANGE
					),
					GREEN
				)

				--====================================
				-- MOVE
				--====================================

				local success, message =
					MoveAboveMob(target)

				if success then

					SetStatus(
						TeleportLabel,
						"🚀 Teleport: OK",
						GREEN
					)

					SetStatus(
						PositionLabel,
						"🛡 Position: %.1f studs above",
						GREEN
					)

					DebugBox.Text =
						"DEBUG: Target found\n"
						.. "Target: " .. target.Name .. "\n"
						.. "Teleport: OK | Position: LOCKED"

				else

					SetStatus(
						TeleportLabel,
						"🚀 Teleport: FAILED",
						RED
					)

					SetStatus(
						PositionLabel,
						"🛡 Position: FAILED",
						RED
					)

					DebugBox.Text =
						"DEBUG ERROR:\n" .. tostring(message)

				end

			else

				SetStatus(
					TargetLabel,
					"🎯 Target: NONE",
					YELLOW
				)

				SetStatus(
					DistanceLabel,
					"📏 Distance: ---",
					WHITE
				)

				SetStatus(
					TeleportLabel,
					"🚀 Teleport: SEARCHING",
					YELLOW
				)

				SetStatus(
					PositionLabel,
					"🛡 Position: WAITING",
					YELLOW
				)

				if Root then
					Root.Anchored = false
				end

				DebugBox.Text =
					"DEBUG: Không có quái trong "
					.. TELEPORT_RANGE
					.. " studs"

			end
		end

		--============================================
		-- ATTACK
		--============================================

		if AutoAttack and CurrentTarget then

			local result = AutoAttackNow()

			if result == "ACTIVE" then

				SetStatus(
					AttackLabel,
					"🔥 Attack: ACTIVE",
					GREEN
				)

			elseif result == "NO_TOOL" then

				SetStatus(
					AttackLabel,
					"🔥 Attack: NO TOOL",
					RED
				)

				DebugBox.Text =
					"DEBUG ERROR:\n"
					.. "Không tìm thấy Tool đang trang bị."

			elseif string.sub(result, 1, 5) == "ERROR" then

				SetStatus(
					AttackLabel,
					"🔥 Attack: ERROR",
					RED
				)

				DebugBox.Text =
					"DEBUG ERROR:\n" .. result

			end

		else

			SetStatus(
				AttackLabel,
				"🔥 Attack: WAITING",
				YELLOW
			)

		end
	end
end)