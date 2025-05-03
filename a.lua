--[[
    Modified Pepsi's UI Library
    Original library by Pepsi
    Modification: Removed configuration/designer window
    
    This modified version keeps the core functionality while removing the configuration interface.
]]

-- Local utility functions
local function Create(Class, Properties)
    local Object = Instance.new(Class)
    for Property, Value in next, Properties do
        if Property ~= "Parent" then
            Object[Property] = Value
        end
    end
    
    if Properties.Parent then
        Object.Parent = Properties.Parent
    end
    
    return Object
end

-- Localization for performance
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

-- Variables
local Library = {
    Version = "0.36 (Modified - Config Removed)",
    OpenFrames = {},
    Options = {},
    Themes = {
        Default = {
            Main = Color3.fromRGB(25, 25, 25),
            Background = Color3.fromRGB(20, 20, 20),
            OuterBorder = Color3.fromRGB(15, 15, 15),
            InnerBorder = Color3.fromRGB(10, 10, 10),
            TopGradient = Color3.fromRGB(35, 35, 35),
            BottomGradient = Color3.fromRGB(25, 25, 25),
            SectionBackground = Color3.fromRGB(20, 20, 20),
            Section = Color3.fromRGB(15, 15, 15),
            ElementText = Color3.fromRGB(175, 175, 175),
            OtherElementText = Color3.fromRGB(175, 175, 175),
            TabText = Color3.fromRGB(175, 175, 175),
            ElementBorder = Color3.fromRGB(10, 10, 10),
            SelectedOption = Color3.fromRGB(55, 55, 55),
            UnselectedOption = Color3.fromRGB(40, 40, 40),
            HoveredOptionTop = Color3.fromRGB(65, 65, 65),
            HoveredOptionBottom = Color3.fromRGB(45, 45, 45),
            UnhoveredOptionTop = Color3.fromRGB(55, 55, 55),
            UnhoveredOptionBottom = Color3.fromRGB(35, 35, 35)
        }
    },
    Flags = {},
    Theme = nil,
    KeybindList = {},
    Open = true
}

-- Utility functions
function Library:SafeCallback(f, ...)
    if f then
        local success, err = pcall(f, ...)
        if not success then
            return err
        end
    end
end

function Library:Round(number, float)
    return float * math.floor(number / float)
end

function Library:GetTextBounds(text, size, font)
    return TextService:GetTextSize(text, size, font, Vector2.new(math.huge, math.huge))
end

function Library:GetCenter(sizeX, sizeY)
    return UDim2.new(0.5, -(sizeX / 2), 0.5, -(sizeY / 2))
end

function Library:OpenWindow(window)
    Library.Open = true
    
    window.Frame.Visible = true
    
    -- Add the window to open frames
    if table.find(Library.OpenFrames, window) then
        return
    end
    
    table.insert(Library.OpenFrames, window)
end

function Library:CloseWindow(window)
    Library.Open = #Library.OpenFrames > 1
    
    -- Remove the window from open frames
    if table.find(Library.OpenFrames, window) then
        table.remove(Library.OpenFrames, table.find(Library.OpenFrames, window))
    end
    
    window.Frame.Visible = false
end

function Library:OnUnload(callback)
    Library.OnUnload = callback
end

function Library:Unload()
    -- Call user-provided callback
    if Library.OnUnload then
        Library:SafeCallback(Library.OnUnload)
    end
    
    -- Restore window focus
    UserInputService.MouseIconEnabled = true
    
    -- Delete UI
    for _, window in next, Library.OpenFrames do
        window.Frame:Destroy()
    end
    
    Library.OpenFrames = {}
end

