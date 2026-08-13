-- GUI Module (system24 TUI Theme)
-- Creates and manages the user interface with a retro Terminal/TUI aesthetic

local GUI = {}

GUI.screenGui = nil
GUI.mainFrame = nil
GUI.modalOverlay = nil
GUI.cursorIndicator = nil
GUI.toggleButton = nil
GUI.tabButtons = {}
GUI.tabs = {}

-- system24 Theme Palette
local THEME = {
    -- Text Colors
    TextPrimary   = Color3.fromRGB(242, 242, 242), -- --text-1 (OKLCH 95%)
    TextSecondary = Color3.fromRGB(191, 191, 191), -- --text-3 (OKLCH 75%)
    TextMuted     = Color3.fromRGB(102, 102, 102), -- --text-5 (OKLCH 40%)
    TextActive    = Color3.fromRGB(25, 25, 25),    -- Text on active elements
    
    -- Surface & Background Colors
    MainBG        = Color3.fromRGB(25, 25, 25),    -- --bg-4 (OKLCH 19%)
    PanelBG       = Color3.fromRGB(33, 33, 33),    -- --bg-3 (OKLCH 23%)
    ButtonBG      = Color3.fromRGB(41, 41, 41),    -- --bg-2 (OKLCH 27%)
    ButtonHover   = Color3.fromRGB(50, 50, 50),
    
    -- Accent Colors (system24 Purple & Accent New)
    Accent        = Color3.fromRGB(198, 120, 221), -- --purple-2 (OKLCH 70% 0.12 310)
    AccentDark    = Color3.fromRGB(156, 82, 181),  -- --purple-4
    Green         = Color3.fromRGB(98, 209, 150),  -- --green-2 (OKLCH 70% 0.12 170)
    Red           = Color3.fromRGB(224, 108, 117), -- --red-2 / --accent-new
    
    -- Borders & Outlines
    Border        = Color3.fromRGB(60, 60, 60),    -- --border
    BorderActive  = Color3.fromRGB(198, 120, 221), -- --border-hover (--accent-2)
    
    -- Fonts
    FontMono      = Enum.Font.Code,
    FontHeader    = Enum.Font.RobotoMono
}

-- Creates a new tab page
local function createTab(container)
    local f = Instance.new("ScrollingFrame", container)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.Visible = false
    f.ScrollBarThickness = 3
    f.ScrollBarImageColor3 = THEME.Accent
    f.CanvasSize = UDim2.new(0, 0, 0, 0)
    f.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local l = Instance.new("UIListLayout", f)
    l.Padding = UDim.new(0, 8)
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    l.SortOrder = Enum.SortOrder.LayoutOrder

    return f
end

-- Creates a toggle button
local function createButton(parent, text, initialActive, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = initialActive and THEME.Accent or THEME.ButtonBG
    btn.Text = (initialActive and "[X] " or "[ ] ") .. text
    btn.TextColor3 = initialActive and THEME.TextActive or THEME.TextPrimary
    btn.Font = THEME.FontMono
    btn.TextSize = 13
    btn.AutoButtonColor = false

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = initialActive and THEME.Accent or THEME.Border
    stroke.Thickness = 1
    
    local active = initialActive and true or false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and THEME.Accent or THEME.ButtonBG
        btn.Text = (active and "[X] " or "[ ] ") .. text
        btn.TextColor3 = active and THEME.TextActive or THEME.TextPrimary
        stroke.Color = active and THEME.Accent or THEME.Border
        callback(active)
    end)

    btn.MouseEnter:Connect(function()
        if not active then
            btn.BackgroundColor3 = THEME.ButtonHover
            stroke.Color = THEME.BorderActive
        end
    end)

    btn.MouseLeave:Connect(function()
        if not active then
            btn.BackgroundColor3 = THEME.ButtonBG
            stroke.Color = THEME.Border
        end
    end)
end

