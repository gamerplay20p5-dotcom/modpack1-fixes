-- AirContamination_Main.lua
local Data = AirContaminationData

-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
-- SANDBOX HELPERS
-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

local function getSandboxVars()
    return SandboxVars.AirContamination or {}
end

local function getSpeedMultiplier()
    local index = getSandboxVars().ContaminationSpeed or 2
    return Data.SpeedMultipliers[index] or 1.0
end

local function getFilterMultiplier()
    local index = getSandboxVars().FilterDurationMultiplier or 3
    return Data.FilterMultipliers[index] or 1.0
end

local function isIndoorSafe()
    local v = getSandboxVars().IndoorSafeZone
    if v == nil then return true end
    return v
end

local function getDelayDays()
    local index = getSandboxVars().ContaminationDelay or 1
    return Data.DelayDays[index] or 0
end

-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
-- CONTAMINATION DELAY CHECK
-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

local function isContaminationActive()
    local delayDays = getDelayDays()
    if delayDays <= 0 then return true end

    local gameTime = GameTime:getInstance()
    if not gameTime then return true end

    local ok, day = pcall(function() return gameTime:getNightsSurvived() end)
    if ok and day then
        return day >= delayDays
    end
    return true
end

-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
-- LOCATION CHECKS
-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

local function isPlayerIndoors(player)
    if not isIndoorSafe() then return false end
    local square = player:getCurrentSquare()
    if not square then return false end
    local okRoom, inRoom = pcall(function() return square:isInARoom() end)
    local okOutside, outside = pcall(function() return square:isOutside() end)
    local okBuilding, building = pcall(function() return square:getBuilding() end)
    return (okRoom and inRoom == true) or (okOutside and outside == false and okBuilding and building ~= nil)
end

local function isPlayerSafe(player)
    return isPlayerIndoors(player)
end

-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
-- FILTER / TANK LIFE HELPERS
-- B42 gas masks / SCBA are Clothing hybrids. PZ still logs ERROR when
-- pcall invokes a missing method Ã¢â‚¬â€ check method fields before calling.
-- Correct API: IsDrainable (capital I), getCurrentUsesFloat / setUsedDelta.
-- getDrainableUsesInt / setDrainableUsesInt / isDrainable do NOT exist.
-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

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

local function isDrainableItem(item)
    if not item then return false end

    -- Prefer InventoryItem.IsDrainable (B42). Never call isDrainable Ã¢â‚¬â€ it is nil.
    local drainable = callBool(item, "IsDrainable")
    if drainable ~= nil then return drainable end

    if instanceof then
        if instanceof(item, "DrainableComboItem") then return true end
        if instanceof(item, "Drainable") then return true end
    end
    return false
end

local function clamp01(n)
    if n < 0 then return 0 end
    if n > 1 then return 1 end
    return n
end

local function normalizeLifeReading(value, maxUses)
    if value == nil then return nil end
    if value > 1 then
        if maxUses and maxUses > 0 then
            return clamp01(value / maxUses)
        end
        return 1.0
    end
    return clamp01(value)
end

-- Strict drainable remaining uses (NO clothing Condition fallback).
-- Condition would false-positive on (No Filter) masks.
local function hasAttachedDrainableUses(item)
    if not item then return false end

    local curFloat = callNumber(item, "getCurrentUsesFloat")
    if curFloat ~= nil and curFloat > 0.001 then
        if isDrainableItem(item) then return true end
        local useDelta = callNumber(item, "getUseDelta")
        if useDelta and useDelta > 0 then return true end
        local maxUses = callNumber(item, "getMaxUses")
        if maxUses and maxUses > 1 then return true end
    end

    local usedDelta = callNumber(item, "getUsedDelta")
    if usedDelta ~= nil and usedDelta > 0.001 and isDrainableItem(item) then
        return true
    end

    local curInt = callNumber(item, "getCurrentUses")
    if curInt ~= nil and curInt > 0 and isDrainableItem(item) then
        return true
    end

    return false
end

