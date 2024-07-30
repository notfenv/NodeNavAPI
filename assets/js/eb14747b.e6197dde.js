"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[982],{1776:e=>{e.exports=JSON.parse('{"functions":[{"name":"new","desc":"Constructs a new navigator for nodegraphs.\\n\\nIf a navigator already exists, this will return\\nthe current node navigator.","params":[],"returns":[{"desc":"The new navigator.","lua_type":"Navigator"}],"function_type":"static","private":true,"source":{"line":73,"path":"lib/Navigator.luau"}},{"name":"Parse","desc":"Changes the navigator\'s graph, rebuilding the grid.","params":[{"name":"self","desc":"","lua_type":"Navigator"},{"name":"nodeGraph","desc":"The new node graph.","lua_type":"NodeGraph"}],"returns":[],"function_type":"static","source":{"line":98,"path":"lib/Navigator.luau"}},{"name":"TryComputePath","desc":"Tries to calculate a path from `startPoint` to `targetPoint`.\\n\\nIf there is no feasible path from `startPoint` to `targetPoint`, this function\\nwill return `nil`.\\n\\nExample Usage:\\n```lua\\nnavigator:TryComputePath(HumanoidRootPart.Position, target.Position):andThen(function(path)\\n\\t-- Show the computed path to the target\\n\\tpath:Visualize()\\nend):catch(warn)\\n```","params":[{"name":"self","desc":"","lua_type":"Navigator"},{"name":"startPoint","desc":"The pathfinding origin.","lua_type":"Vector3"},{"name":"targetPoint","desc":"The pathfinding destination.","lua_type":"Vector3"},{"name":"maxNodeDist","desc":"The longest sightline to the nearest node the bot will try and find (Leave nil to default to 100)","lua_type":"number?"},{"name":"algorithm","desc":"Whether to use A* algorithm, Dijkstra\'s algorithm, Breadth-First Search algorithm, or Greedy Best First Search algorithm for pathfinding. (Leave nil to default to \\"AStar\\")","lua_type":"\\"AStar\\" | \\"Dijkstra\\" | \\"BFS\\" | \\"GBFS\\"?"}],"returns":[{"desc":"The computed path object.","lua_type":"Promise<NavigatorPath>"}],"function_type":"static","errors":[{"lua_type":"\\"No network bound. Did you forget to call :Parse()?\\"","desc":"A node graph wasn\'t parsed."}],"source":{"line":141,"path":"lib/Navigator.luau"}},{"name":"GetEdgeNear","desc":"Finds and returns the nearest edge to `position`.\\n\\nThis is useful if you wish to disable pathfinding through obstructed areas, for example, debris.\\nExample Usage:\\n```lua\\nlocal edge = Navigator:GetEdgeNear(position, 10)\\nedge.SetEnabled(false) -- Don\'t allow pathfinding at this specific edge\\n```\\n\\n:::tip\\nThis only returns the closest edge to `position` within `maxRadius`. If you want a more\\naccurate detection, use `Navigator:GetEdgesInBox()` instead.\\n:::","params":[{"name":"self","desc":"","lua_type":"Navigator"},{"name":"position","desc":"Where to look for a nearby edge.","lua_type":"Vector3"},{"name":"maxRadius","desc":"The maximum distance to check for nearby edges. Default = 100","lua_type":"number?"},{"name":"filterFn","desc":"An optional edge-by-edge filtering function, where if the returned condition is false, that closest edge will not be considered.","lua_type":"(edge: Edge) -> boolean"}],"returns":[{"desc":"The nearest edge","lua_type":"Edge?"}],"function_type":"static","source":{"line":210,"path":"lib/Navigator.luau"}},{"name":"GetEdgesInBox","desc":"Finds and returns the edges inside of a part or given bounds.\\n\\nThis is useful if you wish to disable pathfinding through obstructed areas, for example, debris.\\nExample Usage:\\n```lua\\nfor _,edge in Navigator:GetEdgesInBox(edgeDisableRegion) do\\n\\tedge.SetEnabled(false) -- Don\'t allow pathfinding through `edgeDisableRegion`\\nend\\n```","params":[{"name":"self","desc":"","lua_type":"Navigator"},{"name":"box","desc":"The param for spatial querying","lua_type":"BasePart | BoxParam"},{"name":"filterFn","desc":"An optional edge-by-edge filtering function, where if the returned condition is false, that in-box edge will not be appended.","lua_type":"(edge: Edge) -> boolean"}],"returns":[{"desc":"The edges in the specified box region","lua_type":"{ Edge }"}],"function_type":"static","source":{"line":249,"path":"lib/Navigator.luau"}},{"name":"ConnectNodes","desc":"Bidirectionally connects two nodes with a specified connection type\\nIf the connection type is \\"OneWay,\\" the connection will only be unidirectional.\\n\\n:::tip\\nA good use case for this would be procedural room generation, where you have multiple room prefabs\\nwith their own nodegraphs that are individual from the main / primary nodegraph.\\n\\nIn this case, you\'d go through all of the nodes/connections in the rooms\' nodegraphs, and rebuild them\\non the main nodegraph.\\n\\nExample Usage of what I wrote for [HELLMET by Sensei_Developer](https://www.roblox.com/games/13815196156/HELLMET):\\n```lua\\n-- Get exit node before anything else; dont want to have the exit node as one of the nodes in the room\\nlocal exitNode = navigator:GetNodesInBox(v.ExitArea)[1]\\n\\n-- Instantiate room sub-graph onto main nodegraph. This is basically an alt version of the nodegraph parser\\nlocal roomNodes = {}\\nfor _,node in prefabRoom.NodeGraph.Nodes:GetChildren() do\\n\\tif node:IsA(\\"BasePart\\") then\\n\\t\\t-- Keep track of the old node name for building connections on main graph\\n\\t\\t-- This is so that we can refer to the nodes on the main graph with the sub-graph\'s nodes\\n\\t\\t-- Otherwise there\'d be ambiguity, duplicate nodes\\n\\t\\troomNodes[node.Name] = navigator:PlaceNode(node.Position)\\n\\tend\\nend\\n\\n-- Re-build edges\\nfor _,edge in prefabRoom.NodeGraph.Edges:GetChildren() do\\n\\tif edge:IsA(\\"Constraint\\") or edge:IsA(\\"Beam\\") then\\n\\t\\tlocal delimiter = edge.Name:gmatch(\\"%d+\\")\\n\\t\\tlocal startId, targetId = delimiter(), delimiter()\\n\\t\\tnavigator:ConnectNodes(roomNodes[startId], roomNodes[targetId], GetEdgeType(edge))\\n\\tend\\nend\\n\\t\\n-- OK, now connect the exiting/entrance nodes\\n-- The exit node is the way in and out of the room pretty much\\nif exitNode then\\n\\tnavigator:ConnectNodes(roomNodes[prefabRoom.EnterNode.Value.Name], exitNode)\\nelse\\n\\twarn(\\"Couldnt find exit node\\")\\nend\\n\\n-- Now, the AI can pathfind inside and outside of this room.\\n```\\n:::","params":[{"name":"self","desc":"","lua_type":"Navigator"},{"name":"startNode","desc":"The starting node (the order doesn\'t matter UNLESS it\'s a one-way edge)","lua_type":"GraphNode"},{"name":"targetNode","desc":"The target node (the order doesn\'t matter UNLESS it\'s a one-way edge)","lua_type":"GraphNode"},{"name":"connectionType","desc":"The type of the connection.","lua_type":"\\"Edge\\" | \\"Jump\\" | \\"OneWay\\""},{"name":"isEnabled","desc":"An optional boolean that dictates if the edge is initially enabled or not.","lua_type":"boolean?"}],"returns":[{"desc":"The newly created edge (the main one. Toggling this edge will also toggle the entire edge bidirectionally)","lua_type":"Edge"}],"function_type":"static","errors":[{"lua_type":"\\"No network bound. Did you forget to call :Parse()?\\"","desc":"A node graph wasn\'t parsed."}],"source":{"line":332,"path":"lib/Navigator.luau"}},{"name":"PlaceNodeAt","desc":"Creates a node at a position.\\n\\n:::tip\\nA good use case for this would be procedural room generation, where you have multiple room prefabs\\nwith their own nodegraphs that are individual from the main / primary nodegraph.\\n\\nIn this case, you\'d go through all of the nodes/connections in the rooms\' nodegraphs, and rebuild them\\non the main nodegraph.\\n\\nExample Usage of what I wrote for [HELLMET by Sensei_Developer](https://www.roblox.com/games/13815196156/HELLMET):\\n```lua\\n-- Get exit node before anything else; dont want to have the exit node as one of the nodes in the room\\nlocal exitNode = navigator:GetNodesInBox(prefabRoom.ExitArea)[1]\\n\\n-- Instantiate room sub-graph onto main nodegraph. This is basically an alt version of the nodegraph parser\\nlocal roomNodes = {}\\nfor _,node in prefabRoom.NodeGraph.Nodes:GetChildren() do\\n\\tif node:IsA(\\"BasePart\\") then\\n\\t\\t-- Keep track of the old node name for building connections on main graph\\n\\t\\t-- This is so that we can refer to the nodes on the main graph with the sub-graph\'s nodes\\n\\t\\t-- Otherwise there\'d be ambiguity, duplicate nodes\\n\\t\\troomNodes[node.Name] = navigator:PlaceNode(node.Position)\\n\\tend\\nend\\n\\n-- Re-build edges\\nfor _,edge in prefabRoom.NodeGraph.Edges:GetChildren() do\\n\\tif edge:IsA(\\"Constraint\\") or edge:IsA(\\"Beam\\") then\\n\\t\\tlocal delimiter = edge.Name:gmatch(\\"%d+\\")\\n\\t\\tlocal startId, targetId = delimiter(), delimiter()\\n\\t\\tnavigator:ConnectNodes(roomNodes[startId], roomNodes[targetId], GetEdgeType(edge))\\n\\tend\\nend\\n\\t\\n-- OK, now connect the exiting/entrance nodes\\n-- The exit node is the way in and out of the room pretty much\\nif exitNode then\\n\\tnavigator:ConnectNodes(roomNodes[prefabRoom.EnterNode.Value.Name], exitNode)\\nelse\\n\\twarn(\\"Couldnt find exit node\\")\\nend\\n\\n-- Now, the AI can pathfind inside and outside of this room.\\n```\\n:::","params":[{"name":"self","desc":"","lua_type":"Navigator"},{"name":"position","desc":"The position of the node.","lua_type":"Vector3"},{"name":"index","desc":"The index/name of the node. If not supplied, will use the next available node index.","lua_type":"string?"}],"returns":[{"desc":"The newly created node.","lua_type":"GraphNode"}],"function_type":"static","errors":[{"lua_type":"\\"No network bound. Did you forget to call :Parse()?\\"","desc":"A node graph wasn\'t parsed."}],"source":{"line":409,"path":"lib/Navigator.luau"}},{"name":"GetNodeWithIndex","desc":"Finds a node with a specified index/name.\\nUseful if you want to seek two nodes and connect them together.","params":[{"name":"self","desc":"","lua_type":"Navigator"},{"name":"index","desc":"The index of the node to find","lua_type":"string"}],"returns":[{"desc":"The node with the matching index","lua_type":"GraphNode?"}],"function_type":"static","errors":[{"lua_type":"\\"No network bound. Did you forget to call :Parse()?\\"","desc":"A node graph wasn\'t parsed."},{"lua_type":"\\"Invalid index (expected string, got {X})\\"","desc":"Index MUST be a string."}],"source":{"line":438,"path":"lib/Navigator.luau"}},{"name":"GetNodeNear","desc":"Finds and returns the nearest node to `position`.","params":[{"name":"self","desc":"","lua_type":"Navigator"},{"name":"position","desc":"Where to look for a nearby node.","lua_type":"Vector3"},{"name":"maxRadius","desc":"The maximum distance to check for nearby node. Default = 100","lua_type":"number?"},{"name":"filterFn","desc":"An optional node-by-node filtering function, where if the returned condition is false, that closest node will not be considered.","lua_type":"(node: GraphNode) -> boolean"}],"returns":[{"desc":"The nearest node","lua_type":"GraphNode?"}],"function_type":"static","source":{"line":457,"path":"lib/Navigator.luau"}},{"name":"GetNodesInBox","desc":"Finds and returns the nodes inside of a part or given bounds.","params":[{"name":"self","desc":"","lua_type":"Navigator"},{"name":"box","desc":"The param for spatial querying","lua_type":"BasePart | BoxParam"},{"name":"filterFn","desc":"An optional node-by-node filtering function, where if the returned condition is false, that in-box node will not be appended.","lua_type":"(node: GraphNode) -> boolean"}],"returns":[{"desc":"The nodes in the specified box region","lua_type":"{ GraphNode }"}],"function_type":"static","source":{"line":483,"path":"lib/Navigator.luau"}}],"properties":[],"types":[],"name":"Navigator","desc":"A node navigation class that allows for node pathfinding with various different pathfinding algorithms.\\nUsed with a graph/navigation network.\\n\\nUse `Navigator.OnGraphUpdated` to listen for whenever the graph is manipulated (example: an edge is toggled)\\n\\n\\"Nodes\\" are the points that the AI traverse to.\\n\\"Connectors\\" are the connections between Nodes, marking which nodes the AI\\n\\tcan go to, from the current Node.\\n\\nThere are currently three types of Node Connectors:\\n\\"Edge Connector\\" - A normal, bidirectional movement connector. Visualized as a line\\n\\n\\"Jump Connector\\" - A connector where if the AI has to traverse 2 nodes connected by a Jump Connector,\\n\\tthe AI should jump. Visualized as a spring.\\n\\n\\"One-Way Connector\\" - A connector where the AI can only move to it\'s target node in the direction of it\'s visual indicator,\\n\\tand not back. Visualized as a Beam with an arrows texture, where the direction of the arrows is the direction of movement.","source":{"line":60,"path":"lib/Navigator.luau"}}')}}]);