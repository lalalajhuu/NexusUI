local Players=game:GetService('Players')
local UserInputService=game:GetService('UserInputService')

local U=require(script.Parent.Utility)
local Elements=require(script.Parent.Elements)
local Window={}; Window.__index=Window
local Tab={}; Tab.__index=Tab
for name,constructor in pairs(Elements) do
	Tab['Create'..name]=function(self,options) return constructor(self,options) end
end
function Window.new(options,theme)
	assert(Players.LocalPlayer,'NexusUI must run from a LocalScript')
	options=options or {}
	local self=setmetatable({Theme=theme,Connections={},Tabs={},Destroyed=false},Window)
	local gui=U.New('ScreenGui',{Name='NexusUI',ResetOnSpawn=false,IgnoreGuiInset=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=options.DisplayOrder or 50},Players.LocalPlayer:WaitForChild('PlayerGui')); self.Gui=gui
	local root=U.New('Frame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1},gui)
	-- The ScreenGui stays enabled: the restore button must remain usable on touch.
	local restore=U.Button(root,'NEXUS  +',theme)
	self.TouchControls=UserInputService.TouchEnabled
	restore.Name='RestoreNexusUI'; restore.Visible=self.TouchControls; restore.ZIndex=100
	restore.AnchorPoint=Vector2.new(0,1); restore.Position=UDim2.new(0,16,1,-16)
	restore.Size=UDim2.fromOffset(112,44); restore.TextColor3=theme.AccentLight
	if self.TouchControls then
		restore.Text='N'; restore.TextSize=19
		restore.Size=UDim2.fromOffset(48,48)
		restore.AnchorPoint=Vector2.new(1,0); restore.Position=UDim2.new(1,-16,0,16)
	end
	U.Stroke(restore,theme.Accent); self.RestoreButton=restore
	U.Hover(self,restore)
	U.Connect(self,restore.Activated,function() self:Toggle() end)
	local frame=U.New('Frame',{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(760,520),BackgroundColor3=theme.Background,BorderSizePixel=0,ClipsDescendants=false},root); self.Frame=frame
	local scale=U.New('UIScale',{},frame)
	U.Round(frame,12); U.Stroke(frame,theme.Border)
	-- Layered outlines provide a soft shadow without external assets.
	for i=1,3 do U.New('UIStroke',{Color=Color3.new(),Thickness=i*3,Transparency=.8+i*.04,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},frame) end
	local header=U.New('Frame',{Size=UDim2.new(1,-112,0,58),BackgroundTransparency=1,Active=true},frame)
	local title=U.Text(header,options.Title or 'NEXUS',18,theme); title.Position=UDim2.fromOffset(22,11)
	local subtitle=U.Text(header,options.Subtitle or 'INTERFACE FRAMEWORK',9,theme); subtitle.TextColor3=theme.Dim; subtitle.Position=UDim2.fromOffset(23,32)
	U.New('Frame',{Position=UDim2.fromOffset(0,58),Size=UDim2.new(1,0,0,1),BackgroundColor3=theme.Border,BorderSizePixel=0},frame)
	local minimize=U.Button(frame,'-',theme); minimize.Position=UDim2.new(1,-94,0,13); minimize.Size=UDim2.fromOffset(36,32)
	local close=U.Button(frame,utf8.char(0xD7),theme); close.Position=UDim2.new(1,-50,0,13); close.Size=UDim2.fromOffset(36,32)
	local body=U.New('Frame',{Position=UDim2.fromOffset(0,59),Size=UDim2.new(1,0,1,-59),BackgroundTransparency=1},frame); self.Body=body
	local sidebar=U.New('ScrollingFrame',{Position=UDim2.fromOffset(12,14),Size=UDim2.new(0,152,1,-28),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y},body); self.Sidebar=sidebar
	U.New('UIListLayout',{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},sidebar); U.Padding(sidebar,5,4)
	self.Pages=U.New('Frame',{Position=UDim2.fromOffset(180,14),Size=UDim2.new(1,-196,1,-28),BackgroundTransparency=1,ClipsDescendants=true},body)
	local function resize()
		if self.Destroyed then return end
		local size=root.AbsoluteSize
		if size.X<=0 or size.Y<=0 then return end
		local compact=size.X<600
		self.Width=compact and 420 or 760; self.Height=compact and 590 or 520
		local side=compact and 102 or 152
		sidebar.Size=UDim2.new(0,side,1,-28)
		self.Pages.Position=UDim2.fromOffset(side+28,14); self.Pages.Size=UDim2.new(1,-side-44,1,-28)
		scale.Scale=math.min(1,(size.X-20)/self.Width,(size.Y-20)/self.Height)
		frame.Size=UDim2.fromOffset(self.Width,self.Height)
		-- Recenter on viewport changes to keep the title bar reachable.
		frame.Position=UDim2.fromScale(.5,.5)
	end
	U.Connect(self,root:GetPropertyChangedSignal('AbsoluteSize'),resize); task.defer(resize)
	local start,origin
	U.Drag(self,header,function(p,began)
		if began then start=p; origin=frame.Position; return end
		local delta=p-start
		local size=root.AbsoluteSize; local half=frame.AbsoluteSize/2
		local x=math.clamp(size.X*origin.X.Scale+origin.X.Offset+delta.X,half.X,math.max(half.X,size.X-half.X))
		local y=math.clamp(size.Y*origin.Y.Scale+origin.Y.Offset+delta.Y,half.Y,math.max(half.Y,size.Y-half.Y))
		frame.Position=UDim2.fromOffset(x,y)
	end)
	U.Connect(self,minimize.Activated,function()
		self:Minimize()
	end)
	U.Hover(self,minimize); U.Hover(self,close)
	U.Connect(self,close.Activated,function() self:Destroy() end)
	self.Notices=U.New('Frame',{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-12,1,-12),Size=UDim2.new(1,-24,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},root)
	U.New('UISizeConstraint',{MaxSize=Vector2.new(340,10000)},self.Notices)
	U.New('UIListLayout',{Padding=UDim.new(0,8),VerticalAlignment=Enum.VerticalAlignment.Bottom,SortOrder=Enum.SortOrder.LayoutOrder},self.Notices)
	self.ToggleKey=options.ToggleKey or Enum.KeyCode.RightShift
	U.Connect(self,UserInputService.InputBegan,function(input)
		if self.Destroyed or UserInputService:GetFocusedTextBox() then return end
		-- Shift Lock can consume RightShift. This UI shortcut still has to work.
		if input.KeyCode==self.ToggleKey then self:Toggle() end
	end)
	return self
end
function Window:CreateTab(options)
	assert(not self.Destroyed,'Window destroyed'); options=options or {}
	local tab=setmetatable({Window=self},Tab); local t=self.Theme
	tab.Button=U.Button(self.Sidebar,options.Name or 'Tab',t); tab.Button.LayoutOrder=#self.Tabs+1; tab.Button.Size=UDim2.new(1,-14,0,46)
	tab.Button.TextXAlignment=Enum.TextXAlignment.Left; U.Padding(tab.Button,18,0)
	tab.Indicator=U.New('Frame',{Position=UDim2.new(0,-18,.5,-10),Size=UDim2.fromOffset(3,20),BackgroundColor3=t.Accent,BackgroundTransparency=1,BorderSizePixel=0},tab.Button); U.Round(tab.Indicator,2)
	U.Gradient(tab.Indicator,t.AccentLight,t.Accent,90)
	U.Hover(self,tab.Button,function(hovered) local color=tab.Selected and t.ActiveTab or t.Panel; return hovered and color:Lerp(t.Text,.04) or color end)
	tab.Content=U.New('ScrollingFrame',{Visible=false,BackgroundTransparency=1,Size=UDim2.fromScale(1,1),BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=t.Accent},self.Pages)
	U.New('UIListLayout',{Padding=UDim.new(0,14),SortOrder=Enum.SortOrder.LayoutOrder},tab.Content)
	U.New('UIPadding',{PaddingTop=UDim.new(0,2),PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,8),PaddingBottom=UDim.new(0,10)},tab.Content)
	table.insert(self.Tabs,tab)
	U.Connect(self,tab.Button.Activated,function() self:SelectTab(tab) end)
	if #self.Tabs==1 then self:SelectTab(tab) end
	return tab
