-- GUI Module (Tokyo / Library.lua Version)
-- Replaces Rayfield UI with single segmented tab layout

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local GUI = {}
GUI.Library = nil
GUI.Window = nil
GUI.IsOpen = true

function GUI:init(services, config, callbacks)
    config = config or {}
    callbacks = callbacks or {}

    -- 1. Load library.lua safely from repository
    local success, libraryRaw = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/9fallenone6-a11y/BRM5/refs/heads/main/brm5-pve/library.lua")
    end)

    if not success or not libraryRaw then
        warn("[GUI] Failed to fetch library.lua UI library from URL.")
        return
    end

    local libraryFunc = loadstring(libraryRaw)
    if not libraryFunc then
        warn("[GUI] Failed to parse library.lua.")
        return
    end

    local Library = libraryFunc({cheatname = "BRM5", gamename = "PVE"})
    Library:init()
    self.Library = Library

    -- 2. Create Window
    local Window = Library.NewWindow({
        title = "Blackhawk Rescue Mission 5 | by 9fallenone6",
        size = UDim2.new(0, 520, 0, 440)
    })
    self.Window = Window

    -- 3. Single Main Tab (Segmented into Column 1 and Column 2)
    local MainTab = Window:AddTab("  Main  ")

    -- =========================================================================
    -- COLUMN 1: COMBAT & WEAPONS
    -- =========================================================================
    
    -- --- Combat Section ---
    local CombatSection = MainTab:AddSection("Combat", 1)

    CombatSection:AddToggle({
        text = "Silent Target",
        flag = "SilentTargetToggle",
        state = config.sizingEnabled or false,
        callback = function(Value)
            if callbacks.onSizingToggle then callbacks.onSizingToggle(Value) end
        end
    })

    CombatSection:AddToggle({
        text = "Show HitBox",
        flag = "ShowHitBoxToggle",
        state = config.showTargetBox or false,
        callback = function(Value)
            if callbacks.onShowTargetBoxToggle then callbacks.onShowTargetBoxToggle(Value) end
        end
    })

    -- --- Weapons Section ---
    local WeaponsSection = MainTab:AddSection("Weapons", 1)

    WeaponsSection:AddText({text = "Note: Reset character to apply gun mods!"})

    WeaponsSection:AddToggle({
        text = "No Recoil",
        flag = "NoRecoilToggle",
        state = (config.patchOptions and config.patchOptions.recoil) or false,
        callback = function(Value)
            if callbacks.onStabilityToggle then callbacks.onStabilityToggle(Value) end
        end
    })

    WeaponsSection:AddToggle({
        text = "All Firemodes",
        flag = "AllFiremodesToggle",
        state = (config.patchOptions and config.patchOptions.firemodes) or false,
        callback = function(Value)
            if callbacks.onFiremodeOptionsToggle then callbacks.onFiremodeOptionsToggle(Value) end
        end
    })

    -- =========================================================================
    -- COLUMN 2: VISUALS & SETTINGS
    -- =========================================================================

    -- --- Visuals Section ---
    local VisualsSection = MainTab:AddSection("Visuals & Lighting", 2)

    local espToggle = VisualsSection:AddToggle({
        text = "ESP / Wallhack",
        flag = "ESPToggle",
        state = config.highlightEnabled or false,
        callback = function(Value)
            if callbacks.onHighlightsToggle then callbacks.onHighlightsToggle(Value) end
        end
    })

    -- Attached Visible & Hidden ColorPickers directly to the ESP toggle
    espToggle:AddColor({
        text = "Visible Color",
        color = Color3.fromRGB(config.visibleR or 98, config.visibleG or 209, config.visibleB or 150),
        flag = "VisibleColorPicker",
        callback = function(Value)
            if callbacks.onVisibleRChange then callbacks.onVisibleRChange(math.floor(Value.R * 255)) end
            if callbacks.onVisibleGChange then callbacks.onVisibleGChange(math.floor(Value.G * 255)) end
            if callbacks.onVisibleBChange then callbacks.onVisibleBChange(math.floor(Value.B * 255)) end
        end
    })

    espToggle:AddColor({
        text = "Hidden Color",
        color = Color3.fromRGB(config.hiddenR or 224, config.hiddenG or 108, config.hiddenB or 117),
        flag = "HiddenColorPicker",
        callback = function(Value)
            if callbacks.onHiddenRChange then callbacks.onHiddenRChange(math.floor(Value.R * 255)) end
            if callbacks.onHiddenGChange then callbacks.onHiddenGChange(math.floor(Value.G * 255)) end
            if callbacks.onHiddenBChange then callbacks.onHiddenBChange(math.floor(Value.B * 255)) end
        end
    })

    VisualsSection:AddToggle({
        text = "Fullbright",
        flag = "FullBrightToggle",
        state = config.fullBrightEnabled or false,
        callback = function(Value)
            if callbacks.onFullBrightToggle then callbacks.onFullBrightToggle(Value) end
        end
    })

    VisualsSection:AddSlider({
        text = "NPC Detection Range",
        flag = "NPCRangeSlider",
        min = 0,
        max = config.MAX_NPC_DETECTION_RADIUS or 5000,
        value = config.npcDetectionRadius or 1000,
        increment = 50,
        suffix = " studs",
        callback = function(Value)
            if callbacks.onNPCDetectionRadiusChange then callbacks.onNPCDetectionRadiusChange(Value) end
        end
    })

    VisualsSection:AddText({text = "Tip: Lower range if experiencing FPS drops."})

    -- --- Settings Section ---
    local SettingsSection = MainTab:AddSection("Menu & Utilities", 2)

    SettingsSection:AddButton({
        text = "Fix Camera Lock",
        callback = function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
            task.wait(0.05)
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            Library:SendNotification("Mouse & camera lock reset successfully.", 3)
        end
    })

    SettingsSection:AddButton({
        text = "Copy Discord Link",
        callback = function()
            if type(setclipboard) == "function" then
                setclipboard("https://discord.gg/yourlink")
                Library:SendNotification("Discord invite copied to clipboard!", 3)
            else
                Library:SendNotification("Executor does not support setclipboard.", 3)
            end
        end
    })

    SettingsSection:AddButton({
        text = "Unload Script",
        callback = function()
            if self.Library then
                self.Library:Unload()
            end
            if callbacks.onUnload then callbacks.onUnload() end
        end
    })

    Library:SendNotification("BRM5 Script Loaded Successfully!", 3)
end

function GUI:setVisibleState(isVisible)
    self.IsOpen = isVisible
    if self.Library then
        self.Library:SetOpen(isVisible)
    end
    if not isVisible then
        task.defer(function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end)
    end
end

function GUI:toggleVisibility()
    if self.Library then
        self:setVisibleState(not self.IsOpen)
    end
end

function GUI:destroy()
    if self.Library then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        self.Library:Unload()
    end
end

return GUI
