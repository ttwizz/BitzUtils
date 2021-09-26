--[[
	ModMenu Lib DOCS
	
	Settings
		> Theme
			> Main: COLOR3, defaults Color3.fromRGB(165, 96, 97)
			> Background: COLOR3, defaults Color3.fromRGB(0, 0, 0)
			> TextColor: COLOR3, defaults Color3.fromRGB(255, 255, 255)
		> WindowCount: Amount of windows
		> Draggable: BOOLEAN, whether the windows can be dragged or not
		> Keybind: Enum.KeyCode, used to toggle UI
	
	CreateMenu [params 1; settings]
		> Menu: ScreenGui
		> MenuSettings: Current settings for menu, refer to [Settings]
		> MenuOptions
			> CreateWindow [params 1, name]: Creates a new window, returns [Create Menu > MenuOptions > CreateWindow > WindowOptions]
				> WindowOptions
					> Toggles [table]: Currently enabled toggleables
					> Add [params 2, type, name]: Creates a new child under window, returns [Create Menu > MenuOptions > CreateWindow > WindowOptions > Add > ButtonOptions]
						> Name: Name of button
						> Style: Current style of button [toggleable, clickable]
						> Callback: Function called when button is clicked or toggled
	
	Callbacks [custom params]
		-> Default callback
				function(Type, Name, a)
					if Type == 'toggle' then
						print(Name..' is now toggled to; '..tostring(a))
					elseif Type == 'clickable' then
						print(Name..' was clicked')
					end
				end
		> Callbacks can be modified via [Create Menu > MenuOptions > CreateWindow > WindowOptions > Add > ButtonOptions > Callback]
	
	
	Contact Information
		> [DISCORD] Josh#0903
		
	To Note:
		> Draggable is buggy, don't ask me to fix that -> Do it yourself if you need a working one
		
	Example Script:
		> https://hastebin.com/jakibotohi.lua
--]]

local ModMenu = {}
local ModMenuDefaultSettings = {
	['Theme'] = {
		['Main'] = Color3.fromRGB(171, 71, 188),
		['Background'] = Color3.fromRGB(0, 0, 0),
		['TextColor'] = Color3.fromRGB(255, 255, 255)
	},
	['WindowCount'] = -1,
	['Draggable'] = true,
	['Keybind'] = Enum.KeyCode.F2
} -- Settings for UIs without [param [Settings]]

