-- Porte du module : si le joueur a décoché la case, on n'installe rien du tout, pour laisser
-- la place à un autre mod. Voir EquipmentUI/ModuleFlags.lua.
if not require("EquipmentUI/ModuleFlags").containerReorder then return end

local SortableBackpackButton = require("ReorderContainers/UI/SortableBackpackButton")

local og_addContainerButton = ISInventoryPage.addContainerButton
function ISInventoryPage:addContainerButton(container, texture, name, tooltip)
    local button = og_addContainerButton(self, container, texture, name, tooltip)
    return SortableBackpackButton:inject(button, self)
end