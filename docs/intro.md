---
sidebar_position: 1
---

# Intro
Allows for the parsing and traversing of node graphs.
Originally made by Gnat ([@treebee63](https://www.roblox.com/users/9735417/profile)), revisions/revamp by Mia ([@notawildfox](https://www.roblox.com/users/124963457/profile))

I heartily suggest using this in conjunction with Roblox pathfinding, as
node graphs only really shine in indoors/close-quarters areas.

- Mia's Contributions:

- Complete revamp of the navigator, with additional features (such as the user being able to toggle edges in real-time for obstacles)
- Instead of only using Dijkstra's algorithm, adding multiple algorithms (including, but not limited to: A*, Dijkstra, BFS, GBFS)
- Full networker PLUGIN revamp

# Plans:
- Full real-time control of the node graph, this includes (but is not limited to):

# Node Control
- Changing node positions
- Creating/removing nodes
			
# Edge control
- ✅ Edge querying and toggling
- Edge type manipulation (being able to switch edge types, like Jump or OneWay)

# Dynamic node graph quality

Simply put, a way to auto adjust the graph's resolution, like subdividing the graph.
Gnat dubbed this as "fuzzy pathing, that improves the closer you are to the target"
It should speed up longer distance computation.
			
Probably going to be chunk clustered and each cluster will be treated as one point

# ✅ Path caching
~~Caching already exists, however, it's been disabled due to real-time controls.~~

With this in mind, perhaps an integrity check with cached paths that checks if the nodes and
connections are valid with the current node graph, otherwise, that cache can be invalidated and
a new path may be computed.
