-- Safe Put/Remove conversion for gas masks / respirator / SCBA.
-- Bypasses broken craftRecipe soft-overrides and vanilla removeGasFilter
-- failures that delete the mask ("Couldn't find item Base.*_nofilter").

AirContaminationConvert = AirContaminationConvert or {}

-- Resolve at call-time: shared scripts load alphabetically and Data may
-- not exist yet when this file is parsed (Convert < Data).
local function data()
    return AirContaminationData or {}
end

local function hasMethod(obj, name)
    return obj ~= nil and obj[name] ~= nil
end

local function callNumber(obj, name)
    if not hasMethod(obj, name) then return nil end
    local ok, value = pcall(function() return obj[name](obj) end)
    if ok and type(value) == "number" then return value end
    return nil
end

local function callBool(obj, name)
    if not hasMethod(obj, name) then return nil end
    local ok, value = pcall(function() return obj[name](obj) end)
    if ok then return value == true end
    return nil
end

local function stripModule(fullType)
    if not fullType then return nil end
    local plain = tostring(fullType)
    local dot = plain:find("%.[^%.]*$")
    if dot then
        return plain:sub(dot + 1)
    end
    return plain
end

local function fullTypeOf(typeName)
    if not typeName then return nil end
    if string.find(typeName, ".", 1, true) then
        return typeName
    end
    return "Base." .. typeName
end

function AirContaminationConvert.getItemType(item)
    if not item or not hasMethod(item, "getType") then return nil end
    local ok, t = pcall(function() return item:getType() end)
    if ok then return t end
    return nil
end

local function isDrainableItem(item)
    if not item then return false end
    local drainable = callBool(item, "IsDrainable")
    if drainable ~= nil then return drainable end
    if instanceof then
        if instanceof(item, "DrainableComboItem") then return true end
        if instanceof(item, "Drainable") then return true end
    end
    return false
end

function AirContaminationConvert.getUsesRatio(item)
    if not item then return nil end
    -- GP5-style embedded filters store life on the mask via getUsedDelta.
    if AirContaminationConvert.hasEmbeddedFilter(item) then
        local usedDelta = callNumber(item, "getUsedDelta")
        if usedDelta ~= nil then
            return math.max(0, math.min(1, usedDelta))
        end
        local curFloat = callNumber(item, "getCurrentUsesFloat")
        if curFloat ~= nil then
            return math.max(0, math.min(1, curFloat))
        end
    end
    -- Non-drainable put consumables (RippedSheets): B42 still exposes
    -- getCurrentUsesFloat()==0, which must NOT be treated as empty.
    if not isDrainableItem(item) then
        return 1.0
    end
    local maxUses = callNumber(item, "getMaxUses")
    local curFloat = callNumber(item, "getCurrentUsesFloat")
    if curFloat ~= nil then
        if curFloat > 1 and maxUses and maxUses > 0 then
            return math.max(0, math.min(1, curFloat / maxUses))
        end
        return math.max(0, math.min(1, curFloat))
    end
    local usedDelta = callNumber(item, "getUsedDelta")
    if usedDelta ~= nil then
        return math.max(0, math.min(1, usedDelta))
    end
    local curInt = callNumber(item, "getCurrentUses")
    if curInt ~= nil and maxUses and maxUses > 0 then
        return math.max(0, math.min(1, curInt / maxUses))
    end
    return 1.0
end

function AirContaminationConvert.setUsesRatio(item, ratio)
    if not item or ratio == nil then return false end
    ratio = math.max(0, math.min(1, ratio))
    if hasMethod(item, "setUsedDelta") then
        local ok = pcall(function() item:setUsedDelta(ratio) end)
        if ok then return true end
    end
    if hasMethod(item, "setCurrentUsesFloat") then
        local ok = pcall(function() item:setCurrentUsesFloat(ratio) end)
        if ok then return true end
    end
    return false
end

local function resolveLinkedType(item, getterName, fallbackMap, itemType)
    if itemType and fallbackMap and fallbackMap[itemType] then
        return fallbackMap[itemType]
    end
    if item and hasMethod(item, getterName) then
        local ok, script = pcall(function() return item[getterName](item) end)
        if ok and script then
            if hasMethod(script, "getFullName") then
                local ok2, full = pcall(function() return script:getFullName() end)
                if ok2 and full then return stripModule(full) end
            end
            if hasMethod(script, "getName") then
                local ok3, name = pcall(function() return script:getName() end)
                if ok3 and name then return stripModule(name) end
            end
        end
    end
    return nil
