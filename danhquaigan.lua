--// Auto Mob Gather + Fly + Attack
--// LocalScript -> StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

--========================
-- SETTINGS
--========================
local MOB_RADIUS = 80       -- Bán kính tìm quái
local GATHER_RADIUS = 25    -- Khoảng cách để gom quái
local HEIGHT_ABOVE_MOB = 8  -- Bay trên đầu quái
local ATTACK_DELAY = 0.12   -- Tốc độ đánh
local UPDATE_DELAY = 0.05

-- Tên model/quái có thể sửa tại đây.
-- Để nil để tự nhận diện các model có Humanoid.
local MOB_FOLDER = workspace:FindFirstChild("Mobs")

--========================
-- CHARACTER
--========================
local character
local humanoid
local root

local function setupCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")
end

if player.Character then
	setupCharacter(player.Character)
end

player.CharacterAdded:Connect(setupCharacter)

--========================
-- CHECK MOB
--========================
local function isAliveMob(model)
	if not model or not model:IsA("Model") then
		return false
	end

	if model == character then
		return false
	end

	local hum = model:FindFirstChildOfClass("Humanoid")
	local hrp = model:FindFirstChild("HumanoidRootPart")

	if not hum or not hrp then
		return false
	end

	if hum.Health <= 0 then
		return false
	end

	return true
end

local function getMobs()
	local mobs = {}

	local source = MOB_FOLDER or workspace

	for _, obj in ipairs(source:GetDescendants()) do
		if isAliveMob(obj) then
			table.insert(mobs, obj)
		end
	end

	return mobs
end

--========================
-- FIND NEAREST MOB
--========================
local function getNearestMob()
	if not root then
		return nil
	end

	local nearest = nil
	local nearestDistance = MOB_RADIUS

	for _, mob in ipairs(getMobs()) do
		local mobRoot = mob:FindFirstChild("HumanoidRootPart")

		if mobRoot then
			local distance = (root.Position - mobRoot.Position).Magnitude

			if distance < nearestDistance then
				nearestDistance = distance
				nearest = mob
			end
		end
	end

	return nearest
end

--========================
-- GATHER MOBS
--========================
local function gatherMobs(target)
	if not target or not root then
		return
	end

	local targetRoot = target:FindFirstChild("HumanoidRootPart")
	if not targetRoot then
		return
	end

	for _, mob in ipairs(getMobs()) do
		local mobRoot = mob:FindFirstChild("HumanoidRootPart")

		if mobRoot and mob ~= target then
			local distance = (mobRoot.Position - targetRoot.Position).Magnitude

			if distance <= GATHER_RADIUS then
				-- Gom quái về target
				mobRoot.CFrame =
					targetRoot.CFrame
					* CFrame.new(
						math.random(-3, 3),
						0,
						math.random(-3, 3)
					)
			end
		end
	end
end

--========================
-- MOVE ABOVE MOBS
--========================
local function moveAboveMob(target)
	if not target or not root then
		return
	end

	local targetRoot = target:FindFirstChild("HumanoidRootPart")
	if not targetRoot then
		return
	end

	local position =
		targetRoot.Position
		+ Vector3.new(0, HEIGHT_ABOVE_MOB, 0)

	-- Giữ nhân vật trên đầu quái
	root.CFrame = CFrame.new(
		position,
		targetRoot.Position
	)
end

--========================
-- ATTACK
--========================
local lastAttack = 0

local function attack()
	if not character then
		return
	end

	local now = tick()

	if now - lastAttack < ATTACK_DELAY then
		return
	end

	lastAttack = now

	-- Tìm Tool đang được trang bị
	local equippedTool = character:FindFirstChildOfClass("Tool")

	if equippedTool then
		-- Cách 1: Activate Tool
		pcall(function()
			equippedTool:Activate()
		end)

		-- Cách 2: Nếu Tool có RemoteEvent
		for _, obj in ipairs(equippedTool:GetDescendants()) do
			if obj:IsA("RemoteEvent") then
				pcall(function()
					obj:FireServer()
				end)
			end
		end
	end
end

--========================
-- AUTO LOOP
--========================
task.spawn(function()
	while true do
		task.wait(UPDATE_DELAY)

		if not character
			or not humanoid
			or humanoid.Health <= 0
			or not root then
			continue
		end

		local target = getNearestMob()

		if target then
			-- Gom quái
			gatherMobs(target)

			-- Bay lên trên đầu
			moveAboveMob(target)

			-- Đánh liên tục
			attack()
		end
	end
end)

--========================
-- GIỮ TOOL LUÔN ĐƯỢC ĐÁNH
--========================
character.ChildAdded:Connect(function(child)
	if child:IsA("Tool") then
		task.wait(0.1)

		pcall(function()
			child:Activate()
		end)
	end
end)