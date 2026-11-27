-- Replace YOUR_USER and YOUR_REPO with your GitHub account and repository.
-- This entry point requires an environment with game:HttpGet and loadstring.
local URL = 'https://raw.githubusercontent.com/lalalajhuu/NexusUI/main/dist/NexusUI.lua'
local NexusUI = loadstring(game:HttpGet(URL))()

local window = NexusUI:CreateWindow({
    Title = 'NEXUS UI',
    Subtitle = 'REMOTE / 1.0',
})
local tab = window:CreateTab({Name = 'General'})
tab:CreateToggle({Name = 'Particles', Default = true, Callback = function(value)
    print('Particles:', value)
end})
tab:CreateSlider({Name = 'Volume', Min = 0, Max = 100, Default = 50, Callback = function(value)
    print('Volume:', value)
end})
tab:CreateDropdown({Name = 'Quality', Options = {'Low', 'Medium', 'High'}, Default = 'High', Callback = function(value)
    print('Quality:', value)
end})
window:Notify({Title = 'NexusUI', Content = 'Library loaded.', Type = 'Success'})
