-- GUI Module (Reworked using Obsidian / Linoria-based UI Library)

local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer

local GUI = {}
GUI.Library = nil
GUI.Window = nil
GUI.IsOpen = true

function GUI:init(services, config, callbacks)
    config = config or {}
    callbacks = callbacks or {}

    -- 1. Load Obsidian Library & Addons
    local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
    local successLib, Library = pcall(function()
        return loadstring(game:HttpGet(repo .. "Library.lua"))()
    end)
    local successTheme, ThemeManager = pcall(function()
        return loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
    end)
    local successSave, SaveManager = pcall(function()
        return loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
    end)

    if not successLib or not Library then
        warn("[GUI] Failed to load Obsidian Library.")
        return
    end

    self.Library = Library

    -- 2. Create Window (Compact layout sized to neatly hold smaller dual columns)
    local Window = Library:CreateWindow({
        Title = "Blackhawk Rescue Mission 5 | by 9fallenone6",
        Footer = "Obsidian UI",
        Icon = 95816097006870,
        NotifySide = "Right",
        ShowCustomCursor = true,
        Size = UDim2.new(0, 410, 0, 300),
        Center = true,
        AutoShow = true,
        Resizable = false,
    })

    self.Window = Window

    -- 3. Construct Tabs
    local Tabs = {
        Main = Window:AddTab("Main", "user"),
        Settings = Window:AddTab("UI Settings", "settings"),
    }

    -- Groupboxes (Split side-by-side into Left and Right columns)
    local CombatGroup = Tabs.Main:AddLeftGroupbox("Combat", "sword")
    local WeaponsGroup = Tabs.Main:AddLeftGroupbox("Weapons", "crosshair")

    local VisualsGroup = Tabs.Main:AddRightGroupbox("Visuals & Lighting", "eye")
    local UtilitiesGroup = Tabs.Main:AddRightGroupbox("Menu & Utilities", "wrench")

    -- 4. Combat Elements
    CombatGroup:AddToggle("SilentTargetToggle", {
        Text = "Silent Target",
        Default = config.sizingEnabled or false,
        Callback = function(Value)
            if callbacks.onSizingToggle then callbacks.onSizingToggle(Value) end
        end
    })

    CombatGroup:AddToggle("ShowHitboxToggle", {
        Text = "Show HitBox",
        Default = config.showTargetBox or false,
        Callback = function(Value)
            if callbacks.onShowTargetBoxToggle then callbacks.onShowTargetBoxToggle(Value) end
        end
    })

    -- 5. Weapons Elements
    WeaponsGroup:AddToggle("NoRecoilToggle", {
        Text = "No Recoil",
        Default = (config.patchOptions and config.patchOptions.recoil) or false,
        Callback = function(Value)
            if callbacks.onStabilityToggle then callbacks.onStabilityToggle(Value) end
        end
    })

    WeaponsGroup:AddToggle("AllFiremodesToggle", {
        Text = "All Firemodes",
        Default = (config.patchOptions and config.patchOptions.firemodes) or false,
        Callback = function(Value)
            if callbacks.onFiremodeOptionsToggle then callbacks.onFiremodeOptionsToggle(Value) end
        end
    })

    -- 6. Visuals & Lighting Elements
    VisualsGroup:AddToggle("ESPToggle", {
        Text = "ESP / Wallhack",
        Default = config.highlightEnabled or false,
        Callback = function(Value)
            if callbacks.onHighlightsToggle then callbacks.onHighlightsToggle(Value) end
        end
    })

    VisualsGroup:AddLabel("Visible Color"):AddColorPicker("VisibleColorPicker", {
        Default = Color3.fromRGB(config.visibleR or 98, config.visibleG or 209, config.visibleB or 150),
        Title = "Visible Color",
        Callback = function(Value)
            if callbacks.onVisibleRChange then callbacks.onVisibleRChange(math.floor(Value.R * 255)) end
            if callbacks.onVisibleGChange then callbacks.onVisibleGChange(math.floor(Value.G * 255)) end
            if callbacks.onVisibleBChange then callbacks.onVisibleBChange(math.floor(Value.B * 255)) end
        end
    })

    VisualsGroup:AddLabel("Hidden Color"):AddColorPicker("HiddenColorPicker", {
        Default = Color3.fromRGB(config.hiddenR or 224, config.hiddenG or 108, config.hiddenB or 117),
        Title = "Hidden Color",
        Callback = function(Value)
            if callbacks.onHiddenRChange then callbacks.onHiddenRChange(math.floor(Value.R * 255)) end
            if callbacks.onHiddenGChange then callbacks.onHiddenGChange(math.floor(Value.G * 255)) end
            if callbacks.onHiddenBChange then callbacks.onHiddenBChange(math.floor(Value.B * 255)) end
        end
    })

    VisualsGroup:AddToggle("FullbrightToggle", {
        Text = "Fullbright",
        Default = config.fullBrightEnabled or false,
        Callback = function(Value)
            if callbacks.onFullBrightToggle then callbacks.onFullBrightToggle(Value) end
        end
    })

    VisualsGroup:AddSlider("NPCRangeSlider", {
        Text = "NPC Detection Range",
        Default = config.npcDetectionRadius or 1000,
        Min = 0,
        Max = config.MAX_NPC_DETECTION_RADIUS or 5000,
        Rounding = 0,
        Suffix = " studs",
        Callback = function(Value)
            if callbacks.onNPCDetectionRadiusChange then callbacks.onNPCDetectionRadiusChange(Value) end
        end
    })

    -- 7. Utilities Elements
    UtilitiesGroup:AddButton("Fix Camera Lock", function()
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
        task.wait(0.05)
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
    end)

    UtilitiesGroup:AddButton("Copy Discord Link", function()
        if type(setclipboard) == "function" then
            setclipboard("https://discord.gg/yourlink")
        end
    end)

    UtilitiesGroup:AddButton("Unload Script", function()
        GUI:destroy()
        if callbacks.onUnload then callbacks.onUnload() end
    end)

    -- 8. Setup Theme and Save Managers if available
    if ThemeManager then
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("BlackhawkMission5")
        ThemeManager:ApplyToTab(Tabs.Settings)
    end

    if SaveManager then
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({})
        SaveManager:BuildConfigSection(Tabs.Settings)
        SaveManager:LoadAutoloadConfig()
    end

    -- Toggle menu keybind configuration (End key)
    Library.ToggleKeybind = Enum.KeyCode.End
    self.IsOpen = true
