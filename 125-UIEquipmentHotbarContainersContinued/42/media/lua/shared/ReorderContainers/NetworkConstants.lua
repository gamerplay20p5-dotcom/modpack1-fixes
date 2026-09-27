---@class SaveItemDataRequest
---@field itemId integer
---@field modData table<string, any>
---@field keySuffix string

---@class SaveGroundItemDataRequest
---@field itemId integer
---@field x integer
---@field y integer
---@field z integer
---@field modData table<string, any>
---@field keySuffix string

---@class SortDataAck
---@field playerNum integer

return {
    MODULE = "ReorderContainers",
    COMMAND_SAVE_ITEM_DATA = "SaveItemSortData",
    COMMAND_SAVE_GROUND_ITEM_DATA = "SaveGroundItemSortData",
    COMMAND_SORT_DATA_ACK = "SortDataAck",
}