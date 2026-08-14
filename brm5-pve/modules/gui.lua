-- GUI Module (Octohook Version)
-- Creates and manages user interface using Octohook UI Library

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local GUI = {}
GUI.Library = nil
GUI.Window = nil
GUI.IsOpen = true -- Tracks window state to handle camera locking properly

function GUI:init(services, config, callbacks)
    config = config or {}
    callbacks = callbacks or {}

    -- 1. Load Octohook Library safely
    local success, library = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/portallol/luna/main/src/main.lua"))() 
            or getgenv().library
    end)

    if not success or not library then
        library = getgenv().library
    end

    if not library then
        warn("[GUI] Failed to load Octohook UI library.")
        return
    end

    self.Library = library
    if library.init then
        library:init()
    end

    -- 2. Create Window
    local Window = library.NewWindow({
        title = "Blackhawk Rescue Mission 5",
        size = UDim2.new(0, 550, 0, 600),
        position = UDim2.new(0.5, -275, 0.5, -300)
    })

    self.Window = Window

    -- 3. Setup Tabs
    local TabCombat = Window:AddTab("Combat")
    local TabVisuals = Window:AddTab("Visuals")
    local TabWeapons = Window:AddTab("Weapons")
    local TabSettings = Window:AddTab("Settings")

    -- ====================
    -- COMBAT TAB
    -- ====================
    local SecTarget = TabCombat:AddSection("Target Settings", 1, 1)

    SecTarget:AddToggle({
        text = "Silent Target",
        flag = "SilentTargetToggle",
        state = config.sizingEnabled or false,
        callback = function(Value)
            if callbacks.onSizingToggle then callbacks.onSizingToggle(Value) end
        end
    })

    SecTarget:AddToggle({
        text = "Show HitBox",
        flag = "ShowHitBoxToggle",
        state = config.showTargetBox or false,
        callback = function(Value)
            if callbacks.onShowTargetBoxToggle then callbacks.onShowTargetBoxToggle(Value) end
        end
    })

    -- ====================
    -- VISUALS TAB
    -- ====================
    local SecESP = TabVisuals:AddSection("ESP & Lighting", 1, 1)

    SecESP:AddToggle({
        text = "ESP / Wallhack",
        flag = "ESPToggle",
        state = config.highlightEnabled or false,
        callback = function(Value)
            if callbacks.onHighlightsToggle then callbacks.onHighlightsToggle(Value) end
        end
    })

    SecESP:AddColorPicker({
        text = "Visible ESP Color",
        flag = "VisibleColorPicker",
        color = Color3.fromRGB(config.visibleR or 98, config.visibleG or 209, config.visibleB or 150),
        callback = function(Value)
            if callbacks.onVisibleRChange then callbacks.onVisibleRChange(math.floor(Value.R * 255)) end
            if callbacks.onVisibleGChange then callbacks.onVisibleGChange(math.floor(Value.G * 255)) end
            if callbacks.onVisibleBChange then callbacks.onVisibleBChange(math.floor(Value.B * 255)) end
        end
    })

    SecESP:AddColorPicker({
        text = "Hidden ESP Color",
        flag = "HiddenColorPicker",
        color = Color3.fromRGB(config.hiddenR or 224, config.hiddenG or 108, config.hiddenB or 117),
        callback = function(Value)
            if callbacks.onHiddenRChange then callbacks.onHiddenRChange(math.floor(Value.R * 255)) end
            if callbacks.onHiddenGChange then callbacks.onHiddenGChange(math.floor(Value.G * 255)) end
            if callbacks.onHiddenBChange then callbacks.onHiddenBChange(math.floor(Value.B * 255)) end
        end
    })

    SecESP:AddToggle({
        text = "Fullbright",
        flag = "FullBrightToggle",
        state = config.fullBrightEnabled or false,
        callback = function(Value)
            if callbacks.onFullBrightToggle then callbacks.onFullBrightToggle(Value) end
        end
    })

    local SecPerf = TabVisuals:AddSection("Performance", 2, 1)

    SecPerf:AddSlider({
        text = "NPC Range",
        flag = "NPCRangeSlider",
        min = 0,
        max = config.MAX_NPC_DETECTION_RADIUS or 5000,
        value = config.npcDetectionRadius or 1000,
        suffix = " studs",
        callback = function(Value)
            if callbacks.onNPCDetectionRadiusChange then callbacks.onNPCDetectionRadiusChange(Value) end
        end
    })

    SecPerf:AddLabel({
        text = "Optimization Tip: If experiencing FPS drops, lower NPC Range. Gradually increase until optimal performance is achieved."
    })

    -- ====================
    -- WEAPONS TAB
    -- ====================
    local SecGunMods = TabWeapons:AddSection("Gun Modifiers", 1, 1)

    SecGunMods:AddLabel({
        text = "Notice: Reset character to apply!"
    })

    SecGunMods:AddToggle({
        text = "No Recoil",
        flag = "NoRecoilToggle",
        state = (config.patchOptions and config.patchOptions.recoil) or false,
        callback = function(Value)
            if callbacks.onStabilityToggle then callbacks.onStabilityToggle(Value) end
        end
    })

    SecGunMods:AddToggle({
        text = "All Firemodes",
        flag = "AllFiremodesToggle",
        state = (config.patchOptions and config.patchOptions.firemodes) or false,
        callback = function(Value)
            if callbacks.onFiremodeOptionsToggle then callbacks.onFiremodeOptionsToggle(Value) end
        end
    })

    -- ====================
    -- SETTINGS TAB
    -- ====================
    local SecMenu = TabSettings:AddSection("Menu Control", 1, 1)

    SecMenu:AddButton({
        text = "Fix Camera Lock",
        callback = function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
            task.wait(0.05)
            LocalPlayer.CameraMode = Enum.CameraMode.Classic

            if library.SendNotification then
                library:SendNotification({
                    Title = "Camera Fixed",
                    Text = "Mouse and camera lock have been successfully reset.",
                    Duration = 2
                })
            end
        end
    })

    SecMenu:AddButton({
        text = "Unload Script",
        callback = function()
            self:destroy()
            if callbacks.onUnload then callbacks.onUnload() end
        end
    })

    local SecCredits = TabSettings:AddSection("Credits & Links", 2, 1)

    SecCredits:AddButton({
        text = "Copy Discord Link",
        callback = function()
            if type(setclipboard) == "function" then
                setclipboard("https://discord.gg/yourlink")
                if library.SendNotification then
                    library:SendNotification({
                        Title = "Clipboard",
                        Text = "Invite link copied successfully!",
                        Duration = 3
                    })
                end
            else
                if library.SendNotification then
                    library:SendNotification({
                        Title = "Clipboard Error",
                        Text = "Executor does not support setclipboard.",
                        Duration = 3
                    })
                end
            end
        end
    })

    if Window.SetOpen then
        Window:SetOpen(true)
    elseif library.SetOpen then
        library:SetOpen(true)
    end
end

function GUI:setVisibleState(isVisible)
    self.IsOpen = isVisible
    if self.Window and self.Window.SetOpen then
        self.Window:SetOpen(isVisible)
    elseif self.Library and self.Library.SetOpen then
        self.Library:SetOpen(isVisible)
    end

    if not isVisible then
        task.defer(function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end)
    end
end

function GUI:toggleVisibility()
    self.IsOpen = not self.IsOpen
    self:setVisibleState(self.IsOpen)
end

function GUI:destroy()
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    if self.Library and self.Library.Unload then
        self.Library:Unload()
    elseif self.Window and self.Window.Destroy then
        self.Window:Destroy()
    end
end

return GUI
