local Constants = require("ReorderContainers/NetworkConstants")
local ModDataService = require("ReorderContainers/ModDataService")
local MOD_PREFIX = Constants.MODULE

local Client = {}

-- Note : le modData local est déjà modifié par l'appelant (ReorderContainersService) avant cet
-- appel, sans attendre l'ACK serveur. Le serveur renvoie un COMMAND_SORT_DATA_ACK une fois
-- l'écriture appliquée (voir onSortDataAck plus bas), qui réapplique l'ordre confirmé sur les
-- panneaux visibles - corrige rapidement un affichage temporairement désynchronisé par une
-- resync réseau arrivée entre l'écriture locale et son traitement serveur. Seul cas non couvert :
-- si le serveur rejette la requête (item ramassé/déplacé avant traitement), aucun ACK n'arrive et
-- l'affichage reste désynchronisé jusqu'au prochain resync complet (relog/rechargement chunk) -
-- sans impact sur les données, juste l'affichage.
---@param parentObj GameEntity|IsoObject|nil
---@param playerObj IsoPlayer
---@param keySuffix string
function Client.saveModData(parentObj, playerObj, keySuffix)
    if not isClient() or isServer() then return end

    if not parentObj then
        return
    end

    if instanceof(parentObj, "IsoObject") or instanceof(parentObj, "IsoPlayer") then
        ---@cast parentObj IsoObject
        parentObj:transmitModData()
        return
    end

    if instanceof(parentObj, "InventoryItem") and playerObj then
        ---@cast parentObj InventoryItem

        local rootModData = parentObj:getModData()
        local sortData = ModDataService.getSortData(rootModData, keySuffix)

        ---@cast parentObj InventoryItem
        local worldItem = parentObj:getWorldItem()
        if worldItem then
            local square = worldItem:getSquare()
            ---@type SaveGroundItemDataRequest
            local saveGroundItemData = {
                itemId = parentObj:getID(),
                x = square:getX(),
                y = square:getY(),
                z = square:getZ(),
                modData = sortData,
                keySuffix = keySuffix,
            }
            sendClientCommand(playerObj, Constants.MODULE, Constants.COMMAND_SAVE_GROUND_ITEM_DATA, saveGroundItemData)
        else
            ---@type SaveItemDataRequest
            local saveItemData = {
                itemId = parentObj:getID(),
                modData = sortData,
                keySuffix = keySuffix,
            }
            sendClientCommand(playerObj, Constants.MODULE, Constants.COMMAND_SAVE_ITEM_DATA, saveItemData)
        end
        return
    end
end

-- Confirmation serveur qu'une écriture de tri a bien été appliquée : réapplique l'ordre
-- confirmé sur les panneaux visibles, pour corriger rapidement un éventuel affichage
-- desynchronisé (cf. note en haut de Client.saveModData) plutôt que d'attendre le prochain
-- resync complet (relog/rechargement de chunk).
local function onSortDataAck(module, command, args)
    if module ~= Constants.MODULE or command ~= Constants.COMMAND_SORT_DATA_ACK then return end
    if not args or not args.playerNum then return end

    local inventoryPage = getPlayerInventory(args.playerNum)
    if inventoryPage and inventoryPage.applyBackpackOrder then
        inventoryPage:applyBackpackOrder()
    end

    local lootPage = getPlayerLoot(args.playerNum)
    if lootPage and lootPage.applyBackpackOrder then
        lootPage:applyBackpackOrder()
    end
end
Events.OnServerCommand.Add(onSortDataAck)

return Client