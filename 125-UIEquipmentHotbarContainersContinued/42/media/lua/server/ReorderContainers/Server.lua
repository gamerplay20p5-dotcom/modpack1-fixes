local NetworkConstants = require("ReorderContainers/NetworkConstants")
local ModDataConstants = require("ReorderContainers/ModDataConstants")

local Server = {}

local MAX_KEY_SUFFIX_LENGTH = 64

---@param keySuffix string
---@return boolean
local function isKeySuffixValid(keySuffix)
    return type(keySuffix) == "string" and #keySuffix <= MAX_KEY_SUFFIX_LENGTH
end

-- Champs autorisés pour RCSortingData (voir ModDataConstants.lua), avec leur type attendu
local SORT_DATA_FIELD_TYPES = {
    sortPriority = "number",
    isManual = "boolean",
    colorTag = "string",
}

---@param module string
---@param command string
---@param playerObj IsoPlayer
---@param request any
function Server.handleCommand(module, command, playerObj, request)
    if module ~= NetworkConstants.MODULE then return end

    if command == NetworkConstants.COMMAND_SAVE_ITEM_DATA then
        Server.saveItemData(playerObj, request)
        return
    end

    if command == NetworkConstants.COMMAND_SAVE_GROUND_ITEM_DATA then
        Server.saveGroundItemData(playerObj, request)
        return
    end
end

---@param playerObj IsoPlayer
---@param request SaveItemDataRequest
function Server.saveItemData(playerObj, request)
    if not isKeySuffixValid(request.keySuffix) then return end

    local itemId = request.itemId
    local item = playerObj:getInventory():getItemWithID(itemId)
    if not item then return end

    local key = ModDataConstants.SORT_DATA_KEY .. request.keySuffix
    Server.writeModData(item:getModData(), request.modData, key)
    sendServerCommand(playerObj, NetworkConstants.MODULE, NetworkConstants.COMMAND_SORT_DATA_ACK, {playerNum = playerObj:getPlayerNum()})
end

---@param playerObj IsoPlayer
---@param request SaveGroundItemDataRequest
function Server.saveGroundItemData(playerObj, request)
    if not playerObj then return end
    if not isKeySuffixValid(request.keySuffix) then return end

    local MAX_INTERACT_DISTANCE = 10
    local dx = playerObj:getX() - request.x
    local dy = playerObj:getY() - request.y
    if (dx * dx + dy * dy) > (MAX_INTERACT_DISTANCE * MAX_INTERACT_DISTANCE) then return end
    if playerObj:getZ() ~= request.z then return end

    local square = getCell():getGridSquare(request.x, request.y, request.z)
    if not square then return end

    local targetItem = Server.findItemOnSquare(square, request.itemId)
    if not targetItem then return end

    local key = ModDataConstants.SORT_DATA_KEY .. request.keySuffix
    Server.writeModData(targetItem:getModData(), request.modData, key)
    sendServerCommand(playerObj, NetworkConstants.MODULE, NetworkConstants.COMMAND_SORT_DATA_ACK, {playerNum = playerObj:getPlayerNum()})
end

---@param rootModData table
---@param dataToWrite table
---@param dataKey string
function Server.writeModData(rootModData, dataToWrite, dataKey)
    local moduleData = rootModData[ModDataConstants.PREFIX]
    if not moduleData then
        moduleData = {}
        rootModData[ModDataConstants.PREFIX] = moduleData
    end
    
    local targetData = moduleData[dataKey]
    if not targetData then
        targetData = {}
        moduleData[dataKey] = targetData
    end

    for k, v in pairs(dataToWrite) do
        local expectedType = SORT_DATA_FIELD_TYPES[k]
        if expectedType and type(v) == expectedType then
            targetData[k] = v
        end
    end
end

---@param square IsoGridSquare
---@param itemId integer
---@return InventoryItem|nil
function Server.findItemOnSquare(square, itemId)
    local worldObjects = square:getWorldObjects()
    local targetItem = nil
    for i = 0, worldObjects:size() - 1 do
        local obj = worldObjects:get(i)
        if obj then
            local item = obj:getItem()
            if item and item:getID() == itemId then
                targetItem = item
                break
            end
        end
    end
    return targetItem
end

Events.OnClientCommand.Add(Server.handleCommand)

return Server