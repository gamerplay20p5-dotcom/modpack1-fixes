-- Popup pour taper un chiffre à la main et fixer l'ordre de tri.

require ("ISUI/ISPanel")

local ReorderContainersService = require("ReorderContainers/ReorderContainersService")
local T = require("EquipmentUI/Text")

---@class ManualSortingPriorityWindow : ISPanel
---@field private inventoryPage ISInventoryPage
---@field private inventory ItemContainer
---@field private isLootWindow boolean
local ManualSortingPriorityWindow = ISPanel:derive("ManualSortingPriorityWindow")

---@param x number
---@param y number
---@param inventoryPage ISInventoryPage
---@param inventory ItemContainer
---@return ManualSortingPriorityWindow
function ManualSortingPriorityWindow:new(x, y, inventoryPage, inventory)
    ---@type ManualSortingPriorityWindow
    local o = ISPanel:new(x, y, 280, 135)
    setmetatable(o, self)
    self.__index = self

    o.backgroundColor.a = 0.9
    
    o.inventoryPage = inventoryPage
    o.inventory = inventory

    local lootPage = getPlayerLoot(inventoryPage.player)
    if lootPage == inventoryPage then
        o.isLootWindow = true
    end

    return o
end

function ManualSortingPriorityWindow:initialise()
    ISPanel.initialise(self)
end

function ManualSortingPriorityWindow:createChildren()
    local y = 0
    
    if self.isLootWindow then
        y = y + 10

        self.lootCheckbox = ISTickBox:new(15, y, 20, 20, "")
        self.lootCheckbox:initialise()
        self.lootCheckbox:addOption(T("UI_reorder_containers_sort_loot_checkbox"), true)
        self.lootCheckbox:setSelected(1, ReorderContainersService.getSortLootWindow(getSpecificPlayer(self.inventoryPage.player)))
        self:addChild(self.lootCheckbox)

        y = y + 20
    end

    y = y + 10
    self.label = ISLabel:new(0, y, 10, self:getTargetName() or T("UI_reorder_containers_container_fallback"), 1, 1, 1, 1, UIFont.Small, true)
    self.label:initialise()
    self.label:instantiate()
    self.label:setX(self:getWidth() / 2 - self.label:getWidth() / 2)
    self:addChild(self.label)

    y = y + 28
    self.infoLabel = ISLabel:new(0, y, 10, T("UI_reorder_containers_sorting_priority"), 1, 1, 1, 0.7, UIFont.Small, true)
    self.infoLabel:initialise()
    self.infoLabel:instantiate()
    self.infoLabel:setX(self:getWidth() / 2 - self.infoLabel:getWidth() / 2)
    self:addChild(self.infoLabel)

    local player = getSpecificPlayer(self.inventoryPage.player)
    local currentValue = ReorderContainersService.getSortPriority(player, self.inventory, self.inventoryPage)

    y = y + 28
    self.entry = ISTextEntryBox:new(tostring(currentValue), 0, y, 100, 20)
    self.entry:initialise()
    self.entry:instantiate()
    self.entry:setOnlyNumbers(true)
    self.entry:setTooltip(T("UI_reorder_containers_entry_tooltip"))
    self.entry:setX(self:getWidth() / 2 - self.entry:getWidth() / 2)
    self:addChild(self.entry)

    y = y + 26
    self.hintLabel = ISLabel:new(0, y, 10, T("UI_reorder_containers_priority_hint"), 1, 1, 1, 0.6, UIFont.Small, true)
    self.hintLabel:initialise()
    self.hintLabel:instantiate()
    self.hintLabel:setX(self:getWidth() / 2 - self.hintLabel:getWidth() / 2)
    self:addChild(self.hintLabel)

    y = y + 38
    if y > self:getHeight() then
        self:setHeight(y)
    end

    self.okButton = ISButton:new(self:getWidth() / 2 - 100, self:getHeight() - 25, 100, 25, getText("UI_Ok"), self, self.onOK)
    self.okButton:initialise()
    self.okButton:instantiate()
    self:addChild(self.okButton)

    self.cancelButton = ISButton:new(self:getWidth() / 2, self:getHeight() - 25, 100, 25, getText("UI_Cancel"), self, self.onCancel)
    self.cancelButton:initialise()
    self.cancelButton:instantiate()
    self:addChild(self.cancelButton)

    self:bringToTop()
end

function ManualSortingPriorityWindow:getTargetName()
    local player = getSpecificPlayer(self.inventoryPage.player)

    if self.inventory == player:getInventory() then
        return getText("IGUI_InventoryName", player:getDescriptor():getForename(), player:getDescriptor():getSurname())
    else
        local item = self.inventory:getContainingItem()
        if item then
            return item:getName()
        else
            return getTextOrNull("IGUI_ContainerTitle_" .. self.inventory:getType()) or ""
        end
    end
end

function ManualSortingPriorityWindow:onOK()
    local player = getSpecificPlayer(self.inventoryPage.player)
    local number = tonumber(self.entry:getText())
    if number then
        ReorderContainersService.setSortPriority(player, self.inventory, number, true)
    else
        ReorderContainersService.setSortPriority(player, self.inventory, nil, false)
    end

    ReorderContainersService.setSortLootWindow(player, self.lootCheckbox.selected[1])

    self.inventoryPage:refreshBackpacks()
    self:removeFromUIManager()

    self.inventoryPage:updateReorderContainersLock()
end

function ManualSortingPriorityWindow:onCancel()
    self:removeFromUIManager()
end

return ManualSortingPriorityWindow