-- Returns 0..1 remaining filter/tank life, or nil if unreadable.
local function getFilterLifeRatio(item)
    if not item then return nil end

    local maxUses = callNumber(item, "getMaxUses")
    local isD = isDrainableItem(item)

    local best = nil
    local curFloat = normalizeLifeReading(callNumber(item, "getCurrentUsesFloat"), maxUses)
    local usedDelta = normalizeLifeReading(callNumber(item, "getUsedDelta"), maxUses)
    if curFloat ~= nil then best = curFloat end
    if usedDelta ~= nil and (best == nil or usedDelta > best) then
        best = usedDelta
    end
    if best ~= nil and (isD or best > 0) then
        return best
    end

    local curInt = callNumber(item, "getCurrentUses")
    if curInt ~= nil then
        if maxUses and maxUses > 0 then
            return clamp01(curInt / maxUses)
        end
        if curInt <= 0 then return 0.0 end
        if isD then return 1.0 end
    end

    if best ~= nil and isD then
        return best
    end

    return nil
end

local function getUsesIntSafe(item)
    if not item then return nil end
    local cur = callNumber(item, "getCurrentUses")
    if cur ~= nil then return math.floor(cur + 0.0001) end
    return nil
end

local function setFilterLifeRatio(item, newRatio)
    if not item or newRatio == nil then return false end
    newRatio = clamp01(newRatio)
    if hasMethod(item, "setUsedDelta") then
        local ok = pcall(function() item:setUsedDelta(newRatio) end)
        if ok then return true end
    end
    if hasMethod(item, "setCurrentUsesFloat") then
        local ok = pcall(function() item:setCurrentUsesFloat(newRatio) end)
        if ok then return true end
    end
    return false
end

-- For filter masks: non-activatable items are always "on".
-- For oxygen gear (usesOxygen): require canBeActivated + isActivated.
-- If conversion left a tanked shell without ActivatedItem, treat as OFF
-- (no free full protection Ã¢â‚¬â€ matches normal SCBA that must be Turned On).
local function isItemActivatedSafe(item, requireActivation)
    if not item then return true end
    local can = callBool(item, "canBeActivated")
    if requireActivation then
        if can ~= true then
            return false
        end
        local active = callBool(item, "isActivated")
        return active == true
    end
    if can == nil or can == false then
        return true
    end
    local active = callBool(item, "isActivated")
    if active ~= nil then return active end
    return true
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

local function getPairedFilteredType(item, itemType)
    local map = Data.NofilterToFiltered or {}
    if itemType and map[itemType] then
        return map[itemType]
    end
    if hasMethod(item, "getWithDrainable") then
        local ok, script = pcall(function() return item:getWithDrainable() end)
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
    if type(itemType) == "string" then
        local base = itemType:match("^(.-)_nofilter$") or itemType:match("^(.-)_notank$")
        if base and Data.MaskProtection[base] then
            return base
        end
    end
    return nil
end

-- If a *_nofilter / isNoFilter item actually has drainable filter/tank uses
-- (Put Filter attached without type swap), use the paired with-filter stats.
local function resolveMaskDataForItem(item, itemType, maskData)
    if not item or not maskData then return maskData end

    local looksEmpty = maskData.isNoFilter
        or (type(itemType) == "string" and (itemType:find("_nofilter$") ~= nil or itemType:find("_notank$") ~= nil))

    if not looksEmpty then
        return maskData
    end

    if not hasAttachedDrainableUses(item) then
        return maskData
    end

    local pairedType = getPairedFilteredType(item, itemType)
    if pairedType and Data.MaskProtection[pairedType] then
        return Data.MaskProtection[pairedType]
    end

    -- Soft override: keep table values but stop treating as empty shell.
    local override = {}
    for k, v in pairs(maskData) do
        override[k] = v
    end
    override.isNoFilter = false
    return override
end

local function computeItemProtection(item, maskData)
    if not item or not maskData then return 0.0 end
    local baseProtection = maskData.protection or 0.0
    if maskData.isNoFilter then return 0.0 end

    local ratio = getFilterLifeRatio(item)
    if maskData.usesOxygen then
        local uses = getUsesIntSafe(item)
        local hasTank = (uses and uses > 0) or (ratio and ratio > 0) or hasAttachedDrainableUses(item)
        if not hasTank or ratio == nil or ratio <= 0 then return 0.0 end
        if not isItemActivatedSafe(item, true) then return 0.0 end
        return baseProtection
    end

    if ratio == nil or ratio <= 0 then return 0.0 end
    return baseProtection
