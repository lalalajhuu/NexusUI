-- NexusUI 1.1 visual showcase.
-- This entry point requires an environment with game:HttpGet and loadstring.
local URL = 'https://raw.githubusercontent.com/lalalajhuu/NexusUI/main/dist/NexusUI.lua'
local NexusUI = loadstring(game:HttpGet(URL))()

local window = NexusUI:CreateWindow({
    Title = 'NEXUS UI',
    Subtitle = 'REMOTE / 1.1',
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
tab:CreateButton({Name = 'Test notification', Callback = function()
    window:Notify({Title = 'NexusUI 1.1', Content = 'Visual refresh loaded.', Type = 'Success'})
end})
local appearance = window:CreateTab({Name = 'Appearance'})
appearance:CreateTextbox({Name = 'Profile name', Default = 'Nexus', Callback = function(value)
    print('Profile:', value)
end})
appearance:CreateColorPicker({Name = 'Particle color', Default = Color3.fromRGB(0,191,255), Callback = function(color)
    print('Color:', color)
end})
