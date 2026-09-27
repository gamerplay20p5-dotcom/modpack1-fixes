-- Porte du module : si le joueur a décoché la case, on n'installe rien du tout, pour laisser
-- la place à un autre mod. Voir EquipmentUI/ModuleFlags.lua.
if not require("EquipmentUI/ModuleFlags").containerReorder then return end

local ReorderContainersService = require("ReorderContainers/ReorderContainersService")
local ManualSortingPriorityWindow = require("ReorderContainers/UI/ManualSortingPriorityWindow")
local T = require("EquipmentUI/Text")

local LOCK_TEX = getTexture("media/ui/ReorderContainers/reorder-locked.png")
local UNLOCK_TEX = getTexture("media/ui/ReorderContainers/reorder-unlocked.png")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

-- Tooltip maison au lieu de celle d'ISButton : le ISToolTip vanilla a une largeur mini
-- de 220px en dur (ISToolTip.lua:369), trop large pour un mot seul comme "Locked".
---@param self ISInventoryPage
---@param button ISButton
---@param text string
local function drawSmallTooltip(self, button, text)
    local textWid = getTextManager():MeasureStringX(UIFont.Small, text)
    local bx = button:getX() + button:getWidth() - textWid
    local by = button:getY() - FONT_HGT_SMALL - 8
    self:drawRect(bx - 4, by - 2, textWid + 8, FONT_HGT_SMALL + 4, 0.8, 0, 0, 0)
    self:drawRectBorderStatic(bx - 4, by - 2, textWid + 8, FONT_HGT_SMALL + 4, 0.5, 0.9, 0.9, 1)
    self:drawText(text, bx, by, 1, 1, 1, 1, UIFont.Small)
end

---@param inventoryPage ISInventoryPage
---@return boolean
local function isReorderLocked(inventoryPage)
    return ReorderContainersService.isLocked(inventoryPage) or not ReorderContainersService.isSortingEnabled(inventoryPage)
end

---@param inventoryPage ISInventoryPage
---@param lockButton ISButton
local function updateLock(inventoryPage, lockButton)
    local newState = nil
    if inventoryPage.onCharacter then
        newState = ReorderContainersService.toggleInventoryLock(getSpecificPlayer(inventoryPage.player))
    else
        newState = ReorderContainersService.toggleLootLock(getSpecificPlayer(inventoryPage.player))
    end

    if newState or not ReorderContainersService.isSortingEnabled(inventoryPage) then
        lockButton:setImage(getTexture("media/ui/ReorderContainers/reorder-locked.png"))
    else
        lockButton:setImage(getTexture("media/ui/ReorderContainers/reorder-unlocked.png"))
    end
end


local og_createChildren = ISInventoryPage.createChildren
function ISInventoryPage:createChildren()
    og_createChildren(self)
    
    local inventoryPage = self
    
    local buttonSize = self.buttonSize/2 -- La moitié de la taille des icônes de conteneur d'inventaire
    local xPos = self:getWidth() - buttonSize
    local yPos = self:getHeight() - buttonSize - self:titleBarHeight()
    
    local reorderButton = ISButton:new(xPos, yPos, buttonSize, buttonSize+4, "", self)
    reorderButton.anchorTop = false
    reorderButton.anchorLeft = false
    reorderButton.anchorBottom = true
    reorderButton.anchorRight = true
    reorderButton.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    reorderButton:setImage(getTexture("media/ui/ReorderContainers/reorder-icon.png"))
    reorderButton:initialise()
    reorderButton:instantiate()
    self:addChild(reorderButton)
    self.reorderOptionsButton = reorderButton

    reorderButton:setOnClick(function()
        if not ReorderContainersService.isContainerReorderEnabled() then
            return
        end
        ---@type SortableBackpackButton
        local selectedButton = inventoryPage.selectedButton
        if selectedButton then
            local x = getCore():getScreenWidth() / 2
            local y = getCore():getScreenHeight() / 2
            local popup = ManualSortingPriorityWindow:new(x - 140, y - 67, inventoryPage, selectedButton.inventory)
            popup:initialise()
            popup:setAlwaysOnTop(true)
            popup:setCapture(true)
            popup:addToUIManager()
        end
    end)

    xPos = xPos - buttonSize
    local lockButton = ISButton:new(xPos, yPos, buttonSize, buttonSize+4, "", self)
    lockButton.anchorTop = false
    lockButton.anchorLeft = false
    lockButton.anchorBottom = true
    lockButton.anchorRight = true
    lockButton.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    lockButton:initialise()
    lockButton:instantiate()
    self:addChild(lockButton)
    self.reorderLockButton = lockButton

    local isLocked = isReorderLocked(inventoryPage)
    lockButton:setImage(isLocked and LOCK_TEX or UNLOCK_TEX)

    lockButton:setOnClick(function()
        if not ReorderContainersService.isContainerReorderEnabled() then
            return
        end
        if not ReorderContainersService.isSortingEnabled(self) then
            self.reorderOptionsButton:onMouseDown(0,0)
            return
        end
        updateLock(self, lockButton)
    end)
end

local og_render = ISInventoryPage.render
function ISInventoryPage:render()
    og_render(self)

    local enabled = ReorderContainersService.isContainerReorderEnabled()
    if self.reorderLockButton then
        self.reorderLockButton:setVisible(enabled)
    end
    if self.reorderOptionsButton then
        self.reorderOptionsButton:setVisible(enabled)
    end
    if not enabled then
        return
    end

    if self.reorderLockButton and self.reorderLockButton:isMouseOver() then
        local isLocked = isReorderLocked(self)
        drawSmallTooltip(self, self.reorderLockButton, isLocked and T("UI_reorder_containers_lock_tooltip_locked") or T("UI_reorder_containers_lock_tooltip_unlocked"))
    elseif self.reorderOptionsButton and self.reorderOptionsButton:isMouseOver() then
        drawSmallTooltip(self, self.reorderOptionsButton, T("UI_reorder_containers_sort_tooltip"))
    end
end

ISInventoryPage.updateReorderContainersLock = function(self)
    if self.onCharacter then
        return
    end

    ReorderContainersService.toggleLootLock(getSpecificPlayer(self.player))
    updateLock(self, self.reorderLockButton)
end
