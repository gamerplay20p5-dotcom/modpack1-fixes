-- Porte du module : si le joueur a décoché la case, on n'installe rien du tout, pour laisser
-- la place à un autre mod. Voir EquipmentUI/ModuleFlags.lua.
if not require("EquipmentUI/ModuleFlags").containerReorder then return end

local og_onMouseWheel = ISInventoryPage.onMouseWheel
function ISInventoryPage:onMouseWheel(del)
    -- Stocke l'ordre original des sacs à dos
    local originalOrder = {}
    for index, button in ipairs(self.backpacks) do
        originalOrder[button] = index
    end

    -- Trie les sacs à dos par position Y pour que le défilement marche correctement
    table.sort(self.backpacks, function(a, b) return a:getY() < b:getY() end)

    -- La molette peut déclencher un rafraîchissement des sacs à dos, donc on surveille ça
    self.pendingReorder = true

    local retVal = og_onMouseWheel(self, del)

    -- Pas de rafraîchissement : on restaure l'ordre original
    if self.pendingReorder then
        table.sort(self.backpacks, function(a, b) return originalOrder[a] < originalOrder[b] end)
        self.pendingReorder = false
    end

    return retVal
end