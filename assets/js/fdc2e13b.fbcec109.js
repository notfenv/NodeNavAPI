"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[428],{3905:(e,t,n)=>{n.d(t,{Zo:()=>u,kt:()=>m});var a=n(67294);function o(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function r(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);t&&(a=a.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,a)}return n}function i(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?r(Object(n),!0).forEach((function(t){o(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):r(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function p(e,t){if(null==e)return{};var n,a,o=function(e,t){if(null==e)return{};var n,a,o={},r=Object.keys(e);for(a=0;a<r.length;a++)n=r[a],t.indexOf(n)>=0||(o[n]=e[n]);return o}(e,t);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);for(a=0;a<r.length;a++)n=r[a],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(o[n]=e[n])}return o}var s=a.createContext({}),l=function(e){var t=a.useContext(s),n=t;return e&&(n="function"==typeof e?e(t):i(i({},t),e)),n},u=function(e){var t=l(e.components);return a.createElement(s.Provider,{value:t},e.children)},c="mdxType",h={inlineCode:"code",wrapper:function(e){var t=e.children;return a.createElement(a.Fragment,{},t)}},d=a.forwardRef((function(e,t){var n=e.components,o=e.mdxType,r=e.originalType,s=e.parentName,u=p(e,["components","mdxType","originalType","parentName"]),c=l(n),d=o,m=c["".concat(s,".").concat(d)]||c[d]||h[d]||r;return n?a.createElement(m,i(i({ref:t},u),{},{components:n})):a.createElement(m,i({ref:t},u))}));function m(e,t){var n=arguments,o=t&&t.mdxType;if("string"==typeof e||o){var r=n.length,i=new Array(r);i[0]=d;var p={};for(var s in t)hasOwnProperty.call(t,s)&&(p[s]=t[s]);p.originalType=e,p[c]="string"==typeof e?e:o,i[1]=p;for(var l=2;l<r;l++)i[l]=n[l];return a.createElement.apply(null,i)}return a.createElement.apply(null,n)}d.displayName="MDXCreateElement"},89111:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>s,contentTitle:()=>i,default:()=>h,frontMatter:()=>r,metadata:()=>p,toc:()=>l});var a=n(87462),o=(n(67294),n(3905));const r={},i="Set Up / Basics",p={unversionedId:"Setup",id:"Setup",title:"Set Up / Basics",description:"First you've gotta actually parse the nodegraph you want to use.",source:"@site/docs/Setup.md",sourceDirName:".",slug:"/Setup",permalink:"/NodeNavAPI/docs/Setup",draft:!1,editUrl:"https://github.com/notfenv/NodeNavAPI/edit/master/docs/Setup.md",tags:[],version:"current",frontMatter:{},sidebar:"defaultSidebar",previous:{title:"Plugin Usage",permalink:"/NodeNavAPI/docs/Plugin Usage"}},s={},l=[],u={toc:l},c="wrapper";function h(e){let{components:t,...n}=e;return(0,o.kt)(c,(0,a.Z)({},u,n,{components:t,mdxType:"MDXLayout"}),(0,o.kt)("h1",{id:"set-up--basics"},"Set Up / Basics"),(0,o.kt)("p",null,"First you've gotta actually parse the nodegraph you want to use.\nWhen a nodegraph is parsed, it gives the Navigator information about the graph's nodes, connections (and their types) so that\nthe algorithm has something to navigate with."),(0,o.kt)("admonition",{type:"tip"},(0,o.kt)("p",{parentName:"admonition"},"People who come from using Roblox's pathfinding system tend to think that node-pathfinding will just go through walls or anything stupid of that nature."),(0,o.kt)("p",{parentName:"admonition"},"This is ",(0,o.kt)("b",null,"incorrect"),". Node-pathfinding, as the name implies, pathfinds based on a set of nodes, which means you ",(0,o.kt)("b",null,"place")," those nodes where ",(0,o.kt)("b",null,"YOU")," want your AI to go."),(0,o.kt)("p",{parentName:"admonition"},"Think of each node as a walk-to point.\nEdges define which nodes can go to other nodes.")),(0,o.kt)("pre",null,(0,o.kt)("code",{parentName:"pre",className:"language-lua"},"local NodeNavigator = require(path.to.NodeNavigator)\n\nlocal Navigator = NodeNavigator.Get() or NodeNavigator.Create(game.ServerStorage.NodeGraph) -- Assuming a navigator was already made, or a nodegraph exists somewhere\n")),(0,o.kt)("p",null,"Great, now you can start using the navigator\nTo compute a path between two points, use the ",(0,o.kt)("inlineCode",{parentName:"p"},"Navigator:TryComputePath(startPosition, targetPosition)")," method, which returns\na Promise. You can then get the computed path via chaining ",(0,o.kt)("inlineCode",{parentName:"p"},":andThen(function(path))"),", or following the call with ",(0,o.kt)("inlineCode",{parentName:"p"},":expect()")),(0,o.kt)("p",null,"Example of both cases:"),(0,o.kt)("p",null,(0,o.kt)("inlineCode",{parentName:"p"},"andThen"),":"),(0,o.kt)("pre",null,(0,o.kt)("code",{parentName:"pre",className:"language-lua"},"Navigator:TryComputePath(pointA, pointB):andThen(function(path)\n    -- We have the path\nend):catch(function(err)\n    -- Safely exit due to an error, print it out if you want to see what went wrong.\nend)\n")),(0,o.kt)("p",null,(0,o.kt)("inlineCode",{parentName:"p"},"expect")),(0,o.kt)("pre",null,(0,o.kt)("code",{parentName:"pre",className:"language-lua"},"local path = Navigator:TryComputePath(pointA, pointB):expect()\n")),(0,o.kt)("admonition",{type:"caution"},(0,o.kt)("p",{parentName:"admonition"},"Should an exception occur with the ",(0,o.kt)("inlineCode",{parentName:"p"},":expect()")," method, it will invoke an error.\nAlternatively, you can use the ",(0,o.kt)("inlineCode",{parentName:"p"},":await()")," method and check if the operation was successful\nor not."),(0,o.kt)("pre",{parentName:"admonition"},(0,o.kt)("code",{parentName:"pre",className:"language-lua"},"local success, path = Navigator:TryComputePath(pointA, pointB):await()\nif success then\n    -- Got path\nelse\n    -- Something went wrong\nend\n"))),(0,o.kt)("p",null,"To get the waypoints of a path, simply call ",(0,o.kt)("inlineCode",{parentName:"p"},"path:GetWaypoints()"),". This returns an ordered array of ",(0,o.kt)("inlineCode",{parentName:"p"},"PathWaypoint")," objects,\nthat you can use to make a humanoid follow along.\nIn addition, you can also visualize the computed path by running ",(0,o.kt)("inlineCode",{parentName:"p"},"path:Visualize()"),"."),(0,o.kt)("h1",{id:"usage-guide"},"Usage Guide"),(0,o.kt)("p",null,"With all of this in mind, here is how you can set up a simple pathfinding loop with a humanoid agent."),(0,o.kt)("pre",null,(0,o.kt)("code",{parentName:"pre",className:"language-lua"},'local Character = script.Parent\nlocal RootPart = Character.HumanoidRootPart\nlocal Humanoid = Character.Humanoid\n\nlocal pathId = 0\n\nlocal function RunPath(targetPosition: Vector3): ()\n    -- Compute the path\n    Navigator:TryComputePath(RootPart.Position, targetPosition)\n        :andThen(function(path)\n            -- Because we\'re recomputing every second, we need some sort of way\n            -- to cancel the current path.\n            pathId += 1\n            local myPath = pathId\n\n            -- Make humanoid traverse along path\n            for _,waypoint in path:GetWaypoints() do\n                if pathId ~= myPath then continue end -- This path got cancelled\n                if waypoint.Action == Enum.PathWaypointAction.Jump then\n                    -- Hit a jump connector, force the Humanoid to jump\n                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)\n                end\n\n                Humanoid:MoveTo(waypoint.Position)\n                Humanoid.MoveToFinished:Wait()\n\n                -- We reached the waypoint, move on\n            end\n        end)\n        :catch(function(err)\n            -- Computation must\'ve failed, lets see where we went wrong\n            warn(err)\n        end)\n\n    -- NOTE: You can also use different algorithms for pathfinding:\n    -- Navigator:TryComputePath(RootPart.Position, targetPosition, 10, "Dijkstra")\n    -- Navigator:TryComputePath(RootPart.Position, targetPosition, 10, "BFS")\n    -- The "10" param specifies the maximum start/target node query distance, smaller numbers are usually more optimal.\nend\n\nwhile true do\n    RunPath(workspace.TargetBlock.Position) -- Assuming you have a part called `TargetBlock` in the `Workspace`\n    task.wait(1)\nend\n')),(0,o.kt)("p",null,"To learn more about the API, visit the ",(0,o.kt)("a",{parentName:"p",href:"https://notfenv.github.io/NodeNavAPI/api/NodeNavigator"},"API Reference")))}h.isMDXComponent=!0}}]);