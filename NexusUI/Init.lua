-- ReplicatedStorage.NexusUI.Init (ModuleScript). Require from a LocalScript.
local Theme=require(script.Parent.Theme)
local Window=require(script.Parent.Window)
local NexusUI={Version='1.1.0'}
-- NexusUI:CreateWindow({Title='NEXUS', Theme={Accent=Color3.fromRGB(255,51,51)}})
function NexusUI:CreateWindow(options)
	options=options or {}
	local theme=table.clone(Theme)
	for key,value in pairs(options.Theme or {}) do theme[key]=value end
	return Window.new(options,theme)
end
return NexusUI