end

function AirContaminationConvert.resolveWithType(item, itemType)
    itemType = itemType or AirContaminationConvert.getItemType(item)
    return resolveLinkedType(item, "getWithDrainable", data().NofilterToFiltered, itemType)
end

function AirContaminationConvert.resolveWithoutType(item, itemType)
    itemType = itemType or AirContaminationConvert.getItemType(item)
    return resolveLinkedType(item, "getWithoutDrainable", data().FilteredToNofilter, itemType)
end

local function copyItemState(fromItem, toItem)
    if not fromItem or not toItem then return end
    if hasMethod(fromItem, "isFavorite") and hasMethod(toItem, "setFavorite") then
        local fav = callBool(fromItem, "isFavorite")
        if fav ~= nil then
            pcall(function() toItem:setFavorite(fav) end)
        end
    end
    if hasMethod(fromItem, "getCondition") and hasMethod(toItem, "setCondition") then
        local cond = callNumber(fromItem, "getCondition")
        if cond ~= nil then
            pcall(function() toItem:setCondition(cond) end)
        end
    end
    if hasMethod(fromItem, "getBloodLevel") and hasMethod(toItem, "setBloodLevel") then
        local blood = callNumber(fromItem, "getBloodLevel")
        if blood ~= nil then
            pcall(function() toItem:setBloodLevel(blood) end)
        end
    end
    if hasMethod(fromItem, "getWetness") and hasMethod(toItem, "setWetness") then
        local wet = callNumber(fromItem, "getWetness")
        if wet ~= nil then
            pcall(function() toItem:setWetness(wet) end)
        end
    end
end

local function getItemContainer(item)
    if not item or not hasMethod(item, "getContainer") then return nil end
    local ok, container = pcall(function() return item:getContainer() end)
    if ok then return container end
    return nil
end

local function getPlayerInventory(player)
    if not player or not hasMethod(player, "getInventory") then return nil end
    local ok, inv = pcall(function() return player:getInventory() end)
    if ok then return inv end
    return nil
end

local function addItemToContainer(container, fullType, usesRatio)
    if not container or not fullType or not hasMethod(container, "AddItem") then
        return nil
    end
    local newItem = nil
    local okAdd, result = pcall(function() return container:AddItem(fullType) end)
    if okAdd then newItem = result end
    if newItem and usesRatio ~= nil then
        AirContaminationConvert.setUsesRatio(newItem, usesRatio)
    end
    return newItem
end

local function refreshEmbeddedFilterItem(item)
    if not item then return end
    if GP5 and GP5.Refresh then
        pcall(function() GP5.Refresh(item) end)
    end
    if hasMethod(item, "syncItemFields") then
        pcall(function() item:syncItemFields() end)
    end
end

local function isEmbeddedFilterMask(itemType)
    return itemType ~= nil
        and data().EmbeddedFilterMasks ~= nil
        and data().EmbeddedFilterMasks[itemType] ~= nil
end

function AirContaminationConvert.hasEmbeddedFilter(item)
    if not item or not hasMethod(item, "hasFilter") then return false end
    return callBool(item, "hasFilter") == true
end

local function clearEmbeddedFilter(item)
    if not item then return false end
    if hasMethod(item, "setFilterType") then
        pcall(function() item:setFilterType(nil) end)
        if callBool(item, "hasFilter") then
            pcall(function() item:setFilterType("") end)
        end
    end
    if hasMethod(item, "setUsedDelta") then
        pcall(function() item:setUsedDelta(0) end)
    end
    refreshEmbeddedFilterItem(item)
    return callBool(item, "hasFilter") ~= true
end

local function attachEmbeddedFilter(item, filterFullType, ratio)
    if not item or not filterFullType then return false end
    if hasMethod(item, "setFilterType") then
        pcall(function() item:setFilterType(filterFullType) end)
    end
    if ratio ~= nil then
        AirContaminationConvert.setUsesRatio(item, ratio)
    end
    refreshEmbeddedFilterItem(item)
    return AirContaminationConvert.hasEmbeddedFilter(item)
