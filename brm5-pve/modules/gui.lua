-- GUI Module (Converted to Bracket V3 UI Library - Monochrome Edition)

local Bracket = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Bracket/main/BracketV32.lua"))()
local UserInputService = game:GetService("UserInputService")

local GUI = {}
GUI.Window = nil
GUI.IsOpen = true

function GUI:init(services, config, callbacks)
    config = config or {}
    callbacks = callbacks or {}

    -- 🎨 Monochrome Theme Accent (Neutral Light Gray)
    local monochromeAccent = Color3.fromRGB(180, 180, 180)

    -- 1. Initialize Bracket Window
    local Window = Bracket:Window({
        Name = "Blackhawk Rescue Mission 5 | Monochrome",
        Enabled = true,
        Color = monochromeAccent,
        Size = UDim2.new(0, 496, 0, 496),
        Position = UDim2.new(0.5, -248, 0.5, -248)
    })
    self.Window = Window

    -- 2. Build Main Tab
    local MainTab = Window:Tab({Name = "Main"})

    -- Left Column: Combat & Weapons
    local CombatSection = MainTab:Section({Name = "Combat", Side = "Left"})
    
    CombatSection:Toggle({
        Name = "Silent Target",
        Value = config.sizingEnabled or false,
        Callback = function(state)
            if callbacks.onSizingToggle then callbacks.onSizingToggle(state) end
        end
    })

    CombatSection:Toggle({
        Name = "Show HitBox",
        Value = config.showTargetBox or false,
        Callback = function(state)
            if callbacks.onShowTargetBoxToggle then callbacks.onShowTargetBoxToggle(state) end
        end
    })

    local WeaponsSection = MainTab:Section({Name = "Weapons", Side = "Left"})

    WeaponsSection:Toggle({
        Name = "No Recoil",
        Value = (config.patchOptions and config.patchOptions.recoil) or false,
        Callback = function(state)
            if callbacks.onStabilityToggle then callbacks.onStabilityToggle(state) end
        end
    })

    WeaponsSection:Toggle({
        Name = "All Firemodes",
        Value = (config.patchOptions and config.patchOptions.firemodes) or false,
        Callback = function(state)
            if callbacks.onFiremodeOptionsToggle then callbacks.onFiremodeOptionsToggle(state) end
        end
    })

    -- Right Column: Visuals & Lighting
    local VisualsSection = MainTab:Section({Name = "Visuals & Lighting", Side = "Right"})

    VisualsSection:Toggle({
        Name = "ESP / Wallhack",
        Value = config.highlightEnabled or false,
        Callback = function(state)
            if callbacks.onHighlightsToggle then callbacks.onHighlightsToggle(state) end
        end
    })

    VisualsSection:Colorpicker({
        Name = "Visible Color",
        -- Defaulting to White for monochrome theme
        Color = Color3.fromRGB(config.visibleR or 255, config.visibleG or 255, config.visibleB or 255),
        Callback = function(color)
            if callbacks.onVisibleRChange then callbacks.onVisibleRChange(math.floor(color.R * 255)) end
            if callbacks.onVisibleGChange then callbacks.onVisibleGChange(math.floor(color.G * 255)) end
            if callbacks.onVisibleBChange then callbacks.onVisibleBChange(math.floor(color.B * 255)) end
        end
    })

    VisualsSection:Colorpicker({
        Name = "Hidden Color",
        -- Defaulting to Dark Gray for monochrome theme
        Color = Color3.fromRGB(config.hiddenR or 100, config.hiddenG or 100, config.hiddenB or 100),
        Callback = function(color)
            if callbacks.onHiddenRChange then callbacks.onHiddenRChange(math.floor(color.R * 255)) end
            if callbacks.onHiddenGChange then callbacks.onHiddenGChange(math.floor(color.G * 255)) end
            if callbacks.onHiddenBChange then callbacks.onHiddenBChange(math.floor(color.B * 255)) end
        end
    })

    VisualsSection:Toggle({
        Name = "Fullbright",
        Value = config.fullBrightEnabled or false,
        Callback = function(state)
            if callbacks.onFullBrightToggle then callbacks.onFullBrightToggle(state) end
        end
    })

    VisualsSection:Slider({
        Name = "NPC Detection Range",
        Min = 0,
        Max = config.MAX_NPC_DETECTION_RADIUS or 5000,
        Value = config.npcDetectionRadius or 1000,
        Precise = 0,
        Unit = " studs",
        Callback = function(value)
            if callbacks.onNPCDetectionRadiusChange then callbacks.onNPCDetectionRadiusChange(value) end
        end
    })

    -- 3. Build Config Tab
    local ConfigTab = Window:Tab({Name = "Config"})
    
    local UtilsSection = ConfigTab:Section({Name = "Menu & Utilities", Side = "Left"})

    UtilsSection:Button({
        Name = "Unload Script",
        Callback = function()
            self:destroy()
            if callbacks.onUnload then callbacks.onUnload() end
        end
    })

    -- Bind Key (End key toggles menu)
    UserInputService.InputEnded:Connect(function(key)
        if key.KeyCode == Enum.KeyCode.End then
            self:toggleVisibility()
        end
    end)
    
    Bracket:Notification({
        Title = "Script Loaded",
        Description = "Press END to toggle the menu.",
        Duration = 5
    })

    self.IsOpen = true
end

function GUI:setVisibleState(isVisible)
    self.IsOpen = isVisible
    if self.Window then
        self.Window:Toggle(isVisible)
    end
end

function GUI:toggleVisibility()
    self.IsOpen = not self.IsOpen
    if self.Window then
        self.Window:Toggle(self.IsOpen)
    end
end

function GUI:destroy()
    if self.Window and self.Window.Background and self.Window.Background.Parent then
        self.Window.Background.Parent:Destroy()
        self.Window = nil
    end
end

return GUI
