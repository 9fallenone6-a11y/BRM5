-- GUI Module (Rayfield Version)
-- Creates and manages a professional user interface using Rayfield UI Library

local GUI = {}
GUI.Rayfield = nil
GUI.Window = nil

function GUI:init(services, config, callbacks)
    -- 1. Load Rayfield Library safely
    local success, Rayfield = pcall(function()
        return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    end)

    if not success or not Rayfield then
        warn("[GUI] Failed to load Rayfield UI library.")
        return
    end

    self.Rayfield = Rayfield

    -- 2. Create Window
    local Window = Rayfield:CreateWindow({
        Name = "SYSTEM24 // BRM5 v7.0 PVE",
        Icon = 0,
        LoadingTitle = "BRM5 Interface Suite",
        LoadingSubtitle = "by system24",
        Theme = "Default", 
        
        DisableRayfieldPrompts = false,
        DisableBuildWarnings = false,

        ConfigurationSaving = {
            Enabled = true,
            FolderName = "BRM5_Script",
            FileName = "BRM5_Config"
        },

        Discord = {
            Enabled = false,
            Invite = "noinvitelink",
            RememberJoins = true
        },

        KeySystem = false,
    })

    self.Window = Window

    -- 3. Setup Tabs
    local TabCombat = Window:CreateTab("Combat", 4483362458)
    local TabVisuals = Window:CreateTab("Visuals", 4483362458)
    local TabWeapons = Window:CreateTab("Weapons", 4483362458)
    local TabSettings = Window:CreateTab("Settings", 4483362458)

    -- ====================
    -- COMBAT TAB
    -- ====================
    TabCombat:CreateSection("Target Settings")

    TabCombat:CreateToggle({
        Name = "Silent Target",
        CurrentValue = config.sizingEnabled or false,
        Flag = "SilentTargetToggle",
        Callback = function(Value)
            if callbacks.onSizingToggle then callbacks.onSizingToggle(Value) end
        end,
    })

    TabCombat:CreateToggle({
        Name = "Show HitBox",
        CurrentValue = config.showTargetBox or false,
        Flag = "ShowHitBoxToggle",
        Callback = function(Value)
            if callbacks.onShowTargetBoxToggle then callbacks.onShowTargetBoxToggle(Value) end
        end,
    })

    -- ====================
    -- VISUALS TAB
    -- ====================
    TabVisuals:CreateSection("ESP & Lighting")

    TabVisuals:CreateToggle({
        Name = "ESP / Wallhack",
        CurrentValue = config.highlightEnabled or false,
        Flag = "ESPToggle",
        Callback = function(Value)
            if callbacks.onHighlightsToggle then callbacks.onHighlightsToggle(Value) end
        end,
    })

    TabVisuals:CreateColorPicker({
        Name = "Visible ESP Color",
        Color = Color3.fromRGB(config.visibleR or 98, config.visibleG or 209, config.visibleB or 150),
        Flag = "VisibleColorPicker",
        Callback = function(Value)
            if callbacks.onVisibleRChange then callbacks.onVisibleRChange(math.floor(Value.R * 255)) end
            if callbacks.onVisibleGChange then callbacks.onVisibleGChange(math.floor(Value.G * 255)) end
            if callbacks.onVisibleBChange then callbacks.onVisibleBChange(math.floor(Value.B * 255)) end
        end
    })

    TabVisuals:CreateColorPicker({
        Name = "Hidden ESP Color",
        Color = Color3.fromRGB(config.hiddenR or 224, config.hiddenG or 108, config.hiddenB or 117),
        Flag = "HiddenColorPicker",
        Callback = function(Value)
            if callbacks.onHiddenRChange then callbacks.onHiddenRChange(math.floor(Value.R * 255)) end
            if callbacks.onHiddenGChange then callbacks.onHiddenGChange(math.floor(Value.G * 255)) end
            if callbacks.onHiddenBChange then callbacks.onHiddenBChange(math.floor(Value.B * 255)) end
        end
    })

    TabVisuals:CreateToggle({
        Name = "FullBright Light",
        CurrentValue = config.fullBrightEnabled or false,
        Flag = "FullBrightToggle",
        Callback = function(Value)
            if callbacks.onFullBrightToggle then callbacks.onFullBrightToggle(Value) end
        end,
    })

    TabVisuals:CreateSection("Performance")

    TabVisuals:CreateSlider({
        Name = "NPC Range",
        Range = {0, config.MAX_NPC_DETECTION_RADIUS or 5000},
        Increment = 50,
        Suffix = " studs",
        CurrentValue = config.npcDetectionRadius or 1000,
        Flag = "NPCRangeSlider",
        Callback = function(Value)
            if callbacks.onNPCDetectionRadiusChange then callbacks.onNPCDetectionRadiusChange(Value) end
        end,
    })

    TabVisuals:CreateParagraph({
        Title = "Optimization Tip", 
        Content = "If experiencing FPS drops, lower NPC Range. Gradually increase until optimal performance is achieved."
    })

    -- ====================
    -- WEAPONS TAB
    -- ====================
    TabWeapons:CreateSection("Gun Modifiers")

    TabWeapons:CreateParagraph({
        Title = "Notice",
        Content = "! RESET CHAR TO APPLY !"
    })

    TabWeapons:CreateToggle({
        Name = "No Recoil",
        CurrentValue = config.patchOptions and config.patchOptions.recoil or false,
        Flag = "NoRecoilToggle",
        Callback = function(Value)
            if callbacks.onStabilityToggle then callbacks.onStabilityToggle(Value) end
        end,
    })

    TabWeapons:CreateToggle({
        Name = "All Firemodes",
        CurrentValue = config.patchOptions and config.patchOptions.firemodes or false,
        Flag = "AllFiremodesToggle",
        Callback = function(Value)
            if callbacks.onFiremodeOptionsToggle then callbacks.onFiremodeOptionsToggle(Value) end
        end,
    })

    -- ====================
    -- SETTINGS TAB
    -- ====================
    TabSettings:CreateSection("Menu Control")

    TabSettings:CreateButton({
        Name = "Unload Script",
        Callback = function()
            Rayfield:Destroy()
            if callbacks.onUnload then callbacks.onUnload() end
        end,
    })

    TabSettings:CreateSection("Credits & Links")
    
    TabSettings:CreateButton({
        Name = "Copy Discord Link",
        Callback = function()
            if type(setclipboard) == "function" then
                setclipboard("https://discord.gg/yourlink")
                Rayfield:Notify({
                    Title = "Clipboard",
                    Content = "Invite link copied successfully!",
                    Duration = 3,
                    Image = 4483362458
                })
            else
                Rayfield:Notify({
                    Title = "Clipboard Error",
                    Content = "Executor does not support setclipboard.",
                    Duration = 3,
                    Image = 4483362458
                })
            end
        end,
    })

    Rayfield:LoadConfiguration()
end

function GUI:setVisibleState(isVisible)
    -- Rayfield manages visibility internally via keybinds or explicit calls
end

function GUI:toggleVisibility()
    -- Rayfield handles visibility globally via its toggle bind/key
end

function GUI:destroy()
    if self.Rayfield then
        self.Rayfield:Destroy()
    end
end

return GUI
