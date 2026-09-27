local SETTINGS = require("EquipmentUI/Settings")

-- Bascule l'UI quand on appuie sur le bouton select de la manette
local og_ISInventoryPage_onJoypadDown = ISInventoryPage.onJoypadDown
function ISInventoryPage:onJoypadDown(button)
    og_ISInventoryPage_onJoypadDown(self, button)

    local playerNum = self.player

    local inventoryPage = getPlayerInventory(playerNum)
    if not inventoryPage then return end

    if button == SETTINGS.TOGGLE_UI_CONTROLLER_BIND then
        if SETTINGS.InventoryTetris then
            if inventoryPage.equipmentUiPanel and inventoryPage.equipmentUiPanel.isClosed then
                self:toggleEquipmentUIForController()
            end 
            setJoypadFocus(playerNum, inventoryPage.equipmentUiPanel);
        else
            self:toggleEquipmentUIForController()
        end
    end
end

-- Redimensionne les UI lors du basculement de l'UI d'équipement
local standAloneOpen = false
function ISInventoryPage:toggleEquipmentUIForController()
    local playerNum = self.player
    if not playerNum then return end

    local inventoryPage = getPlayerInventory(playerNum)
    if not inventoryPage then return end

    local lootPage = getPlayerLoot(playerNum)
    if not lootPage then return end

    local equipmentPanel = inventoryPage.equipmentUiPanel
    if not equipmentPanel then return end

    equipmentPanel.isClosed = not equipmentPanel.isClosed
    equipmentPanel:setVisible(not equipmentPanel.isClosed)

    -- Redimensionne le butin seulement s'il est aligné juste à droite du joueur, sans grand espace entre les deux
    local resizeLoot = 
        lootPage:getY() == inventoryPage:getY() and 
        lootPage:getHeight() == inventoryPage:getHeight() and
        lootPage:getX() > inventoryPage:getX() and
        lootPage:getX() - (inventoryPage:getX() + inventoryPage:getWidth()) < 200


    -- Ne redimensionne pas les UI si l'UI d'équipement est détachée
    if not equipmentPanel.isDocked then
        return
    end

    local x = getPlayerScreenLeft(self.player) + 0.0
    local w = 0.0

    -- S'il y a la place, on ouvre l'UI d'équipement sans redimensionner le reste
    if not equipmentPanel.isClosed and inventoryPage:getX() - equipmentPanel:getWidth() > x then
        standAloneOpen = true
        return
    end

    if standAloneOpen then
        standAloneOpen = false
        return -- Ferme simplement l'UI d'équipement sans redimensionner les autres UI
    end


    if not resizeLoot then
        x = inventoryPage:getX()
        w = inventoryPage:getWidth()
    else
        x = inventoryPage:getX()
        w = lootPage:getX() + lootPage:getWidth() - x
    end

    if not equipmentPanel.isClosed then
        x = x + equipmentPanel:getWidth()
        w = w - equipmentPanel:getWidth()
    else
        x = x - equipmentPanel:getWidth()
        w = w + equipmentPanel:getWidth()
    end

    if resizeLoot then
        inventoryPage:setWidth(w/2)
        inventoryPage:setX(x)
        lootPage:setWidth(w/2)
        lootPage:setX(x + w/2)
    else
        inventoryPage:setWidth(w)
        inventoryPage:setX(x)
    end
end

--  Gère le changement de focus entre les inventaires et les UI d'équipement
local og_ISInventoryPage_onJoypadDirLeft = ISInventoryPage.onJoypadDirLeft
function ISInventoryPage:onJoypadDirLeft(joypadData)
    og_ISInventoryPage_onJoypadDirLeft(self, joypadData)
    if self == getPlayerInventory(self.player) then
        if self.equipmentUiPanel:isVisible() then
            setJoypadFocus(self.player, self.equipmentUiPanel);
        end
    end
end

local og_ISInventoryPage_onJoypadDirRight = ISInventoryPage.onJoypadDirRight
function ISInventoryPage:onJoypadDirRight(joypadData)
    og_ISInventoryPage_onJoypadDirRight(self, joypadData)
    if self == getPlayerLoot(self.player) then
        local inventoryPage = getPlayerInventory(self.player)
        if not inventoryPage then return end

        local equipmentUi = inventoryPage.equipmentUiPanel
        if equipmentUi:isVisible() then
            setJoypadFocus(self.player, equipmentUi);
        end
    end
end

