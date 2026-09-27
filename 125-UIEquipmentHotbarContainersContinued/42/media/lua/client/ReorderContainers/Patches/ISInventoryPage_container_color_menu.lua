-- Porte du module : si le joueur a décoché la case, on n'installe rien du tout, pour laisser
-- la place à un autre mod. Voir EquipmentUI/ModuleFlags.lua.
if not require("EquipmentUI/ModuleFlags").containerReorder then return end

-- Ajoute "Assigner une couleur" en haut du menu clic droit des boutons de sac (onglets en
-- haut de la fenêtre d'inventaire/butin), avec un sous-menu de palette fixe. La couleur est
-- stockée sur le conteneur lui-même (ReorderContainersService), donc elle suit ce sac précis
-- partout où il apparaît.
local ReorderContainersService = require("ReorderContainers/ReorderContainersService")
local ContainerColors = require("ReorderContainers/ContainerColors")
local T = require("EquipmentUI/Text")

-- ISContextMenu.get(player, x, y) vide et reconstruit le menu à CHAQUE appel (context:clear()
-- à l'intérieur) - le rappeler nous-mêmes après coup effacerait tout ce que le handler vanilla
-- vient d'y mettre (Déséquiper, Jeter...). Donc on capture la référence pendant que le handler
-- vanilla construit son menu, au lieu de la redemander.
local capturedContext = nil
local og_contextMenuGet = ISContextMenu.get
ISContextMenu.get = function(player, x, y)
    capturedContext = og_contextMenuGet(player, x, y)
    return capturedContext
end

local og_onBackpackRightMouseDown = ISInventoryPage.onBackpackRightMouseDown
function ISInventoryPage:onBackpackRightMouseDown(x, y)
    capturedContext = nil
    og_onBackpackRightMouseDown(self, x, y)

    local container = self.inventory
    if not container or not capturedContext then return end

    local page = self.invPage or self.parent.parent
    local playerObj = getSpecificPlayer(page.player)
    local context = capturedContext

    local colorOption = context:addOptionOnTop(T("UI_reorder_containers_assign_color"))
    local subMenu = context:getNew(context)
    context:addSubMenu(colorOption, subMenu)

    local currentColorKey = ReorderContainersService.getContainerColorKey(playerObj, container)
    for _, entry in ipairs(ContainerColors.PALETTE) do
        local option = subMenu:addOption(getText(entry.textKey), nil, function()
            ReorderContainersService.setContainerColorKey(playerObj, container, entry.key)
        end)
        subMenu:setOptionChecked(option, entry.key == currentColorKey)
    end

    subMenu:addOption(T("UI_reorder_containers_clear_color"), nil, function()
        ReorderContainersService.setContainerColorKey(playerObj, container, nil)
    end)
end