end

local function removeItemFromWorld(item)
    if not item then return end
    local container = getItemContainer(item)
    if container and hasMethod(container, "Remove") then
        pcall(function() container:Remove(item) end)
        return
    end
    if hasMethod(item, "getWorldItem") then
        local ok, world = pcall(function() return item:getWorldItem() end)
        if ok and world and hasMethod(world, "removeFromSquare") then
            pcall(function() world:removeFromWorld() end)
            pcall(function() world:removeFromSquare() end)
        end
    end
end

--- Replace gear item with another full type. Optionally set uses / force SCBA off.
function AirContaminationConvert.convertReplace(player, oldItem, newFullType, usesRatio, forceActivatedOff)
    if not player or not oldItem or not newFullType then
        print("[AirContamination] convertReplace: missing args")
        return nil
    end

    local inv = getPlayerInventory(player)
    if not inv or not hasMethod(inv, "AddItem") then
        print("[AirContamination] convertReplace: no inventory")
        return nil
    end
    local targetContainer = getItemContainer(oldItem) or inv

    local wasEquipped = false
    pcall(function()
        if hasMethod(player, "isEquipped") and player:isEquipped(oldItem) then
            wasEquipped = true
        elseif hasMethod(player, "isEquippedClothing") and player:isEquippedClothing(oldItem) then
            wasEquipped = true
        end
    end)

    local bodyLoc = nil
    if wasEquipped and hasMethod(oldItem, "getBodyLocation") then
        pcall(function() bodyLoc = oldItem:getBodyLocation() end)
    end

    if wasEquipped and hasMethod(player, "removeWornItem") then
        pcall(function() player:removeWornItem(oldItem) end)
    end

    local newItem = nil
    local okAdd, result = pcall(function() return targetContainer:AddItem(newFullType) end)
    if okAdd then newItem = result end
    if not newItem then
        print("[AirContamination] ERROR: AddItem failed for " .. tostring(newFullType)
            .. " (ScriptManager missing item?)")
        return nil
    end

    copyItemState(oldItem, newItem)
    if usesRatio ~= nil then
        AirContaminationConvert.setUsesRatio(newItem, usesRatio)
    end
    if forceActivatedOff and hasMethod(newItem, "setActivated") then
        pcall(function() newItem:setActivated(false) end)
    end

    removeItemFromWorld(oldItem)

    if wasEquipped and bodyLoc ~= nil and hasMethod(player, "setWornItem") then
        pcall(function() player:setWornItem(bodyLoc, newItem) end)
    end

    print("[AirContamination] Converted -> " .. tostring(newFullType))
    return newItem
end

function AirContaminationConvert.findConsumable(player, typeList)
    if not player or not typeList then return nil end
    local inv = nil
    pcall(function() inv = player:getInventory() end)
    if not inv then return nil end

    -- Recursive type lookup first (rags/filters inside bags).
    if hasMethod(inv, "getItemFromType") then
        for _, want in ipairs(typeList) do
            local typeName = stripModule(want)
            local found = nil
            pcall(function() found = inv:getItemFromType(typeName, true, true) end)
            if not found then
                pcall(function() found = inv:getItemFromType(typeName) end)
            end
            if found then
                local ratio = AirContaminationConvert.getUsesRatio(found)
                if ratio == nil or ratio > 0.001 then
                    return found
                end
            end
        end
    end

    if not hasMethod(inv, "getItems") then return nil end
    local items = nil
    pcall(function() items = inv:getItems() end)
    if not items or not hasMethod(items, "size") then return nil end

    local size = 0
    pcall(function() size = items:size() end)
    for i = 0, size - 1 do
        local it = nil
        pcall(function() it = items:get(i) end)
        if it then
            local t = AirContaminationConvert.getItemType(it)
            if t then
                for _, want in ipairs(typeList) do
                    if t == want or t == stripModule(want) then
                        -- Prefer non-empty drainables
                        local ratio = AirContaminationConvert.getUsesRatio(it)
                        if ratio == nil or ratio > 0.001 then
                            return it
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function findEmbeddedEmptyShell(player, maskType)
    if not player or not maskType or not isEmbeddedFilterMask(maskType) then
        return nil
    end
    local inv = getPlayerInventory(player)
    if not inv or not hasMethod(inv, "getItems") then return nil end
    local items = nil
    pcall(function() items = inv:getItems() end)
    if not items or not hasMethod(items, "size") then return nil end
    local size = 0
    pcall(function() size = items:size() end)
    for i = 0, size - 1 do
        local it = nil
        pcall(function() it = items:get(i) end)
        if it and AirContaminationConvert.getItemType(it) == maskType then
            if not AirContaminationConvert.hasEmbeddedFilter(it) then
                return it
            end
        end
    end
    return nil
