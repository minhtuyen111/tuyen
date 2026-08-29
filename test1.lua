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
	task.wait(.3)
	SetupCharacter(char)
end)

--========================================================
-- GUI
--========================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "FarmControl"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(640, 360)
Main.Position = UDim2.new(.5, -320, .5, -180)
Main.BackgroundColor3 = Color3.fromRGB(15,16,22)
Main.BorderSizePixel = 0
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius =
	UDim.new(0,16)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(55,58,72)
Stroke.Thickness = 1

--========================================================
-- TOP BAR
--========================================================

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1,0,0,65)
Top.BackgroundTransparency = 1
Top.Parent = Main

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.fromOffset(42,42)
Avatar.Position = UDim2.fromOffset(15,12)
Avatar.BackgroundTransparency = 1
Avatar.Parent = Top

Instance.new("UICorner", Avatar).CornerRadius =
	UDim.new(1,0)

task.spawn(function()

	local image =
		Players:GetUserThumbnailAsync(
			Player.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size100x100
		)

	Avatar.Image = image

end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromOffset(300,30)
Title.Position = UDim2.fromOffset(70,10)
Title.BackgroundTransparency = 1
Title.Text = "AUTO FARM"
Title.TextColor3 = Color3.fromRGB(245,245,250)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local User = Instance.new("TextLabel")
User.Size = UDim2.fromOffset(300,20)
User.Position = UDim2.fromOffset(70,35)
User.BackgroundTransparency = 1
User.Text = "@" .. Player.Name
User.TextColor3 = Color3.fromRGB(130,135,150)
User.TextSize = 11
User.Font = Enum.Font.Gotham
User.TextXAlignment = Enum.TextXAlignment.Left
User.Parent = Top

--========================================================
-- TOGGLE
--========================================================

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.fromOffset(120,38)
Toggle.Position = UDim2.new(1,-140,0,14)
Toggle.BackgroundColor3 = Color3.fromRGB(145,55,55)
Toggle.BorderSizePixel = 0
Toggle.Text = "OFF"
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.TextSize = 13
Toggle.Font = Enum.Font.GothamBold
Toggle.Parent = Top

Instance.new("UICorner", Toggle).CornerRadius =
	UDim.new(0,10)

--========================================================
-- STATUS BOX
--========================================================

local function Box(x,y,w,h)

	local f = Instance.new("Frame")
	f.Size = UDim2.fromOffset(w,h)
	f.Position = UDim2.fromOffset(x,y)
	f.BackgroundColor3 = Color3.fromRGB(25,27,35)
	f.BorderSizePixel = 0
	f.Parent = Main

	Instance.new("UICorner",f).CornerRadius =
		UDim.new(0,11)

	return f
end

local function Label(parent,text,y,color)

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1,-20,0,25)
	l.Position = UDim2.fromOffset(10,y)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = color or Color3.fromRGB(190,195,205)
	l.TextSize = 12
	l.Font = Enum.Font.Gotham
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent

	return l
end

local TargetBox = Box(20,80,290,125)
local SettingBox = Box(330,80,290,125)
local DebugBox = Box(20,215,600,120)

local TargetLabel =
	Label(TargetBox,"TARGET : NONE",10)

local DistanceLabel =
	Label(TargetBox,"DISTANCE : --",42)

local MobLabel =
	Label(TargetBox,"MOBS : 0",74)

local HitboxLabel =
	Label(TargetBox,"HITBOX : 55",106)

local TeleportLabel =
	Label(SettingBox,"TELEPORT : IDLE",10)

local HeightLabel =
	Label(SettingBox,"SAFE HEIGHT : 7",42)

local RangeLabel =
	Label(SettingBox,"TELEPORT RANGE : 300",74)

local StateLabel =
	Label(SettingBox,"STATUS : WAITING",106)

local DebugLabel =
	Label(
		DebugBox,
		"DEBUG\nWaiting...",
		10,
		Color3.fromRGB(150,155,170)
	)

DebugLabel.TextWrapped = true
DebugLabel.TextYAlignment = Enum.TextYAlignment.Top

--========================================================
-- MOB FILTER
--========================================================

local BAD = {
	shop=true,
	merchant=true,
	vendor=true,
	seller=true,
	trader=true,
	store=true,
	quest=true,
	npc=true
}

local function IsBadName(name)

	name = string.lower(name)

	for word in pairs(BAD) do
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

	-- Không nhận NPC tương tác
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

	return true
end

--========================================================
-- FIND MOB
--========================================================

local function FindMob()

	if not Root then
		return nil,0,0
	end

	local nearest
	local shortest = TELEPORT_RANGE
	local count = 0

	for _,obj in ipairs(workspace:GetDescendants()) do

		if IsMob(obj) then

			count += 1

			local r =
				obj:FindFirstChild("HumanoidRootPart")

			local d =
				(Root.Position-r.Position).Magnitude

			if d <= shortest then

				shortest = d
				nearest = obj

			end
		end
	end

	return nearest,shortest,count
