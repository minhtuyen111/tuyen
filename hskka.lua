--========================================================
-- AUTO TELE + HITBOX
-- AF = ẨN / HIỆN MENU
-- TELE = BẬT / TẮT AUTO TELE
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

--========================================================
-- SETTINGS
--========================================================

local TELEPORT_RANGE = 300
local HITBOX_RANGE = 55
local SAFE_HEIGHT = 7

local TELE_ENABLED = false
local MENU_VISIBLE = true

local SCAN_DELAY = 0.25

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

	SetupCharacter(char)

end)

--========================================================
-- GUI
--========================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "AutoTeleGui"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = Player:WaitForChild("PlayerGui")

--========================================================
-- MAIN MENU
--========================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(500,280)
Main.Position = UDim2.new(0.5,-250,0.5,-140)
Main.BackgroundColor3 = Color3.fromRGB(15,16,22)
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0,14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(55,58,70)
MainStroke.Thickness = 1
MainStroke.Parent = Main

--========================================================
-- HEADER
--========================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,55)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.fromOffset(34,34)
Avatar.Position = UDim2.fromOffset(13,10)
Avatar.BackgroundColor3 = Color3.fromRGB(30,32,40)
Avatar.BorderSizePixel = 0
Avatar.Parent = Header

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1,0)
AvatarCorner.Parent = Avatar

task.spawn(function()

	local ok,image = pcall(function()

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

local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromOffset(250,22)
Title.Position = UDim2.fromOffset(57,8)
Title.BackgroundTransparency = 1
Title.Text = "AUTO TELE"
Title.TextColor3 = Color3.fromRGB(245,245,250)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.fromOffset(250,18)
SubTitle.Position = UDim2.fromOffset(57,29)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "TARGET / TELEPORT / HITBOX"
SubTitle.TextColor3 = Color3.fromRGB(110,115,130)
SubTitle.TextSize = 9
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Header

--========================================================
-- AF LOGO
-- CHỈ ẨN / HIỆN MENU
--========================================================

local AFButton = Instance.new("TextButton")
AFButton.Name = "AFLogo"
AFButton.Size = UDim2.fromOffset(38,38)
AFButton.Position = UDim2.new(1,-50,0,8)
AFButton.BackgroundColor3 = Color3.fromRGB(45,48,60)
AFButton.BorderSizePixel = 0
AFButton.AutoButtonColor = false
AFButton.Text = "AF"
AFButton.TextColor3 = Color3.fromRGB(255,255,255)
AFButton.TextSize = 11
AFButton.Font = Enum.Font.GothamBold
AFButton.Parent = Header

local AFCorner = Instance.new("UICorner")
AFCorner.CornerRadius = UDim.new(1,0)
AFCorner.Parent = AFButton

--========================================================
-- TELE BUTTON
-- RIÊNG BIỆT VỚI AF
--========================================================

local TeleButton = Instance.new("TextButton")
TeleButton.Name = "TeleToggle"
TeleButton.Size = UDim2.fromOffset(100,34)
TeleButton.Position = UDim2.new(1,-115,0,60)
TeleButton.BackgroundColor3 = Color3.fromRGB(145,55,55)
TeleButton.BorderSizePixel = 0
TeleButton.AutoButtonColor = false
TeleButton.Text = "TELE : OFF"
TeleButton.TextColor3 = Color3.fromRGB(255,255,255)
TeleButton.TextSize = 10
TeleButton.Font = Enum.Font.GothamBold
TeleButton.Parent = Main

local TeleCorner = Instance.new("UICorner")
TeleCorner.CornerRadius = UDim.new(0,9)
TeleCorner.Parent = TeleButton

local TeleStroke = Instance.new("UIStroke")
TeleStroke.Color = Color3.fromRGB(255,100,100)
TeleStroke.Thickness = 1
TeleStroke.Parent = TeleButton

--========================================================
-- INFO BOX
--========================================================

local function MakeBox(text,x,y,w)

	local Box = Instance.new("Frame")
	Box.Size = UDim2.fromOffset(w,40)
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
	Label.Size = UDim2.new(1,-12,1,0)
	Label.Position = UDim2.fromOffset(6,0)
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
	MakeBox("TARGET : NONE",15,110,225)

local DistanceLabel =
	MakeBox("DISTANCE : --",255,110,225)

local RangeLabel =
	MakeBox("TELE RANGE : 300",15,158,225)

local HitboxLabel =
	MakeBox("HITBOX : 55",255,158,225)

local StatusLabel =
	MakeBox("STATUS : WAITING",15,206,465)

--========================================================
-- DEBUG
--========================================================

local Debug = Instance.new("TextLabel")
Debug.Size = UDim2.fromOffset(465,25)
Debug.Position = UDim2.fromOffset(15,250)
Debug.BackgroundTransparency = 1
Debug.Text = "DEBUG : READY"
Debug.TextColor3 = Color3.fromRGB(110,115,130)
Debug.TextSize = 9
Debug.Font = Enum.Font.Code
Debug.TextXAlignment = Enum.TextXAlignment.Left
Debug.Parent = Main

--========================================================
-- AF LOGO ACTION
--========================================================

AFButton.MouseButton1Click:Connect(function()

	MENU_VISIBLE = not MENU_VISIBLE

	Main.Visible = MENU_VISIBLE

end)

--========================================================
-- TELE TOGGLE ACTION
--========================================================

local function UpdateTeleButton()

	if TELE_ENABLED then

		TeleButton.Text = "TELE : ON"

		TeleButton.BackgroundColor3 =
			Color3.fromRGB(40,155,85)

		TeleStroke.Color =
			Color3.fromRGB(100,255,145)

	else

		TeleButton.Text = "TELE : OFF"

		TeleButton.BackgroundColor3 =
			Color3.fromRGB(145,55,55)

		TeleStroke.Color =
			Color3.fromRGB(255,100,100)

	end

end

TeleButton.MouseButton1Click:Connect(function()

	TELE_ENABLED = not TELE_ENABLED

	UpdateTeleButton()

	if not TELE_ENABLED then

		Target = nil

		if Root then
			Root.Anchored = false
		end

		StatusLabel.Text =
			"STATUS : TELE OFF"

		Debug.Text =
			"DEBUG : AUTO TELE DISABLED"

	else

		StatusLabel.Text =
			"STATUS : SEARCHING"

		Debug.Text =
			"DEBUG : SEARCHING FOR MOB"

	end

end)

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
	"blacksmith",
	"npc"

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
-- FIND TARGET
--========================================================

local function FindTarget()

	if not Root then
		return nil,nil
	end

	local Best
	local BestDistance = TELEPORT_RANGE

	for _,Object in ipairs(workspace:GetChildren()) do

		if IsMob(Object) then

			local HRP =
				Object:FindFirstChild("HumanoidRootPart")

			if HRP then

				local Distance =
					(Root.Position-HRP.Position).Magnitude

				if Distance <= BestDistance then

					Best = Object
					BestDistance = Distance

				end

			end
		end
	end

	return Best,BestDistance
end

--========================================================
-- TELEPORT
--========================================================

local function Teleport(TargetMob)

	if not Root or not TargetMob then
		return false
	end

	local HRP =
		TargetMob:FindFirstChild("HumanoidRootPart")

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
-- DRAG MENU
--========================================================

local Dragging = false
local DragStart
local StartPosition

Header.InputBegan:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or Input.UserInputType ==
		Enum.UserInputType.Touch then

		Dragging = true

		DragStart = Input.Position
		StartPosition = Main.Position

	end

end)

UserInputService.InputChanged:Connect(function(Input)

	if not Dragging then
		return
	end

	if Input.UserInputType ==
		Enum.UserInputType.MouseMovement
		or Input.UserInputType ==
		Enum.UserInputType.Touch then

		local Delta =
			Input.Position-DragStart

		Main.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset+Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset+Delta.Y
		)

	end

end)

