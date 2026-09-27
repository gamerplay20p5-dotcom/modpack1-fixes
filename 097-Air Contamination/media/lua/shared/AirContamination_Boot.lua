-- Boot diagnostics only. No item DoParam / soft-override patches.
-- Put/Remove is handled by AirContamination_Convert + ContextMenu (v1.5.9+).
-- SCBA+backpack via BodyLocations.lua soft-override (v1.5.10+; no reflection).

print("[AirContamination] ========== MOD LOADED v1.5.16 ==========")
print("[AirContamination] Path: Lua soft Put/Remove (NO item/recipe soft-overrides)")

local CHECK_ITEMS = {
    "Base.Hat_GasMask_nofilter",
    "Base.Hat_GasMask",
    "Base.Hat_NBCmask_nofilter",
    "Base.Hat_NBCmask",
    "Base.Hat_BuildersRespirator_nofilter",
    "Base.Hat_BuildersRespirator",
    "Base.Hat_ImprovisedGasMask_nofilter",
    "Base.Hat_ImprovisedGasMask",
    "Base.SCBA_notank",
    "Base.SCBA",
    "Base.GasmaskFilter",
    "Base.RespiratorFilters",
    "Base.Oxygen_Tank",
}

local function getScriptManagerSafe()
    if getScriptManager then
        local ok, mgr = pcall(function() return getScriptManager() end)
        if ok and mgr then return mgr end
    end
    if ScriptManager then
        return ScriptManager.instance
    end
    return nil
end

local function verifyItemScripts()
    local sm = getScriptManagerSafe()
    if not sm or not sm.getItem then
        print("[AirContamination] ERROR: ScriptManager unavailable â€” cannot verify items")
        return
    end

    local okCount, missCount = 0, 0
    for _, fullType in ipairs(CHECK_ITEMS) do
        local item = nil
        local okGet, result = pcall(function() return sm:getItem(fullType) end)
        if okGet then item = result end
        if item then
            okCount = okCount + 1
            local withName, withoutName = nil, nil
            pcall(function()
                if item.getWithDrainable then
                    local w = item:getWithDrainable()
                    if w then
                        if w.getFullName then withName = w:getFullName()
                        elseif w.getName then withName = w:getName() end
                    end
                end
                if item.getWithoutDrainable then
                    local w = item:getWithoutDrainable()
                    if w then
                        if w.getFullName then withoutName = w:getFullName()
                        elseif w.getName then withoutName = w:getName() end
                    end
                end
            end)
            if withName or withoutName then
                print("[AirContamination] OK " .. fullType
                    .. " With=" .. tostring(withName)
                    .. " Without=" .. tostring(withoutName))
            end
        else
            missCount = missCount + 1
            print("[AirContamination] MISSING item script: " .. fullType)
        end
    end

    print("[AirContamination] Item script check: " .. tostring(okCount) .. " ok, "
        .. tostring(missCount) .. " missing")
    if AirContaminationConvert then
        print("[AirContamination] Convert module: PRESENT")
    else
        print("[AirContamination] Convert module: MISSING (shared load order?)")
    end
end

Events.OnGameBoot.Add(verifyItemScripts)
