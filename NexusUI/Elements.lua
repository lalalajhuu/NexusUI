local U=require(script.Parent.Utility)
local Elements={}
local Control={}; Control.__index=Control
function Control:Get() return self.Value end
function Control:Set(value,silent)
	if self.Dead then return end
	self.Apply(value)
	if not silent then
		U.Callback(function(value)
			if not self.Dead and not self.Window.Destroyed and self.Callback then self.Callback(value) end
		end,self.Value)
	end
end
function Control:Destroy() self.Dead=true; self.Frame:Destroy() end
local function base(tab,options,height)
	local w=tab.Window; local t=w.Theme
	local frame=U.New('Frame',{BackgroundColor3=t.Panel,BorderSizePixel=0,Size=UDim2.new(1,-2,0,height or 64)},tab.Content)
	U.Round(frame,t.Radius); U.Stroke(frame,t.Border)
	U.Gradient(frame,Color3.new(1,1,1),Color3.fromRGB(215,220,232),90)
	-- Padding defines the shared content area; control coordinates below are relative to it.
	U.Padding(frame,t.Padding,16)
	local title=U.Text(frame,options.Name or 'Control',15,t); title.Position=UDim2.fromOffset(0,0); title.Size=UDim2.new(1,0,0,22)
	local c=setmetatable({Frame=frame,Callback=options.Callback,Window=w},Control)
	return c,w,t,title
end
-- Static text and section headers for larger scripts, with automatic height.
function Elements.Label(tab,o)
	o=o or {}; local c,w,t,title=base(tab,o,64)
	title.Text=o.Text or o.Name or ''; title.TextWrapped=true
	title.TextColor3=o.Section and t.AccentLight or t.Muted
	title.TextSize=o.Section and 14 or 12
	title.Size=UDim2.new(1,0,0,0); title.AutomaticSize=Enum.AutomaticSize.Y
	c.Frame.Size=UDim2.new(1,-2,0,0); c.Frame.AutomaticSize=Enum.AutomaticSize.Y
	c.Apply=function(value) c.Value=tostring(value or ''); title.Text=c.Value end
	c:Set(title.Text,true); return c
end
-- tab:CreateToggle({Name='Enabled', Default=false, Callback=function(value) end})
function Elements.Toggle(tab,o)
	o=o or {}; local c,w,t,title=base(tab,o,76); title.Size=UDim2.new(1,-76,1,0)
	local b=U.Button(c.Frame,'',t); b.AnchorPoint=Vector2.new(.5,.5); b.Size=UDim2.fromOffset(50,28); b.Position=UDim2.new(1,-25,.5,0)
	U.Stroke(b,t.Border)
	local gradient=U.Gradient(b,t.AccentDark,t.AccentLight,25)
	local knob=U.New('Frame',{Size=UDim2.fromOffset(20,20),BackgroundColor3=t.Text,BorderSizePixel=0},b); U.Round(knob,10)
	c.Apply=function(v)
		c.Value=v==true
		U.Tween(b,{BackgroundColor3=c.Value and t.Accent or t.Surface},t)
		gradient.Enabled=c.Value
		U.Tween(knob,{Position=UDim2.fromOffset(c.Value and 26 or 4,4)},t)
	end
	U.Hover(w,b,function(hovered) local color=c.Value and t.Accent or t.Surface; return hovered and color:Lerp(t.Text,.12) or color end)
	U.Connect(w,b.Activated,function() if not c.Dead then c:Set(not c.Value) end end)
	c:Set(o.Default==true,true); return c