UserInputService.InputEnded:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or Input.UserInputType ==
		Enum.UserInputType.Touch then

		Dragging = false

	end

end)

--========================================================
-- MAIN LOOP
--========================================================

local Timer = 0

RunService.Heartbeat:Connect(function(dt)

	if not Root or not Humanoid then
		return
	end

	if Humanoid.Health <= 0 then

		Target = nil
		Root.Anchored = false

		return
	end

	if not TELE_ENABLED then
		return
	end

	Timer += dt

	if Timer < SCAN_DELAY then
		return
	end

	Timer = 0

	--====================================================
	-- KIỂM TRA TARGET CŨ
	--====================================================

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

			-- Giữ nhân vật trên đầu target
			Root.Anchored = true

			Root.CFrame =
				CFrame.new(
					HRP.Position
					+ Vector3.new(0,SAFE_HEIGHT,0)
				)

			StatusLabel.Text =
				"STATUS : TARGET LOCKED"

			Debug.Text =
				"DEBUG : LOCKED | "..Target.Name

			return
		end
	end

	--====================================================
	-- TARGET CŨ MẤT
	--====================================================

	Target = nil

	local NewTarget,Distance =
		FindTarget()

	--====================================================
	-- KHÔNG CÓ QUÁI
	--====================================================

	if not NewTarget then

		TargetLabel.Text =
			"TARGET : NONE"

		DistanceLabel.Text =
			"DISTANCE : --"

		StatusLabel.Text =
			"STATUS : WAITING"

		Debug.Text =
			"DEBUG : NO MOB | WAITING FOR SPAWN"

		-- ĐỨNG IM CHỜ QUÁI MỚI
		Root.Anchored = true

		return
	end

	--====================================================
	-- TARGET MỚI
	--====================================================

	Target = NewTarget

	TargetLabel.Text =
		"TARGET : "..Target.Name

	DistanceLabel.Text =
		string.format(
			"DISTANCE : %.1f",
			Distance
		)

	if Teleport(Target) then

		StatusLabel.Text =
			"STATUS : TARGET LOCKED"

		Debug.Text =
			"DEBUG : TELEPORTED | "..Target.Name

	end

end)

--========================================================
-- INITIAL
--========================================================

UpdateTeleButton()

RangeLabel.Text =
	"TELE RANGE : "..TELEPORT_RANGE

HitboxLabel.Text =
	"HITBOX : "..HITBOX_RANGE