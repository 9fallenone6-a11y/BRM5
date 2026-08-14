-- GUI Module (Converted to Octernal / Pastebin Library)
-- Replaces broken library.lua with working Drawing UI layout

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local GUI = {}
GUI.Library = nil
GUI.Pointers = nil
GUI.Window = nil
GUI.IsOpen = true

function GUI:init(services, config, callbacks)
    config = config or {}
    callbacks = callbacks or {}

    -- 1. Safely load Octernal UI Library
    local success, loadResult = pcall(function()
        return loadstring(game:HttpGet("https://pastebin.com/raw/Q43KL2RS"))()
    end)

    if not success or not loadResult then
        warn("[GUI] Failed to fetch or parse Octernal UI library.")
        return
    end

    local library, pointers = loadResult
    self.Library = library
    self.Pointers = pointers

    -- 2. Create Window
    local window = library:New({
        name = "Blackhawk Rescue Mission 5 | by 9fallenone6",
        size = Vector2.new(550, 600),
        Accent = Color3.fromRGB(192, 118, 227)
    })
    self.Window = window

    -- 3. Create Main Page
    local mainPage = window:Page({name = "Main", size = 80})

    -- =========================================================================
    -- LEFT COLUMN: COMBAT & WEAPONS
    -- =========================================================================
    
    -- --- Combat Section ---
    local combatSection = mainPage:Section({name = "Combat", side = "Left"})

    combatSection:Toggle({
        pointer = "combat/silent_target",
        name = "Silent Target",
        default = config.sizingEnabled or false,
        callback = function(p_state)
            if callbacks.onSizingToggle then callbacks.onSizingToggle(p_state) end
        end
    })

    combatSection:Toggle({
        pointer = "combat/show_hitbox",
        name = "Show HitBox",
        default = config.showTargetBox or false,
        callback = function(p_state)
            if callbacks.onShowTargetBoxToggle then callbacks.onShowTargetBoxToggle(p_state) end
        end
    })

    -- --- Weapons Section ---
    local weaponsSection = mainPage:Section({name = "Weapons", side = "Left"})

    weaponsSection:Toggle({
        pointer = "weapons/no_recoil",
        name = "No Recoil",
        default = (config.patchOptions and config.patchOptions.recoil) or false,
        callback = function(p_state)
            if callbacks.onStabilityToggle then callbacks.onStabilityToggle(p_state) end
        end
    })

    weaponsSection:Toggle({
        pointer = "weapons/all_firemodes",
        name = "All Firemodes",
        default = (config.patchOptions and config.patchOptions.firemodes) or false,
        callback = function(p_state)
            if callbacks.onFiremodeOptionsToggle then callbacks.onFiremodeOptionsToggle(p_state) end
        end
    })

    -- =========================================================================
    -- RIGHT COLUMN: VISUALS & SETTINGS
    -- =========================================================================

    -- --- Visuals Section ---
    local visualsSection = mainPage:Section({name = "Visuals & Lighting", side = "Right"})

    visualsSection:Toggle({
        pointer = "visuals/esp",
        name = "ESP / Wallhack",
        default = config.highlightEnabled or false,
        callback = function(p_state)
            if callbacks.onHighlightsToggle then callbacks.onHighlightsToggle(p_state) end
        end
    })

    visualsSection:Colorpicker({
        pointer = "visuals/visible_color",
        name = "Visible Color",
        default = Color3.fromRGB(config.visibleR or 98, config.visibleG or 209, config.visibleB or 150),
        callback = function(p_state)
            if callbacks.onVisibleRChange then callbacks.onVisibleRChange(math.floor(p_state.R * 255)) end
            if callbacks.onVisibleGChange then callbacks.onVisibleGChange(math.floor(p_state.G * 255)) end
            if callbacks.onVisibleBChange then callbacks.onVisibleBChange(math.floor(p_state.B * 255)) end
        end
    })

    visualsSection:Colorpicker({
        pointer = "visuals/hidden_color",
        name = "Hidden Color",
        default = Color3.fromRGB(config.hiddenR or 224, config.hiddenG or 108, config.hiddenB or 117),
        callback = function(p_state)
            if callbacks.onHiddenRChange then callbacks.onHiddenRChange(math.floor(p_state.R * 255)) end
            if callbacks.onHiddenGChange then callbacks.onHiddenGChange(math.floor(p_state.G * 255)) end
            if callbacks.onHiddenBChange then callbacks.onHiddenBChange(math.floor(p_state.B * 255)) end
        end
    })

    visualsSection:Toggle({
        pointer = "visuals/fullbright",
        name = "Fullbright",
        default = config.fullBrightEnabled or false,
        callback = function(p_state)
            if callbacks.onFullBrightToggle then callbacks.onFullBrightToggle(p_state) end
        end
    })

    visualsSection:Slider({
        Pointer = "visuals/npc_range",
        Name = "NPC Detection Range",
        Minimum = 0,
        Maximum = config.MAX_NPC_DETECTION_RADIUS or 5000,
        Default = config.npcDetectionRadius or 1000,
        Decimals = 1,
        suffix = " studs",
        callback = function(p_state)
            if callbacks.onNPCDetectionRadiusChange then callbacks.onNPCDetectionRadiusChange(p_state) end
        end
    })

    -- --- Menu & Utilities Section ---
    local settingsSection = mainPage:Section({name = "Menu & Utilities", side = "Right"})

    settingsSection:Button({
        name = "Fix Camera Lock",
        callback = function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
            task.wait(0.05)
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
        end
    })

    settingsSection:Button({
        name = "Copy Discord Link",
        callback = function()
            if type(setclipboard) == "function" then
                setclipboard("https://discord.gg/yourlink")
            end
        end
    })

    settingsSection:Button({
        name = "Unload Script",
        confirmation = true,
        callback = function()
            if self.Window then
                self.Window:Unload()
            end
            if callbacks.onUnload then callbacks.onUnload() end
        end
    })

    -- Finalize UI Initialization
    window.uibind = Enum.KeyCode.End
    window:Initialize()
    self.IsOpen = true
end

function GUI:setVisibleState(isVisible)
    self.IsOpen = isVisible
    if self.Window and self.Window.isVisible ~= isVisible then
        self.Window:Fade()
    end
    if not isVisible then
        task.defer(function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end)
    end
end

function GUI:toggleVisibility()
    if self.Window then
        self.Window:Fade()
        self.IsOpen = self.Window.isVisible
    end
end

function GUI:destroy()
    if self.Window then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        self.Window:Unload()
    end
end

return GUI