end
-- Numeric entry and pointer dragging share clamping / step rounding.
function Elements.Slider(tab,o)
	o=o or {}; local c,w,t,title=base(tab,o,120)
	local low=o.Min or 0; local high=o.Max or 100; assert(high>low,'Slider Max must exceed Min')
	local step=o.Step or 1; assert(step>0,'Slider Step must be positive')
	title.Size=UDim2.new(1,-92,0,32)
	local entry=U.Input(c.Frame,'',t); entry.Size=UDim2.fromOffset(72,32); entry.Position=UDim2.new(1,-72,0,0); U.Stroke(entry,t.Border)
	local hit=U.Button(c.Frame,'',t); hit.BackgroundTransparency=1; hit.Position=UDim2.fromOffset(8,40); hit.Size=UDim2.new(1,-16,0,44)
	local track=U.New('Frame',{Position=UDim2.fromOffset(0,17),Size=UDim2.new(1,0,0,10),BackgroundColor3=t.Surface,BorderSizePixel=0},hit); U.Round(track,5); U.Stroke(track,t.Border)
	local fill=U.New('Frame',{Size=UDim2.fromScale(0,1),BackgroundColor3=t.Accent,BorderSizePixel=0},track)
	fill.BackgroundColor3=Color3.new(1,1,1); U.Round(fill,5); U.Gradient(fill,t.AccentDark,t.AccentLight)
	local shadow=U.New('Frame',{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(26,26),BackgroundColor3=Color3.new(),BackgroundTransparency=.55,BorderSizePixel=0},track); U.Round(shadow,13)
	local knob=U.New('Frame',{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(18,18),BackgroundColor3=t.Accent,BorderSizePixel=0},track); U.Round(knob,9)
	local ring=U.Stroke(knob,t.Text); ring.Transparency=0; ring.Thickness=2
	c.Apply=function(v)
		v=tonumber(v) or low
		if v~=v or math.abs(v)==math.huge then v=low end
		c.Value=math.clamp(low+math.round((v-low)/step)*step,low,high)
		entry.Text=string.format('%.6g',c.Value)
		local ratio=(c.Value-low)/(high-low)
		fill.Size=UDim2.fromScale(ratio,1); knob.Position=UDim2.fromScale(ratio,.5); shadow.Position=UDim2.new(ratio,0,.5,2)
	end
	U.Drag(w,hit,function(p) if not c.Dead then c:Set(low+math.clamp((p.X-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)*(high-low)) end end)
	U.Connect(w,entry.FocusLost,function() c:Set(tonumber(entry.Text) or c.Value) end)
	c:Set(o.Default or low,true); return c
end
function Elements.Dropdown(tab,o)
	o=o or {}; local c,w,t=base(tab,o,128); local values={}; local opened=false
	local b=U.Button(c.Frame,'Select',t); b.AnchorPoint=Vector2.new(.5,.5); b.Position=UDim2.new(.5,0,0,57); b.Size=UDim2.new(1,0,0,42); b.TextXAlignment=Enum.TextXAlignment.Left
	U.Padding(b,14,0); U.Stroke(b,t.Border); U.Hover(w,b)
	local arrow=U.Text(b,utf8.char(0x25BC),11,t); arrow.AnchorPoint=Vector2.new(1,.5); arrow.Position=UDim2.new(1,0,.5,0); arrow.Size=UDim2.fromOffset(16,20); arrow.TextColor3=t.Muted
	local panel=U.New('Frame',{Visible=false,BackgroundTransparency=1,Position=UDim2.fromOffset(0,92),Size=UDim2.new(1,0,0,190)},c.Frame)
	local search=U.Input(panel,'Search...',t)
	local list=U.New('ScrollingFrame',{BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.fromOffset(0,46),Size=UDim2.new(1,0,0,140),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=t.Accent},panel)
	U.New('UIListLayout',{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},list)
	local rows={}; local rowConnections={}
	local function open(v) opened=v; panel.Visible=v; U.Tween(arrow,{Rotation=v and 180 or 0},t); U.Tween(c.Frame,{Size=UDim2.new(1,-2,0,v and 330 or 128)},t) end
	c.Apply=function(v)
		assert(v==nil or table.find(values,v),'Dropdown value must be an option')
		c.Value=v; b.Text=v and tostring(v) or 'Select'
	end
	function c:SetOptions(newValues)
		for _,connection in ipairs(rowConnections) do connection:Disconnect() end; table.clear(rowConnections)
		for _,row in ipairs(rows) do row:Destroy() end; table.clear(rows)
		values=table.clone(newValues)
		for i,v in ipairs(values) do
			assert(type(v)=='string','Dropdown options must be strings')
			local row=U.Button(list,v,t); row.LayoutOrder=i; row.Size=UDim2.new(1,-6,0,38); table.insert(rows,row)
			row.Visible=string.find(string.lower(v),string.lower(search.Text),1,true)~=nil
			table.insert(rowConnections,U.Connect(w,row.Activated,function() c:Set(v); open(false) end))
		end
		if c.Value and not table.find(values,c.Value) then c:Set(nil) end
	end
	U.Connect(w,b.Activated,function() open(not opened) end)
	U.Connect(w,search:GetPropertyChangedSignal('Text'),function()
		for _,row in ipairs(rows) do row.Visible=string.find(string.lower(row.Text),string.lower(search.Text),1,true)~=nil end
	end)
	c:SetOptions(o.Options or {}); c:Set(o.Default,true); return c
end
function Elements.Button(tab,o)
	o=o or {}; local c,w,t,title=base(tab,o,80); title:Destroy()
	local b=U.Button(c.Frame,o.Name or 'Button',t); b.AnchorPoint=Vector2.new(.5,.5); b.Position=UDim2.fromScale(.5,.5); b.Size=UDim2.new(1,0,0,40); U.Stroke(b,t.Border); U.Hover(w,b)
	U.Connect(w,b.Activated,function()
		U.Callback(function() if not c.Dead and not w.Destroyed and o.Callback then o.Callback() end end)
	end); return c
end
function Elements.Textbox(tab,o)
	o=o or {}; local c,w,t=base(tab,o,124)
	local b=U.Input(c.Frame,o.Placeholder or 'Enter text...',t); b.Position=UDim2.fromOffset(0,40); b.Size=UDim2.new(1,0,0,40); U.Padding(b,12,0); U.Stroke(b,t.Border)
	c.Apply=function(v) c.Value=tostring(v or ''); b.Text=c.Value end
	U.Connect(w,b.FocusLost,function() c:Set(b.Text) end); c:Set(o.Default or '',true); return c
end
function Elements.ColorPicker(tab,o)
	o=o or {}; local c,w,t=base(tab,o,310)
	local h,s,v=0,1,1
	local preview=U.New('Frame',{Position=UDim2.new(1,-54,0,10),Size=UDim2.fromOffset(40,22),BorderSizePixel=0},c.Frame); U.Round(preview,5)
	local sv=U.Button(c.Frame,'',t); sv.Position=UDim2.fromOffset(14,42); sv.Size=UDim2.new(1,-76,0,155)
	local white=U.New('Frame',{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},sv); U.Round(white,8)
	U.New('UIGradient',{Transparency=NumberSequence.new(0,1)},white)
	local black=U.New('Frame',{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(),BorderSizePixel=0},sv); U.Round(black,8)
	U.New('UIGradient',{Rotation=90,Transparency=NumberSequence.new(1,0)},black)
	local marker=U.New('Frame',{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(10,10),BackgroundTransparency=1},sv); U.Round(marker,5); U.Stroke(marker,t.Text)
	local hue=U.Button(c.Frame,'',t); hue.Position=UDim2.new(1,-48,0,42); hue.Size=UDim2.fromOffset(32,155); hue.BackgroundColor3=Color3.new(1,1,1)
	local keys={}; for i=0,6 do table.insert(keys,ColorSequenceKeypoint.new(i/6,Color3.fromHSV(i/6,1,1))) end
	U.New('UIGradient',{Rotation=90,Color=ColorSequence.new(keys)},hue)
	local hueMark=U.New('Frame',{Size=UDim2.new(1,0,0,3),BackgroundColor3=t.Text,BorderSizePixel=0},hue)
	local inputs={}
	for i,name in ipairs({'R','G','B'}) do
		local input=U.Input(c.Frame,name,t); input.Position=UDim2.new((i-1)/3,14,0,216); input.Size=UDim2.new(1/3,-20,0,38); inputs[i]=input
		U.Connect(w,input.FocusLost,function()
			c:Set(Color3.fromRGB(math.clamp(tonumber(inputs[1].Text) or 0,0,255),math.clamp(tonumber(inputs[2].Text) or 0,0,255),math.clamp(tonumber(inputs[3].Text) or 0,0,255)))
		end)
	end
	local function draw(color)
		c.Value=color; preview.BackgroundColor3=color; sv.BackgroundColor3=Color3.fromHSV(h,1,1)
		marker.Position=UDim2.fromScale(s,1-v); hueMark.Position=UDim2.fromScale(0,h)
		inputs[1].Text=tostring(math.round(color.R*255)); inputs[2].Text=tostring(math.round(color.G*255)); inputs[3].Text=tostring(math.round(color.B*255))
	end
	c.Apply=function(color) assert(typeof(color)=='Color3','Expected Color3'); h,s,v=color:ToHSV(); draw(color) end
	U.Drag(w,sv,function(p)
		if c.Dead then return end
		s=math.clamp((p.X-sv.AbsolutePosition.X)/math.max(1,sv.AbsoluteSize.X),0,1); v=1-math.clamp((p.Y-sv.AbsolutePosition.Y)/math.max(1,sv.AbsoluteSize.Y),0,1)
		draw(Color3.fromHSV(h,s,v)); U.Callback(c.Callback,c.Value)
	end)
	U.Drag(w,hue,function(p)
		if c.Dead then return end
		h=math.clamp((p.Y-hue.AbsolutePosition.Y)/math.max(1,hue.AbsoluteSize.Y),0,1); draw(Color3.fromHSV(h,s,v)); U.Callback(c.Callback,c.Value)
	end)
	c:Set(o.Default or t.Accent,true); return c
end
return Elements
