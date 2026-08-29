--========================================================
-- AUTO FARM / AUTO TELE
--========================================================
-- AF       = MỞ LẠI MENU
-- TELE     = BẬT / TẮT AUTO TELE
-- TELE 300 = TẦM QUÉT / TÌM QUÁI
-- ATTACK   = TẦM ĐÁNH RIÊNG
-- SAFE     = KHOẢNG CÁCH ĐỨNG TRÊN QUÁI
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

--========================================================
-- SETTINGS
--========================================================

local TELEPORT_RANGE = 300
local ATTACK_RANGE = 70
local SAFE_HEIGHT = 7

local SCAN_INTERVAL = 0.10

local TELE_ENABLED = false
local MENU_VISIBLE = true

local Character
local Humanoid
local Root

local CurrentTarget = nil
local ScanTimer = 0

--========================================================
-- CHARACTER
--========================================================

local function SetupCharacter(CharacterModel)

	Character = CharacterModel

	Humanoid =
		Character:WaitForChild("Humanoid")

	Root =
		Character:WaitForChild("HumanoidRootPart")

	CurrentTarget = nil

end

if Player.Character then
	SetupCharacter(Player.Character)
end

Player.CharacterAdded:Connect(function(CharacterModel)

	SetupCharacter(CharacterModel)

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
-- MAIN MENU
--========================================================

local Main = Instance.new("Frame")

Main.Name = "Main"
Main.Size = UDim2.fromOffset(500,280)
Main.Position = UDim2.new(0.5,-250,0.5,-140)

Main.BackgroundColor3 =
	Color3.fromRGB(15,16,22)

Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")

MainCorner.CornerRadius =
	UDim.new(0,14)

MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")

MainStroke.Color =
	Color3.fromRGB(55,58,70)

MainStroke.Thickness = 1

MainStroke.Parent = Main

--========================================================
-- HEADER
--========================================================

local Header = Instance.new("Frame")

Header.Size =
	UDim2.new(1,0,0,55)

Header.BackgroundTransparency = 1
Header.Parent = Main

--========================================================
-- AVATAR
--========================================================

local Avatar = Instance.new("ImageLabel")

Avatar.Size =
	UDim2.fromOffset(36,36)

Avatar.Position =
	UDim2.fromOffset(12,9)

Avatar.BackgroundColor3 =
	Color3.fromRGB(30,32,40)

Avatar.BorderSizePixel = 0
Avatar.Parent = Header

local AvatarCorner = Instance.new("UICorner")

AvatarCorner.CornerRadius =
	UDim.new(1,0)

AvatarCorner.Parent = Avatar

task.spawn(function()

	local Success, Image =
		pcall(function()

			return Players:GetUserThumbnailAsync(
				Player.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size100x100
			)

		end)

	if Success then
		Avatar.Image = Image
	end

end)

--========================================================
-- TITLE
--========================================================

local Title = Instance.new("TextLabel")

Title.Size =
	UDim2.fromOffset(250,22)

Title.Position =
	UDim2.fromOffset(57,7)

Title.BackgroundTransparency = 1

Title.Text =
	"AUTO FARM"

Title.TextColor3 =
	Color3.fromRGB(245,245,250)

Title.TextSize = 16

Title.Font =
	Enum.Font.GothamBold

Title.TextXAlignment =
	Enum.TextXAlignment.Left

Title.Parent = Header

local Subtitle = Instance.new("TextLabel")

Subtitle.Size =
	UDim2.fromOffset(270,18)

Subtitle.Position =
	UDim2.fromOffset(57,29)

Subtitle.BackgroundTransparency = 1

Subtitle.Text =
	"TARGET  •  TELEPORT  •  ATTACK"

Subtitle.TextColor3 =
	Color3.fromRGB(110,115,130)

Subtitle.TextSize = 9

Subtitle.Font =
	Enum.Font.Gotham

Subtitle.TextXAlignment =
	Enum.TextXAlignment.Left

Subtitle.Parent = Header

--========================================================
-- TELE BUTTON
--========================================================

local TeleButton = Instance.new("TextButton")

TeleButton.Name =
	"TeleButton"

TeleButton.Size =
	UDim2.fromOffset(100,34)

TeleButton.Position =
	UDim2.new(1,-145,0,10)

TeleButton.BackgroundColor3 =
	Color3.fromRGB(145,55,55)

TeleButton.BorderSizePixel = 0

TeleButton.AutoButtonColor = false

TeleButton.Text =
	"TELE : OFF"

TeleButton.TextColor3 =
	Color3.new(1,1,1)

TeleButton.TextSize = 10

TeleButton.Font =
	Enum.Font.GothamBold

TeleButton.Parent = Header

local TeleCorner = Instance.new("UICorner")

TeleCorner.CornerRadius =
	UDim.new(0,9)

TeleCorner.Parent = TeleButton

local TeleStroke = Instance.new("UIStroke")

TeleStroke.Color =
	Color3.fromRGB(255,100,100)

TeleStroke.Thickness = 1

TeleStroke.Parent = TeleButton

--========================================================
-- HIDE BUTTON
--========================================================

local HideButton = Instance.new("TextButton")

HideButton.Size =
	UDim2.fromOffset(28,28)

HideButton.Position =
	UDim2.new(1,-38,0,13)

HideButton.BackgroundTransparency = 1

HideButton.Text = "×"

HideButton.TextColor3 =
	Color3.fromRGB(150,155,170)

HideButton.TextSize = 18

HideButton.Font =
	Enum.Font.GothamBold

HideButton.Parent = Header

--========================================================
-- INFO BOX FUNCTION
--========================================================

local function CreateBox(TextValue,X,Y,W)

	local Box = Instance.new("Frame")

	Box.Size =
		UDim2.fromOffset(W,42)

	Box.Position =
		UDim2.fromOffset(X,Y)

	Box.BackgroundColor3 =
		Color3.fromRGB(25,27,35)

	Box.BorderSizePixel = 0
	Box.Parent = Main

	local Corner = Instance.new("UICorner")

	Corner.CornerRadius =
		UDim.new(0,9)

	Corner.Parent = Box

	local Stroke = Instance.new("UIStroke")

	Stroke.Color =
		Color3.fromRGB(42,45,55)

	Stroke.Thickness = 1

	Stroke.Parent = Box

	local Label = Instance.new("TextLabel")

	Label.Size =
		UDim2.new(1,-12,1,0)

	Label.Position =
		UDim2.fromOffset(6,0)

	Label.BackgroundTransparency = 1

	Label.Text =
		TextValue

	Label.TextColor3 =
		Color3.fromRGB(190,195,205)

	Label.TextSize = 10

	Label.Font =
		Enum.Font.GothamMedium

	Label.TextXAlignment =
		Enum.TextXAlignment.Left

	Label.Parent = Box

	return Label

end

--========================================================
-- INFO
--========================================================

local TargetLabel =
	CreateBox(
		"TARGET : NONE",
		15,70,225
	)

local DistanceLabel =
	CreateBox(
		"DISTANCE : --",
		255,70,225
	)

local TeleRangeLabel =
	CreateBox(
		"TELE RANGE : 300",
		15,120,225
	)

local AttackRangeLabel =
	CreateBox(
		"ATTACK RANGE : 70",
		255,120,225
	)

local StatusLabel =
	CreateBox(
		"STATUS : WAITING",
		15,170,465
	)

--========================================================
-- DEBUG
--========================================================

local Debug = Instance.new("TextLabel")

Debug.Size =
	UDim2.fromOffset(465,25)

Debug.Position =
	UDim2.fromOffset(15,225)

Debug.BackgroundTransparency = 1

Debug.Text =
	"DEBUG : READY"

Debug.TextColor3 =
	Color3.fromRGB(110,115,130)

Debug.TextSize = 9

Debug.Font =
	Enum.Font.Code

Debug.TextXAlignment =
	Enum.TextXAlignment.Left

Debug.Parent = Main

--========================================================
-- FLOATING AF LOGO
--========================================================

local AFLogo = Instance.new("TextButton")

AFLogo.Name =
	"AFLogo"

AFLogo.Size =
	UDim2.fromOffset(48,48)

AFLogo.Position =
	UDim2.new(1,-65,0.5,-24)

AFLogo.BackgroundColor3 =
	Color3.fromRGB(24,26,34)

AFLogo.BorderSizePixel = 0

AFLogo.Text =
	"AF"

AFLogo.TextColor3 =
	Color3.fromRGB(255,255,255)

AFLogo.TextSize = 12

AFLogo.Font =
	Enum.Font.GothamBold

AFLogo.AutoButtonColor = false

AFLogo.Visible = false

AFLogo.Parent = Gui

local LogoCorner = Instance.new("UICorner")

LogoCorner.CornerRadius =
	UDim.new(1,0)

LogoCorner.Parent = AFLogo

local LogoStroke = Instance.new("UIStroke")

LogoStroke.Color =
	Color3.fromRGB(85,90,110)

LogoStroke.Thickness = 2

LogoStroke.Parent = AFLogo

--========================================================
-- MENU SHOW / HIDE
--========================================================

HideButton.MouseButton1Click:Connect(function()

	MENU_VISIBLE = false

	Main.Visible = false

	-- AF LUÔN HIỆN
	AFLogo.Visible = true

end)

AFLogo.MouseButton1Click:Connect(function()

	MENU_VISIBLE = true

	Main.Visible = true

	-- Ẩn AF khi menu đang mở
	AFLogo.Visible = false

end)

--========================================================
-- TELE BUTTON
--========================================================

local function UpdateTeleButton()

	if TELE_ENABLED then

		TeleButton.Text =
			"TELE : ON"

		TeleButton.BackgroundColor3 =
			Color3.fromRGB(40,155,85)

		TeleStroke.Color =
			Color3.fromRGB(100,255,145)

	else

		TeleButton.Text =
			"TELE : OFF"

		TeleButton.BackgroundColor3 =
			Color3.fromRGB(145,55,55)

		TeleStroke.Color =
			Color3.fromRGB(255,100,100)

	end

end

TeleButton.MouseButton1Click:Connect(function()

	TELE_ENABLED =
		not TELE_ENABLED

	UpdateTeleButton()

	if TELE_ENABLED then

		StatusLabel.Text =
			"STATUS : SCANNING"

		Debug.Text =
			"DEBUG : TELE ENABLED"

	else

		CurrentTarget = nil

		if Root then
			Root.Anchored = false
		end

		StatusLabel.Text =
			"STATUS : TELE OFF"

		Debug.Text =
			"DEBUG : TELE DISABLED"

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
	"dealer",
	"trainer"

}

local function IsBadName(Name)

	Name =
		string.lower(Name)

	for _,Word in ipairs(BAD_NAMES) do

		if string.find(
			Name,
			Word,
			1,
			true
		) then

			return true

		end

	end

	return false

end

--========================================================
-- MOB CHECK
--========================================================

local function IsMob(Model)

	if not Model:IsA("Model") then
		return false
	end

	if Model == Character then
		return false
	end

	if IsBadName(Model.Name) then
		return false
	end

	local EnemyHumanoid =
		Model:FindFirstChildOfClass("Humanoid")

	local EnemyRoot =
		Model:FindFirstChild("HumanoidRootPart")

	if not EnemyHumanoid
		or not EnemyRoot then

		return false

	end

	if EnemyHumanoid.Health <= 0 then
		return false
	end

	-- NPC có Dialog
	if Model:FindFirstChildOfClass("Dialog") then
		return false
	end

	-- NPC tương tác
	if Model:FindFirstChildWhichIsA(
		"ProximityPrompt",
		true
	) then

		return false

	end

	-- Attribute
	if Model:GetAttribute("Friendly") == true then
		return false
	end

	if Model:GetAttribute("IsNPC") == true then
		return false
	end

	if Model:GetAttribute("CanAttack") == false then
		return false
	end

	return true

end

--========================================================
-- FIND NEAREST MOB
--========================================================

local function FindNearestMob()

	if not Root then
		return nil,nil
	end

	local Nearest = nil
	local NearestDistance =
		TELEPORT_RANGE

	-- Ưu tiên folder quái
	local Containers = {}

	local Mobs =
		workspace:FindFirstChild("Mobs")

	local Enemies =
		workspace:FindFirstChild("Enemies")

	local Monsters =
		workspace:FindFirstChild("Monsters")

	if Mobs then
		table.insert(
			Containers,
			Mobs
		)
	end

	if Enemies then
		table.insert(
			Containers,
			Enemies
		)
	end

	if Monsters then
		table.insert(
			Containers,
			Monsters
		)
	end

	-- Không có folder -> Workspace
	if #Containers == 0 then

		table.insert(
			Containers,
			workspace
		)

	end

	for _,Container in ipairs(Containers) do

		for _,Object in ipairs(
			Container:GetChildren()
		) do

			if IsMob(Object) then

				local EnemyRoot =
					Object:FindFirstChild(
						"HumanoidRootPart"
					)

				if EnemyRoot then

					local Distance =
						(
							Root.Position
							- EnemyRoot.Position
						).Magnitude

					if Distance
						<= TELEPORT_RANGE
						and Distance
						< NearestDistance then

						Nearest =
							Object

						NearestDistance =
							Distance

					end

				end

			end

		end

	end

	return Nearest,NearestDistance

end

--========================================================
-- TELEPORT POSITION
--========================================================

local function MoveAboveMob(Mob)

	if not Root or not Mob then
		return false
	end

	local EnemyRoot =
		Mob:FindFirstChild(
			"HumanoidRootPart"
		)

	if not EnemyRoot then
		return false
	end

	Root.Anchored = true

	Root.CFrame =
		CFrame.new(
			EnemyRoot.Position
			+ Vector3.new(
				0,
				SAFE_HEIGHT,
				0
			)
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

		DragStart =
			Input.Position

		StartPosition =
			Main.Position

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
			Input.Position
			- DragStart

		Main.Position =
			UDim2.new(
				StartPosition.X.Scale,
				StartPosition.X.Offset
					+ Delta.X,

				StartPosition.Y.Scale,
				StartPosition.Y.Offset
					+ Delta.Y
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
-- AUTO TELE LOOP
--========================================================

RunService.Heartbeat:Connect(function(DeltaTime)

	if not Root or not Humanoid then
		return
	end

	if Humanoid.Health <= 0 then

		CurrentTarget = nil
		Root.Anchored = false

		return

	end

	if not TELE_ENABLED then
		return
	end

	ScanTimer += DeltaTime

	if ScanTimer < SCAN_INTERVAL then
		return
	end

	ScanTimer = 0

	--====================================================
	-- QUÉT LIÊN TỤC
	--====================================================

	local NewTarget,NewDistance =
		FindNearestMob()

	-- Có quái mới gần hơn -> đổi target
	if NewTarget then

		if not CurrentTarget then

			CurrentTarget =
				NewTarget

		else

			local OldRoot =
				CurrentTarget:FindFirstChild(
					"HumanoidRootPart"
				)

			local OldDistance =
				math.huge

			if OldRoot then

				OldDistance =
					(
						Root.Position
						- OldRoot.Position
					).Magnitude

			end

			-- đổi sang con gần hơn
			if NewDistance < OldDistance then

				CurrentTarget =
					NewTarget

			end

		end

	end

	--====================================================
	-- TARGET KHÔNG CÒN
	--====================================================

	if not CurrentTarget
		or not IsMob(CurrentTarget) then

		CurrentTarget =
			NewTarget

	end

	--====================================================
	-- KHÔNG CÓ QUÁI
	--====================================================

	if not CurrentTarget then

		TargetLabel.Text =
			"TARGET : NONE"

		DistanceLabel.Text =
			"DISTANCE : --"

		StatusLabel.Text =
			"STATUS : WAITING"

		Debug.Text =
			"DEBUG : SCANNING 300 STUDS"

		-- đứng im chờ spawn
		Root.Anchored = true

		return

	end

	--====================================================
	-- TARGET ROOT
	--====================================================

	local EnemyRoot =
		CurrentTarget:FindFirstChild(
			"HumanoidRootPart"
		)

	if not EnemyRoot then

		CurrentTarget = nil
		return

	end

	local Distance =
		(
			Root.Position
			- EnemyRoot.Position
		).Magnitude

	TargetLabel.Text =
		"TARGET : "
		..CurrentTarget.Name

	DistanceLabel.Text =
		string.format(
			"DISTANCE : %.1f",
			Distance
		)

	--====================================================
	-- TELE / ATTACK RANGE
	--====================================================

	if Distance > ATTACK_RANGE then

		MoveAboveMob(CurrentTarget)

		StatusLabel.Text =
			"STATUS : TELE TO TARGET"

		Debug.Text =
			"DEBUG : TARGET FOUND | TELE RANGE 300"

	else

		-- Trong attack range
		Root.Anchored = true

		Root.CFrame =
			CFrame.new(
				EnemyRoot.Position
				+ Vector3.new(
					0,
					SAFE_HEIGHT,
					0
				)
			)

		StatusLabel.Text =
			"STATUS : ATTACK RANGE"

		Debug.Text =
			"DEBUG : TARGET IN ATTACK RANGE"

	end

end)

--========================================================
-- INITIAL
--========================================================

UpdateTeleButton()

TeleRangeLabel.Text =
	"TELE RANGE : "
	..TELEPORT_RANGE

AttackRangeLabel.Text =
	"ATTACK RANGE : "
	..ATTACK_RANGE