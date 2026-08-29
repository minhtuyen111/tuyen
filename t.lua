--========================================================
-- AUTO FARM / TARGET / HITBOX
-- 1 FILE - LocalScript
-- StarterPlayer > StarterPlayerScripts
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

--========================================================
-- SETTINGS
--========================================================

local TELEPORT_RANGE = 300
local SAFE_HEIGHT = 7
local HITBOX_RANGE = 55

local ENABLED = false
local HITBOX_ENABLED = true

local Character
local Humanoid
local Root
local Target

--========================================================
-- CHARACTER
--========================================================

local function SetupCharacter(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	Root = char:WaitForChild("HumanoidRootPart")
	Target = nil
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
Gui.Name = "FarmControl"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(640, 360)
Main.Position = UDim2.new(0.5, -320, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(55, 58, 72)
MainStroke.Thickness = 1
MainStroke.Parent = Main

--========================================================
-- TOP BAR
--========================================================

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 65)
Top.BackgroundTransparency = 1
Top.Parent = Main

-- Avatar
local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.fromOffset(42, 42)
Avatar.Position = UDim2.fromOffset(15, 11)
Avatar.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
Avatar.BorderSizePixel = 0
Avatar.Parent = Top

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = Avatar

task.spawn(function()
	local ok, image = pcall(function()
		return Players:GetUserThumbnailAsync(
			Player.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size100x100
		)
	end)

	if ok then
		Avatar.Image = image
	end
end)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromOffset(300, 28)
Title.Position = UDim2.fromOffset(70, 9)
Title.BackgroundTransparency = 1
Title.Text = "AUTO FARM"
Title.TextColor3 = Color3.fromRGB(245, 245, 250)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local User = Instance.new("TextLabel")
User.Size = UDim2.fromOffset(300, 20)
User.Position = UDim2.fromOffset(70, 35)
User.BackgroundTransparency = 1
User.Text = "@" .. Player.Name
User.TextColor3 = Color3.fromRGB(125, 130, 145)
User.TextSize = 11
User.Font = Enum.Font.Gotham
User.TextXAlignment = Enum.TextXAlignment.Left
User.Parent = Top

--========================================================
-- LOGO TOGGLE
--========================================================

local ToggleOuter = Instance.new("Frame")
ToggleOuter.Name = "ToggleOuter"
ToggleOuter.Size = UDim2.fromOffset(48, 48)
ToggleOuter.Position = UDim2.new(1, -63, 0, 8)
ToggleOuter.BackgroundColor3 = Color3.fromRGB(145, 55, 55)
ToggleOuter.BorderSizePixel = 0
ToggleOuter.Parent = Top

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleOuter

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(255, 110, 110)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleOuter

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.fromScale(1, 1)
Toggle.BackgroundTransparency = 1
Toggle.BorderSizePixel = 0
Toggle.Text = "AF"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.TextSize = 14
Toggle.Font = Enum.Font.GothamBold
Toggle.AutoButtonColor = false
Toggle.Parent = ToggleOuter

-- trạng thái nhỏ bên dưới logo
local ToggleState = Instance.new("TextLabel")
ToggleState.Size = UDim2.fromOffset(60, 15)
ToggleState.Position = UDim2.new(1, -69, 0, 55)
ToggleState.BackgroundTransparency = 1
ToggleState.Text = "OFF"
ToggleState.TextColor3 = Color3.fromRGB(255, 100, 100)
ToggleState.TextSize = 9
ToggleState.Font = Enum.Font.GothamBold
ToggleState.Parent = Top

--========================================================
-- STATUS BOX
--========================================================

local function CreateBox(x, y, w, h)
	local box = Instance.new("Frame")
	box.Size = UDim2.fromOffset(w, h)
	box.Position = UDim2.fromOffset(x, y)
	box.BackgroundColor3 = Color3.fromRGB(25, 27, 35)
	box.BorderSizePixel = 0
	box.Parent = Main

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 11)
	corner.Parent = box

	return box
end

local function CreateLabel(parent, text, y)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 25)
	label.Position = UDim2.fromOffset(10, y)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(190, 195, 205)
	label.TextSize = 12
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent

	return label
end

local TargetBox = CreateBox(20, 80, 290, 125)
local SettingBox = CreateBox(330, 80, 290, 125)
local DebugBox = CreateBox(20, 215, 600, 120)

local TargetLabel = CreateLabel(TargetBox, "TARGET : NONE", 10)
local DistanceLabel = CreateLabel(TargetBox, "DISTANCE : --", 42)
local MobLabel = CreateLabel(TargetBox, "MOBS : 0", 74)
local HitboxLabel = CreateLabel(TargetBox, "HITBOX : 55", 106)

