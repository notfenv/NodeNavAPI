--!strict
-- Node Navigator
-- treebee63 @ 2019, Updated by Mia Vince/notawildfox @ Jan 30, 2024


local CHUNK_SIZE = 40 -- size of each node/connection chunk

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Signal = require(Packages.Signal)
local Promise = require(Packages.Promise)

type Promise<T...> = Promise.Promise<T...>

local root = script.Parent
local Helpers = require(root.Helpers)
local types = require(root.Types)
type NodeGraph = types.NodeGraph
type Edge = types.Edge
type ConnectionType = types.ConnectionType
type ComputedPath = types.ComputedPath
type GraphNode = types.GraphNode
type PathAlgorithm = types.PathAlgorithm

local ComputePath = require(script.ComputePath)
local Path = require(script.Path)
local ChunkService = require(script.ChunkService)

type NavigatorPath = Path.NavigatorPath

local OptimizePath = Helpers.OptimizePath
local FindClosestNode = Helpers.FindClosestNode

local Waypoint = PathWaypoint.new

type Signal<T...> = Signal.Signal<T...>


--[=[
	@class Navigator
	A node navigation class that allows for node pathfinding with various different pathfinding algorithms.
	Used with a graph/navigation network.

	Use `Navigator.OnGraphUpdated` to listen for whenever the graph is manipulated (example: an edge is toggled)
	
	"Nodes" are the points that the AI traverse to.
	"Connectors" are the connections between Nodes, marking which nodes the AI
		can go to, from the current Node.
	
	There are currently three types of Node Connectors:
	"Edge Connector" - A normal, bidirectional movement connector. Visualized as a line

	"Jump Connector" - A connector where if the AI has to traverse 2 nodes connected by a Jump Connector,
		the AI should jump. Visualized as a spring.

	"One-Way Connector" - A connector where the AI can only move to it's target node in the direction of it's visual indicator,
		and not back. Visualized as a Beam with an arrows texture, where the direction of the arrows is the direction of movement.
]=]
local Navigator = {}
Navigator.__index = Navigator


--[=[
	@private
	@return Navigator -- The new navigator.

	Constructs a new navigator for nodegraphs.
	
	If a navigator already exists, this will return
	the current node navigator.
]=]
function Navigator.new()
	local self = {}

	self._network = nil :: NodeGraph?
	self._nodeCount = 0
	self._connections = ChunkService.new(CHUNK_SIZE)
	self._nodes = ChunkService.new(CHUNK_SIZE)

	self.GraphUpdated = Signal.new()

	self._updateId = 0
	self.GraphUpdated:Connect(function()
		self._updateId += 1
	end)

	setmetatable(self, Navigator)

	return self
end


--[=[
	@param nodeGraph NodeGraph -- The new node graph.
	Changes the navigator's graph, rebuilding the grid.
]=]
function Navigator.Parse(self: Navigator, nodeGraph: NodeGraph): ()
	self._network = nodeGraph

	-- Clear chunks
	local cons, nodes = self._connections, self._nodes
	table.clear(cons.chunks)
	table.clear(nodes.chunks)
	self._nodeCount = 0

	-- Rebuild chunks
	for _,con in nodeGraph.Connections do
		cons:AddToChunk(con.Center, con)
	end
	for _,node in nodeGraph.Nodes do
		self._nodeCount += 1
		nodes:AddToChunk(node.Position, node)
	end
end


