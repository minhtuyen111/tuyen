--========================================================
-- AUTO FARM + BIG HITBOX + AUTO DAMAGE
-- 1 SCRIPT
-- Đặt tại ServerScriptService
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--========================================================
-- SETTINGS
--========================================================

local TELEPORT_RANGE = 300
local ATTACK_RANGE = 50
local SAFE_HEIGHT = 8

local DAMAGE = 20
local ATTACK_COOLDOWN = 0.12

local ENABLED = true

--========================================================
-- NPC FILTER
--========================================================

local BAD_NAMES = {
	shop = true,
	shopkeeper = true,
	merchant = true,
	vendor = true,
	seller = true,
	trader = true,
	store = true,
	npc = true,
	quest = true,
}

local function BadName(name)
	name = string.lower(name)

	for bad in pairs(BAD_NAMES) do
		if string.find(name, bad, 1, true) then
			return true
		end
	end

	return false
end

local function IsMob(model, character)

	if not model:IsA("Model") then
		return false
	end

	if model == character then
		return false
	end

	if BadName(model.Name) then
		return false
	end

	local humanoid =
		model:FindFirstChildOfClass("Humanoid")

	local root =
		model:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root then
		return false
	end

	if humanoid.Health <= 0 then
		return false
	end

	-- Loại NPC tương tác
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
-- GET NEAREST MOB
--========================================================

local function GetNearestMob(player)

	local character = player.Character

	if not character then
		return nil
	end

	local root =
		character:FindFirstChild("HumanoidRootPart")

	if not root then
		return nil
	end

	local nearest
	local nearestDistance = TELEPORT_RANGE

	for _, obj in ipairs(workspace:GetDescendants()) do

		if IsMob(obj, character) then

			local mobRoot =
				obj:FindFirstChild("HumanoidRootPart")

			local distance =
				(root.Position - mobRoot.Position).Magnitude

			if distance <= nearestDistance then
				nearest = obj
				nearestDistance = distance
			end
		end
	end

	return nearest
end

--========================================================
-- GET MOBS IN HITBOX
--========================================================

local function GetMobsInRange(player, center)

	local character = player.Character

	if not character then
		return {}
	end

	local results = {}

	for _, obj in ipairs(workspace:GetDescendants()) do

		if IsMob(obj, character) then

			local mobRoot =
				obj:FindFirstChild("HumanoidRootPart")

			if mobRoot then

				local distance =
					(center - mobRoot.Position).Magnitude

				if distance <= ATTACK_RANGE then
					table.insert(results, obj)
				end
			end
		end
	end

	return results
end

--========================================================
-- DAMAGE
--========================================================

local LastAttack = {}

local function DamageMobs(player, target)

	local now = os.clock()

	if LastAttack[player] then
		if now - LastAttack[player] < ATTACK_COOLDOWN then
			return
		end
	end

	LastAttack[player] = now

	if not target then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local root =
		character:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end

	-- Đánh toàn bộ quái trong hitbox
	local mobs = GetMobsInRange(
		player,
		root.Position
	)

	for _, mob in ipairs(mobs) do

		local humanoid =
			mob:FindFirstChildOfClass("Humanoid")

		if humanoid
			and humanoid.Health > 0 then

			humanoid:TakeDamage(DAMAGE)

		end
	end
end

--========================================================
-- FARM PLAYER
--========================================================

local function FarmPlayer(player)

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

	if humanoid.Health <= 0 then
		return
	end

	local target =
		GetNearestMob(player)

	if not target then
		root.Anchored = false
		return
	end

	local mobRoot =
		target:FindFirstChild("HumanoidRootPart")

	if not mobRoot then
		return
	end

	--====================================================
	-- TELEPORT + SAFE POSITION
	--====================================================

	root.Anchored = true

	root.CFrame =
		CFrame.new(
			mobRoot.Position
			+ Vector3.new(0, SAFE_HEIGHT, 0)
		)

	--====================================================
	-- AUTO DAMAGE
	--====================================================

	DamageMobs(player, target)
end

--========================================================
-- MAIN
--========================================================

RunService.Heartbeat:Connect(function()

	if not ENABLED then
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do

		task.spawn(function()
			FarmPlayer(player)
		end)

	end
end)

--========================================================
-- CLEANUP
--========================================================

Players.PlayerRemoving:Connect(function(player)

	LastAttack[player] = nil

end)