-- Creates a label
local function createLabel(parent, text, color, layoutIndex)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, -10, 0, 24)
    lbl.Text = text
    lbl.TextColor3 = color or THEME.Accent
    lbl.Font = THEME.FontHeader
    lbl.TextSize = 13
    lbl.BackgroundTransparency = 1
    if layoutIndex then
        lbl.LayoutOrder = layoutIndex
    end
    return lbl
end

local function createInfoLabel(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, -10, 0, 54)
    lbl.Text = "// " .. text
    lbl.TextColor3 = THEME.TextMuted
    lbl.Font = THEME.FontMono
    lbl.TextSize = 11
    lbl.TextWrapped = true
    lbl.TextXAlignment = "Left"
    lbl.TextYAlignment = "Top"
    lbl.BackgroundTransparency = 1
    return lbl
end

local function updateToggleButtonText(button, isVisible)
    if button then
        button.Text = isVisible and "[SYS: HIDE]" or "[SYS: SHOW]"
    end
end

-- Creates a slider
local function createSlider(parent, label, initialValue, maxValue, callback, layoutIndex, services)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, -10, 0, 48)
    f.BackgroundTransparency = 1
    if layoutIndex then
        f.LayoutOrder = layoutIndex
    end

    local l = Instance.new("TextLabel", f)
    l.Text = string.format("%s: %d / %d", label, initialValue, maxValue)
    l.Size = UDim2.new(1, 0, 0, 18)
    l.TextColor3 = THEME.TextSecondary
    l.Font = THEME.FontMono
    l.TextSize = 12
    l.BackgroundTransparency = 1
    l.TextXAlignment = "Left"

    local bar = Instance.new("Frame", f)
    bar.Position = UDim2.new(0, 0, 0, 22)
    bar.Size = UDim2.new(1, 0, 0, 12)
    bar.BackgroundColor3 = THEME.PanelBG

    local barStroke = Instance.new("UIStroke", bar)
    barStroke.Color = THEME.Border
    barStroke.Thickness = 1

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(maxValue > 0 and (initialValue / maxValue) or 0, 0, 1, 0)
    fill.BackgroundColor3 = THEME.Accent
    fill.BorderSizePixel = 0

    local dragging = false
    local function update()
        local mousePos = services.UserInputService:GetMouseLocation().X
        local p = math.clamp((mousePos - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(p * maxValue)
        fill.Size = UDim2.new(p, 0, 1, 0)
        l.Text = string.format("%s: %d / %d", label, val, maxValue)
        callback(val)
    end

    bar.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = true 
            update() 
        end 
    end)
    
    services.UserInputService.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = false 
        end 
    end)
    
    services.RunService.RenderStepped:Connect(function() 
        if dragging then 
            update() 
        end 
    end)
end