end

function AirContaminationConvert.findEmptyShell(player, shellType)
    if not player or not shellType then return nil end
    local inv = getPlayerInventory(player)
    if not inv then return nil end
    local full = fullTypeOf(shellType)
    if hasMethod(inv, "FindAndReturn") then
        local found = nil
        pcall(function() found = inv:FindAndReturn(full) end)
        if found then return found end
        pcall(function() found = inv:FindAndReturn(stripModule(shellType)) end)
        if found then return found end
    end
    local found = AirContaminationConvert.findConsumable(player, { stripModule(shellType) })
    if found then return found end

    local paired = data().NofilterToFiltered and data().NofilterToFiltered[shellType]
    if paired then
        return findEmbeddedEmptyShell(player, paired)
    end
    if isEmbeddedFilterMask(shellType) then
        return findEmbeddedEmptyShell(player, shellType)
    end
    return nil
end

local function putEmbeddedFilter(player, shellItem, consumableItem, embeddedCfg)
    local ratio = AirContaminationConvert.getUsesRatio(consumableItem)
    if ratio == nil then ratio = 1.0 end
    if ratio <= 0.001 then
        print("[AirContamination] Put blocked: consumable empty")
        return false
    end
    if AirContaminationConvert.hasEmbeddedFilter(shellItem) then
        print("[AirContamination] Put blocked: mask already has filter")
        return false
    end
    local filterType = embeddedCfg and embeddedCfg.filterType
    if not filterType then return false end
    if not attachEmbeddedFilter(shellItem, fullTypeOf(filterType), ratio) then
        print("[AirContamination] ERROR: attachEmbeddedFilter failed")
        return false
    end
    removeItemFromWorld(consumableItem)
    return true
end

function AirContaminationConvert.putOn(player, shellItem, consumableItem)
    if not player or not shellItem or not consumableItem then return false end

    local shellType = AirContaminationConvert.getItemType(shellItem)
    local embeddedCfg = data().EmbeddedFilterMasks and data().EmbeddedFilterMasks[shellType]
    if embeddedCfg then
        return putEmbeddedFilter(player, shellItem, consumableItem, embeddedCfg)
    end

    local cfg = data().PutFilterConfig and data().PutFilterConfig[shellType]
    if cfg and cfg.requireUnequipped then
        local worn = false
        pcall(function()
            if player:isEquipped(shellItem) then worn = true end
        end)
        if worn then
            print("[AirContamination] Put Tank blocked: SCBA must be unequipped")
            return false
        end
    end

    local withType = AirContaminationConvert.resolveWithType(shellItem, shellType)
    if not withType then
        print("[AirContamination] ERROR: no WithDrainable for " .. tostring(shellType))
        return false
    end

    local ratio = AirContaminationConvert.getUsesRatio(consumableItem)
    if ratio == nil then ratio = 1.0 end
    if ratio <= 0.001 then
        print("[AirContamination] Put blocked: consumable empty")
        return false
    end

    local forceOff = (shellType == "SCBA_notank") or (withType == "SCBA") or (withType == "HazmatSuit")
    local newItem = AirContaminationConvert.convertReplace(
        player, shellItem, fullTypeOf(withType), ratio, forceOff)

    if not newItem then return false end
    removeItemFromWorld(consumableItem)
    return true
end