--[=[
	@param startPoint Vector3 -- The pathfinding origin.
	@param targetPoint Vector3 -- The pathfinding destination.
	@param maxNodeDist number? -- The longest sightline to the nearest node the bot will try and find (Leave nil to default to 100)
	@param algorithm "AStar" | "Dijkstra" | "BFS" | "GBFS"? -- Whether to use A* algorithm, Dijkstra's algorithm, Breadth-First Search algorithm, or Greedy Best First Search algorithm for pathfinding. (Leave nil to default to "AStar")

	@return Promise<NavigatorPath> -- The computed path object.

	@error "No network bound. Did you forget to call :Parse()?" -- A node graph wasn't parsed.

	Tries to calculate a path from `startPoint` to `targetPoint`.

	If there is no feasible path from `startPoint` to `targetPoint`, this function
	will return `nil`.

	Example Usage:
	```lua
	navigator:TryComputePath(HumanoidRootPart.Position, target.Position):andThen(function(path)
		-- Show the computed path to the target
		path:Visualize()
	end):catch(warn)
	```
]=]
function Navigator.TryComputePath(
	self: Navigator,
	startPoint: Vector3,
	targetPoint: Vector3,
	maxNodeDist: number?,
	algorithm: PathAlgorithm?
): Promise<NavigatorPath>
	local network = self._network
	assert(network, "No network bound. Did you forget to call :Parse()?")

	-- Check if the node graph exists and positions are provided
	local dist = maxNodeDist or 100

	-- Perform node processing
	local nodes = self._nodes

	return Promise.new(function(resolve, reject)
		local startNode = FindClosestNode(nodes, startPoint, dist)
		local targetNode = FindClosestNode(nodes, targetPoint, dist)
		if not startNode or not targetNode then
			local failReason = if not startNode and not targetNode
				then "Could not find start/target nodes"
				elseif not startNode then "Could not find start node"
				else "Could not find target node"
			reject(failReason)
			return
		end

		-- Calculate path using A*
		local computeFunc = ComputePath[algorithm or "AStar"] :: (...any) -> ComputedPath
		local computedPath = computeFunc(startNode, targetNode, network.Connections, self._updateId)
		if computedPath then
			-- Insert from and target positions as first/final waypoints
			local waypoints = computedPath.Waypoints
			table.insert(waypoints, 1, Waypoint(startPoint, Enum.PathWaypointAction.Walk))
			table.insert(waypoints, Waypoint(targetPoint, Enum.PathWaypointAction.Walk))

			-- Optimize path by removing unnecessary start/end A* waypoints that contradict the start/target positions
			OptimizePath(waypoints)

			resolve(Path.new(waypoints))
		else
			reject("There is no possible path between the two points")
		end
	end)
end


--[=[
	@param position Vector3 -- Where to look for a nearby edge.
	@param maxRadius number? -- The maximum distance to check for nearby edges. Default = 100
	@param filterFn (edge: Edge) -> boolean -- An optional edge-by-edge filtering function, where if the returned condition is false, that closest edge will not be considered.

	@return Edge? -- The nearest edge

	Finds and returns the nearest edge to `position`.

	This is useful if you wish to disable pathfinding through obstructed areas, for example, debris.
	Example Usage:
	```lua
	local edge = Navigator:GetEdgeNear(position, 10)
	edge.SetEnabled(false) -- Don't allow pathfinding at this specific edge
	```

	:::tip
	This only returns the closest edge to `position` within `maxRadius`. If you want a more
	accurate detection, use `Navigator:GetEdgesInBox()` instead.
	:::
]=]
function Navigator.GetEdgeNear(self: Navigator, position: Vector3, maxRadius: number?, filterFn: ((edge: Edge) -> boolean)?): Edge?
	local closest: Edge?, maxDist = nil, maxRadius or 100

	for _,edge: Edge in self._connections:GetObjectsNearby(position, maxDist) do
		local dist = (position - edge.Center).Magnitude
		if dist < maxDist then
			if filterFn and not filterFn(edge) then continue end

			-- this edge is closer than the last one
			closest = edge
			maxDist = dist
		end
	end

	return closest
end


type BoxParam = {
	CFrame: CFrame,
	Size: Vector3,
}

--[=[
	@param box BasePart | BoxParam -- The param for spatial querying
	@param filterFn (edge: Edge) -> boolean -- An optional edge-by-edge filtering function, where if the returned condition is false, that in-box edge will not be appended.

	@return { Edge } -- The edges in the specified box region

	Finds and returns the edges inside of a part or given bounds.

	This is useful if you wish to disable pathfinding through obstructed areas, for example, debris.
	Example Usage:
	```lua
	for _,edge in Navigator:GetEdgesInBox(edgeDisableRegion) do
		edge.SetEnabled(false) -- Don't allow pathfinding through `edgeDisableRegion`
	end
	```
]=]
function Navigator.GetEdgesInBox(self: Navigator, box: BasePart | BoxParam, filterFn: ((edge: Edge) -> boolean)?): { Edge }
	local boxCFrame, boxSize = box.CFrame, box.Size

	local edgesInBox = {} :: { Edge }

	for _,edge: Edge in self._connections:GetObjectsNearby(boxCFrame.Position, boxSize.Magnitude * 1.25) do
		-- Check if edge is in box
		if
			Helpers.InBox(edge.Center, boxCFrame, boxSize)
			or Helpers.InBox(edge.FromNode.Position, boxCFrame, boxSize)
			or Helpers.InBox(edge.TargetNode.Position, boxCFrame, boxSize)
		then
			-- Check if elligible edge
			if filterFn and not filterFn(edge) then
				continue
			end

			-- Append
			table.insert(edgesInBox, edge)
		end
	end

	return edgesInBox