end
local function considerWornItem(item, bestItem, bestData, bestProt)
    if not item then return bestItem, bestData, bestProt end
    local ok, itemType = pcall(function() return item:getType() end)
    if not ok or not itemType then return bestItem, bestData, bestProt end

    local maskData = Data.MaskProtection[itemType]
    if not maskData then return bestItem, bestData, bestProt end

    maskData = resolveMaskDataForItem(item, itemType, maskData)

    local prot = computeItemProtection(item, maskData)
    if prot > bestProt then
        return item, maskData, prot
    end
    return bestItem, bestData, bestProt
end

local function getEquippedMaskData(player)
    local bestItem, bestData = nil, nil
    local bestProt = -1.0

    -- B42 getWornItem requires ItemBodyLocation (not a String)
    if player.getWornItem and Data.MaskSlots and ItemBodyLocation then
        for _, slot in ipairs(Data.MaskSlots) do
            local loc = ItemBodyLocation[slot] or ItemBodyLocation[string.upper(slot)]
            if loc ~= nil then
                local ok, item = pcall(function() return player:getWornItem(loc) end)
                if ok and item then
                    bestItem, bestData, bestProt = considerWornItem(item, bestItem, bestData, bestProt)
                end
            end
        end
    end

    local worn = player:getWornItems()
    if worn then
        local count = 0
        local ok, c = pcall(function() return worn:size() end)
        if ok and c then count = c end

        for i = 0, count - 1 do
            local entry = nil
            local ok2, e = pcall(function() return worn:get(i) end)
            if ok2 and e then entry = e end

            if entry then
                local item = nil
                local ok3, it = pcall(function() return entry:getItem() end)
                if ok3 and it then item = it end
                bestItem, bestData, bestProt = considerWornItem(item, bestItem, bestData, bestProt)
            end
        end
    end

    if bestItem then
        return bestItem, bestData
    end
    return nil, nil
end

-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
-- EFFECTIVE PROTECTION
-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

local function getEffectiveProtection(player)
    local mask, maskData = getEquippedMaskData(player)
    if not mask then return 0.0 end

    local protection = computeItemProtection(mask, maskData)
    return math.max(0.0, math.min(1.0, protection))
end

-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
-- FILTER / TANK DEGRADATION
-- Drains worn filter/tank life while exposed. Skips isNoFilter items.
-- Uses FilterDurationMultiplier for both filters and oxygen tanks.
-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

local function degradeFilterIfPresent(player)
    local mask, maskData = getEquippedMaskData(player)
    if not mask or not maskData or maskData.isNoFilter then return end

    -- Oxygen gear: only drain while Turned On
    if maskData.usesOxygen and not isItemActivatedSafe(mask, true) then
        return
    end

    -- B42 clothing hybrids: drain the 0..1 Remaining bar.
    local ratio = getFilterLifeRatio(mask)
    if ratio == nil then
        ratio = getFilterLifeRatio(mask)
    end
    if ratio and ratio > 0 then
        local deltaDrain = 0.005 / getFilterMultiplier()
        if deltaDrain > 0 then
            setFilterLifeRatio(mask, math.max(0, ratio - deltaDrain))
        end
        return
    end

    -- Integer uses fallback (rare); only if setCurrentUses exists.
    local current = getUsesIntSafe(mask)
    if current and current > 0 and hasMethod(mask, "setCurrentUses") then
        local drain = 0.5 / getFilterMultiplier()
        local intDrain = math.floor(drain)
        if ZombRand(100) < ((drain - intDrain) * 100) then
            intDrain = intDrain + 1
        end
        if intDrain > 0 then
            pcall(function() mask:setCurrentUses(math.max(0, current - intDrain)) end)
        end
    end
end

-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
-- COUGH & ALERTS
-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

local contaminationWarningShown = false
local ticksSinceLastCough = 99
local COUGH_INTERVAL_TICKS = 4
local EXPOSURE_KEY = "AirContaminationExposureTime"
local EXPOSURE_STEP_SECONDS = 10
local EXPOSURE_RECOVERY_SECONDS = 10
local exposureAccumulator = {}