end

--========================================================
-- HITBOX VISUAL
--========================================================

local HitboxPart = Instance.new("Part")
HitboxPart.Name = "FarmHitbox"
HitboxPart.Shape = Enum.PartType.Ball
HitboxPart.Size =
	Vector3.new(
		HITBOX_RANGE*2,
		HITBOX_RANGE*2,
		HITBOX_RANGE*2
	)

HitboxPart.Transparency = 1
HitboxPart.CanCollide = false
HitboxPart.CanTouch = false
HitboxPart.CanQuery = false
HitboxPart.Anchored = true
HitboxPart.Parent = workspace

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
			+ Vector3.new(0,SAFE_HEIGHT,0)
		)

	return true
end

--========================================================
-- TOGGLE
--========================================================

Toggle.MouseButton1Click:Connect(function()

	ENABLED = not ENABLED

	if ENABLED then

		Toggle.Text = "ON"
		Toggle.BackgroundColor3 =
			Color3.fromRGB(40,155,85)

		StateLabel.Text =
			"STATUS : RUNNING"

	else

		Toggle.Text = "OFF"
		Toggle.BackgroundColor3 =
			Color3.fromRGB(145,55,55)

		StateLabel.Text =
			"STATUS : STOPPED"

		if Root then
			Root.Anchored = false
		end

		Target = nil

	end
end)

--========================================================
-- HOVER EFFECT
--========================================================

Toggle.MouseEnter:Connect(function()

	TweenService:Create(
		Toggle,
		TweenInfo.new(.15),
		{Size=UDim2.fromOffset(125,40)}
	):Play()

end)

Toggle.MouseLeave:Connect(function()

	TweenService:Create(
		Toggle,
		TweenInfo.new(.15),
		{Size=UDim2.fromOffset(120,38)}
	):Play()

end)

--========================================================
-- MAIN LOOP
--========================================================

local timer = 0

RunService.Heartbeat:Connect(function(dt)

	if not Root then
		return
	end

	-- Hitbox luôn đi theo player
	if HITBOX_ENABLED then

		HitboxPart.Position = Root.Position
		HitboxPart.Size =
			Vector3.new(
				HITBOX_RANGE*2,
				HITBOX_RANGE*2,
				HITBOX_RANGE*2
			)

	end

	if not ENABLED then
		return
	end

	timer += dt

	if timer < .12 then
		return
	end

	timer = 0

	-- Target cũ còn sống thì giữ
	if Target and not IsMob(Target) then
		Target = nil
	end

	-- Tìm target mới
	if not Target then

		local mob,distance,count =
			FindMob()

		Target = mob

		MobLabel.Text =
			"MOBS : " .. tostring(count)

	end

	-- Không có quái
	if not Target then

		TargetLabel.Text =
			"TARGET : NONE"

		DistanceLabel.Text =
			"DISTANCE : --"

		TeleportLabel.Text =
			"TELEPORT : WAITING"

		TeleportLabel.TextColor3 =
			Color3.fromRGB(255,205,80)

		DebugLabel.Text =
			"DEBUG\n"
			.. "No attackable mob within "
			.. TELEPORT_RANGE
			.. " studs.\n"
			.. "Standing by..."

		Root.Anchored = false

		return
	end

	-- Target
	local mobRoot =
		Target:FindFirstChild("HumanoidRootPart")

	if not mobRoot then
		Target = nil
		return
	end

	local distance =
		(Root.Position-mobRoot.Position).Magnitude

	TargetLabel.Text =
		"TARGET : " .. Target.Name

	TargetLabel.TextColor3 =
		Color3.fromRGB(90,190,255)

	DistanceLabel.Text =
		string.format(
			"DISTANCE : %.1f",
			distance
		)

	-- Teleport nếu ngoài vùng an toàn
	if distance > HITBOX_RANGE then

		local success =
			TeleportToMob(Target)

		if success then

			TeleportLabel.Text =
				"TELEPORT : OK"

			TeleportLabel.TextColor3 =
				Color3.fromRGB(90,240,125)

			DebugLabel.Text =
				"DEBUG\n"
				.. "Target locked : "
				.. Target.Name
				.. "\nMoved above target."

		end

	else

		TeleportLabel.Text =
			"TELEPORT : HOLD"

		TeleportLabel.TextColor3 =
			Color3.fromRGB(90,240,125)

	end

	-- Hitbox status
	HitboxLabel.Text =
		"HITBOX : "
		.. tostring(HITBOX_RANGE)

	-- Luôn giữ khoảng cách an toàn
	if distance <= HITBOX_RANGE then

		local desired =
			mobRoot.Position
			+ Vector3.new(0,SAFE_HEIGHT,0)

		Root.Anchored = true
		Root.CFrame =
			CFrame.new(desired)

		StateLabel.Text =
			"STATUS : TARGET LOCKED"

	else

		StateLabel.Text =
			"STATUS : MOVING"

	end

end)