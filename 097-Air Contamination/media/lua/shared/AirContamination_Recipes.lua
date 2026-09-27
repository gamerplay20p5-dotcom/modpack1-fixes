-- Wrap vanilla Remove* OnCreate so craft-menu Remove cannot delete the mask.
-- Put on empty shells is handled by AirContamination_ContextMenu (Lua).
-- Soft GP5 craft gate: MakeGP5Filter OnTest (item script must exist).

RecipeCodeOnCreate = RecipeCodeOnCreate or {}
AirContaminationRecipes = AirContaminationRecipes or {}

local function hasGP5FilterScript()
    local sm = nil
    if getScriptManager then
        local ok, mgr = pcall(function() return getScriptManager() end)
        if ok then sm = mgr end
    end
    if not sm and ScriptManager then
        sm = ScriptManager.instance
    end
    if not sm or not sm.getItem then
        return false
    end
    local item = nil
    local okGet, result = pcall(function() return sm:getItem("Base.GP5_Filter") end)
    if okGet then item = result end
    return item ~= nil
end

-- B42 craftRecipe OnTest signature: (item, character) — called per input.
-- Soft-disable MakeGP5Filter when GP5Civilian (or another mod) is not loaded.
function AirContaminationRecipes.canCraftGP5Filter(_item, _character)
    return hasGP5FilterScript()
end

local function wrapRemoveHandlers()
    local Convert = AirContaminationConvert
    if not Convert then
        print("[AirContamination] ERROR: Convert missing — cannot wrap Remove handlers")
        return
    end

    local origRemoveFilter = RecipeCodeOnCreate.removeGasFilter
    RecipeCodeOnCreate.removeGasFilter = function(craftData, character)
        local keep = Convert.collectKeepItems(craftData)
        local did = false
        local map = AirContaminationData and AirContaminationData.FilteredToNofilter
        for _, item in ipairs(keep) do
            local t = Convert.getItemType(item)
            if t and map and map[t] then
                if Convert.removeFrom(character, item) then
                    did = true
                end
            end
        end
        if did then
            print("[AirContamination] Safe removeGasFilter OK")
            return
        end
        -- Fallback: vanilla (may delete if WithoutDrainable broken)
        if origRemoveFilter then
            print("[AirContamination] WARN: safe remove missed keep-items; trying vanilla removeGasFilter")
            pcall(function() origRemoveFilter(craftData, character) end)
        end
    end

    local origRemoveTank = RecipeCodeOnCreate.removeOxygenTank
    RecipeCodeOnCreate.removeOxygenTank = function(craftData, character)
        local keep = Convert.collectKeepItems(craftData)
        local did = false
        for _, item in ipairs(keep) do
            local t = Convert.getItemType(item)
            if t == "SCBA" or t == "HazmatSuit" then
                if Convert.removeFrom(character, item) then
                    did = true
                end
            end
        end
        if did then
            print("[AirContamination] Safe removeOxygenTank OK")
            return
        end
        if origRemoveTank then
            print("[AirContamination] WARN: safe remove tank missed; trying vanilla")
            pcall(function() origRemoveTank(craftData, character) end)
        end
    end

    -- Oxygen Put: keep vanilla conversion, force SCBA/Hazmat OFF afterward.
    local origAddTank = RecipeCodeOnCreate.addOxygenTank
    if origAddTank then
        RecipeCodeOnCreate.addOxygenTank = function(craftData, character)
            pcall(function() origAddTank(craftData, character) end)
            for _, item in ipairs(Convert.collectKeepItems(craftData)) do
                local t = Convert.getItemType(item)
                if (t == "SCBA" or t == "HazmatSuit") and item.setActivated then
                    pcall(function() item:setActivated(false) end)
                end
            end
            if character and character.getInventory then
                local inv = nil
                pcall(function() inv = character:getInventory() end)
                if inv and inv.FindAndReturn then
                    local found = nil
                    pcall(function() found = inv:FindAndReturn("Base.SCBA") end)
                    if found and found.setActivated then
                        pcall(function() found:setActivated(false) end)
                    end
                end
            end
        end
    end

    print("[AirContamination] Recipe Remove/Tank wrappers installed")
    if hasGP5FilterScript() then
        print("[AirContamination] GP5_Filter craft: ENABLED (item script present)")
    else
        print("[AirContamination] GP5_Filter craft: DISABLED (Base.GP5_Filter not loaded)")
    end
end

Events.OnGameBoot.Add(wrapRemoveHandlers)