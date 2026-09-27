local ClothingItemExtraService = {}

---@type table<string, InventoryItem>
local _extraItemCache = {}

---@param item InventoryItem
---@return ItemBodyLocation
function ClothingItemExtraService.getDefaultBodyLocation(item)
    local bodyLocation = item:getBodyLocation()
    if bodyLocation then return bodyLocation end

    -- canBeEquipped() renvoie "" (pas nil) pour un objet non-portable, comme le fait vanilla
    -- (cf. ISWearClothing.lua, ISUnequipAction.lua) - normalise ici pour ne pas faire fuiter
    -- ce "" vers isExclusive()/getBodyLocationsForItem.
    local canBeEquipped = item:canBeEquipped()
    if canBeEquipped == "" then return nil end
    return canBeEquipped
end

---@param module string
---@param extra string
---@return ItemBodyLocation
function ClothingItemExtraService.getExtraItemBodyLocation(module, extra)
    local item = _extraItemCache[extra]
    if item == false then return nil end
    if not item then
        local extraType = tostring(extra)
        local fullType = extraType:find(".", 1, true) and extraType or (module .. "." .. extraType)
        local ok, result = pcall(instanceItem, fullType)
        item = ok and result or nil
        _extraItemCache[extra] = item or false
    end
    return item and item:getBodyLocation() or nil
end

--- Certains objets sont valides pour plusieurs emplacements (par ex. bagues et montres)
---@param item InventoryItem
---@return table<ItemBodyLocation, boolean>
ClothingItemExtraService.getBodyLocationsForItem = function(item)
    local bodyLocationsMap = {}
    
    local defaultBodyLocation = ClothingItemExtraService.getDefaultBodyLocation(item)
    if not defaultBodyLocation then
        return bodyLocationsMap
    end
    
    bodyLocationsMap[defaultBodyLocation] = true

    local extraOptions = item:getClothingItemExtra()
    if extraOptions then
        local module = item:getModule()
        for i=0, extraOptions:size()-1 do
            local extra = extraOptions:get(i)
            local extraBodyLocation = ClothingItemExtraService.getExtraItemBodyLocation(module, extra)
            if extraBodyLocation then bodyLocationsMap[extraBodyLocation] = true end
        end
    end

    return bodyLocationsMap
end

--- Trouve le type d'objet extra (module.type) pour cet emplacement, requis pour appeler ISInventoryContextMenu::wearExtra
---@param item InventoryItem
---@param targetBodyLocation ItemBodyLocation
---@return string|nil
ClothingItemExtraService.findExtraOptionForBodyLocation = function(item, targetBodyLocation)
    local extraOptions = item:getClothingItemExtra()
    if not extraOptions then
        return nil
    end

    for i=0, extraOptions:size()-1 do
        local module = item:getModule()
        local extra = extraOptions:get(i)
        local extraBodyLocation = ClothingItemExtraService.getExtraItemBodyLocation(module, extra)
        if extraBodyLocation == targetBodyLocation then
            return moduleDotType(module, extra);
        end
    end

    return nil
end

return ClothingItemExtraService
