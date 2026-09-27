-- AirContamination_BodyLocations.lua
-- SCBA exclusivity with BACK/WEBBING/SHOULDER_HOLSTER is removed via soft-override of
-- media/lua/shared/NPCs/BodyLocations.lua (no Java reflection; works without -debug).
-- This file only verifies the override took effect using the public isExclusive API.

local function resolveBodyLocation(name)
    if not name then return nil end
    if ItemBodyLocation then
        if ItemBodyLocation[name] ~= nil then return ItemBodyLocation[name] end
        local upper = string.upper(name)
        if ItemBodyLocation[upper] ~= nil then return ItemBodyLocation[upper] end
    end
    return name
end

local function isExclusive(group, locA, locB)
    if not group or not locA or not locB or not group.isExclusive then return nil end
    local ok, exclusive = pcall(function() return group:isExclusive(locA, locB) end)
    if not ok then return nil end
    return exclusive == true
end

local function verifyScbaExclusives()
    if not BodyLocations or not BodyLocations.getGroup then
        print("[AirContamination] BodyLocations API unavailable; SCBA backpack patch skipped.")
        return
    end

    local ok, group = pcall(function() return BodyLocations.getGroup("Human") end)
    if not ok or not group then
        print("[AirContamination] Human BodyLocation group missing; SCBA backpack patch skipped.")
        return
    end

    local scba = resolveBodyLocation("SCBA")
    local scbaNoTank = resolveBodyLocation("SCBANOTANK")
    local back = resolveBodyLocation("BACK")
    local webbing = resolveBodyLocation("WEBBING")
    local shoulder = resolveBodyLocation("SHOULDER_HOLSTER")

    -- Pairs that must NOT be exclusive (cleared by BodyLocations.lua soft-override)
    local pairsCleared = {
        { scba, back },
        { scba, webbing },
        { scba, shoulder },
        { scbaNoTank, webbing },
        { scbaNoTank, shoulder },
    }

    local cleared = 0
    local stillExclusive = 0
    for _, pair in ipairs(pairsCleared) do
        if pair[1] and pair[2] then
            local exclusive = isExclusive(group, pair[1], pair[2])
            if exclusive == false then
                cleared = cleared + 1
            elseif exclusive == true then
                stillExclusive = stillExclusive + 1
            end
        end
    end

    if stillExclusive > 0 then
        print("[AirContamination] SCBA BodyLocation patch partial (" .. tostring(cleared) .. " cleared, " .. tostring(stillExclusive) .. " still exclusive).")
        print("[AirContamination] Another mod may have re-applied vanilla BodyLocations.lua after ours.")
    else
        print("[AirContamination] SCBA BodyLocation exclusivity patch applied (" .. tostring(cleared) .. " pairs cleared)")
    end
end

Events.OnGameBoot.Add(verifyScbaExclusives)
