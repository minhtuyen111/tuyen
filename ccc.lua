--========================================================
-- AUTO FARM
-- TELEPORT + TARGET + HITBOX
-- LOCAL SCRIPT
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")

local Player = Players.LocalPlayer

--========================================================
-- CONFIG
--========================================================

local TELEPORT_RANGE = 300
local HITBOX_RANGE = 55
local SAFE_HEIGHT = 7

local ENABLED = false

local SCAN_DELAY = 0.25
local POSITION_DELAY = 0.04

--========================================================
-- CHARACTER
--========================================================

local Character
local Humanoid
local Root

local function SetupCharacter(char)

	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	Root = char:WaitForChild("HumanoidRootPart")

end

if Player.Character then
	SetupCharacter(Player.Character)
end

Player.CharacterAdded:Connect(function(char)

	SetupCharacter(char)

end)

--========================================================
-- GUI
--========================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "AutoFarmUI"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = Player:WaitForChild("PlayerGui")

--========================================================
-- MAIN
--========================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(500, 280)
Main.Position = UDim2.new(0.5, -250, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(16, 17, 23)
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(55, 58, 70)
MainStroke.Thickness = 1
MainStroke.Parent = Main

--========================================================
-- HEADER / DRAG AREA
--========================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.fromOffset(34, 34)
Avatar.Position = UDim2.fromOffset(13, 10)
Avatar.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
Avatar.BorderSizePixel = 0
Avatar.Parent = Header

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = Avatar

task.spawn(function()

	local success, image =
		pcall(function()

			return Players:GetUserThumbnailAsync(
				Player.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size100x100
			)

		end)

	if success then
		Avatar.Image = image
	end

end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromOffset(250, 22)
Title.Position = UDim2.fromOffset(57, 8)
Title.BackgroundTransparency = 1
Title.Text = "AUTO FARM"
Title.TextColor3 = Color3.fromRGB(245,245,250)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.fromOffset(250, 18)
Subtitle.Position = UDim2.fromOffset(57, 29)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Target / Teleport / Hitbox"
Subtitle.TextColor3 = Color3.fromRGB(115,120,135)
Subtitle.TextSize = 9
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

--========================================================
-- LOGO TOGGLE
--========================================================

local Toggle = Instance.new("TextButton")
Toggle.Name = "LogoToggle"
Toggle.Size = UDim2.fromOffset(38,38)
Toggle.Position = UDim2.new(1,-50,0,8)
Toggle.BackgroundColor3 = Color3.fromRGB(145,55,55)
Toggle.BorderSizePixel = 0
Toggle.AutoButtonColor = false
Toggle.Text = "AF"
Toggle.TextColor3 = Color3.fromRGB(255,255,255)
Toggle.TextSize = 11
Toggle.Font = Enum.Font.GothamBold
Toggle.Parent = Header

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1,0)
ToggleCorner.Parent = Toggle

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 2
ToggleStroke.Color = Color3.fromRGB(255,100,100)
ToggleStroke.Parent = Toggle

--========================================================
-- STATUS BOX
--========================================================

local function CreateStatus(text, x, y, w)

	local Box = Instance.new("Frame")
	Box.Size = UDim2.fromOffset(w,42)
	Box.Position = UDim2.fromOffset(x,y)
	Box.BackgroundColor3 = Color3.fromRGB(25,27,35)
	Box.BorderSizePixel = 0
	Box.Parent = Main

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,9)
	Corner.Parent = Box

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Color3.fromRGB(42,45,55)
	Stroke.Thickness = 1
	Stroke.Parent = Box

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1,-14,1,0)
	Label.Position = UDim2.fromOffset(7,0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(190,195,205)
	Label.TextSize = 10
	Label.Font = Enum.Font.GothamMedium
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Box

	return Label
end

local TargetLabel =
	CreateStatus("TARGET : NONE",15,65,225)

local DistanceLabel =
	CreateStatus("DISTANCE : --",255,65,225)

local TeleportLabel =
	CreateStatus("TELEPORT : OFF",15,115,225)

local StateLabel =
	CreateStatus("STATUS : WAITING",255,115,225)

local RangeLabel =
	CreateStatus("TELE RANGE : 300",15,165,225)

local HitboxLabel =
	CreateStatus("HITBOX : 55",255,165,225)

--========================================================
-- DEBUG
--========================================================

local DebugBox = Instance.new("Frame")
DebugBox.Size = UDim2.fromOffset(465,42)
DebugBox.Position = UDim2.fromOffset(15,220)
DebugBox.BackgroundColor3 = Color3.fromRGB(11,12,17)
DebugBox.BorderSizePixel = 0
DebugBox.Parent = Main

local DebugCorner = Instance.new("UICorner")
DebugCorner.CornerRadius = UDim.new(0,9)
DebugCorner.Parent = DebugBox

local Debug = Instance.new("TextLabel")
Debug.Size = UDim2.new(1,-14,1,0)
Debug.Position = UDim2.fromOffset(7,0)
Debug.BackgroundTransparency = 1
Debug.Text = "DEBUG : READY"
Debug.TextColor3 = Color3.fromRGB(130,135,150)
Debug.TextSize = 9
Debug.Font = Enum.Font.Code
Debug.TextXAlignment = Enum.TextXAlignment.Left
Debug.Parent = DebugBox

--========================================================
-- NPC FILTER
--========================================================

local BAD_NAMES = {

	"shop",
	"shopkeeper",
	"merchant",
	"vendor",
	"seller",
	"trader",
	"store",
	"quest",
	"bank",
	"blacksmith"

}

local function IsBadName(name)

	name = string.lower(name)

	for _,word in ipairs(BAD_NAMES) do

		if string.find(name,word,1,true) then
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

	local Hum =
		model:FindFirstChildOfClass("Humanoid")

	local HRP =
		model:FindFirstChild("HumanoidRootPart")

	if not Hum or not HRP then
		return false
	end

	if Hum.Health <= 0 then
		return false
	end

	-- NPC tương tác
	if model:FindFirstChildOfClass("Dialog") then
		return false
	end

	if model:FindFirstChildWhichIsA(
		"ProximityPrompt",
		true
	) then
		return false
	end

	-- Attribute bảo vệ
	if model:GetAttribute("Friendly") == true then
		return false
	end

	if model:GetAttribute("IsNPC") == true then
		return false
	end

	if model:GetAttribute("CanAttack") == false then
		return false
	end

	-- Tag Mob / Enemy được ưu tiên
	if CollectionService:HasTag(model,"Mob")
		or CollectionService:HasTag(model,"Enemy")
		or CollectionService:HasTag(model,"Monster") then

		return true

	end

	return true
end

--========================================================
-- FIND TARGET
--========================================================

local function FindTarget()

	if not Root then
		return nil
	end

	local nearest = nil
	local nearestDistance = TELEPORT_RANGE

	for _,obj in ipairs(workspace:GetChildren()) do

		-- Quét Model cấp workspace trước
		if IsMob(obj) then

			local HRP =
				obj:FindFirstChild("HumanoidRootPart")

			if HRP then

				local distance =
					(Root.Position-HRP.Position).Magnitude

				if distance < nearestDistance then

					nearest = obj
					nearestDistance = distance

				end

			end

		end

	end

	return nearest, nearestDistance
end

--========================================================
-- TELEPORT
--========================================================

local function TeleportToTarget(target)

	if not Root or not target then
		return false
	end

	local HRP =
		target:FindFirstChild("HumanoidRootPart")

	if not HRP then
		return false
	end

	Root.Anchored = true

	Root.CFrame =
		CFrame.new(
			HRP.Position
			+ Vector3.new(0,SAFE_HEIGHT,0)
		)

	return true
end

--========================================================
-- UPDATE LOGO
--========================================================

local function UpdateLogo()

	if ENABLED then

		Toggle.BackgroundColor3 =
			Color3.fromRGB(40,155,85)

		ToggleStroke.Color =
			Color3.fromRGB(100,255,145)

		Toggle.Text = "AF"

		TeleportLabel.Text =
			"TELEPORT : ON"

		StateLabel.Text =
			"STATUS : SEARCHING"

	else

		Toggle.BackgroundColor3 =
			Color3.fromRGB(145,55,55)

		ToggleStroke.Color =
			Color3.fromRGB(255,100,100)

		Toggle.Text = "AF"

		TeleportLabel.Text =
			"TELEPORT : OFF"

		StateLabel.Text =
			"STATUS : WAITING"

	end

end

--========================================================
-- TOGGLE CLICK
--========================================================

Toggle.MouseButton1Click:Connect(function()

	ENABLED = not ENABLED

	TweenService:Create(
		Toggle,
		TweenInfo.new(
			0.12,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Size = UDim2.fromOffset(44,44)
		}
	):Play()

	task.delay(0.12,function()

		TweenService:Create(
			Toggle,
			TweenInfo.new(0.1),
			{
				Size = UDim2.fromOffset(38,38)
			}
		):Play()

	end)

	UpdateLogo()

	if not ENABLED then

		Target = nil

		if Root then
			Root.Anchored = false
		end

		Debug.Text =
			"DEBUG : FARM DISABLED"

	else

		Debug.Text =
			"DEBUG : SEARCHING TARGET..."

	end

end)

--========================================================
-- DRAG MENU
--========================================================

local Dragging = false
local DragStart
local StartPos

Header.InputBegan:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or input.UserInputType ==
		Enum.UserInputType.Touch then

		Dragging = true
		DragStart = input.Position
		StartPos = Main.Position

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
			input.Position-DragStart

		Main.Position = UDim2.new(
			StartPos.X.Scale,
			StartPos.X.Offset+Delta.X,
			StartPos.Y.Scale,
			StartPos.Y.Offset+Delta.Y
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
-- MAIN FARM LOOP
--========================================================

local ScanTimer = 0

RunService.Heartbeat:Connect(function(dt)

	if not Root or not Humanoid then
		return
	end

	if Humanoid.Health <= 0 then

		Target = nil
		Root.Anchored = false

		return
	end

	if not ENABLED then
		return
	end

	ScanTimer += dt

	-- Không quét liên tục
	if ScanTimer < SCAN_DELAY then
		return
	end

	ScanTimer = 0

	-- Target cũ
	if Target and IsMob(Target) then

		local HRP =
			Target:FindFirstChild("HumanoidRootPart")

		if HRP then

			local Distance =
				(Root.Position-HRP.Position).Magnitude

			TargetLabel.Text =
				"TARGET : "..Target.Name

			DistanceLabel.Text =
				string.format(
					"DISTANCE : %.1f",
					Distance
				)

			-- Giữ vị trí trên đầu
			Root.Anchored = true

			Root.CFrame =
				CFrame.new(
					HRP.Position
					+ Vector3.new(0,SAFE_HEIGHT,0)
				)

			StateLabel.Text =
				"STATUS : LOCKED"

			TeleportLabel.Text =
				"TELEPORT : HOLD"

			Debug.Text =
				"DEBUG : TARGET LOCKED | HITBOX "
				..HITBOX_RANGE

			return
		end
	end

	-- Target chết / mất
	Target = nil

	-- Tìm target mới
	local NewTarget,Distance =
		FindTarget()

	if not NewTarget then

		TargetLabel.Text =
			"TARGET : NONE"

		DistanceLabel.Text =
			"DISTANCE : --"

		TeleportLabel.Text =
			"TELEPORT : WAITING"

		StateLabel.Text =
			"STATUS : WAITING"

		Debug.Text =
			"DEBUG : NO MOB | WAITING FOR SPAWN"

		-- Đứng tại vị trí hiện tại
		Root.Anchored = true

		return
	end

	Target = NewTarget

	TargetLabel.Text =
		"TARGET : "..Target.Name

	DistanceLabel.Text =
		string.format(
			"DISTANCE : %.1f",
			Distance
		)

	-- Tele tới target
	if TeleportToTarget(Target) then

		TeleportLabel.Text =
			"TELEPORT : OK"

		TeleportLabel.TextColor3 =
			Color3.fromRGB(90,240,125)

		StateLabel.Text =
			"STATUS : LOCKED"

		Debug.Text =
			"DEBUG : TARGET FOUND | "
			..Target.Name

	end

end)

--========================================================
-- INITIAL
--========================================================

UpdateLogo()

HitboxLabel.Text =
	"HITBOX : "..HITBOX_RANGE

RangeLabel.Text =
	"TELE RANGE : "..TELEPORT_RANGE