function Library:CreateWindow(options)
    options = options or {}
    local name = options.Name or "Untitled Window"
    local theme = options.Theme or options.DefaultTheme or Library.Themes.Default
    
    Library.Theme = theme
    
    -- Main frame
    local windowFrame = Create("Frame", {
        Name = "Window",
        Size = UDim2.new(0, 550, 0, 600),
        BackgroundColor3 = theme.Background,
        BorderColor3 = theme.OuterBorder,
        Position = Library:GetCenter(550, 600),
        Parent = game:GetService("CoreGui"),
        Active = true,
        Draggable = true
    })
    
    -- Title bar
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = theme.Main,
        BorderSizePixel = 0,
        Parent = windowFrame
    })
    
    -- Title text
    local titleText = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = theme.ElementText,
        TextSize = 15,
        Font = Enum.Font.SourceSans,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })
    
    -- Close button
    local closeButton = Create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -30, 0, 0),
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = theme.ElementText,
        TextSize = 15,
        Font = Enum.Font.SourceSans,
        Parent = titleBar
    })
    
    closeButton.MouseButton1Click:Connect(function()
        Library:CloseWindow({Frame = windowFrame})
    end)
    
    -- Content container
    local contentFrame = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Parent = windowFrame
    })
    
    -- Tab container
    local tabContainer = Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = theme.Section,
        BorderSizePixel = 0,
        Parent = contentFrame
    })
    
    -- Tab content container
    local tabContentContainer = Create("Frame", {
        Name = "TabContent",
        Size = UDim2.new(1, 0, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Parent = contentFrame
    })
    
    local window = {
        Frame = windowFrame,
        Tabs = {},
        ActiveTab = nil,
        Options = options
    }
    
    -- Add window to open frames
    table.insert(Library.OpenFrames, window)
    
    -- Window methods
    function window:CreateTab(options)
        options = options or {}
        local tabName = options.Name or "Tab"
        local tabImage = options.Image
        
        -- Create tab button
        local tabButtonX = 10 + (#self.Tabs * 100)
        local tabButton = Create("TextButton", {
            Name = tabName,
            Size = UDim2.new(0, 100, 1, 0),
            Position = UDim2.new(0, tabButtonX, 0, 0),
            BackgroundColor3 = theme.Main,
            BorderSizePixel = 0,
            Text = tabName,
            TextColor3 = theme.TabText,
            TextSize = 14,
            Font = Enum.Font.SourceSans,
            Parent = tabContainer
        })
        
        -- Tab content frame
        local tabContentFrame = Create("ScrollingFrame", {
            Name = tabName .. "Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = theme.Section,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = tabContentContainer,
            Visible = false
        })
        
        -- Left and right columns
        local leftColumn = Create("Frame", {
            Name = "LeftColumn",
            Size = UDim2.new(0.5, -10, 1, 0),
            Position = UDim2.new(0, 5, 0, 5),
            BackgroundTransparency = 1,
            Parent = tabContentFrame
        })
        
        local rightColumn = Create("Frame", {
            Name = "RightColumn",
            Size = UDim2.new(0.5, -10, 1, 0),
            Position = UDim2.new(0.5, 5, 0, 5),
            BackgroundTransparency = 1,
            Parent = tabContentFrame
        })
        
        local tab = {
            Button = tabButton,
            Container = tabContentFrame,
            Sections = {},
            Columns = {
                Left = leftColumn,
                Right = rightColumn
            }
        }
        
        table.insert(self.Tabs, tab)
        
        -- Set active tab if it's the first one
        if #self.Tabs == 1 then
            self.ActiveTab = tab
            tab.Container.Visible = true
            tab.Button.BackgroundColor3 = theme.SelectedOption
        end
        
        -- Handle tab button click
        tabButton.MouseButton1Click:Connect(function()
            -- Deactivate current tab
            if self.ActiveTab then
                self.ActiveTab.Container.Visible = false
                self.ActiveTab.Button.BackgroundColor3 = theme.Main
            end
            
            -- Activate clicked tab
            self.ActiveTab = tab
            tab.Container.Visible = true
            tab.Button.BackgroundColor3 = theme.SelectedOption
        end)
        
        -- Tab methods
        function tab:CreateSection(options)
            options = options or {}
            local sectionName = options.Name or "Section"
            local sectionSide = (options.Side and string.lower(options.Side)) or "left"
            
            local sectionColumn = string.lower(sectionSide) == "right" and self.Columns.Right or self.Columns.Left
            
            -- Calculate Y position based on existing sections
            local yPos = 0
            for _, section in ipairs(self.Sections) do
                if section.Container.Parent == sectionColumn then
                    yPos = yPos + section.Container.Size.Y.Offset + 10
                end
            end
            
            -- Create section container
            local sectionFrame = Create("Frame", {
                Name = sectionName,
                Size = UDim2.new(1, 0, 0, 30),  -- Initial height, will be resized as elements are added
                Position = UDim2.new(0, 0, 0, yPos),
                BackgroundColor3 = theme.SectionBackground,
                BorderColor3 = theme.Section,
                Parent = sectionColumn
            })
            
            -- Section title
            local sectionTitle = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -10, 0, 25),
                Position = UDim2.new(0, 5, 0, 2),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = theme.ElementText,
                TextSize = 15,
                Font = Enum.Font.SourceSans,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sectionFrame
            })
            
            -- Create content container
            local contentContainer = Create("Frame", {
                Name = "Content",
                Size = UDim2.new(1, -10, 1, -30),
                Position = UDim2.new(0, 5, 0, 30),
                BackgroundTransparency = 1,
                Parent = sectionFrame
            })
            
            local section = {
                Container = sectionFrame,
                ContentContainer = contentContainer,
                Name = sectionName,
                Parent = tab,
                Offset = 0
            }
            
            table.insert(self.Sections, section)
            
            -- Update tab canvas size
            local function updateCanvasSize()
                local leftHeight = 0
                local rightHeight = 0
                
                for _, section in ipairs(self.Sections) do
                    local height = section.Container.Position.Y.Offset + section.Container.Size.Y.Offset
                    
                    if section.Container.Parent == self.Columns.Left then
                        leftHeight = math.max(leftHeight, height)
                    else
                        rightHeight = math.max(rightHeight, height)
                    end
                end
                
                self.Container.CanvasSize = UDim2.new(0, 0, 0, math.max(leftHeight, rightHeight) + 10)
            end
            
            -- Section methods
            function section:AddLabel(options)
                options = options or {}
                local labelText = options.Text or options.Value or options.Name or "Label"
                local flag = options.Flag
                
                -- Create label
                local label = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 25),
                    Position = UDim2.new(0, 0, 0, self.Offset),
                    BackgroundTransparency = 1,
                    Text = labelText,
                    TextColor3 = theme.ElementText,
                    TextSize = 14,
                    Font = Enum.Font.SourceSans,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = self.ContentContainer
                })
                
                -- Update section height
                self.Offset = self.Offset + 25
                self.Container.Size = UDim2.new(1, 0, 0, self.Offset + 30)
                updateCanvasSize()
                
                -- Label object
                local labelObj = {
                    Options = options,
                    Name = options.Name or labelText,
                    Type = "Label",
                    Default = labelText,
                    Parent = self,
                    Instance = label
                }
                
                -- Set up flag if provided
                if flag then
                    Library.Flags[flag] = labelText
                    Library.Options[flag] = labelObj
                end
                
                -- Label methods
                function labelObj:Set(text)
                    labelText = text
                    label.Text = text
                    
                    if flag then
                        Library.Flags[flag] = text
                    end
                    
                    return text
                end
                
                labelObj.RawSet = labelObj.Set
                
                function labelObj:Reset()
                    return labelObj:Set(self.Default)
                end
                
                function labelObj:Get()
                    return labelText
                end
                
                labelObj.Update = labelObj.Get
                
                return labelObj
            end
            
            function section:AddToggle(options)
                options = options or {}
                local toggleName = options.Name or "Toggle"
                local toggleValue = options.Value or options.Enabled or false
                local callback = options.Callback
                local flag = options.Flag
                
                -- Create toggle container
                local toggleContainer = Create("Frame", {
                    Name = "Toggle",
                    Size = UDim2.new(1, 0, 0, 25),
                    Position = UDim2.new(0, 0, 0, self.Offset),
                    BackgroundTransparency = 1,
                    Parent = self.ContentContainer
                })
                
                -- Toggle label
                local toggleLabel = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = toggleName,
                    TextColor3 = theme.ElementText,
                    TextSize = 14,
                    Font = Enum.Font.SourceSans,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggleContainer
                })
                
                -- Toggle box
                local toggleBox = Create("Frame", {
                    Name = "Box",
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -25, 0, 3),
                    BackgroundColor3 = toggleValue and theme.SelectedOption or theme.UnselectedOption,
                    BorderColor3 = theme.ElementBorder,
                    Parent = toggleContainer
                })
                
                -- Toggle indicator
                local toggleIndicator = Create("Frame", {
                    Name = "Indicator",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 2, 0, 2),
                    BackgroundColor3 = theme.Main,
                    BorderSizePixel = 0,
                    Visible = toggleValue,
                    Parent = toggleBox
                })
                
                -- Create button to handle click
                local toggleButton = Create("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = toggleContainer
                })
                
                -- Update section height
                self.Offset = self.Offset + 30
                self.Container.Size = UDim2.new(1, 0, 0, self.Offset + 30)
                updateCanvasSize()
                
                -- Toggle object
                local toggleObj = {
                    Options = options,
                    Name = toggleName,
                    Type = "Toggle",
                    Default = toggleValue,
                    Parent = self,
                    Instance = toggleContainer
                }
                
                -- Set up flag if provided
                if flag then
                    Library.Flags[flag] = toggleValue
                    Library.Options[flag] = toggleObj
                end
                
                -- Handle toggle click
                toggleButton.MouseButton1Click:Connect(function()
                    if options.Locked then
                        return
                    end
                    
                    toggleValue = not toggleValue
                    toggleIndicator.Visible = toggleValue
                    toggleBox.BackgroundColor3 = toggleValue and theme.SelectedOption or theme.UnselectedOption
                    
                    if flag then
                        Library.Flags[flag] = toggleValue
                    end
                    
                    Library:SafeCallback(callback, toggleValue)
                end)
                
                -- Toggle methods
                function toggleObj:Set(value)
                    local oldValue = toggleValue
                    toggleValue = value
                    toggleIndicator.Visible = value
                    toggleBox.BackgroundColor3 = value and theme.SelectedOption or theme.UnselectedOption
                    
                    if flag then
                        Library.Flags[flag] = value
                    end
                    
                    if options.AllowDuplicateCalls or value ~= oldValue then
                        Library:SafeCallback(callback, value, oldValue)
                    end
                    
                    return value
                end
                
                function toggleObj:RawSet(value, condition)
                    if condition ~= false then
                        return self:Set(value)
                    end
                    
                    toggleValue = value
                    toggleIndicator.Visible = value
                    toggleBox.BackgroundColor3 = value and theme.SelectedOption or theme.UnselectedOption
                    
                    if flag then
                        Library.Flags[flag] = value
                    end
                    
                    return value
                end
                
                function toggleObj:Reset()
                    return self:Set(self.Default)
                end
                
                function toggleObj:Get()
                    return toggleValue
                end
                
                toggleObj.Update = toggleObj.Get
                
                function toggleObj:SetLocked(lockedState)
                    options.Locked = lockedState
                    return lockedState
                end
                
                function toggleObj:Lock()
                    return self:SetLocked(true)
                end
                
                function toggleObj:Unlock()
                    return self:SetLocked(false)
                end
                
                function toggleObj:SetCondition(condition)
                    options.Condition = condition
                    return condition
                end
                
                return toggleObj
            end
            
            function section:AddButton(options)
                options = options or {}
                local buttonName = options.Name or "Button"
                local callback = options.Callback or function() end
                
                -- Create button container
                local buttonContainer = Create("Frame", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 0, 25),
                    Position = UDim2.new(0, 0, 0, self.Offset),
                    BackgroundTransparency = 1,
                    Parent = self.ContentContainer
                })
                
                -- Button
                local button = Create("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = theme.Main,
                    BorderColor3 = theme.ElementBorder,
                    Text = buttonName,
                    TextColor3 = theme.ElementText,
                    TextSize = 14,
                    Font = Enum.Font.SourceSans,
                    Parent = buttonContainer
                })
                
                -- Update section height
                self.Offset = self.Offset + 30
                self.Container.Size = UDim2.new(1, 0, 0, self.Offset + 30)
                updateCanvasSize()
                
                -- Button object
                local buttonObj = {
                    Options = options,
                    Name = buttonName,
                    Type = "Button",
                    Parent = self,
                    Instance = buttonContainer,
                    PressCount = 0
                }
                
                -- Handle button click
                local function press(...)
                    if options.Locked then
                        return
                    end
                    
                    if options.Condition then
                        if not options.Condition(buttonObj.PressCount) then
                            return
                        end
                    end
                    
                    buttonObj.PressCount = buttonObj.PressCount + 1
                    
                    Library:SafeCallback(callback, buttonObj.PressCount, ...)
                end
                
                button.MouseButton1Click:Connect(press)
                
                -- Button methods
                function buttonObj:Press(...)
                    press(...)
                end
                
                function buttonObj:RawPress(...)
                    if options.Locked then
                        return
                    end
                    
                    if options.Condition then
                        if not options.Condition(buttonObj.PressCount) then
                            return
                        end
                    end
                    
                    Library:SafeCallback(callback, buttonObj.PressCount, ...)
                end
                
                function buttonObj:SetLocked(lockedState)
                    options.Locked = lockedState
                    return lockedState
                end
                
                function buttonObj:Lock()
                    return self:SetLocked(true)
                end
                
                function buttonObj:Unlock()
                    return self:SetLocked(false)
                end
                
                function buttonObj:SetCondition(condition)
                    options.Condition = condition
                    return condition
                end
                
                function buttonObj:Get()
                    return callback, self.PressCount
                end
                
                function buttonObj:SetText(text)
                    button.Text = text
                    return text
                end
                
                function buttonObj:SetCallback(cb)
                    callback = cb
                    return cb
                end
                
                function buttonObj:Update()
                    return buttonName
                end
                
                return buttonObj
            end
            
            function section:AddSlider(options)
                options = options or {}
                local sliderName = options.Name or "Slider"
                local sliderMin = options.Min or 0
                local sliderMax = options.Max or 100
                local sliderValue = options.Value or sliderMin
                local sliderDecimals = options.Decimals or options.Precision or options.Precise or 0
                local sliderFormat = options.Format or "%s"
                local callback = options.Callback
                local flag = options.Flag
                
                -- Validate value
                sliderValue = math.clamp(sliderValue, sliderMin, sliderMax)
                
                -- Create slider container
                local sliderContainer = Create("Frame", {
                    Name = "Slider",
                    Size = UDim2.new(1, 0, 0, 45),
                    Position = UDim2.new(0, 0, 0, self.Offset),
                    BackgroundTransparency = 1,
                    Parent = self.ContentContainer
                })
                
                -- Slider label and value
                local sliderLabel = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = sliderName,
                    TextColor3 = theme.ElementText,
                    TextSize = 14,
                    Font = Enum.Font.SourceSans,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = sliderContainer
                })
                
                local sliderValueLabel = Create("TextLabel", {
                    Name = "Value",
                    Size = UDim2.new(0, 50, 0, 20),
                    Position = UDim2.new(1, -50, 0, 0),
                    BackgroundTransparency = 1,
                    Text = string.format(sliderFormat, sliderValue),
                    TextColor3 = theme.ElementText,
                    TextSize = 14,
                    Font = Enum.Font.SourceSans,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = sliderContainer
                })
                
                -- Slider bar
                local sliderBar = Create("Frame", {
                    Name = "Bar",
                    Size = UDim2.new(1, 0, 0, 10),
                    Position = UDim2.new(0, 0, 0, 25),
                    BackgroundColor3 = theme.UnselectedOption,
                    BorderColor3 = theme.ElementBorder,
                    Parent = sliderContainer
                })
                
                -- Slider fill
                local sliderFill = Create("Frame", {
                    Name = "Fill",
                    Size = UDim2.new((sliderValue - sliderMin) / (sliderMax - sliderMin), 0, 1, 0),
                    BackgroundColor3 = theme.SelectedOption,
                    BorderSizePixel = 0,
                    Parent = sliderBar
                })
                
                -- Create button to handle interactions
                local sliderButton = Create("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = sliderBar
                })
                
                -- Update section height
                self.Offset = self.Offset + 50
                self.Container.Size = UDim2.new(1, 0, 0, self.Offset + 30)
                updateCanvasSize()
                
                -- Function to update slider value based on mouse position
                local function updateSlider(input)
                    local relativePos = input.Position.X - sliderBar.AbsolutePosition.X
                    local percent = math.clamp(relativePos / sliderBar.AbsoluteSize.X, 0, 1)
                    local value = sliderMin + (sliderMax - sliderMin) * percent
                    
                    -- Round to decimals
                    if sliderDecimals > 0 then
                        local factor = 10 ^ sliderDecimals
                        value = math.floor(value * factor + 0.5) / factor
                    else
                        value = math.floor(value + 0.5)
                    end
                    
                    -- Update UI
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    sliderValueLabel.Text = string.format(sliderFormat, value)
                    
                    -- Update value
                    if value ~= sliderValue then
                        local oldValue = sliderValue
                        sliderValue = value
                        
                        if flag then
                            Library.Flags[flag] = value
                        end
                        
                        Library:SafeCallback(callback, value, oldValue)
                    end
                end
                
                -- Handle slider interactions
                sliderButton.MouseButton1Down:Connect(function()
                    local mouseConnection
                    local inputEndedConnection
                    
                    mouseConnection = Mouse.Move:Connect(function()
                        updateSlider({Position = Vector2.new(Mouse.X, Mouse.Y)})
                    end)
                    
                    inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            if mouseConnection then
                                mouseConnection:Disconnect()
                            end
                            
                            if inputEndedConnection then
                                inputEndedConnection:Disconnect()
                            end
                        end
                    end)
                    
                    updateSlider({Position = Vector2.new(Mouse.X, Mouse.Y)})
                end)
                
                -- Slider object
                local sliderObj = {
                    Options = options,
                    Name = sliderName,
                    Type = "Slider",
                    Default = sliderValue,
                    Parent = self,
                    Instance = sliderContainer
                }
                
                -- Set up flag if provided
                if flag then
                    Library.Flags[flag] = sliderValue
                    Library.Options[flag] = sliderObj
                end
                
                -- Slider methods
                function sliderObj:Set(value)
                    local oldValue = sliderValue
                    
                    value = math.clamp(value, sliderMin, sliderMax)
                    
                    -- Round to decimals
                    if sliderDecimals > 0 then
                        local factor = 10 ^ sliderDecimals
                        value = math.floor(value * factor + 0.5) / factor
                    else
                        value = math.floor(value + 0.5)
                    end
                    
                    -- Update UI
                    local percent = (value - sliderMin) / (sliderMax - sliderMin)
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    sliderValueLabel.Text = string.format(sliderFormat, value)
                    
                    -- Update value
                    sliderValue = value
                    
                    if flag then
                        Library.Flags[flag] = value
                    end
                    
                    if options.AllowDuplicateCalls or value ~= oldValue then
                        Library:SafeCallback(callback, value, oldValue)
                    end
                    
                    return value
                end
                
                function sliderObj:RawSet(value)
                    value = math.clamp(value, sliderMin, sliderMax)
                    
                    if sliderDecimals > 0 then
                        local factor = 10 ^ sliderDecimals
                        value = math.floor(value * factor + 0.5) / factor
                    else
                        value = math.floor(value + 0.5)
                    end
                    
                    local percent = (value - sliderMin) / (sliderMax - sliderMin)
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    sliderValueLabel.Text = string.format(sliderFormat, value)
                    
                    sliderValue = value
                    
                    if flag then
                        Library.Flags[flag] = value
                    end
                    
                    return value
                end
                
                function sliderObj:Reset()
                    return self:Set(self.Default)
                end
                
                function sliderObj:Get()
                    return sliderValue
                end
                
                function sliderObj:SetConstraints(min, max)
                    sliderMin = min
                    sliderMax = max
                    
                    sliderValue = math.clamp(sliderValue, min, max)
                    self:Set(sliderValue)
                end
                
                function sliderObj:SetMin(min)
                    self:SetConstraints(min, sliderMax)
                end
                
                function sliderObj:SetMax(max)
                    self:SetConstraints(sliderMin, max)
                end
                
                function sliderObj:Update()
                    return sliderValue
                end
                
                return sliderObj
            end
            
            function section:AddDropdown(options)
                options = options or {}
                local dropdownName = options.Name or "Dropdown"
                local dropdownValues = options.Values or options.Items or {}
                local dropdownValue = options.Value or dropdownValues[1] or ""
                local callback = options.Callback
                local flag = options.Flag
                local multi = options.Multi or false
                
                -- Create dropdown container
                local dropdownContainer = Create("Frame", {
                    Name = "Dropdown",
                    Size = UDim2.new(1, 0, 0, 40),
                    Position = UDim2.new(0, 0, 0, self.Offset),
                    BackgroundTransparency = 1,
                    Parent = self.ContentContainer
                })
                
                -- Dropdown label
                local dropdownLabel = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = dropdownName,
                    TextColor3 = theme.ElementText,
                    TextSize = 14,
                    Font = Enum.Font.SourceSans,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = dropdownContainer
                })
                
                -- Dropdown button
                local dropdownButton = Create("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = theme.Main,
                    BorderColor3 = theme.ElementBorder,
                    Text = multi and "Select..." or tostring(dropdownValue),
                    TextColor3 = theme.ElementText,
                    TextSize = 14,
                    Font = Enum.Font.SourceSans,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ClipsDescendants = true,
                    Parent = dropdownContainer
                })
                
                -- Dropdown icon
                local dropdownIcon = Create("TextLabel", {
                    Name = "Icon",
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = theme.ElementText,
                    TextSize = 14,
                    Font = Enum.Font.SourceSans,
                    Parent = dropdownButton
                })
                
                -- Dropdown list
                local dropdownList = Create("Frame", {
                    Name = "List",
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = theme.SectionBackground,
                    BorderColor3 = theme.ElementBorder,
                    Visible = false,
                    ZIndex = 5,
                    Parent = dropdownButton
                })
                
                -- Dropdown list layout
                local dropdownListLayout = Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = dropdownList
                })
                
                -- Update section height
                self.Offset = self.Offset + 45
                self.Container.Size = UDim2.new(1, 0, 0, self.Offset + 30)
                updateCanvasSize()
                
                -- Create option buttons
                local function createOptions()
                    -- Clear existing options
                    for _, child in ipairs(dropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Determine list height
                    local listHeight = math.min(#dropdownValues * 20, 100)
                    dropdownList.Size = UDim2.new(1, 0, 0, listHeight)
                    
                    -- Create scroll frame if needed
                    local optionContainer = dropdownList
                    if #dropdownValues * 20 > 100 then
                        local scrollFrame = Create("ScrollingFrame", {
                            Size = UDim2.new(1, 0, 1, 0),
                            CanvasSize = UDim2.new(1, 0, 0, #dropdownValues * 20),
                            BackgroundTransparency = 1,
                            ScrollBarThickness = 4,
                            Parent = dropdownList,
                            ZIndex = 6
                        })
                        
                        Create("UIListLayout", {
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            Parent = scrollFrame
                        })
                        
                        optionContainer = scrollFrame
                    end
                    
                    -- Add option buttons
                    for i, value in ipairs(dropdownValues) do
                        local optionButton = Create("TextButton", {
                            Size = UDim2.new(1, 0, 0, 20),
                            BackgroundColor3 = theme.Main,
                            BorderSizePixel = 0,
                            Text = tostring(value),
                            TextColor3 = theme.ElementText,
                            TextSize = 14,
                            Font = Enum.Font.SourceSans,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 6,
                            Parent = optionContainer
                        })
                        
                        -- Handle option click
                        optionButton.MouseButton1Click:Connect(function()
                            if multi then
                                -- Toggle value in multi-select
                                if table.find(dropdownValue, value) then
                                    table.remove(dropdownValue, table.find(dropdownValue, value))
                                else
                                    table.insert(dropdownValue, value)
                                end
                                
                                -- Update text
                                if #dropdownValue == 0 then
                                    dropdownButton.Text = "Select..."
                                else
                                    local displayText = ""
                                    for i, val in ipairs(dropdownValue) do
                                        if i > 1 then
                                            displayText = displayText .. ", "
                                        end
                                        displayText = displayText .. tostring(val)
                                    end
                                    dropdownButton.Text = displayText
                                end
                            else
                                -- Set value in single-select
                                if dropdownValue ~= value then
                                    local oldValue = dropdownValue
                                    dropdownValue = value
                                    dropdownButton.Text = tostring(value)
                                    
                                    if flag then
                                        Library.Flags[flag] = value
                                    end
                                    
                                    Library:SafeCallback(callback, value, oldValue)
                                end
                                
                                -- Close dropdown
                                dropdownList.Visible = false
                                dropdownIcon.Text = "▼"
                            end
                        end)
                    end
                end
                
                -- Create initial options
                createOptions()
                
                -- Handle dropdown button click
                dropdownButton.MouseButton1Click:Connect(function()
                    dropdownList.Visible = not dropdownList.Visible
                    dropdownIcon.Text = dropdownList.Visible and "▲" or "▼"
                    
                    -- Hide when clicking elsewhere
                    if dropdownList.Visible then
                        local hideDropdown
                        hideDropdown = UserInputService.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                local isInDropdown = false
                                for _, obj in next, {dropdownButton, dropdownList} do
                                    if input.Position.X >= obj.AbsolutePosition.X and 
                                       input.Position.X <= obj.AbsolutePosition.X + obj.AbsoluteSize.X and 
                                       input.Position.Y >= obj.AbsolutePosition.Y and 
                                       input.Position.Y <= obj.AbsolutePosition.Y + obj.AbsoluteSize.Y then
                                        isInDropdown = true
                                        break
                                    end
                                end
                                
                                if not isInDropdown then
                                    dropdownList.Visible = false
                                    dropdownIcon.Text = "▼"
                                    hideDropdown:Disconnect()
                                end
                            end
                        end)
                    end
                end)
                
                -- Dropdown object
                local dropdownObj = {
                    Options = options,
                    Name = dropdownName,
                    Type = "Dropdown",
                    Default = multi and (dropdownValue and table.clone(dropdownValue) or {}) or dropdownValue,
                    Parent = self,
                    Instance = dropdownContainer
                }
                
                -- Set up flag if provided
                if flag then
                    Library.Flags[flag] = dropdownValue
                    Library.Options[flag] = dropdownObj
                end
                
                -- Dropdown methods
                function dropdownObj:Set(value)
                    local oldValue = dropdownValue
                    
                    if multi then
                        -- Handle multi-select
                        if type(value) ~= "table" then
                            value = {value}
                        end
                        
                        dropdownValue = value
                        
                        -- Update text
                        if #value == 0 then
                            dropdownButton.Text = "Select..."
                        else
                            local displayText = ""
                            for i, val in ipairs(value) do
                                if i > 1 then
                                    displayText = displayText .. ", "
                                end
                                displayText = displayText .. tostring(val)
                            end
                            dropdownButton.Text = displayText
                        end
                    else
                        -- Handle single-select
                        if table.find(dropdownValues, value) then
                            dropdownValue = value
                            dropdownButton.Text = tostring(value)
                        end
                    end
                    
                    if flag then
                        Library.Flags[flag] = dropdownValue
                    end
                    
                    if options.AllowDuplicateCalls or oldValue ~= dropdownValue then
                        Library:SafeCallback(callback, dropdownValue, oldValue)
                    end
                    
                    return dropdownValue
                end
                
                function dropdownObj:RawSet(value)
                    if multi then
                        -- Handle multi-select
                        if type(value) ~= "table" then
                            value = {value}
                        end
                        
                        dropdownValue = value
                        
                        -- Update text
                        if #value == 0 then
                            dropdownButton.Text = "Select..."
                        else
                            local displayText = ""
                            for i, val in ipairs(value) do
                                if i > 1 then
                                    displayText = displayText .. ", "
                                end
                                displayText = displayText .. tostring(val)
                            end
                            dropdownButton.Text = displayText
                        end
                    else
                        -- Handle single-select
                        if table.find(dropdownValues, value) then
                            dropdownValue = value
                            dropdownButton.Text = tostring(value)
                        end
                    end
                    
                    if flag then
                        Library.Flags[flag] = dropdownValue
                    end
                    
                    return dropdownValue
                end
                
                function dropdownObj:Reset()
                    return self:Set(self.Default)
                end
                
                function dropdownObj:Get()
                    return dropdownValue
                end
                
                function dropdownObj:SetValues(values)
                    dropdownValues = values
                    
                    -- Update dropdown value
                    if not multi and not table.find(values, dropdownValue) then
                        dropdownValue = values[1] or ""
                        dropdownButton.Text = tostring(dropdownValue)
                        
                        if flag then
                            Library.Flags[flag] = dropdownValue
                        end
                    elseif multi then
                        local newValues = {}
                        for _, v in next, dropdownValue do
                            if table.find(values, v) then
                                table.insert(newValues, v)
                            end
                        end
                        
                        dropdownValue = newValues
                        
                        if #newValues == 0 then
                            dropdownButton.Text = "Select..."
                        else
                            local displayText = ""
                            for i, val in ipairs(newValues) do
                                if i > 1 then
                                    displayText = displayText .. ", "
                                end
                                displayText = displayText .. tostring(val)
                            end
                            dropdownButton.Text = displayText
                        end
                        
                        if flag then
                            Library.Flags[flag] = dropdownValue
                        end
                    end
                    
                    -- Recreate options
                    createOptions()
                    
                    return dropdownValues
                end
                
                function dropdownObj:AddValue(value)
                    if value == nil then
                        return
                    end
                    
                    if not table.find(dropdownValues, value) then
                        table.insert(dropdownValues, value)
                        createOptions()
                    end
                    
                    return value
                end
                
                function dropdownObj:RemoveValue(value)
                    if value == nil then
                        return
                    end
                    
                    local valueIndex = table.find(dropdownValues, value)
                    if valueIndex then
                        table.remove(dropdownValues, valueIndex)
                        
                        -- Update dropdown value
                        if not multi and dropdownValue == value then
                            dropdownValue = dropdownValues[1] or ""
                            dropdownButton.Text = tostring(dropdownValue)
                            
                            if flag then
                                Library.Flags[flag] = dropdownValue
                            end
                        elseif multi then
                            local valueIndex = table.find(dropdownValue, value)
                            if valueIndex then
                                table.remove(dropdownValue, valueIndex)
                                
                                if #dropdownValue == 0 then
                                    dropdownButton.Text = "Select..."
                                else
                                    local displayText = ""
                                    for i, val in ipairs(dropdownValue) do
                                        if i > 1 then
                                            displayText = displayText .. ", "
                                        end
                                        displayText = displayText .. tostring(val)
                                    end
                                    dropdownButton.Text = displayText
                                end
                                
                                if flag then
                                    Library.Flags[flag] = dropdownValue
                                end
                            end
                        end
                        
                        createOptions()
                    end
                    
                    return value
                end
                
                function dropdownObj:Update()
                    return dropdownValue
                end
                
                return dropdownObj
            end
            
            -- Add more element types here as needed
            
            return section
        end
        
        return tab
    end
    
    return window
end

-- Set up keybind handling
RunService.Heartbeat:Connect(function()
    for _, keybind in next, Library.KeybindList do
        local key = keybind.Key
        if key and key ~= "None" then
            if UserInputService:IsKeyDown(key) then
                if keybind.Mode == "Hold" and not keybind.Holding then
                    keybind.Holding = true
                    Library:SafeCallback(keybind.Callback, keybind.Key)
                elseif keybind.Mode == "Toggle" and not keybind.Toggled and not keybind.KeyDown then
                    keybind.Toggled = not keybind.Toggled
                    Library:SafeCallback(keybind.Callback, keybind.Toggled, keybind.Key)
                    keybind.KeyDown = true
                elseif keybind.Mode == "Dynamic" and not keybind.KeyDown then
                    Library:SafeCallback(keybind.Callback, true, keybind.Key)
                    Library:SafeCallback(keybind.DynamicCallback, true, keybind.Key)
                    keybind.KeyDown = true
                    keybind.LastPress = tick()
                end
            else
                if keybind.Mode == "Hold" and keybind.Holding then
                    keybind.Holding = false
                elseif keybind.Mode == "Dynamic" and keybind.KeyDown then
                    Library:SafeCallback(keybind.Callback, false, keybind.Key)
                    keybind.KeyDown = false
                    if tick() - keybind.LastPress <= keybind.DynamicTime then
                        Library:SafeCallback(keybind.DynamicCallback, false, keybind.Key)
                    end
                elseif keybind.Mode == "Toggle" and keybind.KeyDown then
                    keybind.KeyDown = false
                end
            end
        end
    end
end)

-- Return the library
return Library
