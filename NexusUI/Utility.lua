local TweenService = game:GetService('TweenService')
local UserInputService = game:GetService('UserInputService')
local U = {}
function U.New(class, props, parent)
	local object = Instance.new(class)
	for key,value in pairs(props or {}) do object[key] = value end
	object.Parent = parent
	return object
end
function U.Round(object, radius)
	U.New('UICorner', {CornerRadius=UDim.new(0,radius or 8)}, object)
end
function U.Stroke(object, color)
	return U.New('UIStroke', {Color=color, Thickness=1, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, object)
end
function U.Tween(object, props, theme)
	local tween = TweenService:Create(object,TweenInfo.new(theme.Duration,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),props)
	tween:Play()
	return tween
end
function U.Text(parent, text, size, theme)
	return U.New('TextLabel',{BackgroundTransparency=1,Text=text or '',TextColor3=theme.Text,
		Font=theme.Font,TextSize=size or 13,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,0,0,20)},parent)
end
function U.Button(parent, text, theme)
	local b=U.New('TextButton',{AutoButtonColor=false,Text=text or '',Font=theme.Font,TextSize=13,
		TextColor3=theme.Text,BackgroundColor3=theme.Surface,BorderSizePixel=0,Size=UDim2.new(1,0,0,40)},parent)
	U.Round(b,theme.Radius)
	return b
end
function U.Input(parent, placeholder, theme)
	local b=U.New('TextBox',{ClearTextOnFocus=false,Text='',PlaceholderText=placeholder or '',
		PlaceholderColor3=theme.Muted,Font=theme.Font,TextSize=13,TextColor3=theme.Text,
		BackgroundColor3=theme.Surface,BorderSizePixel=0,Size=UDim2.new(1,0,0,38)},parent)
	U.Round(b,theme.Radius)
	return b
end
function U.Connect(window, signal, callback)
	local connection=signal:Connect(callback)
	table.insert(window.Connections,connection)
	return connection
end
function U.Callback(callback,...)
	if not callback then return end
	local args=table.pack(...)
	task.spawn(function()
		local ok,err=pcall(callback,table.unpack(args,1,args.n))
		if not ok then warn('[NexusUI] callback: '..tostring(err)) end
	end)
end
-- One input lifecycle for mouse and touch. Touch identity prevents multitouch jumps.
function U.Drag(window, target, callback)
	local active
	U.Connect(window,target.InputBegan,function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			active=input; callback(input.Position,true)
		end
	end)
	U.Connect(window,UserInputService.InputChanged,function(input)
		if active and (input==active or (active.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement)) then
			callback(input.Position,false)
		end
	end)
	U.Connect(window,UserInputService.InputEnded,function(input)
		if input==active then active=nil end
	end)
end
return U
