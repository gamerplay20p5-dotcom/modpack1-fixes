-- Porte du module : si le joueur a décoché la case, on n'installe rien du tout, pour laisser
-- la place à un autre mod. Voir EquipmentUI/ModuleFlags.lua.
if not require("EquipmentUI/ModuleFlags").containerReorder then return end

local ReorderContainersService = require("ReorderContainers/ReorderContainersService")

local og_onJoypadDown = ISInventoryPage.onJoypadDown

local function handleJoypadDown(self, target, button)
    -- Stocke l'ordre original des sacs à dos
    local originalOrder = {}
    for index, button in ipairs(target.backpacks) do
        originalOrder[button] = index
    end

    -- Trie les sacs à dos par position Y pour que le défilement marche correctement
    table.sort(target.backpacks, function(a, b) return a:getY() < b:getY() end)

    -- Réinitialise 'backpackChoice' (rôle pas clair) pour éviter qu'il traîne sur les entrées de bumper
    target.killTheChoice = true

    local retVal = og_onJoypadDown(self, button)
    table.sort(target.backpacks, function(a, b) return originalOrder[a] < originalOrder[b] end)
    return retVal
end

function ISInventoryPage:onJoypadDown(button)
    if button == Joypad.LBumper then
        return handleJoypadDown(self, getPlayerInventory(self.player), button)
    end

    if button == Joypad.RBumper then
        local lootPage = getPlayerLoot(self.player)
        if lootPage and ReorderContainersService.isSortingEnabled(lootPage) then
            return handleJoypadDown(self, lootPage, button)
        end
    end

    return og_onJoypadDown(self, button)
end