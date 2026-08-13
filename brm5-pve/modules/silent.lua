local TargetSizing = {}

TargetSizing.originalSizes = {} -- Storage for original sizes to restore them later

-- Adjusts the NPC target bounds
function TargetSizing:applyTargetSizing(model, root, config) -- Added colon
    if not self.originalSizes[model] then 
        self.originalSizes[model] = root.Size 
    end
    
    if root.Size ~= config.TARGET_BOX_SIZE then
        root.Size = config.TARGET_BOX_SIZE
    end
    local targetTransparency = config.showTargetBox and 0.85 or 1
    if root.Transparency ~= targetTransparency then
        root.Transparency = targetTransparency -- If showTargetBox is true, you'll see a faint target box
    end
    if not root.CanCollide then
        root.CanCollide = true
    end
end

-- Restores target bounds to their normal size
function TargetSizing:restoreOriginalSize(model, npcManager) -- Added colon
    local data = npcManager:getActiveNPCs()[model] -- Added colon
    local root = data and data.root
    if not root then
        local character = data and data.character
        root = character and npcManager.getRootPart(character) or npcManager.getRootPart(model)
    end
    if root and self.originalSizes[model] then
        root.Size = self.originalSizes[model]
        root.Transparency = 1
        root.CanCollide = false
    end
    self.originalSizes[model] = nil
end

-- Updates target bounds for all NPCs based on config
function TargetSizing:updateAllTargets(npcManager, config) -- Added colon
    if not config.sizingEnabled then
        if next(self.originalSizes) then
            self:cleanup(npcManager) -- Added colon
        end
        return
    end
    for model, data in pairs(npcManager:getActiveNPCs()) do -- Added colon
        if data.root then
            self:applyTargetSizing(model, data.root, config) -- Added colon
        end
    end
end

-- Cleanup all adjusted target bounds
function TargetSizing:cleanup(npcManager) -- Added colon
    for model, _ in pairs(self.originalSizes) do
        self:restoreOriginalSize(model, npcManager) -- Added colon
    end
end

return TargetSizing