local TeleportLabel = CreateLabel(SettingBox, "TELEPORT : IDLE", 10)
local HeightLabel = CreateLabel(SettingBox, "SAFE HEIGHT : 7", 42)
local RangeLabel = CreateLabel(SettingBox, "TELEPORT RANGE : 300", 74)
local StateLabel = CreateLabel(SettingBox, "STATUS : WAITING", 106)

local DebugLabel = CreateLabel(
	DebugBox,
	"DEBUG\nWaiting...",
	10
)

DebugLabel.TextWrapped = true
DebugLabel.TextYAlignment = Enum.TextYAlignment.Top
DebugLabel.TextColor3 = Color3.fromRGB(150, 155, 170)

--========================================================
-- HITBOX VISUAL
--========================================================

local HitboxPart = Instance.new("Part")
HitboxPart.Name = "FarmHitbox"
HitboxPart.Shape = Enum.PartType.Ball
HitboxPart.Size = Vector3.new(
	HITBOX_RANGE * 2,
	HITBOX_RANGE * 2,
	HITBOX_RANGE * 2
)

HitboxPart.Transparency = 1
HitboxPart.CanCollide = false
HitboxPart.CanTouch = false
HitboxPart.CanQuery = false
HitboxPart.Anchored = true
HitboxPart.Parent = workspace

--========================================================
-- NPC FILTER
--========================================================

local BAD = {
	shop = true,
	merchant = true,
	vendor = true,
	seller = true,
	trader = true,
	store = true,
	quest = true,
	npc = true
}

local function IsBadName(name)
	name = string.lower(name)

	for word in pairs(BAD) do
		if string.find(name, word, 1, true) then
			return true
		end
	end

	return false
end

local function IsMob(model)

	if not model:IsA("Model") then
		return false
	end

	if model == Character then
		return false
	end

	if IsBadName(model.Name) then
		return false
	end

	local hum =
		model:FindFirstChildOfClass("Humanoid")

	local root =
		model:FindFirstChild("HumanoidRootPart")

	if not hum or not root then
		return false
	end

	if hum.Health <= 0 then
		return false
	end

	if model:FindFirstChildOfClass("Dialog") then
		return false
	end

	if model:FindFirstChildWhichIsA(
		"ProximityPrompt",
		true
	) then
		return false
	end

	if model:GetAttribute("Friendly") == true then
		return false
	end

	if model:GetAttribute("IsNPC") == true then
		return false
	end

	if model:GetAttribute("CanAttack") == false then
		return false
	end

	return true
end

--========================================================
-- FIND MOB
--========================================================

local function FindMob()

	if not Root then
		return nil, 0, 0
	end

	local nearest
	local shortest = TELEPORT_RANGE
	local count = 0

	for _, obj in ipairs(workspace:GetDescendants()) do

		if IsMob(obj) then

			count += 1

			local r =
				obj:FindFirstChild("HumanoidRootPart")

			if r then

				local d =
					(Root.Position - r.Position).Magnitude

				if d <= shortest then
					shortest = d
					nearest = obj
				end
			end
		end
	end

	return nearest, shortest, count
end

--========================================================
-- TELEPORT
--========================================================

local function TeleportToMob(mob)

	if not Root or not mob then
		return false
	end

	local mobRoot =
		mob:FindFirstChild("HumanoidRootPart")

	if not mobRoot then
		return false
	end

	Root.Anchored = true

	Root.CFrame =
		CFrame.new(
			mobRoot.Position
				+ Vector3.new(0, SAFE_HEIGHT, 0)
		)

	return true
end

--========================================================
-- LOGO EFFECT
--========================================================

local function UpdateToggle()

	if ENABLED then

		ToggleOuter.BackgroundColor3 =
			Color3.fromRGB(40, 155, 85)

		ToggleStroke.Color =
			Color3.fromRGB(100, 255, 145)

		Toggle.Text = "AF"

		ToggleState.Text = "ON"
		ToggleState.TextColor3 =
			Color3.fromRGB(90, 255, 130)

	else

		ToggleOuter.BackgroundColor3 =
			Color3.fromRGB(145, 55, 55)

		ToggleStroke.Color =
			Color3.fromRGB(255, 105, 105)

		Toggle.Text = "AF"

		ToggleState.Text = "OFF"
		ToggleState.TextColor3 =
			Color3.fromRGB(255, 100, 100)

	end
end

Toggle.MouseButton1Click:Connect(function()

	ENABLED = not ENABLED

	local targetSize =
		ENABLED
		and UDim2.fromOffset(53, 53)
		or UDim2.fromOffset(48, 48)

	TweenService:Create(
		ToggleOuter,
		TweenInfo.new(
			0.12,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Size = targetSize
		}
	):Play()

	UpdateToggle()

	if ENABLED then

		StateLabel.Text =
			"STATUS : RUNNING"

		DebugLabel.Text =
			"DEBUG\nAuto Farm enabled."

	else

		StateLabel.Text =
			"STATUS : STOPPED"

		DebugLabel.Text =
			"DEBUG\nAuto Farm disabled."

		Target = nil

		if Root then
			Root.Anchored = false
		end
	end
end)