-- Initialize the GUI
function GUI:init(services, config, callbacks)
    local localPlayer = services.localPlayer
    local playerMouse = localPlayer:GetMouse()
    
    -- Create ScreenGui
    self.screenGui = Instance.new("ScreenGui", localPlayer.PlayerGui)
    self.screenGui.Name = "BRM5_V6_Final"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.DisplayOrder = 9999
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local modalOverlay = Instance.new("TextButton", self.screenGui)
    modalOverlay.Name = "ModalOverlay"
    modalOverlay.Size = UDim2.fromScale(1, 1)
    modalOverlay.Position = UDim2.fromScale(0, 0)
    modalOverlay.BackgroundTransparency = 1
    modalOverlay.BorderSizePixel = 0
    modalOverlay.Text = ""
    modalOverlay.AutoButtonColor = false
    modalOverlay.Modal = true
    modalOverlay.Active = true
    modalOverlay.Visible = config.guiVisible
    modalOverlay.ZIndex = 0
    self.modalOverlay = modalOverlay

    local cursorIndicator = Instance.new("Frame", self.screenGui)
    cursorIndicator.Name = "CursorIndicator"
    cursorIndicator.Size = UDim2.fromOffset(8, 8)
    cursorIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
    cursorIndicator.BackgroundColor3 = THEME.Accent
    cursorIndicator.BorderSizePixel = 0
    cursorIndicator.Visible = config.guiVisible
    cursorIndicator.ZIndex = 100
    self.cursorIndicator = cursorIndicator

    local cursorStroke = Instance.new("UIStroke", cursorIndicator)
    cursorStroke.Color = THEME.MainBG
    cursorStroke.Thickness = 1

    local toggleButton = Instance.new("TextButton", self.screenGui)
    toggleButton.Name = "GuiToggleButton"
    toggleButton.Size = UDim2.fromOffset(120, 32)
    toggleButton.Position = UDim2.new(0, 20, 0.5, -16)
    toggleButton.BackgroundColor3 = THEME.MainBG
    toggleButton.TextColor3 = THEME.Accent
    toggleButton.Font = THEME.FontMono
    toggleButton.TextSize = 12
    toggleButton.ZIndex = 101

    local toggleStroke = Instance.new("UIStroke", toggleButton)
    toggleStroke.Color = THEME.BorderActive
    toggleStroke.Thickness = 2

    self.toggleButton = toggleButton
    updateToggleButtonText(toggleButton, config.guiVisible)

    toggleButton.MouseButton1Click:Connect(function()
        if callbacks.onVisibilityToggle then
            callbacks.onVisibilityToggle()
        else
            self:toggleVisibility()
        end
    end)

    -- Main Window Frame
    local main = Instance.new("Frame", self.screenGui)
    main.Size = UDim2.new(0, 520, 0, 360)
    main.Position = UDim2.new(0.5, -260, 0.5, -180)
    main.BackgroundColor3 = THEME.MainBG
    main.Active = true
    main.Visible = config.guiVisible
    main.ZIndex = 1
    self.mainFrame = main

    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Color = THEME.Border
    mainStroke.Thickness = 2

    -- Make draggable
    local dragging, dragInput, dragStart, startPos
    local function updateDrag(input)
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                  startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    local topBar = Instance.new("Frame", main)
    topBar.Size = UDim2.new(1, 0, 0, 32)
    topBar.BackgroundColor3 = THEME.PanelBG

    local topBarStroke = Instance.new("UIStroke", topBar)
    topBarStroke.Color = THEME.Border
    topBarStroke.Thickness = 1

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then 
                    dragging = false 
                end
            end)
        end
    end)

    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then 
            dragInput = input 
        end
    end)

    services.RunService.RenderStepped:Connect(function()
        if dragging and dragInput then 
            updateDrag(dragInput) 
        end

        if self.cursorIndicator then
            self.cursorIndicator.Position = UDim2.fromOffset(
                playerMouse.X,
                playerMouse.Y
            )
        end
    end)

    -- Title (system24 ASCII / TUI Header Style)
    local title = Instance.new("TextLabel", topBar)
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "SYSTEM24 // BRM5 v7.0 PVE"
    title.Font = THEME.FontHeader
    title.TextColor3 = THEME.Accent
    title.TextSize = 13
    title.TextXAlignment = "Left"
    title.BackgroundTransparency = 1

    -- Sidebar
    local sidebar = Instance.new("Frame", main)
    sidebar.Position = UDim2.new(0, 0, 0, 32)
    sidebar.Size = UDim2.new(0, 140, 1, -32)
    sidebar.BackgroundColor3 = THEME.PanelBG

    local sideStroke = Instance.new("UIStroke", sidebar)
    sideStroke.Color = THEME.Border
    sideStroke.Thickness = 1

    local sideLayout = Instance.new("UIListLayout", sidebar)
    sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sideLayout.Padding = UDim.new(0, 6)

    -- Side Panel Label (system24 visual style)
    local sideLabel = Instance.new("TextLabel", sidebar)
    sideLabel.Size = UDim2.new(1, -16, 0, 24)
    sideLabel.Text = "[NAVIGATION]"
    sideLabel.TextColor3 = THEME.TextMuted
    sideLabel.Font = THEME.FontMono
    sideLabel.TextSize = 10
    sideLabel.TextXAlignment = "Left"
    sideLabel.BackgroundTransparency = 1

    -- Content Container
    local container = Instance.new("Frame", main)
    container.Position = UDim2.new(0, 148, 0, 40)
    container.Size = UDim2.new(1, -156, 1, -48)
    container.BackgroundTransparency = 1

    -- Create Tabs
    local tabCombat = createTab(container)
    local tabVisuals = createTab(container)
    local tabWeapons = createTab(container)
    local tabColors = createTab(container)
    local tabCredits = createTab(container)
    tabCombat.Visible = true

    self.tabs = {
        combat = tabCombat,
        visuals = tabVisuals,
        weapons = tabWeapons,
        colors = tabColors,
        credits = tabCredits
    }

    -- Add Tab Buttons
    local function addTabBtn(name, targetTab)
        local b = Instance.new("TextButton", sidebar)
        b.Size = UDim2.new(1, -12, 0, 30)
        b.BackgroundColor3 = THEME.ButtonBG
        b.TextColor3 = THEME.TextSecondary
        b.Font = THEME.FontMono
        b.TextSize = 12
        b.Text = "> " .. name
        b.TextXAlignment = "Left"

        local bStroke = Instance.new("UIStroke", b)
        bStroke.Color = THEME.Border
        bStroke.Thickness = 1

        self.tabButtons[name] = b
        if name == "Combat" then
            b.BackgroundColor3 = THEME.Accent
            b.TextColor3 = THEME.TextActive
            bStroke.Color = THEME.Accent
        end

        b.MouseButton1Click:Connect(function()
            for _, btn in pairs(self.tabButtons) do
                btn.BackgroundColor3 = THEME.ButtonBG
                btn.TextColor3 = THEME.TextSecondary
                btn:FindFirstChildOfClass("UIStroke").Color = THEME.Border
            end
            b.BackgroundColor3 = THEME.Accent
            b.TextColor3 = THEME.TextActive
            bStroke.Color = THEME.Accent

            for _, tab in pairs(self.tabs) do
                tab.Visible = false
            end
            targetTab.Visible = true
        end)
    end

    addTabBtn("Combat", tabCombat)
    addTabBtn("Visuals", tabVisuals)
    addTabBtn("Weapons", tabWeapons)
    addTabBtn("Colors", tabColors)
    addTabBtn("Credits", tabCredits)

    -- COMBAT TAB
    createButton(tabCombat, "Silent Target", config.sizingEnabled, callbacks.onSizingToggle)
    createButton(tabCombat, "Show HitBox", config.showTargetBox, callbacks.onShowTargetBoxToggle)

    -- VISUALS TAB
    createButton(tabVisuals, "ESP / Wallhack", config.highlightEnabled, callbacks.onHighlightsToggle)
    createButton(tabVisuals, "FullBright Light", config.fullBrightEnabled, callbacks.onFullBrightToggle)
    createSlider(
        tabVisuals,
        "NPC Range",
        config.npcDetectionRadius,
        config.MAX_NPC_DETECTION_RADIUS,
        callbacks.onNPCDetectionRadiusChange,
        nil,
        services
    )
    createInfoLabel(
        tabVisuals,
        "If experiencing FPS drops, lower NPC Range. Gradually increase until optimal performance is achieved."
    )

    -- WEAPONS TAB
    local weaponNote = createLabel(tabWeapons, "! RESET CHAR TO APPLY !", THEME.Red)
    createButton(tabWeapons, "No Recoil", config.patchOptions.recoil, callbacks.onStabilityToggle)
    createButton(tabWeapons, "All Firemodes", config.patchOptions.firemodes, callbacks.onFiremodeOptionsToggle)

    -- COLORS TAB
    local layoutIndex = 1
    createLabel(tabColors, "--- VISIBLE COLOR ---", THEME.Green, layoutIndex)
    layoutIndex = layoutIndex + 1
    
    createSlider(tabColors, "R", config.visibleR, 255, callbacks.onVisibleRChange, layoutIndex, services)
    layoutIndex = layoutIndex + 1
    createSlider(tabColors, "G", config.visibleG, 255, callbacks.onVisibleGChange, layoutIndex, services)
    layoutIndex = layoutIndex + 1
    createSlider(tabColors, "B", config.visibleB, 255, callbacks.onVisibleBChange, layoutIndex, services)
    layoutIndex = layoutIndex + 1

    createLabel(tabColors, "--- HIDDEN COLOR ---", THEME.Red, layoutIndex)
    layoutIndex = layoutIndex + 1
    
    createSlider(tabColors, "R", config.hiddenR, 255, callbacks.onHiddenRChange, layoutIndex, services)
    layoutIndex = layoutIndex + 1
    createSlider(tabColors, "G", config.hiddenG, 255, callbacks.onHiddenGChange, layoutIndex, services)
    layoutIndex = layoutIndex + 1
    createSlider(tabColors, "B", config.hiddenB, 255, callbacks.onHiddenBChange, layoutIndex, services)

    -- CREDITS TAB
    local clipboardStatus = createInfoLabel(tabCredits, "Select a link to copy URL to clipboard.")
    clipboardStatus.Size = UDim2.new(1, -10, 0, 36)
    clipboardStatus.TextColor3 = THEME.Accent

    local function copyToClipboard(text, label)
        if type(setclipboard) == "function" then
            local ok = pcall(setclipboard, text)
            if ok then
                clipboardStatus.Text = "// Copied: " .. label
                return
            end
        end
        clipboardStatus.Text = "// Err: Clipboard unsupported by executor."
    end

    local function addLinkButton(label, url, accentColor)
        local btn = Instance.new("TextButton", tabCredits)
        btn.Size = UDim2.new(1, -10, 0, 38)
        btn.BackgroundColor3 = THEME.ButtonBG
        btn.Text = "[LINK] " .. label
        btn.TextColor3 = THEME.TextPrimary
        btn.Font = THEME.FontMono
        btn.TextSize = 12
        btn.AutoButtonColor = true

        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = accentColor or THEME.Border
        stroke.Thickness = 1

        btn.MouseButton1Click:Connect(function()
            copyToClipboard(url, label)
        end)
    end

    -- UNLOAD BUTTON
    local unl = Instance.new("TextButton", sidebar)
    unl.Size = UDim2.new(1, -12, 0, 30)
    unl.Position = UDim2.new(0, 6, 1, -36)
    unl.Text = "[X] UNLOAD"
    unl.BackgroundColor3 = THEME.Red
    unl.TextColor3 = THEME.TextActive
    unl.Font = THEME.FontMono
    unl.TextSize = 12

    local unlStroke = Instance.new("UIStroke", unl)
    unlStroke.Color = THEME.Red
    unlStroke.Thickness = 1

    unl.MouseButton1Click:Connect(callbacks.onUnload)
end

function GUI:setVisibleState(isVisible)
    if self.mainFrame then
        self.mainFrame.Visible = isVisible
    end
    if self.modalOverlay then
        self.modalOverlay.Visible = isVisible
    end
    if self.cursorIndicator then
        self.cursorIndicator.Visible = isVisible
    end
    updateToggleButtonText(self.toggleButton, isVisible)
    return isVisible
end

-- Toggle GUI visibility
function GUI:toggleVisibility()
    if self.mainFrame then
        return self:setVisibleState(not self.mainFrame.Visible)
    end
    return false
end

-- Destroy GUI
function GUI:destroy()
    if self.screenGui then
        self.screenGui:Destroy()
    end
    self.screenGui = nil
    self.mainFrame = nil
    self.modalOverlay = nil
    self.cursorIndicator = nil
    self.toggleButton = nil
end

return GUI