end

function GUI:setVisibleState(isVisible)
    self.IsOpen = isVisible
    if self.Window then
        self.Window.Visible = isVisible
    end
end

function GUI:toggleVisibility()
    if self.Window then
        self.Window:Toggle()
        self.IsOpen = self.Window.Visible
    end
end

function GUI:destroy()
    if self.Library then
        self.Library:Unload()
    end
end

return GUI-- GUI Module (Converted to Seere / Fiji UI Library)

local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer
local Mouse            = LocalPlayer:GetMouse()

local GUI = {}
GUI.Library = nil
GUI.Menu = nil
GUI.IsOpen = true

function GUI:init(services, config, callbacks)
    config = config or {}
    callbacks = callbacks or {}

    -- 1. Load UI Asset
    local success, menu = pcall(function()
        return game:GetObjects("rbxassetid://12702460854")[1]
    end)

    if not success or not menu then
        warn("[GUI] Failed to load UI asset.")
        return
    end

    -- Protect GUI if supported
    if syn and syn.protect_gui then
        syn.protect_gui(menu)
        menu.Parent = game:GetService("CoreGui")
    elseif gethui then
        menu.Parent = gethui()
    else
        menu.Parent = game:GetService("CoreGui")
    end

    self.Menu = menu
    menu.bg.Position = UDim2.new(0.5, -menu.bg.Size.X.Offset / 2, 0.5, -menu.bg.Size.Y.Offset / 2)
    menu.bg.pre.Text = 'Blackhawk Rescue Mission 5 <font color="#c375ae">| by 9fallenone6</font>'

    -- 2. Library Setup
    local library = {
        cheatname = "", ext = "", gamename = "",
        colorpicking = false, tabbuttons = {}, tabs = {},
        options = {}, flags = {}, scrolling = false,
        notifyText = Drawing.new("Text"), playing = false,
        multiZindex = 200, toInvis = {},
        libColor = Color3.fromRGB(192, 118, 227),
        disabledcolor = Color3.fromRGB(233, 0, 0),
        blacklisted = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.UserInputType.MouseMovement}
    }
    self.Library = library

    -- Resize the main window and background containers to snugly fit 2 smaller group columns side-by-side (~390px width)
    local bgMain = menu.bg.bg.bg.bg
    bgMain.Size = UDim2.new(0, 410, 0, 300)

    local mainFrame = bgMain.main
    mainFrame.Size = UDim2.new(1, 0, 1, -30) -- Matches the smaller parent container

    local groupContainer = mainFrame.group
    local columnsLayout = groupContainer:FindFirstChildOfClass("UIListLayout")
    if columnsLayout then
        columnsLayout.Padding = UDim.new(0, 10) -- Bring categories closer together
        columnsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    end

    -- Make Menu Draggable
    local function makeDraggable(frame)
        local dragging, dragInput, dragStart, startPos
        local function update(input)
            if not library.colorpicking then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then update(input) end
        end)
    end
    makeDraggable(menu.bg)

    local tabholder = menu.bg.bg.bg.bg.main.group
    local tabviewer = menu.bg.bg.bg.bg.tabbuttons

    -- Keybind mapping helper
    local keyNames = {
        [Enum.KeyCode.LeftAlt] = 'LALT', [Enum.KeyCode.RightAlt] = 'RALT',
        [Enum.KeyCode.LeftControl] = 'LCTRL', [Enum.KeyCode.RightControl] = 'RCTRL',
        [Enum.KeyCode.LeftShift] = 'LSHIFT', [Enum.KeyCode.RightShift] = 'RSHIFT',
        [Enum.KeyCode.Underscore] = '_', [Enum.KeyCode.Minus] = '-',
        [Enum.KeyCode.Plus] = '+', [Enum.KeyCode.Period] = '.',
        [Enum.KeyCode.Slash] = '/', [Enum.KeyCode.BackSlash] = '\\',
        [Enum.KeyCode.Question] = '?',
        [Enum.UserInputType.MouseButton1] = 'MB1',
        [Enum.UserInputType.MouseButton2] = 'MB2',
        [Enum.UserInputType.MouseButton3] = 'MB3',
    }

    library.notifyText.Font = 2
    library.notifyText.Size = 13
    library.notifyText.Outline = true
    library.notifyText.Color = Color3.new(1, 1, 1)
    library.notifyText.Position = Vector2.new(10, 60)

    function library:Tween(...)
        TweenService:Create(...):Play()
    end

    function library:addTab(name)
        local newTab = tabholder.tab:Clone()
        local newButton = tabviewer.button:Clone()

        table.insert(library.tabs, newTab)
        newTab.Parent = tabholder
        newTab.Visible = false

        table.insert(library.tabbuttons, newButton)
        newButton.Parent = tabviewer
        newButton.Modal = true
        newButton.Visible = true
        newButton.text.Text = name
        newButton.MouseButton1Click:Connect(function()
            for _, v in next, library.tabs do v.Visible = (v == newTab) end
            for _, v in next, library.toInvis do v.Visible = false end
            for _, v in next, library.tabbuttons do
                local state = (v == newButton)
                if state then
                    v.element.Visible = true
                    library:Tween(v.element, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
                    v.text.TextColor3 = Color3.fromRGB(244, 244, 244)
                else
                    library:Tween(v.element, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
                    v.text.TextColor3 = Color3.fromRGB(144, 144, 144)
                end
            end
        end)

        local tab = {}
        local groupCount = 0
        local jigCount = 0
        local topStuff = 2000

        function tab:createGroup(pos, groupname)
            local groupbox = Instance.new("Frame")
            local grouper = Instance.new("Frame")
            local UIListLayout = Instance.new("UIListLayout")
            local UIPadding = Instance.new("UIPadding")
            local element = Instance.new("Frame")
            local title = Instance.new("TextLabel")
            local backframe = Instance.new("Frame")

            groupCount -= 1

            -- Find or create the column container with a narrower width to fit snugly
            local targetParent = newTab:FindFirstChild(pos)
            if not targetParent then
                targetParent = Instance.new("Frame")
                targetParent.Name = pos
                targetParent.Parent = newTab
                targetParent.BackgroundTransparency = 1
                targetParent.Size = UDim2.new(0, 185, 1, 0)
            end

            groupbox.Parent = targetParent
            groupbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            groupbox.BorderColor3 = Color3.fromRGB(30, 30, 30)
            groupbox.BorderSizePixel = 2
            groupbox.Size = UDim2.new(0, 185, 0, 8) -- Narrower group width
            groupbox.ZIndex = groupCount

            grouper.Parent = groupbox
            grouper.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            grouper.BorderColor3 = Color3.fromRGB(0, 0, 0)
            grouper.Size = UDim2.new(1, 0, 1, 0)

            UIListLayout.Parent = grouper
            UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

            UIPadding.Parent = grouper
            UIPadding.PaddingBottom = UDim.new(0, 4)
            UIPadding.PaddingTop = UDim.new(0, 7)

            element.Name = "element"
            element.Parent = groupbox
            element.BackgroundColor3 = library.libColor
            element.BorderSizePixel = 0
            element.Size = UDim2.new(1, 0, 0, 1)

            title.Parent = groupbox
            title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            title.BackgroundTransparency = 1.000
            title.BorderSizePixel = 0
            title.Position = UDim2.new(0, 17, 0, 0)
            title.ZIndex = 2
            title.Font = Enum.Font.Code
            title.Text = groupname or ""
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.TextSize = 13.000
            title.TextStrokeTransparency = 0.000
            title.TextXAlignment = Enum.TextXAlignment.Left

            backframe.Parent = groupbox
            backframe.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            backframe.BorderSizePixel = 0
            backframe.Position = UDim2.new(0, 10, 0, -2)
            backframe.Size = UDim2.new(0, 13 + title.TextBounds.X, 0, 3)

            local group = {}

            function group:addToggle(args)
                if not args.flag and args.text then args.flag = args.text end
                if not args.flag then return warn("⚠️ Missing args on toggle") end
                groupbox.Size += UDim2.new(0, 0, 0, 20)

                local toggleframe = Instance.new("Frame")
                local tobble = Instance.new("Frame")
                local mid = Instance.new("Frame")
                local front = Instance.new("Frame")
                local text = Instance.new("TextLabel")
                local button = Instance.new("TextButton")

                jigCount -= 1
                library.multiZindex -= 1

                toggleframe.Name = "toggleframe"
                toggleframe.Parent = grouper
                toggleframe.BackgroundTransparency = 1.000
                toggleframe.Size = UDim2.new(1, 0, 0, 20)
                toggleframe.ZIndex = library.multiZindex

                tobble.Name = "tobble"
                tobble.Parent = toggleframe
                tobble.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                tobble.BorderColor3 = Color3.fromRGB(0, 0, 0)
                tobble.BorderSizePixel = 3
                tobble.Position = UDim2.new(0.03, 0, 0.272, 0)
                tobble.Size = UDim2.new(0, 10, 0, 10)

                mid.Name = "mid"
                mid.Parent = tobble
                mid.BackgroundColor3 = Color3.fromRGB(69, 23, 255)
                mid.BorderColor3 = Color3.fromRGB(30, 30, 30)
                mid.BorderSizePixel = 2
                mid.Size = UDim2.new(0, 10, 0, 10)

                front.Name = "front"
                front.Parent = mid
                front.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                front.BorderColor3 = Color3.fromRGB(0, 0, 0)
                front.Size = UDim2.new(0, 10, 0, 10)

                text.Name = "text"
                text.Parent = toggleframe
                text.BackgroundTransparency = 1.000
                text.Position = UDim2.new(0, 22, 0, 0)
                text.Size = UDim2.new(0, 0, 1, 2)
                text.Font = Enum.Font.Code
                text.Text = args.text or args.flag
                text.TextColor3 = Color3.fromRGB(155, 155, 155)
                text.TextSize = 13.000
                text.TextXAlignment = Enum.TextXAlignment.Left

                button.Name = "button"
                button.Parent = toggleframe
                button.BackgroundTransparency = 1.000
                button.Size = UDim2.new(0, 101, 1, 0)
                button.Text = ""

                local state = false
                local function toggle(newState)
                    state = newState
                    library.flags[args.flag] = state
                    front.BackgroundColor3 = state and library.libColor or Color3.fromRGB(15, 15, 15)
                    text.TextColor3 = state and Color3.fromRGB(244, 244, 244) or Color3.fromRGB(144, 144, 144)
                    if args.callback then args.callback(state) end
                end

                button.MouseButton1Click:Connect(function()
                    toggle(not state)
                end)
                button.MouseEnter:Connect(function() mid.BorderColor3 = library.libColor end)
                button.MouseLeave:Connect(function() mid.BorderColor3 = Color3.fromRGB(30, 30, 30) end)

                library.flags[args.flag] = false
                library.options[args.flag] = {type = "toggle", changeState = toggle, skipflag = args.skipflag, oldargs = args}
            end

            function group:addButton(args)
                if not args.callback or not (args.text or args.flag) then return warn("⚠️ Missing args on button") end
                groupbox.Size += UDim2.new(0, 0, 0, 22)

                local buttonframe = Instance.new("Frame")
                local bg = Instance.new("Frame")
                local main = Instance.new("Frame")
                local button = Instance.new("TextButton")
                local gradient = Instance.new("UIGradient")

                buttonframe.Name = "buttonframe"
                buttonframe.Parent = grouper
                buttonframe.BackgroundTransparency = 1.000
                buttonframe.Size = UDim2.new(1, 0, 0, 21)

                bg.Name = "bg"
                bg.Parent = buttonframe
                bg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                bg.BorderColor3 = Color3.fromRGB(0, 0, 0)
                bg.BorderSizePixel = 2
                bg.Position = UDim2.new(0.02, -1, 0, 0)
                bg.Size = UDim2.new(0, 177, 0, 15) -- Scaled button to fit narrower group

                main.Name = "main"
                main.Parent = bg
                main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                main.BorderColor3 = Color3.fromRGB(60, 60, 60)
                main.Size = UDim2.new(1, 0, 1, 0)

                button.Name = "button"
                button.Parent = main
                button.BackgroundTransparency = 1.000
                button.Size = UDim2.new(1, 0, 1, 0)
                button.Font = Enum.Font.Code
                button.Text = args.text or args.flag
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 13.000

                gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(105, 105, 105)), ColorSequenceKeypoint.new(1, Color3.fromRGB(121, 121, 121))}
                gradient.Rotation = 90
                gradient.Parent = main

                button.MouseButton1Click:Connect(function()
                    if not library.colorpicking then args.callback() end
                end)
                button.MouseEnter:Connect(function() main.BorderColor3 = library.libColor end)
                button.MouseLeave:Connect(function() main.BorderColor3 = Color3.fromRGB(60, 60, 60) end)
            end

            function group:addSlider(args, sub)
                sub = sub or ""
                if not args.flag or not args.max then return warn("⚠️ Missing args on slider") end
                groupbox.Size += UDim2.new(0, 0, 0, 30)

                local slider = Instance.new("Frame")
                local bg = Instance.new("Frame")
                local main = Instance.new("Frame")
                local fill = Instance.new("Frame")
                local button = Instance.new("TextButton")
                local valuetext = Instance.new("TextLabel")
                local text = Instance.new("TextLabel")

                slider.Name = "slider"
                slider.Parent = grouper
                slider.BackgroundTransparency = 1.000
                slider.Size = UDim2.new(1, 0, 0, 30)

                bg.Name = "bg"
                bg.Parent = slider
                bg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                bg.BorderColor3 = Color3.fromRGB(0, 0, 0)
                bg.BorderSizePixel = 2
                bg.Position = UDim2.new(0.02, -1, 0, 16)
                bg.Size = UDim2.new(0, 177, 0, 10) -- Scaled slider to fit narrower group

                main.Name = "main"
                main.Parent = bg
                main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                main.BorderColor3 = Color3.fromRGB(50, 50, 50)
                main.Size = UDim2.new(1, 0, 1, 0)

                fill.Name = "fill"
                fill.Parent = main
                fill.BackgroundColor3 = library.libColor
                fill.BackgroundTransparency = 0.200
                fill.BorderSizePixel = 0
                fill.Size = UDim2.new(0, 0, 1, 0)

                button.Name = "button"
                button.Parent = main
                button.BackgroundTransparency = 1.000
                button.Size = UDim2.new(1, 0, 1, 0)
                button.Text = ""

                valuetext.Parent = main
                valuetext.BackgroundTransparency = 1.000
                valuetext.Position = UDim2.new(0.5, 0, 0.5, 0)
                valuetext.Font = Enum.Font.Code
                valuetext.TextColor3 = Color3.fromRGB(255, 255, 255)
                valuetext.TextSize = 13.000

                text.Name = "text"
                text.Parent = slider
                text.BackgroundTransparency = 1.000
                text.Position = UDim2.new(0.03, -1, 0, 7)
                text.Font = Enum.Font.Code
                text.Text = args.text or args.flag
                text.TextColor3 = Color3.fromRGB(244, 244, 244)
                text.TextSize = 13.000
                text.TextXAlignment = Enum.TextXAlignment.Left

                local entered = false
                local scrolling = false

                local function updateValue(value)
                    if library.colorpicking then return end
                    local min = args.min or 0
                    local max = args.max
                    local percent = math.clamp((value - min) / (max - min), 0, 1)
                    fill:TweenSize(UDim2.new(percent, 0, 1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.01)
                    valuetext.Text = tostring(value) .. sub
                    library.flags[args.flag] = value
                    if args.callback then args.callback(value) end
                end

                local function updateScroll()
                    if scrolling or library.scrolling or not newTab.Visible or library.colorpicking then return end
                    while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and menu.Enabled do
                        RunService.RenderStepped:Wait()
                        library.scrolling = true
                        scrolling = true
                        local min = args.min or 0
                        local max = args.max
                        local value = min + ((Mouse.X - button.AbsolutePosition.X) / button.AbsoluteSize.X) * (max - min)
                        value = math.clamp(math.floor(value), min, max)
                        updateValue(value)
                    end
                    scrolling = false
                    library.scrolling = false
                end

                button.MouseEnter:Connect(function()
                    if library.colorpicking or scrolling or entered then return end
                    entered = true
                    main.BorderColor3 = library.libColor
                    while entered do
                        task.wait()
                        updateScroll()
                    end
                end)
                button.MouseLeave:Connect(function()
                    entered = false
                    main.BorderColor3 = Color3.fromRGB(60, 60, 60)
                end)

                library.flags[args.flag] = args.value or args.min or 0
                library.options[args.flag] = {type = "slider", changeState = updateValue, skipflag = args.skipflag, oldargs = args}
                updateValue(args.value or args.min or 0)
            end

            function group:addColorpicker(args)
                if not args.flag and args.text then args.flag = args.text end
                if not args.flag then return warn("⚠️ Missing args on colorpicker") end
                groupbox.Size += UDim2.new(0, 0, 0, 20)

                topStuff -= 1

                local colorpicker = Instance.new("Frame")
                local mid = Instance.new("Frame")
                local front = Instance.new("Frame")
                local text = Instance.new("TextLabel")
                local button = Instance.new("TextButton")
                local colorFrame = Instance.new("Frame")
                local colorFrame_2 = Instance.new("Frame")
                local hueframe = Instance.new("Frame")
                local main = Instance.new("Frame")
                local hue = Instance.new("ImageLabel")
                local pickerframe = Instance.new("Frame")
                local main_2 = Instance.new("Frame")
                local picker = Instance.new("ImageLabel")
                local clr = Instance.new("Frame")
                local copy = Instance.new("TextButton")

                colorpicker.Name = "colorpicker"
                colorpicker.Parent = grouper
                colorpicker.BackgroundTransparency = 1.000
                colorpicker.Size = UDim2.new(1, 0, 0, 20)
                colorpicker.ZIndex = topStuff

                text.Name = "text"
                text.Parent = colorpicker
                text.BackgroundTransparency = 1.000
                text.Position = UDim2.new(0.02, -1, 0, 10)
                text.Font = Enum.Font.Code
                text.Text = args.text or args.flag
                text.TextColor3 = Color3.fromRGB(244, 244, 244)
                text.TextSize = 13.000
                text.TextXAlignment = Enum.TextXAlignment.Left

                local colorpicker_2 = Instance.new("Frame")
                colorpicker_2.Name = "colorpicker"
                colorpicker_2.Parent = colorpicker
                colorpicker_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                colorpicker_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
                colorpicker_2.BorderSizePixel = 3
                colorpicker_2.Position = UDim2.new(0.86, 4, 0.272, 0)
                colorpicker_2.Size = UDim2.new(0, 20, 0, 10)

                mid.Name = "mid"
                mid.Parent = colorpicker_2
                mid.BackgroundColor3 = Color3.fromRGB(69, 23, 255)
                mid.BorderColor3 = Color3.fromRGB(30, 30, 30)
                mid.BorderSizePixel = 2
                mid.Size = UDim2.new(1, 0, 1, 0)

                front.Name = "front"
                front.Parent = mid
                front.BackgroundColor3 = args.color or Color3.fromRGB(240, 142, 214)
                front.Size = UDim2.new(1, 0, 1, 0)

                button.Name = "button"
                button.Parent = colorpicker
                button.BackgroundTransparency = 1.000
                button.Size = UDim2.new(0, 177, 0, 22)
                button.Text = ""

                colorFrame.Name = "colorFrame"
                colorFrame.Parent = colorpicker
                colorFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                colorFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
                colorFrame.BorderSizePixel = 2
                colorFrame.Position = UDim2.new(0.1, 0, 0.75, 0)
                colorFrame.Size = UDim2.new(0, 137, 0, 128)
                colorFrame.Visible = false

                colorFrame_2.Parent = colorFrame
                colorFrame_2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                colorFrame_2.BorderColor3 = Color3.fromRGB(60, 60, 60)
                colorFrame_2.Size = UDim2.new(1, 0, 1, 0)

                hueframe.Parent = colorFrame_2
                hueframe.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
                hueframe.BorderColor3 = Color3.fromRGB(60, 60, 60)
                hueframe.BorderSizePixel = 2
                hueframe.Position = UDim2.new(-0.093, 18, -0.06, 30)
                hueframe.Size = UDim2.new(0, 100, 0, 100)

                main.Parent = hueframe
                main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                main.Size = UDim2.new(0, 100, 0, 100)
                main.ZIndex = 6

                picker.Parent = main
                picker.BackgroundColor3 = Color3.fromRGB(232, 0, 255)
                picker.BorderSizePixel = 0
                picker.Size = UDim2.new(0, 100, 0, 100)
                picker.ZIndex = 104
                picker.Image = "rbxassetid://2615689005"

                pickerframe.Parent = colorFrame
                pickerframe.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
                pickerframe.BorderColor3 = Color3.fromRGB(60, 60, 60)
                pickerframe.BorderSizePixel = 2
                pickerframe.Position = UDim2.new(0.711, 14, -0.06, 30)
                pickerframe.Size = UDim2.new(0, 20, 0, 100)

                main_2.Parent = pickerframe
                main_2.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                main_2.Size = UDim2.new(0, 20, 0, 100)
                main_2.ZIndex = 6

                hue.Parent = main_2
                hue.BackgroundColor3 = Color3.fromRGB(255, 0, 178)
                hue.BorderSizePixel = 0
                hue.Size = UDim2.new(0, 20, 0, 100)
                hue.ZIndex = 104
                hue.Image = "rbxassetid://2615692420"

                clr.Parent = colorFrame
                clr.BackgroundTransparency = 1.000
                clr.Position = UDim2.new(0.028, 0, 0, 2)
                clr.Size = UDim2.new(0, 129, 0, 14)

                copy.Parent = clr
                copy.BackgroundTransparency = 1.000
                copy.Size = UDim2.new(0, 129, 0, 14)
                copy.Font = Enum.Font.Code
                copy.Text = args.text or args.flag
                copy.TextColor3 = Color3.fromRGB(100, 100, 100)
                copy.TextSize = 14.000

                copy.MouseButton1Click:Connect(function() colorFrame.Visible = false end)
                button.MouseButton1Click:Connect(function()
                    colorFrame.Visible = not colorFrame.Visible
                    mid.BorderColor3 = Color3.fromRGB(30, 30, 30)
                end)
                button.MouseEnter:Connect(function() mid.BorderColor3 = library.libColor end)
                button.MouseLeave:Connect(function() mid.BorderColor3 = Color3.fromRGB(30, 30, 30) end)

                local function updateValue(val)
                    library.flags[args.flag] = val
                    front.BackgroundColor3 = val
                    if args.callback then args.callback(val) end
                end

                local white, black = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
                local colors = {Color3.new(1,0,0), Color3.new(1,1,0), Color3.new(0,1,0), Color3.new(0,1,1), Color3.new(0,0,1), Color3.new(1,0,1), Color3.new(1,0,0)}
                local pickerX, pickerY, hueY = 0, 0, 0
                local oldpercentX, oldpercentY = 0, 0

                hue.MouseEnter:Connect(function()
                    local input = hue.InputBegan:Connect(function(key)
                        if key.UserInputType == Enum.UserInputType.MouseButton1 then
                            while RunService.Heartbeat:Wait() and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                                library.colorpicking = true
                                local percent = (hueY - hue.AbsolutePosition.Y - 36) / hue.AbsoluteSize.Y
                                local num = math.clamp(math.floor(((percent * 7 + 0.5) * 100)) / 100, 1, 7)
                                local startC = colors[math.floor(num)]
                                local endC = colors[math.ceil(num)]
                                picker.BackgroundColor3 = startC:lerp(endC, num - math.floor(num))
                                local color = white:lerp(picker.BackgroundColor3, oldpercentX):lerp(black, oldpercentY)
                                updateValue(color)
                            end
                            library.colorpicking = false
                        end
                    end)
                    local leave
                    leave = hue.MouseLeave:Connect(function()
                        input:Disconnect()
                        leave:Disconnect()
                    end)
                end)

                picker.MouseEnter:Connect(function()
                    local input = picker.InputBegan:Connect(function(key)
                        if key.UserInputType == Enum.UserInputType.MouseButton1 then
                            while RunService.Heartbeat:Wait() and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                                library.colorpicking = true
                                local xPercent = (pickerX - picker.AbsolutePosition.X) / picker.AbsoluteSize.X
                                local yPercent = (pickerY - picker.AbsolutePosition.Y - 36) / picker.AbsoluteSize.Y
                                local color = white:lerp(picker.BackgroundColor3, xPercent):lerp(black, yPercent)
                                updateValue(color)
                                oldpercentX, oldpercentY = xPercent, yPercent
                            end
                            library.colorpicking = false
                        end
                    end)
                    local leave
                    leave = picker.MouseLeave:Connect(function()
                        input:Disconnect()
                        leave:Disconnect()
                    end)
                end)

                hue.MouseMoved:Connect(function(_, y) hueY = y end)
                picker.MouseMoved:Connect(function(x, y) pickerX, pickerY = x, y end)

                table.insert(library.toInvis, colorFrame)
                library.flags[args.flag] = args.color or Color3.new(1, 1, 1)
                library.options[args.flag] = {type = "colorpicker", changeState = updateValue, skipflag = args.skipflag, oldargs = args}
                updateValue(args.color or Color3.new(1, 1, 1))
            end

            return group, groupbox
        end

        return tab
    end

    -- 3. Construct Pages and Controls
    local mainTab = library:addTab("Main")

    -- Left Column: Combat & Weapons
    local combatGroup  = mainTab:createGroup("left", "Combat")
    local weaponsGroup = mainTab:createGroup("left", "Weapons")

    combatGroup:addToggle({
        text = "Silent Target",
        flag = "combat/silent_target",
        callback = function(p_state)
            if callbacks.onSizingToggle then callbacks.onSizingToggle(p_state) end
        end
    })

    combatGroup:addToggle({
        text = "Show HitBox",
        flag = "combat/show_hitbox",
        callback = function(p_state)
            if callbacks.onShowTargetBoxToggle then callbacks.onShowTargetBoxToggle(p_state) end
        end
    })

    weaponsGroup:addToggle({
        text = "No Recoil",
        flag = "weapons/no_recoil",
        callback = function(p_state)
            if callbacks.onStabilityToggle then callbacks.onStabilityToggle(p_state) end
        end
    })

    weaponsGroup:addToggle({
        text = "All Firemodes",
        flag = "weapons/all_firemodes",
        callback = function(p_state)
            if callbacks.onFiremodeOptionsToggle then callbacks.onFiremodeOptionsToggle(p_state) end
        end
    })

    -- Right Column: Visuals & Settings
    local visualsGroup   = mainTab:createGroup("right", "Visuals & Lighting")
    local utilitiesGroup = mainTab:createGroup("right", "Menu & Utilities")

    visualsGroup:addToggle({
        text = "ESP / Wallhack",
        flag = "visuals/esp",
        callback = function(p_state)
            if callbacks.onHighlightsToggle then callbacks.onHighlightsToggle(p_state) end
        end
    })

    visualsGroup:addColorpicker({
        text = "Visible Color",
        flag = "visuals/visible_color",
        color = Color3.fromRGB(config.visibleR or 98, config.visibleG or 209, config.visibleB or 150),
        callback = function(p_state)
            if callbacks.onVisibleRChange then callbacks.onVisibleRChange(math.floor(p_state.R * 255)) end
            if callbacks.onVisibleGChange then callbacks.onVisibleGChange(math.floor(p_state.G * 255)) end
            if callbacks.onVisibleBChange then callbacks.onVisibleBChange(math.floor(p_state.B * 255)) end
        end
    })

    visualsGroup:addColorpicker({
        text = "Hidden Color",
        flag = "visuals/hidden_color",
        color = Color3.fromRGB(config.hiddenR or 224, config.hiddenG or 108, config.hiddenB or 117),
        callback = function(p_state)
            if callbacks.onHiddenRChange then callbacks.onHiddenRChange(math.floor(p_state.R * 255)) end
            if callbacks.onHiddenGChange then callbacks.onHiddenGChange(math.floor(p_state.G * 255)) end
            if callbacks.onHiddenBChange then callbacks.onHiddenBChange(math.floor(p_state.B * 255)) end
        end
    })

    visualsGroup:addToggle({
        text = "Fullbright",
        flag = "visuals/fullbright",
        callback = function(p_state)
            if callbacks.onFullBrightToggle then callbacks.onFullBrightToggle(p_state) end
        end
    })

    visualsGroup:addSlider({
        text = "NPC Detection Range",
        flag = "visuals/npc_range",
        min = 0,
        max = config.MAX_NPC_DETECTION_RADIUS or 5000,
        value = config.npcDetectionRadius or 1000,
        callback = function(p_state)
            if callbacks.onNPCDetectionRadiusChange then callbacks.onNPCDetectionRadiusChange(p_state) end
        end
    }, " studs")

    utilitiesGroup:addButton({
        text = "Fix Camera Lock",
        callback = function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
            task.wait(0.05)
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
        end
    })

    utilitiesGroup:addButton({
        text = "Copy Discord Link",
        callback = function()
            if type(setclipboard) == "function" then
                setclipboard("https://discord.gg/yourlink")
            end
        end
    })

    utilitiesGroup:addButton({
        text = "Unload Script",
        callback = function()
            self:destroy()
            if callbacks.onUnload then callbacks.onUnload() end
        end
    })

    -- Set Default Initial States
    if config.sizingEnabled then library.options["combat/silent_target"].changeState(true) end
    if config.showTargetBox then library.options["combat/show_hitbox"].changeState(true) end
    if config.patchOptions and config.patchOptions.recoil then library.options["weapons/no_recoil"].changeState(true) end
    if config.patchOptions and config.patchOptions.firemodes then library.options["weapons/all_firemodes"].changeState(true) end
    if config.highlightEnabled then library.options["visuals/esp"].changeState(true) end
    if config.fullBrightEnabled then library.options["visuals/fullbright"].changeState(true) end

    -- Bind Key (End key toggles menu)
    UserInputService.InputEnded:Connect(function(key)
        if key.KeyCode == Enum.KeyCode.End then
            self:toggleVisibility()
        end
    end)

    self.IsOpen = true
end

function GUI:setVisibleState(isVisible)
    self.IsOpen = isVisible
    if self.Menu then
        self.Menu.Enabled = isVisible
    end
    if not isVisible then
        task.defer(function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end)
    end
end

function GUI:toggleVisibility()
    if self.Menu then
        self.Menu.Enabled = not self.Menu.Enabled
        self.IsOpen = self.Menu.Enabled
        if self.Library then
            self.Library.scrolling = false
            self.Library.colorpicking = false
            for _, v in next, self.Library.toInvis do
                v.Visible = false
            end
        end
    end
end

function GUI:destroy()
    if self.Menu then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        self.Menu:Destroy()
        self.Menu = nil
    end
    if self.Library and self.Library.notifyText then
        self.Library.notifyText:Remove()
    end
end

return GUI