Toggle.MouseEnter:Connect(function()

	TweenService:Create(
		ToggleOuter,
		TweenInfo.new(0.12),
		{
			BackgroundTransparency = 0.05
		}
	):Play()

end)

Toggle.MouseLeave:Connect(function()

	TweenService:Create(
		ToggleOuter,
		TweenInfo.new(0.12),
		{
			BackgroundTransparency = 0
		}
	):Play()

end)

--========================================================
-- DRAG MENU
--========================================================

local Dragging = false
local DragStart
local StartPosition

Top.InputBegan:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or input.UserInputType ==
		Enum.UserInputType.Touch then

		Dragging = true
		DragStart = input.Position
		StartPosition = Main.Position

	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not Dragging then
		return
	end

	if input.UserInputType ==
		Enum.UserInputType.MouseMovement
		or input.UserInputType ==
		Enum.UserInputType.Touch then

		local Delta =
			input.Position - DragStart

		Main.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or input.UserInputType ==
		Enum.UserInputType.Touch then

		Dragging = false

	end
end)

--========================================================
-- MAIN LOOP
--========================================================

local Timer = 0

RunService.Heartbeat:Connect(function(dt)

	if not Root then
		return
	end

	if HITBOX_ENABLED then

		HitboxPart.Position = Root.Position

		HitboxPart.Size =
			Vector3.new(
				HITBOX_RANGE * 2,
				HITBOX_RANGE * 2,
				HITBOX_RANGE * 2
			)

	end

	if not ENABLED then
		return
	end

	Timer += dt

	-- Không quét map mỗi frame
	if Timer < 0.15 then
		return
	end

	Timer = 0

	-- Target chết/mất thì tìm target mới
	if Target and not IsMob(Target) then
		Target = nil
	end

	if not Target then

		local Mob, Distance, Count =
			FindMob()

		Target = Mob

		MobLabel.Text =
			"MOBS : " .. tostring(Count)

	end

	--====================================================
	-- HẾT QUÁI
	--====================================================

	if not Target then

		TargetLabel.Text =
			"TARGET : NONE"

		DistanceLabel.Text =
			"DISTANCE : --"

		TeleportLabel.Text =
			"TELEPORT : WAITING"

		StateLabel.Text =
			"STATUS : WAITING"

		DebugLabel.Text =
			"DEBUG\n"
			.. "No attackable mob found.\n"
			.. "Standing by for next spawn."

		Root.Anchored = false

		return
	end

	--====================================================
	-- TARGET
	--====================================================

	local MobRoot =
		Target:FindFirstChild("HumanoidRootPart")

	if not MobRoot then
		Target = nil
		return
	end

	local Distance =
		(Root.Position - MobRoot.Position).Magnitude

	TargetLabel.Text =
		"TARGET : " .. Target.Name

	TargetLabel.TextColor3 =
		Color3.fromRGB(90, 190, 255)

	DistanceLabel.Text =
		string.format(
			"DISTANCE : %.1f",
			Distance
		)

	MobLabel.Text =
		"MOB : LOCKED"

	--====================================================
	-- TELEPORT
	--====================================================

	if Distance > HITBOX_RANGE then

		if TeleportToMob(Target) then

			TeleportLabel.Text =
				"TELEPORT : OK"

			TeleportLabel.TextColor3 =
				Color3.fromRGB(90, 240, 125)

		end

	else

		TeleportLabel.Text =
			"TELEPORT : HOLD"

		TeleportLabel.TextColor3 =
			Color3.fromRGB(90, 240, 125)

	end

	--====================================================
	-- STABLE POSITION
	--====================================================

	local Desired =
		MobRoot.Position
			+ Vector3.new(0, SAFE_HEIGHT, 0)

	Root.Anchored = true
	Root.CFrame = CFrame.new(Desired)

	--====================================================
	-- STATUS
	--====================================================

	StateLabel.Text =
		"STATUS : TARGET LOCKED"

	HitboxLabel.Text =
		"HITBOX : " .. tostring(HITBOX_RANGE)

	DebugLabel.Text =
		"DEBUG\n"
		.. "Target : " .. Target.Name .. "\n"
		.. "Distance : "
		.. string.format("%.1f", Distance)
		.. "\n"
		.. "Hitbox : "
		.. HITBOX_RANGE
end)

--========================================================
-- INITIAL STATE
--========================================================

UpdateToggle()