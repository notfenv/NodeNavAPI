--!strict
-- Node Navigator
-- Mia Vince
-- April 13, 2024

--[[

	Allows for the parsing and traversing of node graphs.
	Originally made by Gnat (@treebee63), revisions by Mia (@notawildfox)

	I heartily suggest using this in conjunction with Roblox pathfinding, as
	node graphs only really shine in indoors/close-quarters areas.

	Mia's Contributions:
		- Complete revamp of the navigator, with additional features (such as the user being able to toggle edges in real-time for obstacles)
		- Removal of Dijkstra algorithm in favor of A* algorithm
		- Full networker PLUGIN revamp

	Plans:
		- Full real-time control of the node graph, this includes (but is not limited to):
			- Node Control
				Changing node positions
				Creating/removing nodes
			
			- Edge control
				✅ Edge querying and toggling
				Edge type manipulation (being able to switch edge types, like Jump or OneWay)

		- Dynamic node graph quality
			Simply put, a way to auto adjust the graph's resolution, like subdividing the graph.
			Gnat dubbed this as "fuzzy pathing, that improves the closer you are to the target"
			It should speed up longer distance computation.
			
			Probably going to be chunk clustered and each cluster will be treated as one point

		- ✅ Path caching
			Caching already exists, however, it's been disabled due to real-time controls.

			With this in mind, perhaps an integrity check with cached paths that checks if the nodes and
			connections are valid with the current node graph, otherwise, that cache can be invalidated and
			a new path may be computed.

]]


local Navigator = require(script.Navigator)
export type NodeNavigator = Navigator.NodeNavigator

local types = require(script.Types)
type NodeGraph = types.NodeGraph

-- expose some types
export type Path = typeof(require(script.Navigator.Path).new(...))
export type Edge = types.Edge

local Parsing = require(script.Parsing)

local currentNavigator: NodeNavigator

--[=[
	@class NodeNavigator
	Allows for the parsing and traversing of node graphs.
	Originally made by Gnat ([@treebee63](https://www.roblox.com/users/9735417/profile)), revisions/revamp by Mia ([@notawildfox](https://www.roblox.com/users/124963457/profile))

	Here is how you can create a simple pathfinding loop:
	```lua
	local Navigator = require(path.to.Navigator)

	local Navigator = Navigator.Get() or Navigator.Create(game.ServerStorage.NodeGraph) -- Assuming a navigator was already made, or a nodegraph exists somewhere

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
]=]


--[=[
	@within NodeNavigator
	@return NodeNavigator -- The current navigator.
	Returns the current node navigator, if there is one.
]=]
local function Get(): NodeNavigator
	return currentNavigator
end


--[=[
	@param nodeGraph Folder  -- The node graph to use. If it's a folder, it's considered a workspace node graph.
	@param replaceCurrentNavigator boolean? -- If this navigator will replace the current navigator.

	@return NodeNodeNavigator -- The new navigator.

	@within NodeNavigator

	Constructs a new node navigator.
	
	:::tip
	If a navigator already exists, this will return the existing navigator unless `replaceCurrentNavigator` is `true`,
	in which it will replace the current navigator with the new one.
	:::
]=]
local function Create(
	nodeGraph: Folder,
	replaceCurrentNavigator: boolean?
): NodeNavigator
	if currentNavigator and not replaceCurrentNavigator then
		return currentNavigator
	end

	local navigator = Navigator.new()
	navigator:Parse(Parsing.Parse(nodeGraph, navigator.GraphUpdated))

	currentNavigator = navigator
	return navigator
end


return {
	Get = Get,
	Create = Create,
}