end


--[=[
	@param startNode GraphNode -- The starting node (the order doesn't matter UNLESS it's a one-way edge)
	@param targetNode GraphNode -- The target node (the order doesn't matter UNLESS it's a one-way edge)
	@param connectionType "Edge" | "Jump" | "OneWay" -- The type of the connection.
	@param isEnabled boolean? -- An optional boolean that dictates if the edge is initially enabled or not.

	@return Edge -- The newly created edge (the main one. Toggling this edge will also toggle the entire edge bidirectionally)

	@error "No network bound. Did you forget to call :Parse()?" -- A node graph wasn't parsed.

	Bidirectionally connects two nodes with a specified connection type
	If the connection type is "OneWay," the connection will only be unidirectional.

	:::tip
	A good use case for this would be procedural room generation, where you have multiple room prefabs
	with their own nodegraphs that are individual from the main / primary nodegraph.

	In this case, you'd go through all of the nodes/connections in the rooms' nodegraphs, and rebuild them
	on the main nodegraph.

	Example Usage of what I wrote for [HELLMET by Sensei_Developer](https://www.roblox.com/games/13815196156/HELLMET):
	```lua
	-- Get exit node before anything else; dont want to have the exit node as one of the nodes in the room
	local exitNode = navigator:GetNodesInBox(v.ExitArea)[1]

	-- Instantiate room sub-graph onto main nodegraph. This is basically an alt version of the nodegraph parser
	local roomNodes = {}
	for _,node in prefabRoom.NodeGraph.Nodes:GetChildren() do
		if node:IsA("BasePart") then
			-- Keep track of the old node name for building connections on main graph
			-- This is so that we can refer to the nodes on the main graph with the sub-graph's nodes
			-- Otherwise there'd be ambiguity, duplicate nodes
			roomNodes[node.Name] = navigator:PlaceNode(node.Position)
		end
	end

	-- Re-build edges
	for _,edge in prefabRoom.NodeGraph.Edges:GetChildren() do
		if edge:IsA("Constraint") or edge:IsA("Beam") then
			local delimiter = edge.Name:gmatch("%d+")
			local startId, targetId = delimiter(), delimiter()
			navigator:ConnectNodes(roomNodes[startId], roomNodes[targetId], GetEdgeType(edge))
		end
	end
		
	-- OK, now connect the exiting/entrance nodes
	-- The exit node is the way in and out of the room pretty much
	if exitNode then
		navigator:ConnectNodes(roomNodes[prefabRoom.EnterNode.Value.Name], exitNode)
	else
		warn("Couldnt find exit node")
	end

	-- Now, the AI can pathfind inside and outside of this room.
	```
	:::
]=]
function Navigator.ConnectNodes(
	self: Navigator,
	startNode: GraphNode,
	targetNode: GraphNode,
	connectionType: ConnectionType,
	isEnabled: boolean?
): Edge
	local network = self._network
	assert(network, "No network bound. Did you forget to call :Parse()?")

	local edge = Helpers.ConnectNodes(
		self.GraphUpdated,
		network.Connections,
		startNode,
		targetNode,
		connectionType,
		if isEnabled ~= nil then isEnabled else true
	)
	self._connections:AddToChunk(edge.Center, edge)
	return edge
end


--[=[
	@param position Vector3 -- The position of the node.
	@param index string? -- The index/name of the node. If not supplied, will use the next available node index.

	@return GraphNode -- The newly created node.

	@error "No network bound. Did you forget to call :Parse()?" -- A node graph wasn't parsed.

	Creates a node at a position.

	:::tip
	A good use case for this would be procedural room generation, where you have multiple room prefabs
	with their own nodegraphs that are individual from the main / primary nodegraph.

	In this case, you'd go through all of the nodes/connections in the rooms' nodegraphs, and rebuild them
	on the main nodegraph.

	Example Usage of what I wrote for [HELLMET by Sensei_Developer](https://www.roblox.com/games/13815196156/HELLMET):
	```lua
	-- Get exit node before anything else; dont want to have the exit node as one of the nodes in the room
	local exitNode = navigator:GetNodesInBox(prefabRoom.ExitArea)[1]

	-- Instantiate room sub-graph onto main nodegraph. This is basically an alt version of the nodegraph parser
	local roomNodes = {}
	for _,node in prefabRoom.NodeGraph.Nodes:GetChildren() do
		if node:IsA("BasePart") then
			-- Keep track of the old node name for building connections on main graph
			-- This is so that we can refer to the nodes on the main graph with the sub-graph's nodes
			-- Otherwise there'd be ambiguity, duplicate nodes
			roomNodes[node.Name] = navigator:PlaceNode(node.Position)
		end
	end

	-- Re-build edges
	for _,edge in prefabRoom.NodeGraph.Edges:GetChildren() do
		if edge:IsA("Constraint") or edge:IsA("Beam") then
			local delimiter = edge.Name:gmatch("%d+")
			local startId, targetId = delimiter(), delimiter()
			navigator:ConnectNodes(roomNodes[startId], roomNodes[targetId], GetEdgeType(edge))
		end
	end
		
	-- OK, now connect the exiting/entrance nodes
	-- The exit node is the way in and out of the room pretty much
	if exitNode then
		navigator:ConnectNodes(roomNodes[prefabRoom.EnterNode.Value.Name], exitNode)
	else
		warn("Couldnt find exit node")
	end

	-- Now, the AI can pathfind inside and outside of this room.
	```
	:::
]=]
function Navigator.PlaceNodeAt(self: Navigator, position: Vector3, index: string?): GraphNode
	local network = self._network
	assert(network, "No network bound. Did you forget to call :Parse()?")

	-- Update total nodes
	self._nodeCount += 1

	-- Create node
	local nodeIdx = tostring(index or self._nodeCount)
	local node = Helpers.CreateNode(position, nodeIdx)

	-- Append the node to the graph
	network.Nodes[nodeIdx] = node
	self._nodes:AddToChunk(position, node)

	return node
end


--[=[
	@param index string -- The index of the node to find
	@return GraphNode? -- The node with the matching index
	
	@error "No network bound. Did you forget to call :Parse()?" -- A node graph wasn't parsed.
	@error "Invalid index (expected string, got {X})" -- Index MUST be a string.

	Finds a node with a specified index/name.
	Useful if you want to seek two nodes and connect them together.
]=]
function Navigator.GetNodeWithIndex(self: Navigator, index: string): GraphNode?
	local network = self._network
	assert(network, "No network bound. Did you forget to call :Parse()?")

	assert(typeof(index) == "string", `Invalid index (expected string, got {typeof(index)}`)

	return network.Nodes[index]
end


--[=[
	@param position Vector3 -- Where to look for a nearby node.
	@param maxRadius number? -- The maximum distance to check for nearby node. Default = 100
	@param filterFn (node: GraphNode) -> boolean -- An optional node-by-node filtering function, where if the returned condition is false, that closest node will not be considered.

	@return GraphNode? -- The nearest node

	Finds and returns the nearest node to `position`.
]=]
function Navigator.GetNodeNear(self: Navigator, position: Vector3, maxRadius: number?, filterFn: ((node: GraphNode) -> boolean)?): GraphNode?
	local closest: GraphNode?, maxDist = nil, maxRadius or 100

	for _,node: GraphNode in self._nodes:GetObjectsNearby(position, maxDist) do
		local dist = (position - node.Position).Magnitude
		if dist < maxDist then
			if filterFn and not filterFn(node) then continue end

			-- this node is closer than the last one
			closest = node
			maxDist = dist
		end
	end

	return closest
end


--[=[
	@param box BasePart | BoxParam -- The param for spatial querying
	@param filterFn (node: GraphNode) -> boolean -- An optional node-by-node filtering function, where if the returned condition is false, that in-box node will not be appended.

	@return { GraphNode } -- The nodes in the specified box region

	Finds and returns the nodes inside of a part or given bounds.
]=]
function Navigator.GetNodesInBox(self: Navigator, box: BasePart | BoxParam, filterFn: ((node: GraphNode) -> boolean)?): { GraphNode }
	local boxCFrame, boxSize = box.CFrame, box.Size

	local nodesInBox = {} :: { GraphNode }

	for _,node: GraphNode in self._nodes:GetObjectsNearby(boxCFrame.Position, boxSize.Magnitude * 1.25) do
		-- Check if edge is in box
		if Helpers.InBox(node.Position, boxCFrame, boxSize) then
			-- Check if elligible edge
			if filterFn and not filterFn(node) then
				continue
			end

			-- Append
			table.insert(nodesInBox, node)
		end
	end

	return nodesInBox
end


export type Navigator = typeof(Navigator.new(...))
return Navigator
