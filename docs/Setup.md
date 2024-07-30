# Set Up / Basics
First you've gotta actually parse the nodegraph you want to use.
When a nodegraph is parsed, it gives the Navigator information about the graph's nodes, connections (and their types) so that
the algorithm has something to navigate with.

:::tip
People who come from using Roblox's pathfinding system tend to think that node-pathfinding will just go through walls or anything stupid of that nature.

This is <b>incorrect</b>. Node-pathfinding, as the name implies, pathfinds based on a set of nodes, which means you <b>place</b> those nodes where <b>YOU</b> want your AI to go.

Think of each node as a walk-to point.
Edges define which nodes can go to other nodes.
:::

```lua
local NodeNavigator = require(path.to.NodeNavigator)

local Navigator = NodeNavigator.Get() or NodeNavigator.Create(game.ServerStorage.NodeGraph) -- Assuming a navigator was already made, or a nodegraph exists somewhere
```

Great, now you can start using the navigator
To compute a path between two points, use the `Navigator:TryComputePath(startPosition, targetPosition)` method, which returns
a Promise. You can then get the computed path via chaining `:andThen(function(path))`, or following the call with `:expect()`

Example of both cases:

`andThen`:
```lua
Navigator:TryComputePath(pointA, pointB):andThen(function(path)
	-- We have the path
end):catch(function(err)
	-- Safely exit due to an error, print it out if you want to see what went wrong.
end)
```

`expect`
```lua
local path = Navigator:TryComputePath(pointA, pointB):expect()
```

:::caution
Should an exception occur with the `:expect()` method, it will invoke an error.
Alternatively, you can use the `:await()` method and check if the operation was successful
or not.

```lua
local success, path = Navigator:TryComputePath(pointA, pointB):await()
if success then
	-- Got path
else
	-- Something went wrong
end
:::


To get the waypoints of a path, simply call `path:GetWaypoints()`. This returns an ordered array of `PathWaypoint` objects,
that you can use to make a humanoid follow along.
In addition, you can also visualize the computed path by running `path:Visualize()`.



# Usage Guide

With all of this in mind, here is how you can set up a simple pathfinding loop with a humanoid agent.

```lua
local Character = script.Parent
local RootPart = Character.HumanoidRootPart
local Humanoid = Character.Humanoid

local pathId = 0

local function RunPath(targetPosition: Vector3): ()
	-- Compute the path
	Navigator:TryComputePath(RootPart.Position, targetPosition)
		:andThen(function(path)
			-- Because we're recomputing every second, we need some sort of way
			-- to cancel the current path.
			pathId += 1
			local myPath = pathId

			-- Make humanoid traverse along path
			for _,waypoint in path:GetWaypoints() do
				if pathId ~= myPath then continue end -- This path got cancelled
				if waypoint.Action == Enum.PathWaypointAction.Jump then
					-- Hit a jump connector, force the Humanoid to jump
					Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end

				Humanoid:MoveTo(waypoint.Position)
				Humanoid.MoveToFinished:Wait()

				-- We reached the waypoint, move on
			end
		end)
		:catch(function(err)
			-- Computation must've failed, lets see where we went wrong
			warn(err)
		end)

	-- NOTE: You can also use different algorithms for pathfinding:
	-- Navigator:TryComputePath(RootPart.Position, targetPosition, 10, "Dijkstra")
	-- Navigator:TryComputePath(RootPart.Position, targetPosition, 10, "BFS")
	-- The "10" param specifies the maximum start/target node query distance, smaller numbers are usually more optimal.
end

while true do
	RunPath(workspace.TargetBlock.Position) -- Assuming you have a part called `TargetBlock` in the `Workspace`
	task.wait(1)
end
```

To learn more about the API, visit the [API Reference](https://notfenv.github.io/NodeNavAPI/api/NodeNavigator)
