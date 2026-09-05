local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = Instance.new("RemoteEvent")
remote.Name = "FastRunRemote"
remote.Parent = ReplicatedStorage

local speeds = {}

Players.PlayerAdded:Connect(function(player)
	speeds[player] = 16

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.WalkSpeed = speeds[player]
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	speeds[player] = nil
end)

remote.OnServerEvent:Connect(function(player, value)
	value = tonumber(value)
	if not value then return end

	value = math.clamp(math.floor(value), 16, 9999)
	speeds[player] = value

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.WalkSpeed = value
	end
end)