end
function Window:SelectTab(tab)
	assert(table.find(self.Tabs,tab),'Tab belongs to another window')
	for _,item in ipairs(self.Tabs) do
		item.Content.Visible=item==tab; item.Selected=item==tab
		U.Tween(item.Indicator,{BackgroundTransparency=item==tab and 0 or 1},self.Theme)
		U.Tween(item.Button,{BackgroundColor3=item==tab and self.Theme.ActiveTab or self.Theme.Panel,TextColor3=item==tab and self.Theme.Text or self.Theme.Muted},self.Theme)
	end
	tab.Content.Position=UDim2.fromOffset(0,8); U.Tween(tab.Content,{Position=UDim2.fromOffset(0,0)},self.Theme)
end
function Window:Notify(options)
	if self.Destroyed then return end
	options=options or {}; local t=self.Theme
	local card=U.New('Frame',{Size=UDim2.new(1,0,0,86),BackgroundColor3=t.Panel,BorderSizePixel=0},self.Notices); U.Round(card,8)
	U.Stroke(card,t[options.Type or 'Success'] or t.Accent)
	local heading=U.Text(card,options.Title or 'NexusUI',13,t); heading.Position=UDim2.fromOffset(14,10); heading.Size=UDim2.new(1,-28,0,20)
	local message=U.Text(card,options.Content or '',12,t); message.Position=UDim2.fromOffset(14,33); message.Size=UDim2.new(1,-28,0,42); message.TextWrapped=true; message.TextColor3=t.Muted
	U.Tween(card,{BackgroundColor3=t.Surface},t)
	task.delay(math.clamp(tonumber(options.Duration) or 4,1,60),function()
		if self.Destroyed or not card.Parent then return end
		local tween=U.Tween(card,{BackgroundTransparency=1},t)
		heading.Visible=false; message.Visible=false
		tween.Completed:Once(function() card:Destroy() end)
	end)
	return card
end
function Window:SetVisible(visible)
	if self.Destroyed then return end
	visible=visible==true
	self.Hidden=not visible
	self.Gui.Enabled=true
	self.Frame.Visible=visible
	self.Notices.Visible=visible
	self.RestoreButton.Visible=self.TouchControls or not visible
	if visible then
		self.Minimized=false
		self.Body.Visible=true
	end
end
function Window:Toggle()
	if not self.Destroyed then self:SetVisible(not self.Frame.Visible) end
end
function Window:Minimize()
	if self.Destroyed then return end
	self.Minimized=true
	self:SetVisible(false)
end
function Window:Restore()
	self:SetVisible(true)
end
function Window:Destroy()
	if self.Destroyed then return end; self.Destroyed=true
	-- Synchronous cleanup lets application scripts stop their own loops before UI teardown.
	if self.OnDestroy then
		local ok,err=pcall(self.OnDestroy)
		if not ok then warn('[NexusUI] cleanup: '..tostring(err)) end
	end
	for _,connection in ipairs(self.Connections) do connection:Disconnect() end
	table.clear(self.Connections); self.Gui:Destroy()
end
return Window