local ALERT_MESSAGES = {
    EN = {
        "The air burns my lungs.",
        "I struggle to breathe.",
        "The contamination is getting to me.",
        "My chest tightens with every breath.",
    },
    ES = {
        "El aire quema mis pulmones.",
        "Me cuesta respirar.",
        "La contaminacion me esta afectando.",
        "Mi pecho se aprieta con cada respiracion.",
    },
}

local function getLanguageIsSpanish()
    local isSpanish = false
    if Translator and Translator.getLanguage then
        local ok, lang = pcall(function() return Translator.getLanguage() end)
        if ok and lang then
            isSpanish = (tostring(lang) == "ES")
        end
    end
    return isSpanish
end

local function getAlertMessages()
    return getLanguageIsSpanish() and ALERT_MESSAGES.ES or ALERT_MESSAGES.EN
end

local function triggerCoughAndAlert(player, isFirstExposure)
    if isFirstExposure and not contaminationWarningShown then
        contaminationWarningShown = true

        local ok, messages = pcall(getAlertMessages)
        if ok and messages then
            local msg = messages[ZombRand(#messages) + 1]
            if msg and player.Say then
                pcall(function() player:Say(msg) end)
            end
        end
    end

    ticksSinceLastCough = ticksSinceLastCough + 1
    if ticksSinceLastCough >= COUGH_INTERVAL_TICKS then
        ticksSinceLastCough = 0

        local isFemale = false
        if player.isFemale then
            local ok, val = pcall(function() return player:isFemale() end)
            if ok then isFemale = val end
        end
        local soundName = isFemale and "VoiceFemaleCough" or "VoiceMaleCough"

        if player.playSound then
            pcall(function() player:playSound(soundName) end)
        end

        if player.setVariable and player.reportEvent then
            pcall(function()
                player:setVariable("Ext", "Cough")
                player:reportEvent("EventDoExt")
            end)
        end

        local coughTexts = {
            "*cough cough*",
            "*cough*",
            "*hack*",
            "*wheeze*",
        }

        if getLanguageIsSpanish() then
            coughTexts = {
                "*cof cof*",
                "*cof*",
                "*arg*",
                "*gasp*",
            }
        end

        local coughMsg = coughTexts[ZombRand(#coughTexts) + 1]
        if coughMsg and player.Say then
            pcall(function() player:Say(coughMsg) end)
        end
    end
end

local function resetCoughState()
    contaminationWarningShown = false
    ticksSinceLastCough = COUGH_INTERVAL_TICKS
end

-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
-- HEALTH
-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

local function getOverallHealthPercent(player)
    local ok, hp = pcall(function() return player:getHealth() end)
    if ok and hp then return hp / 100.0 end
    return 1.0
end

local function applyContaminationDamage(player, damageAmount)
    if damageAmount <= 0 then return end
    local bodyDamage = player:getBodyDamage()
    if not bodyDamage then return end

    if bodyDamage.ReduceGeneralHealth then
        pcall(function() bodyDamage:ReduceGeneralHealth(damageAmount) end)
    end
end

local function applyRecovery(player)
    local bodyDamage = player:getBodyDamage()
    if not bodyDamage then return end

    if bodyDamage.ReduceGeneralHealth then
        pcall(function() bodyDamage:ReduceGeneralHealth(-Data.RecoveryPerTick) end)
    end
end

-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
-- STAT HELPERS (B42 CharacterStat API)
-- B42 removed per-stat setters (setDrunkenness / setFoodSicknessLevel).
-- INTOXICATION and FOOD_SICKNESS are 0..100 (Tipsy >= 10, Queasy >= 25).
-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

local function setCharacterStat(stats, statEnum, value)
    if not stats or not statEnum then return false end
    if stats.set then
        local ok = pcall(function() stats:set(statEnum, value) end)
        if ok then return true end
    end
    return false
end

-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
-- VISION BORROSA (CharacterStat.INTOXICATION / drunk vision)
-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

local currentBlurValue = 0

local function updateBlurEffect(player, isExposed)
    local stats = player:getStats()
    if not stats or not isExposed then return end
    local current = 0
    if CharacterStat and CharacterStat.INTOXICATION and stats.get then
        local ok, value = pcall(function() return stats:get(CharacterStat.INTOXICATION) end)
        if ok and type(value) == "number" then current = value end
    end
    local target = math.max(current, 95)
    if CharacterStat and CharacterStat.INTOXICATION then
        setCharacterStat(stats, CharacterStat.INTOXICATION, target)
    elseif stats.setDrunkenness then
        pcall(function() stats:setDrunkenness(target) end)
    end
    currentBlurValue = target
end
local function updateSicknessMoodle(player, exposureSeconds)
    local stats = player:getStats()
    if not stats or not CharacterStat or not CharacterStat.FOOD_SICKNESS then return end
    local target = 0
    if exposureSeconds >= 180 then target = 55 elseif exposureSeconds >= 60 then target = 28 end
    local current = 0
    if stats.get then
        local ok, value = pcall(function() return stats:get(CharacterStat.FOOD_SICKNESS) end)
        if ok and type(value) == "number" then current = value end
    end
    if target > current then setCharacterStat(stats, CharacterStat.FOOD_SICKNESS, target) end
end

local function applyExposureFever(player)
    local bodyDamage = player:getBodyDamage()
    if not bodyDamage then return end
    local md = player:getModData()
    if md.AC_ToxicFeverApplied then return end

    if bodyDamage.setHasACold then
        local ok = pcall(function() bodyDamage:setHasACold(true) end)
        if not ok then return end
    else
        return
    end

    local strength = 0
    if bodyDamage.getColdStrength then
        local ok, value = pcall(function() return bodyDamage:getColdStrength() end)
        if ok and type(value) == "number" then strength = value end
    end
    if strength < 50 and bodyDamage.setColdStrength then
        pcall(function() bodyDamage:setColdStrength(50.0) end)
    end
    md.AC_ToxicFeverApplied = true
end
local function getExposure(player)
    local value = tonumber(player:getModData()[EXPOSURE_KEY]) or 0
    return math.max(0, value)
end

local function setExposure(player, value)
    player:getModData()[EXPOSURE_KEY] = math.max(0, value)
end

local function debugExposure(player, outside, gas, mask, protected, exposure, exposureGain)
    if getSandboxVars().DebugProtection ~= true then return end
    local name = "?"
    if player.getUsername then
        local ok, value = pcall(function() return player:getUsername() end)
        if ok and value then name = tostring(value) end
    end
    local item, data = getEquippedMaskData(player)
    local itemType = nil
    if item and hasMethod(item, "getFullType") then local okType, value = pcall(function() return item:getFullType() end); if okType then itemType = tostring(value) end end
    local ratio = item and data and not data.isNoFilter and getFilterLifeRatio(item) or nil
    local installed = data ~= nil and not data.isNoFilter and ratio ~= nil
    local functional = data ~= nil and not data.isNoFilter and ratio ~= nil and ratio > 0
    print("[AirContamination DEBUG] Player=" .. name .. " Gas=" .. tostring(gas) .. " Outside=" .. tostring(outside)
        .. " MaskEquipped=" .. tostring(mask) .. " MaskType=" .. tostring(itemType or "none")
        .. " FilterRequired=" .. tostring(data ~= nil and not data.isNoFilter)
        .. " FilterInstalled=" .. tostring(installed) .. " FilterCondition=" .. tostring(ratio and math.floor(ratio * 100 + 0.5) or "n/a")
        .. " FilterFunctional=" .. tostring(functional)
        .. " Protected=" .. tostring(protected) .. " ExposureGain=" .. tostring(exposureGain or 0)
        .. " Exposure=" .. tostring(exposure))
end

local function onExposureInterval(player)
    if not player then return end
    if isClient and isClient() then
        if player.isLocalPlayer then
            local okLocal, localPlayer = pcall(function() return player:isLocalPlayer() end)
            if okLocal and not localPlayer then return end
        elseif player ~= getPlayer() then
            return
        end
    end

    local ok, dead = pcall(function() return player:isDead() end)
    if ok and dead then return end
    local playerId = tostring(player:getOnlineID())
    local firstUpdate = exposureAccumulator[playerId] == nil
    if firstUpdate then exposureAccumulator[playerId] = 0 end

    if not isContaminationActive() then
        exposureAccumulator[playerId] = 0
        setExposure(player, getExposure(player) - EXPOSURE_RECOVERY_SECONDS)
        return
    end

    local safe = isPlayerSafe(player)
    if safe then
        exposureAccumulator[playerId] = 0
        resetCoughState()
        setExposure(player, getExposure(player) - EXPOSURE_RECOVERY_SECONDS)
        debugExposure(player, false, true, false, true, getExposure(player))
        return
    end

    -- Sample filter consumption while the player is outdoors in active gas,
    -- including while currently protected. Re-evaluate protection immediately
    -- after the filter is consumed so an empty filter cannot grant one extra tick.
    exposureAccumulator[playerId] = exposureAccumulator[playerId] + 1
    if exposureAccumulator[playerId] >= 600 then
        exposureAccumulator[playerId] = 0
        degradeFilterIfPresent(player)
    end

    local protection = getEffectiveProtection(player)
    local maskEquipped = getEquippedMaskData(player) ~= nil
    if protection >= 1.0 then
        resetCoughState()
        setExposure(player, getExposure(player) - EXPOSURE_RECOVERY_SECONDS)
        debugExposure(player, true, true, maskEquipped, true, getExposure(player))
        return
    end

    -- Immediate onset: coughing and real INTOXICATION stat start on the first
    -- exposed player update. Subsequent exposure/damage/filter work is sampled.
    if firstUpdate then
        triggerCoughAndAlert(player, true)
        updateBlurEffect(player, true)
        debugExposure(player, true, true, maskEquipped, false, getExposure(player))
        return
    end

    if exposureAccumulator[playerId] > 0 then return end
    triggerCoughAndAlert(player, not contaminationWarningShown)
    local nextExposure = getExposure(player) + EXPOSURE_STEP_SECONDS * (1.0 - protection)
    setExposure(player, nextExposure)
    updateBlurEffect(player, true)
    updateSicknessMoodle(player, nextExposure)
    if nextExposure >= 600 then applyExposureFever(player) end

    local damage = Data.BaseDamagePerTick * (EXPOSURE_STEP_SECONDS / 10) * (1.0 - protection) * getSpeedMultiplier()
    applyContaminationDamage(player, damage)
    debugExposure(player, true, true, maskEquipped, false, nextExposure, EXPOSURE_STEP_SECONDS * (1.0 - protection))
end
-- STARTING ITEMS
-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

local startingItemsPending = false

local function tryGiveStartingItems()
    local player = getPlayer()
    if not player then return end

    local inventory = player:getInventory()
    if not inventory then return end

    local md = player:getModData()
    if md.AC_startItemsGiven then
        startingItemsPending = false
        Events.OnTick.Remove(tryGiveStartingItems)
        return
    end

    local ok, count = pcall(function() return inventory:getItems():size() end)
    if not ok or not count or count <= 0 then
        return
    end

    md.AC_startItemsGiven = true
    startingItemsPending = false
    Events.OnTick.Remove(tryGiveStartingItems)

    for _, itemData in ipairs(Data.StartingItems) do
        local fullName = "Base." .. itemData.type
        for _ = 1, itemData.count do
            local item = inventory:AddItem(fullName)
            if not item then
                print("[AirContamination] ERROR: failed to give starting item: " .. fullName)
            end
        end
    end
end

local function onCreatePlayer(playerIndex, player)
    if not getSandboxVars().StartWithMask then return end
    if startingItemsPending then return end
    startingItemsPending = true
    Events.OnTick.Add(tryGiveStartingItems)
end

-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
-- WELCOME MESSAGE (once per world on first enter)
-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

local WELCOME_MODDATA_KEY = "AirContamination"
local welcomeShown = false
local welcomeTickCounter = 0

local function getWorldModData()
    if not ModData or not ModData.getOrCreate then return nil end
    local ok, gmd = pcall(function() return ModData.getOrCreate(WELCOME_MODDATA_KEY) end)
    if ok then return gmd end
    return nil
end

local function isStartupMessageShown(player)
    local gmd = getWorldModData()
    if gmd and gmd.startupMessageShown then return true end
    if player then
        local md = player:getModData()
        if md and md.startupMessageShown then return true end
    end
    return false
end

local function markStartupMessageShown(player)
    local gmd = getWorldModData()
    if gmd then
        gmd.startupMessageShown = true
    end
    if player then
        local md = player:getModData()
        if md then md.startupMessageShown = true end
    end
end

-- Skip (and migrate) worlds that are already past the first hours of play.
local function isFreshNewWorld()
    local gameTime = GameTime:getInstance()
    if not gameTime then return true end

    local ok, nights = pcall(function() return gameTime:getNightsSurvived() end)
    if ok and nights and nights > 0 then return false end

    local ok2, hours = pcall(function() return gameTime:getWorldAgeHours() end)
    if ok2 and hours and hours > 6 then return false end

    return true
end

local function showWelcomeMessage()
    welcomeTickCounter = welcomeTickCounter + 1

    if welcomeTickCounter < 200 then return end

    if welcomeShown then
        Events.OnTick.Remove(showWelcomeMessage)
        return
    end

    local player = getPlayer()
    if not player then return end

    if isStartupMessageShown(player) then
        welcomeShown = true
        Events.OnTick.Remove(showWelcomeMessage)
        return
    end

    if not isFreshNewWorld() then
        markStartupMessageShown(player)
        welcomeShown = true
        Events.OnTick.Remove(showWelcomeMessage)
        return
    end

    welcomeShown = true
    Events.OnTick.Remove(showWelcomeMessage)
    markStartupMessageShown(player)

    local isSpanish = getLanguageIsSpanish()
    local delayDays = getDelayDays()

    local msg = ""

    if isSpanish then
        if delayDays > 0 then
            msg = "ALERTA: El aire se contaminara en " .. delayDays .. " dias. Busca mascaras y refugio."
        else
            msg = "ALERTA: El aire esta contaminado. Necesitas una mascara para sobrevivir afuera."
        end
    else
        if delayDays > 0 then
            msg = "WARNING: The air will be contaminated in " .. delayDays .. " days. Find masks and shelter."
        else
            msg = "WARNING: The air is contaminated. You need a mask to survive outdoors."
        end
    end

    if player.Say then
        pcall(function() player:Say(msg) end)
    end
end

local function onGameStart()
    welcomeShown = false
    welcomeTickCounter = 0
    Events.OnTick.Add(showWelcomeMessage)
end

-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
-- PRE-START WARNING (1 day before contamination begins)
-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

local PRESTART_WARNING = {
    ES = "A partir de manana el aire se contamina, Espero que tengas lo necesario para sobrevivir",
    EN = "Contaminated air begins tomorrow. I hope you have what you need to survive",
}

local function isPreStartWarningShown(player)
    local gmd = getWorldModData()
    if gmd and gmd.preStartWarningShown then return true end
    if player then
        local md = player:getModData()
        if md and md.preStartWarningShown then return true end
    end
    return false
end

local function markPreStartWarningShown(player)
    local gmd = getWorldModData()
    if gmd then
        gmd.preStartWarningShown = true
    end
    if player then
        local md = player:getModData()
        if md then md.preStartWarningShown = true end
    end
end

-- Contamination starts when nightsSurvived >= delayDays; warn when remaining == 1.
local function tryShowPreStartWarning()
    local player = getPlayer()
    if not player then return end

    local delayDays = getDelayDays()
    if delayDays <= 0 then return end
    if isContaminationActive() then return end
    if isPreStartWarningShown(player) then return end

    local gameTime = GameTime:getInstance()
    if not gameTime then return end

    local ok, nights = pcall(function() return gameTime:getNightsSurvived() end)
    if not ok or nights == nil then return end

    if nights ~= (delayDays - 1) then return end

    markPreStartWarningShown(player)

    local msg = getLanguageIsSpanish() and PRESTART_WARNING.ES or PRESTART_WARNING.EN
    if player.Say then
        pcall(function() player:Say(msg) end)
    end
end

-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
-- CONTAMINATION START ANNOUNCEMENT (green Large UI, once)
-- Only for delayed starts (7 / 15 days). Immediate uses welcome Say.
-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

local START_ANNOUNCE = {
    ES = "Ya llego el dia... afuera el aire esta contaminado!!!",
    EN = "The day has come... the outdoor air is contaminated!!!",
}

local startAnnounceUI = nil
local AirContaminationStartUI = nil

local function isContaminationStartAnnounced(player)
    local gmd = getWorldModData()
    if gmd and gmd.contaminationStartAnnounced then return true end
    if player then
        local md = player:getModData()
        if md and md.contaminationStartAnnounced then return true end
    end
    return false
end

local function markContaminationStartAnnounced(player)
    local gmd = getWorldModData()
    if gmd then
        gmd.contaminationStartAnnounced = true
    end
    if player then
        local md = player:getModData()
        if md then md.contaminationStartAnnounced = true end
    end
end

local function ensureStartAnnounceUIClass()
    if AirContaminationStartUI then return true end
    if not ISPanel or not ISPanel.derive then return false end

    local ok, cls = pcall(function()
        local UI = ISPanel:derive("AirContaminationStartUI")

        function UI:new(message)
            local o = ISPanel.new(self, 0, 0, 1, 1)
            o.message = message or ""
            o.age = 0
            o.alpha = 1.0
            o.holdTicks = 240
            o.fadeTicks = 120
            o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
            o.borderColor = { r = 0, g = 0, b = 0, a = 0 }
            return o
        end

        function UI:initialise()
            ISPanel.initialise(self)
        end

        function UI:prerender()
        end

        function UI:render()
            if not self.message or self.message == "" then return end
            local core = getCore()
            if not core then return end
            local screenW = core:getScreenWidth()
            local screenH = core:getScreenHeight()
            local font = (UIFont and UIFont.Large) or (UIFont and UIFont.Medium)
            if not font then return end
            local y = math.floor(screenH * 0.22)
            self:drawTextCentre(self.message, screenW / 2, y, 0.2, 0.9, 0.25, self.alpha or 1.0, font)
        end

        function UI:update()
            ISPanel.update(self)
            self.age = (self.age or 0) + 1
            local hold = self.holdTicks or 240
            local fade = self.fadeTicks or 120
            if self.age > hold then
                self.alpha = math.max(0, 1 - ((self.age - hold) / fade))
            end
            if self.age >= (hold + fade) then
                self:removeFromUIManager()
                if startAnnounceUI == self then
                    startAnnounceUI = nil
                end
            end
        end

        return UI
    end)

    if ok and cls then
        AirContaminationStartUI = cls
        return true
    end
    return false
end

local function showContaminationStartAnnouncement(text)
    if startAnnounceUI then
        pcall(function() startAnnounceUI:removeFromUIManager() end)
        startAnnounceUI = nil
    end

    if ensureStartAnnounceUIClass() then
        local ok, ui = pcall(function()
            local panel = AirContaminationStartUI:new(text)
            panel:initialise()
            panel:addToUIManager()
            return panel
        end)
        if ok and ui then
            startAnnounceUI = ui
            return
        end
    end

    -- Fallbacks if custom UI is unavailable
    local player = getPlayer()
    if player and player.setHaloNote then
        pcall(function() player:setHaloNote(text, 50, 230, 60, 350.0) end)
        return
    end
    if player and HaloTextHelper and HaloTextHelper.addTextWithArrow then
        local color = nil
        if HaloTextHelper.getColorGreen then
            color = HaloTextHelper.getColorGreen()
        end
        pcall(function()
            if color then
                HaloTextHelper.addTextWithArrow(player, text, true, color)
            else
                HaloTextHelper.addTextWithArrow(player, text, true, 50, 230, 60)
            end
        end)
    end
end

local function tryShowContaminationStartAnnouncement()
    local player = getPlayer()
    if not player then return end

    local delayDays = getDelayDays()
    if delayDays <= 0 then return end
    if not isContaminationActive() then return end
    if isContaminationStartAnnounced(player) then return end

    markContaminationStartAnnounced(player)

    local msg = getLanguageIsSpanish() and START_ANNOUNCE.ES or START_ANNOUNCE.EN
    showContaminationStartAnnouncement(msg)
end

-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
-- EVENT REGISTRATION
-- Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

Events.OnPlayerUpdate.Add(onExposureInterval)
print("[AirContamination] Toxic exposure progression registered")
Events.EveryOneMinute.Add(tryShowPreStartWarning)
Events.EveryOneMinute.Add(tryShowContaminationStartAnnouncement)
Events.OnCreatePlayer.Add(onCreatePlayer)
Events.OnGameStart.Add(onGameStart)




