ModMenu.CreateMenu = function(Settings)
	if game:GetService'CoreGui':FindFirstChild'ModMenu' then
		error'ModMenu Lib: Menu already exists'
		return
	end
	local Menu = Instance.new'ScreenGui'
	Menu.Name = 'ModMenu'
    Menu.Parent = game:GetService'CoreGui'
    local RFrameGuis = {}
    local RTextLabels = {}
    local TKeys = {}
    local TGetKey = false
	local TGrabKey
    local CurrentColor = Color3.new()
    local function TableFind(tab,el)
        for index, value in pairs(tab) do
            if value == el then
                return index
            end
        end
    end
	local MenuSettings = ModMenuDefaultSettings
	if Settings then
		MenuSettings = Settings
	end
	local UpdateCallback = function() end
	local MenuOptions = {}
	local GlobalModules = {}
	local GlobalEmuModules = {}
	local GlobalEmuKeyBindModules = {}
    local AllowDrag = {}
    local EnableBlur = true
	MenuOptions.CreateWindow = function(Name)
		if not Menu:FindFirstChild'Windows' then
			local Windows = Instance.new'Frame'
			Windows.Name = "Windows"
			Windows.Parent = Menu
			Windows.BackgroundTransparency = 1
			Windows.Position = UDim2.new(0, 10, 0, 70)
			Windows.Size = UDim2.new(1, -20, 0, 0)
		end 
		if Name == 'Windows' then
			error'ModMenu Lib: Name not allowed'
			return
		end
		
		local LastPos = -1
		for _, v in next, Menu.Windows:GetChildren() do
			if v.Size.X.Offset > LastPos then
				LastPos = v.Position.X.Offset
			end
		end
		
		local NewWindow = Instance.new'Frame'
		local Title = Instance.new'TextLabel'
		local Title_2 = Instance.new'TextLabel'
		local Children = Instance.new'Frame'

		local UIS = game:GetService("UserInputService")
		local dragging
		local dragInput
		local dragStart
		local startPos

		local function update(input)
			local delta = input.Position - dragStart
			NewWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end

		NewWindow.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = NewWindow.Position
		
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		NewWindow.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)

		UIS.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
		
		NewWindow.Name = Name
		NewWindow.Parent = Menu:WaitForChild'Windows'
        NewWindow.BackgroundColor3 = MenuSettings.Theme.Main
        table.insert(RFrameGuis, NewWindow)
		NewWindow.BorderSizePixel = 0
		NewWindow.Size = UDim2.new(0, 150, 0, 25)
		NewWindow.Active = true

		Title.Name = "Title"
		Title.Parent = NewWindow
		Title.BackgroundColor3 = Color3.new(1, 1, 1)
		Title.BackgroundTransparency = 1
		Title.Size = UDim2.new(1, 0, 0.9, 0)
		Title.ZIndex = 3
		Title.Font = Enum.Font.SourceSans
		Title.Text = Name
		Title.TextColor3 = Color3.new(1, 1, 1)
		Title.TextSize = 17

		Title_2.Name = "bg"
		Title_2.Parent = Title
		Title_2.BackgroundColor3 = Color3.new(1, 1, 1)
		Title_2.BackgroundTransparency = 1
		Title_2.Position = UDim2.new(0, 1, 0, 1)
		Title_2.Size = UDim2.new(1, 0, 1, 0)
		Title_2.Font = Enum.Font.SourceSans
		Title_2.Text = Name
		Title_2.TextSize = 17
		Title_2.ZIndex = 2
		
		Children.Name = "Children"
		Children.Parent = NewWindow
		Children.BackgroundColor3 = Color3.new(0, 0, 0)
		Children.BackgroundTransparency = 0.5
		Children.BorderSizePixel = 0
		Children.Position = UDim2.new(0.015, 0, 1, 0)
		Children.Size = UDim2.new(0.97, 0, 0, 0)
		
		MenuSettings.WindowCount = MenuSettings.WindowCount + 1
		if MenuSettings.WindowCount > 1 then
			NewWindow.Position = UDim2.new(0, LastPos * MenuSettings.WindowCount, 0, 0)
		elseif MenuSettings.WindowCount == 1 then
			NewWindow.Position = UDim2.new(0, 155, 0, 0)
		end
		
		local WindowOptions = {}
		WindowOptions.Toggles = {}
		
		WindowOptions.Add = function(Type, Name)
			Type = string.lower(Type)
			if not NewWindow:FindFirstChild'Children' then
				error'ModMenu Lib: Children container not existent'
				return
			end
			Children.Size = UDim2.new(0.97, 0, Children.Size.Y.Scale + 1, 0)
			local LastPos = -1
			for _, v in next, Children:GetChildren() do
				if v.Size.Y.Offset > LastPos then
					LastPos = v.Position.Y.Offset
				end
			end				
				
			local Frame = Instance.new'TextButton'
			local TextLabel = Instance.new'TextLabel'
            local toggled = Instance.new'TextLabel'
            local tvar = false
			Frame.Name = "Frame"
			Frame.Active = false
			Frame.BackgroundTransparency = 1
			Frame.BorderSizePixel = 0
			Frame.Selectable = false
			Frame.Size = UDim2.new(0, 146, 0, 25)
			Frame.Text = ""
			Frame.TextTransparency = 1
				
			if LastPos == -1 then
				Frame.Position = UDim2.new(0, 0, 0, 0)
			else
				Frame.Position = UDim2.new(0, 0, 0, #Children:GetChildren() * 25)
			end
				
			Frame.Parent = NewWindow.Children

			TextLabel.Parent = Frame
			TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
			TextLabel.BackgroundTransparency = 1
			TextLabel.Position = UDim2.new(0.2, 0, 0, 0)
			TextLabel.Size = UDim2.new(0.8, 0, 0.9, 0)
			TextLabel.Font = Enum.Font.SourceSansBold
			TextLabel.Text = Name
			TextLabel.TextColor3 = Color3.new(1, 1, 1)
			TextLabel.TextSize = 14
			TextLabel.TextXAlignment = Enum.TextXAlignment.Left

			toggled.Name = "toggled"
			toggled.Parent = Frame
			toggled.BackgroundColor3 = Color3.new(1, 1, 1)
			toggled.BackgroundTransparency = 1
			toggled.Position = UDim2.new(0.075, 0, 0.03, 0)
			toggled.Size = UDim2.new(0.1, 0, 0.9, 0)
			toggled.Font = Enum.Font.SourceSansBold
			toggled.Text = ">"
            toggled.TextColor3 = MenuSettings.Theme.TextColor
			toggled.TextSize = 20
			toggled.TextXAlignment = Enum.TextXAlignment.Left
			toggled.Visible = true
				
			local ButtonOptions = {}
			ButtonOptions.Name = Name
			ButtonOptions.Style = Type
				
			-- Default callback
            ButtonOptions['Callback'] = function(Type, Name, a)
                --Nothing
			end
				
			-- maybe add more themes later idk
			if Type == 'toggle' then
				GlobalEmuModules[Name] = (function()
					GlobalModules[Name] = not tvar
                    WindowOptions.Toggles[Name] = not tvar
                    if WindowOptions.Toggles[Name] then
                        table.insert(RTextLabels, toggled)
                    else
                        table.remove(RTextLabels, TableFind(RTextLabels, toggled))
                    end
					tvar = WindowOptions.Toggles[Name]
					if WindowOptions.Toggles[Name] then
                        TextLabel.TextColor3 = CurrentColor
                        table.insert(RTextLabels, TextLabel)
					else
                        TextLabel.TextColor3 = MenuSettings.Theme.TextColor
                        toggled.TextColor3 = MenuSettings.Theme.TextColor
                        table.remove(RTextLabels, TableFind(RTextLabels, TextLabel))
					end
					UpdateCallback(GlobalModules)
					ButtonOptions['Callback'](Type, Name, WindowOptions.Toggles[Name])
                end)
				Frame.MouseButton1Click:connect(function()
					GlobalModules[Name] = not tvar
                    WindowOptions.Toggles[Name] = not tvar
                    if WindowOptions.Toggles[Name] then
                        table.insert(RTextLabels, toggled)
                    else
                        table.remove(RTextLabels, TableFind(RTextLabels, toggled))
                    end
					tvar = WindowOptions.Toggles[Name]
					if WindowOptions.Toggles[Name] then
                        TextLabel.TextColor3 = CurrentColor
                        table.insert(RTextLabels, TextLabel)
					else
                        TextLabel.TextColor3 = MenuSettings.Theme.TextColor
                        toggled.TextColor3 = MenuSettings.Theme.TextColor
                        table.remove(RTextLabels, TableFind(RTextLabels, TextLabel))
					end
					UpdateCallback(GlobalModules)
					ButtonOptions['Callback'](Type, Name, WindowOptions.Toggles[Name])
				end)
				GlobalEmuKeyBindModules[Name] = (function(KeyCode)
					TextLabel.Text = Name .. " [" .. KeyCode.Name .. "]"
					TKeys[Name] = 
					{
						Callback = function()
							GlobalModules[Name] = not tvar
							WindowOptions.Toggles[Name] = not tvar
							if WindowOptions.Toggles[Name] then
								table.insert(RTextLabels, toggled)
							else
								table.remove(RTextLabels, TableFind(RTextLabels, toggled))
							end
							tvar = WindowOptions.Toggles[Name]
							if WindowOptions.Toggles[Name] then
								TextLabel.TextColor3 = CurrentColor
								table.insert(RTextLabels, TextLabel)
							else
								TextLabel.TextColor3 = MenuSettings.Theme.TextColor
								toggled.TextColor3 = MenuSettings.Theme.TextColor
								table.remove(RTextLabels, TableFind(RTextLabels, TextLabel))
							end
							UpdateCallback(GlobalModules)
							ButtonOptions['Callback'](Type, Name, WindowOptions.Toggles[Name])
						end,
						Key = KeyCode
					}
                end)
                Frame.MouseButton2Click:connect(function()
					if TGetKey then 
						TKeys[Name] = nil
						TextLabel.Text = Name 
						TGrabKey = true
						TGetKey = false
						return
					end
                    TGetKey = true
                    TextLabel.Text = Name .. " [-]"
					while not TGrabKey do wait() end
					if TGrabKey == true then TGrabKey = nil TextLabel.Text = Name return end
					TKeys[Name] = 
					{
						Callback = function()
							GlobalModules[Name] = not tvar
							WindowOptions.Toggles[Name] = not tvar
							if WindowOptions.Toggles[Name] then
								table.insert(RTextLabels, toggled)
							else
								table.remove(RTextLabels, TableFind(RTextLabels, toggled))
							end
							tvar = WindowOptions.Toggles[Name]
							if WindowOptions.Toggles[Name] then
								TextLabel.TextColor3 = CurrentColor
								table.insert(RTextLabels, TextLabel)
							else
								TextLabel.TextColor3 = MenuSettings.Theme.TextColor
								toggled.TextColor3 = MenuSettings.Theme.TextColor
								table.remove(RTextLabels, TableFind(RTextLabels, TextLabel))
							end
							UpdateCallback(GlobalModules)
							ButtonOptions['Callback'](Type, Name, WindowOptions.Toggles[Name])
						end,
						Key = TGrabKey.KeyCode
					}
					TextLabel.Text = Name .. " [" .. TGrabKey.KeyCode.Name .. "]"
					TGrabKey = nil
					TGetKey = false
				end)
			elseif Type == 'clickable' then
                Frame.MouseButton1Click:connect(function()
                    ButtonOptions['Callback'](Type, Name)
                    spawn(function()
                        toggled.TextColor3 = CurrentColor
                        TextLabel.TextColor3 = CurrentColor
                        table.insert(RTextLabels, toggled)
                        table.insert(RTextLabels, TextLabel)
                        wait(0.5)
                        toggled.TextColor3 = MenuSettings.Theme.TextColor
                        TextLabel.TextColor3 = MenuSettings.Theme.TextColor
                        table.remove(RTextLabels, TableFind(RTextLabels, toggled))
                        table.remove(RTextLabels, TableFind(RTextLabels, TextLabel))
					end)
				end)
				GlobalEmuKeyBindModules[Name] = (function(KeyCode)
					TextLabel.Text = Name .. " [" .. KeyCode.Name .. "]"
					TKeys[Name] = 
					{
						Callback = function()
							ButtonOptions['Callback'](Type, Name)
							spawn(function()
								toggled.TextColor3 = CurrentColor
								TextLabel.TextColor3 = CurrentColor
								table.insert(RTextLabels, toggled)
								table.insert(RTextLabels, TextLabel)
								wait(0.5)
								toggled.TextColor3 = MenuSettings.Theme.TextColor
								TextLabel.TextColor3 = MenuSettings.Theme.TextColor
								table.remove(RTextLabels, TableFind(RTextLabels, toggled))
								table.remove(RTextLabels, TableFind(RTextLabels, TextLabel))
							end)
						end,
						Key = KeyCode
					}
                end)
				Frame.MouseButton2Click:connect(function()
					if TGetKey then 
						TKeys[Name] = nil
						TextLabel.Text = Name 
						TGrabKey = true
						TGetKey = false
						return
					end
                    TGetKey = true
                    TextLabel.Text = Name .. " [-]"
					while not TGrabKey do wait() end
					if TGrabKey == true then TGrabKey = nil TextLabel.Text = Name return end
					TKeys[Name] = 
					{
						Callback = function()
							ButtonOptions['Callback'](Type, Name)
							spawn(function()
								toggled.TextColor3 = CurrentColor
								TextLabel.TextColor3 = CurrentColor
								table.insert(RTextLabels, toggled)
								table.insert(RTextLabels, TextLabel)
								wait(0.5)
								toggled.TextColor3 = MenuSettings.Theme.TextColor
								TextLabel.TextColor3 = MenuSettings.Theme.TextColor
								table.remove(RTextLabels, TableFind(RTextLabels, toggled))
								table.remove(RTextLabels, TableFind(RTextLabels, TextLabel))
							end)
						end,
						Key = TGrabKey.KeyCode
					}
					TextLabel.Text = Name .. " [" .. TGrabKey.KeyCode.Name .. "]"
					TGrabKey = nil
					TGetKey = false
				end)
			end
			
			return ButtonOptions
		end
		return WindowOptions
	end
	
	local BlurEffect = Instance.new'BlurEffect'; BlurEffect.Parent = game:GetService'Lighting'
	local UserInputService = game:GetService'UserInputService'
    local Enabled = true
    
    local JBFrame = Instance.new("Frame")
    local JBTextLabel = Instance.new("TextLabel")
    local JBTextLabel_2 = Instance.new("TextLabel")

    JBFrame.Parent = Menu
    JBFrame.Active = true
    JBFrame.BackgroundTransparency = 1
    JBFrame.Position = UDim2.new(0, 2, 0, 2)
    JBFrame.Size = UDim2.new(0, 380, 0, 80)

    JBTextLabel.Parent = JBFrame
    JBTextLabel.Active = true
    JBTextLabel.TextStrokeTransparency = 0.75
    JBTextLabel.BackgroundTransparency = 1
    JBTextLabel.Position = UDim2.new(0, 10, 0, 0)
    JBTextLabel.Size = UDim2.new(0, 210, 0, 60)
    JBTextLabel.Font = Enum.Font.SourceSansLight
    JBTextLabel.Text = "jailbreakhaxx"
    JBTextLabel.TextSize = 48
    JBTextLabel.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(RTextLabels, JBTextLabel)

    JBTextLabel_2.Parent = JBFrame
    JBTextLabel_2.Active = true
    JBTextLabel_2.BackgroundTransparency = 1
    JBTextLabel_2.TextStrokeTransparency = 0.75
    JBTextLabel_2.BorderSizePixel = 0
    JBTextLabel_2.Position = UDim2.new(0, 220, 0, 10)
    JBTextLabel_2.Size = UDim2.new(0, 50, 0, 50)
    JBTextLabel_2.Font = Enum.Font.SourceSansLight
    JBTextLabel_2.Text = "v5.0-luau"
    JBTextLabel_2.TextColor3 = Color3.new(0.501961, 0.501961, 0.501961)
    JBTextLabel_2.TextSize = 24
    JBTextLabel_2.TextXAlignment = Enum.TextXAlignment.Left
    JBTextLabel_2.TextYAlignment = Enum.TextYAlignment.Bottom
 	
	UserInputService.InputBegan:connect(function(a, b)
        if a.UserInputType == Enum.UserInputType.Keyboard then
            if TGetKey then TGrabKey = a return end

			for I,V in pairs(TKeys) do
				if type(V) == "table" then
					if V["Key"] == a.KeyCode then
						V["Callback"]()
					end
				end
			end

			if a.KeyCode == MenuSettings.Keybind then
                Menu.Enabled = not Enabled
                if EnableBlur then
                    BlurEffect.Enabled = not Enabled
                else
                    BlurEffect.Enabled = false
                end
				Enabled = not Enabled
				for I,V in pairs(AllowDrag) do
					V.Draggable = Enabled
				end
				local StarterGui = game:GetService('StarterGui')
				if Enabled then
					StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
				else
					StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
				end
			end
		end
    end)
    
    spawn(function()
        while true do
            for i = 0, 1, 0.01 do
                if Enabled then
                    CurrentColor = Color3.fromHSV(i,1,1)
                    for i,v in pairs(RFrameGuis) do
                        v.BackgroundColor3 = CurrentColor
                    end
                    for i,v in pairs(RTextLabels) do
                        v.TextColor3 = CurrentColor
                    end
                end
                wait(0.1)
            end
        end
	end)
	
	function SetUpdateCallback(Call)
		UpdateCallback = Call
	end

	function AddAllowDrag(Element)
		table.insert(AllowDrag, Element)
	end

	function GetKeyBinds()
		return TKeys
	end

	function GetActive()
		return GlobalModules
	end

	function EmuToggle(Name)
		GlobalEmuModules[Name]()
	end

	function EmuKeyBind(Name, KeyCode)
		GlobalEmuKeyBindModules[Name](KeyCode)
    end
    
    function SetBlur(Value)
		EnableBlur = Value
		BlurEffect.Enabled = EnableBlur
    end
	
	return {
		['Menu'] = Menu, 
		['MenuSettings'] = MenuSettings, 
		['MenuOptions'] = MenuOptions,
		['SetUpdateCallback'] = SetUpdateCallback,
		['AddAllowDrag'] = AddAllowDrag,
		['GetKeyBinds'] = GetKeyBinds,
		['GetActive'] = GetActive,
		['EmulateToggle'] = EmuToggle,
        ['EmulateKeyBind'] = EmuKeyBind,
        ['SetBlur'] = SetBlur
	}
end

return ModMenu