local function removeEmbeddedFilter(player, gearItem, gearType, embeddedCfg)
    if not AirContaminationConvert.hasEmbeddedFilter(gearItem) then
        print("[AirContamination] Remove blocked: no embedded filter")
        return false
    end

    local ratio = AirContaminationConvert.getUsesRatio(gearItem)
    if not clearEmbeddedFilter(gearItem) then
        print("[AirContamination] ERROR: clearEmbeddedFilter failed for " .. tostring(gearType))
        return false
    end

    local returnType = embeddedCfg.filterType
        or (data().ReturnFilterType and data().ReturnFilterType[gearType])
    if returnType and ratio and ratio > 0.001 then
        local container = getItemContainer(gearItem) or getPlayerInventory(player)
        local returned = addItemToContainer(container, fullTypeOf(returnType), ratio)
        if returned then
            print("[AirContamination] Returned " .. tostring(returnType)
                .. " uses=" .. string.format("%.3f", ratio))
        else
            print("[AirContamination] WARN: could not return " .. tostring(returnType))
        end
    end
    return true
end

function AirContaminationConvert.removeFrom(player, gearItem)
    if not player or not gearItem then return false end

    local gearType = AirContaminationConvert.getItemType(gearItem)
    local embeddedCfg = data().EmbeddedFilterMasks and data().EmbeddedFilterMasks[gearType]
    if embeddedCfg then
        return removeEmbeddedFilter(player, gearItem, gearType, embeddedCfg)
    end

    local withoutType = AirContaminationConvert.resolveWithoutType(gearItem, gearType)
    if not withoutType then
        print("[AirContamination] ERROR: no WithoutDrainable for " .. tostring(gearType))
        return false
    end

    -- Block remove tank while worn for SCBA / Hazmat (vanilla IsNotWorn)
    if gearType == "SCBA" or gearType == "HazmatSuit" then
        local worn = false
        pcall(function()
            if player:isEquipped(gearItem) then worn = true end
        end)
        if worn then
            print("[AirContamination] Remove Tank blocked: must be unequipped")
            return false
        end
    end

    local ratio = AirContaminationConvert.getUsesRatio(gearItem)
    local newItem = AirContaminationConvert.convertReplace(
        player, gearItem, fullTypeOf(withoutType), nil, false)
    if not newItem then return false end

    local returnType = data().ReturnFilterType and data().ReturnFilterType[gearType]
    if returnType and ratio and ratio > 0.001 then
        local container = getItemContainer(newItem) or getPlayerInventory(player)
        local uses = (returnType ~= "RippedSheets") and ratio or nil
        local returned = addItemToContainer(container, fullTypeOf(returnType), uses)
        if returned then
            print("[AirContamination] Returned " .. tostring(returnType)
                .. " uses=" .. string.format("%.3f", ratio))
        else
            print("[AirContamination] WARN: could not return " .. tostring(returnType))
        end
    end
    return true
end

-- Collect keep-mode items from craft recipe data (B42 craft API variants).
local function collectItemsFromList(items)
    local list = {}
    if not items or not hasMethod(items, "size") then return list end
    local okSize, size = pcall(function() return items:size() end)
    if not okSize or not size or size <= 0 then return list end
    for i = 0, size - 1 do
        local okGet, it = pcall(function() return items:get(i) end)
        if okGet and it then
            table.insert(list, it)
        end
    end
    return list
end

function AirContaminationConvert.collectKeepItems(data)
    if not data then return {} end
    if hasMethod(data, "getAllKeepInputItems") then
        local ok, items = pcall(function() return data:getAllKeepInputItems() end)
        if ok and items then return collectItemsFromList(items) end
    end
    if hasMethod(data, "getKeepItems") then
        local ok, items = pcall(function() return data:getKeepItems() end)
        if ok and items then return collectItemsFromList(items) end
    end
    if hasMethod(data, "getAllInputItems") then
        local ok, items = pcall(function() return data:getAllInputItems() end)
        if ok and items then return collectItemsFromList(items) end
    end
    return {}
end

function AirContaminationConvert.scriptItemExists(fullType)
    local sm = nil
    if getScriptManager then
        pcall(function() sm = getScriptManager() end)
    end
    if not sm and ScriptManager then
        sm = ScriptManager.instance
    end
    if not sm or not sm.getItem then return false end
    local item = nil
    pcall(function() item = sm:getItem(fullType) end)
    return item ~= nil
end
