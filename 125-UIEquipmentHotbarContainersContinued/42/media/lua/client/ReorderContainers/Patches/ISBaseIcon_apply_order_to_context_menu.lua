-- Porte du module : si le joueur a décoché la case, on n'installe rien du tout, pour laisser
-- la place à un autre mod. Voir EquipmentUI/ModuleFlags.lua.
if not require("EquipmentUI/ModuleFlags").containerReorder then return end

-- Applique la réorganisation des sacs à dos au menu contextuel d'ISBaseIcon
ISBaseIcon.pre_reorder_doContextMenu = ISBaseIcon.doContextMenu
function ISBaseIcon:doContextMenu(_context)
    local playerInv = getPlayerInventory(self.player)

    local originalOrder = {};
    local bpList = {};

    -- Trie les sacs à dos par position Y pour que le menu contextuel suive le même ordre
    if playerInv then
        bpList = playerInv.backpacks;

        for i = 1, #bpList do
            originalOrder[i] = bpList[i];
        end

        table.sort(bpList, function(a, b)
            return a:getY() < b:getY();
        end);
    end

    local retVal = ISBaseIcon.pre_reorder_doContextMenu(self, _context)

    -- Restaure l'ordre original pour ne pas perturber les autres mods
    if playerInv then
        for i = 1, #bpList do
            bpList[i] = originalOrder[i];
        end
    end

    return retVal;
end