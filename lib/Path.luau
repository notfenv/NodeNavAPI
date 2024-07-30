--!strict
-- Navigator Path
-- Mia Vince
-- June 21, 2024


local Draw = require(script.Draw)
local types = require(script.Parent.Parent.Types)
type ComputedPath = types.ComputedPath
type Path = types.Path


--[=[
    @class NavigatorPath
    A result path object, computed by the node navigator.
]=]
local NavigatorPath = {}
NavigatorPath.__index = NavigatorPath


--[=[
    Constructs a new path.
    @param waypoints { PathWaypoint } -- The array of waypoints, aka the computed path.
    @return NavigatorPath -- The new NavigatorPath object.
]=]
function NavigatorPath.new(waypoints: { PathWaypoint })
    local self = {}

    self._waypoints = waypoints :: { PathWaypoint }
    self._visualizedWaypoints = {} :: { Part }

    setmetatable(self, NavigatorPath)
    return self
end


--[=[
    Returns the path's waypoints.
    @return Path -- The waypoints in order, from start to finish.
]=]
function NavigatorPath.GetWaypoints(self: NavigatorPath): Path
    return self._waypoints
end


--[=[
	Visualizes the path.
	@param container Instance? -- The container of the visualized path. Defaults to `Workspace`.
]=]
function NavigatorPath.Visualize(self: NavigatorPath, container: Instance?): ()
    -- Clear old visualizer
    local visualWaypoints = self._visualizedWaypoints
    for _,oldWaypoint in visualWaypoints do
        oldWaypoint:Destroy()
    end
    table.clear(visualWaypoints)

    -- Draw waypoints
    local drawnWaypoints = Draw.Path(self._waypoints, container)
    for _,newWaypoint in drawnWaypoints do
        table.insert(visualWaypoints, newWaypoint)
    end
end


--[=[
	Clears the path visuals.
]=]
function NavigatorPath.ClearVisualizer(self: NavigatorPath): ()
    local visualWaypoints = self._visualizedWaypoints
    for _,waypoint in visualWaypoints do
        waypoint:Destroy()
    end
    table.clear(visualWaypoints)
end


--[=[
	Destroys the path, clearing all data and visualizers.
]=]
function NavigatorPath.Destroy(self: NavigatorPath): ()
    -- Clear visualizers
    self:ClearVisualizer()

    -- Clear data
    table.clear(self._waypoints)
end


export type NavigatorPath = typeof(NavigatorPath.new(...))
return NavigatorPath
