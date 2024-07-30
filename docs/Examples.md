---
sidebar_position: 100
---

# Examples
Here are some open-source examples of node navigation being used.

# Mannequin AI
Movement for a mannequin AI by [@notawildfox](https://www.roblox.com/users/124963457/profile) similar to the one in the new game [DESCENT](https://www.roblox.com/games/15428225119/DESCENT) that moves
only when out of line of sight, and has deceleration/acceleration.

This example uses <b>Dijkstra's</b> algorithm, because Dijkstra's paths are less "zigzaggy" unlike how A* cost evaluation works 


```lua
--[=[
    Makes the entity traverse along a path.
    @param path NavigatorPath -- The path to traverse along.
]=]
type Path = NodeNavigator.Path
local pathId = 0
local function TraversePath(path: Path): ()
	-- Get id for interruption when necessary
	pathId = (pathId + 1) % 1000
	local myPath = pathId

    -- Traverse path
    local waypoints = path:GetWaypoints()
    table.remove(waypoints, 1) -- first waypoint is root position, removing it as it bricks the mannequin movement a tiny bit

	for i, waypoint in waypoints do
		if pathId ~= myPath then break end
		if inView then
			-- We're being observed, freeze.
			moving = false
			break
		end

		-- Start navigating
		local targetPosition = waypoint.Position
		Humanoid:MoveTo(targetPosition)

		-- Yield until reached
		repeat
			task.wait()
		until (RootPart.Position - targetPosition).Magnitude <= 2 or pathId ~= myPath or inView or not moving
	end
end


--[=[
    Makes the entity follow its target.
]=]
local function MoveToTarget(): ()
	if not target or inView then return end

	moving = true

    -- Start accelerating
	Accelerate()

	-- Start pathfinding
	while moving and not inView and target do
		local otherRootPart = target:FindFirstChild("HumanoidRootPart") :: BasePart
		if not otherRootPart then
			target = nil
			moving = false
			break
		end

        -- Compute path from our position to target's current position
		local success, path =
			Navigator
				:TryComputePath(RootPart.Position, otherRootPart.Position, nil, "Dijkstra")
				:await()
		if not success then
			break
		end

		-- Traverse path
		task.spawn(TraversePath, path)

        -- Yield until complete or cancelled
		local nextRecompute = time() + PATH_RECOMPUTE_INTERVAL
		repeat
			task.wait()
		until time() > nextRecompute or not moving or inView
	end

	-- Grind to halt
    Decelerate()
	moving = false
end
```