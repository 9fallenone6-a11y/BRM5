-- GUI Module (LinoriaLib Version)
-- Creates and manages a professional exploit-style user interface

local GUI = {}
GUI.Library = nil

function GUI:init(services, config, callbacks)
    -- 1. Load LinoriaLib and Addons
    local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
    local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
    local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
    local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
    
    self.Library = Library

    -- 2. Create the Main Window
    local Window = Library:CreateWindow({
        Title = 'BRM5 v7.0 PVE | Linoria',
        Center = true,
        AutoShow = config.guiVisible,
        TabPadding = 8,
        MenuFadeTime = 0.2
    })

    -- 3. Setup Tabs
    local Tabs = {
        Combat = Window:AddTab('Combat'),
        Visuals = Window:AddTab('Visuals'),
        Weapons = Window:AddTab('Weapons'),
        Settings = Window:AddTab('Settings') -- Consolidated Colors/Credits into Settings
    }

    -- ====================
    -- COMBAT TAB
    -- ====================
    local CombatMain = Tabs.Combat:AddLeftGroupbox('Target Modification')
    
    CombatMain:AddToggle('SizingEnabled', {
        Text = 'Silent Target',
        Default = config.sizingEnabled or false,
        Tooltip = 'Adjusts NPC target bounds',
        Callback = function(Value)
            if callbacks.onSizingToggle then callbacks.onSizingToggle(Value) end
        end
    })

    CombatMain:AddToggle('ShowHitBox', {
        Text = 'Show HitBox',
        Default = config.showTargetBox or false,
        Callback = function(Value)
            if callbacks.onShowTargetBoxToggle then callbacks.onShowTargetBoxToggle(Value) end
        end
    })

    -- ====================
    -- VISUALS TAB
    -- ====================
    local EspGroup = Tabs.Visuals:AddLeftGroupbox('ESP & Lighting')
    
    -- Combines your Highlight toggle with your Color Sliders using inline color pickers
    EspGroup:AddToggle('HighlightEnabled', {
        Text = 'ESP / Wallhack',
        Default = config.highlightEnabled or false,
        Callback = function(Value)
            if callbacks.onHighlightsToggle then callbacks.onHighlightsToggle(Value) end
        end
    }):AddColorPicker('VisibleColor', {
        Default = Color3.fromRGB(config.visibleR or 98, config.visibleG or 209, config.visibleB or 150),
        Title = 'Visible ESP Color',
        Transparency = 0,
        Callback = function(Value)
            if callbacks.onVisibleRChange then callbacks.onVisibleRChange(math.floor(Value.R * 255)) end
            if callbacks.onVisibleGChange then callbacks.onVisibleGChange(math.floor(Value.G * 255)) end
            if callbacks.onVisibleBChange then callbacks.onVisibleBChange(math.floor(Value.B * 255)) end
        end
    }):AddColorPicker('HiddenColor', {
        Default = Color3.fromRGB(config.hiddenR or 224, config.hiddenG or 108, config.hiddenB or 117),
        Title = 'Hidden ESP Color',
        Transparency = 0,
        Callback = function(Value)
            if callbacks.onHiddenRChange then callbacks.onHiddenRChange(math.floor(Value.R * 255)) end
            if callbacks.onHiddenGChange then callbacks.onHiddenGChange(math.floor(Value.G * 255)) end
            if callbacks.onHiddenBChange then callbacks.onHiddenBChange(math.floor(Value.B * 255)) end
        end
    })

    EspGroup:AddToggle('FullBright', {
        Text = 'FullBright Light',
        Default = config.fullBrightEnabled or false,
        Callback = function(Value)
            if callbacks.onFullBrightToggle then callbacks.onFullBrightToggle(Value) end
        end
    })
    
    local PerformanceGroup = Tabs.Visuals:AddRightGroupbox('Optimization')
    
    PerformanceGroup:AddSlider('NPCRange', {
        Text = 'NPC Range',
        Default = config.npcDetectionRadius or 1000,
        Min = 0,
        Max = config.MAX_NPC_DETECTION_RADIUS or 5000,
        Rounding = 0,
        Compact = false,
        Callback = function(Value)
            if callbacks.onNPCDetectionRadiusChange then callbacks.onNPCDetectionRadiusChange(Value) end
        end
    })
    PerformanceGroup:AddLabel('Lower range if experiencing FPS drops.'):SetStyle('Secondary')

    -- ====================
    -- WEAPONS TAB
    -- ====================
    local WeaponMods = Tabs.Weapons:AddLeftGroupbox('Gun Mods')
    
    WeaponMods:AddLabel('! RESET CHAR TO APPLY !')
    
    WeaponMods:AddToggle('NoRecoil', {
        Text = 'No Recoil',
        Default = config.patchOptions and config.patchOptions.recoil or false,
        Callback = function(Value)
            if callbacks.onStabilityToggle then callbacks.onStabilityToggle(Value) end
        end
    })
    
    WeaponMods:AddToggle('AllFiremodes', {
        Text = 'All Firemodes',
        Default = config.patchOptions and config.patchOptions.firemodes or false,
        Callback = function(Value)
            if callbacks.onFiremodeOptionsToggle then callbacks.onFiremodeOptionsToggle(Value) end
        end
    })

    -- ====================
    -- SETTINGS & CONFIG TAB
    -- ====================
    local MenuGroup = Tabs.Settings:AddLeftGroupbox('Menu Options')
    
    MenuGroup:AddButton('Unload Script', function()
        Library:Unload()
        if callbacks.onUnload then callbacks.onUnload() end
    end)
    
    -- Sets up the UI toggle key (Default: Right Shift)
    MenuGroup:AddLabel('Menu Bind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })
    Library.ToggleKeybind = Options.MenuKeybind 
    
    local CreditsGroup = Tabs.Settings:AddRightGroupbox('Credits & Links')
    CreditsGroup:AddLabel('SYSTEM24 // BRM5 v7.0 PVE')
    CreditsGroup:AddButton('Copy Discord Link', function()
        if type(setclipboard) == "function" then
            setclipboard("https://discord.gg/yourlink")
            Library:Notify("Invite copied to clipboard!")
        else
            Library:Notify("Your executor does not support setclipboard.", 3)
        end
    end)

    -- 4. Setup Theme and Save Managers (The Customizability)
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)

    -- Ignore the menu keybind so it doesn't get overwritten by configs
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
    
    -- Creates folders in your workspace for saving configs/themes
    ThemeManager:SetFolder('BRM5_Script')
    SaveManager:SetFolder('BRM5_Script/main')

    -- Builds the actual UI sections in the Settings tab
    SaveManager:BuildConfigSection(Tabs.Settings)
    ThemeManager:BuildThemeSection(Tabs.Settings)
    
    -- Load the user's custom theme automatically
    ThemeManager:ApplyToTab(Tabs.Settings)
    
    Library:Notify('BRM5 Script Loaded Successfully!', 3)
end

function GUI:toggleVisibility()
    if self.Library then
        self.Library:Toggle()
    end
end

function GUI:setVisibleState(isVisible)
    -- Linoria handles internal state via Library:Toggle()
    -- We can sync it if the script forces a state externally:
    if self.Library and self.Library.Keybit ~= isVisible then
        self.Library:Toggle()
    end
end

function GUI:destroy()
    if self.Library then
        self.Library:Unload()
    end
end

return GUI
