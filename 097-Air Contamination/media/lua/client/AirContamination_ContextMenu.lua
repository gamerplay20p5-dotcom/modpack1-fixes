-- Inventory context-menu Put Filter / Put Tank / Remove.
-- Primary fix for empty shells that vanilla recipes ignore (wrong tags)
-- and for Remove that deletes the mask when WithoutDrainable resolution fails.

require "ISUI/ISInventoryPaneContextMenu"

print("[AirContamination] Context menu handler LOADED (Put/Remove Filter & Tank)")

local function data()
    return AirContaminationData or {}
end

local function convert()
    return AirContaminationConvert
end

local function isSpanish()
    if Translator and Translator.getLanguage then
        local ok, lang = pcall(function() return Translator.getLanguage() end)
        if ok and lang and tostring(lang) == "ES" then return true end
    end
    return false
end

local function T(en, es)
    if isSpanish() then return es end
    return en
end

local function stripModuleSafe(fullType)
    if not fullType then return nil end
    local plain = tostring(fullType)
    local dot = plain:find("%.[^%.]*$")
    if dot then return plain:sub(dot + 1) end
    return plain
end

local function getPlayerObj(playerIndex)
    if getSpecificPlayer then
        return getSpecificPlayer(playerIndex)
    end
    return getPlayer()
end

local function onPut(playerIndex, shellItem, consumableItem)
    local player = getPlayerObj(playerIndex)
    local C = convert()
    if not player or not C then return end
    local ok = C.putOn(player, shellItem, consumableItem)
    if not ok then
        print("[AirContamination] Context Put FAILED for "
            .. tostring(C.getItemType(shellItem)))
    end
end

local function onRemove(playerIndex, gearItem)
    local player = getPlayerObj(playerIndex)
    local C = convert()
    if not player or not C then return end
    local ok = C.removeFrom(player, gearItem)
    if not ok then
        print("[AirContamination] Context Remove FAILED for "
            .. tostring(C.getItemType(gearItem)))
    end
end

local function addPutOption(context, playerIndex, shellItem, consumableItem, label)
    if not context or not shellItem or not consumableItem then return end
    local opt = context:addOption(label, playerIndex, onPut, shellItem, consumableItem)
    if opt then
        opt.itemForTexture = consumableItem
    end
end

local function addRemoveOption(context, playerIndex, gearItem, label)
    if not context or not gearItem then return end
    local opt = context:addOption(label, playerIndex, onRemove, gearItem)
    if opt then
        opt.itemForTexture = gearItem
    end
end

local function handleEmbeddedShellItem(context, playerIndex, player, item, itemType)
    local D = data()
    local C = convert()
    if not C then return end
    local embeddedCfg = D.EmbeddedFilterMasks and D.EmbeddedFilterMasks[itemType]
    if not embeddedCfg then return end
    if C.hasEmbeddedFilter(item) then return end

    local consumable = C.findConsumable(player, { embeddedCfg.filterType })
    if not consumable then return end

    addPutOption(context, playerIndex, item, consumable,
        T("Put Filter", "Poner filtro"))
end

local function handleShellItem(context, playerIndex, player, item, itemType)
    local D = data()
    local C = convert()
    if not C then return end

    handleEmbeddedShellItem(context, playerIndex, player, item, itemType)

    local cfg = D.PutFilterConfig and D.PutFilterConfig[itemType]
    if not cfg then return end

    local consumable = C.findConsumable(player, cfg.filters)
    if not consumable then return end

    if cfg.kind == "tank" then
        addPutOption(context, playerIndex, item, consumable,
            T("Put Oxygen Tank", "Poner tanque de oxigeno"))
    elseif cfg.kind == "improvised" then
        addPutOption(context, playerIndex, item, consumable,
            T("Put Rag Filter", "Poner trapo (filtro)"))
    else
        addPutOption(context, playerIndex, item, consumable,
            T("Put Filter", "Poner filtro"))
    end
end

local function handleGearItem(context, playerIndex, item, itemType)
    local D = data()
    local C = convert()
    if not D.FilteredToNofilter or not D.FilteredToNofilter[itemType] then
        return
    end

    if D.EmbeddedFilterMasks and D.EmbeddedFilterMasks[itemType] then
        if not C or not C.hasEmbeddedFilter(item) then return end
    end

    if itemType == "SCBA" or itemType == "HazmatSuit" then
        addRemoveOption(context, playerIndex, item,
            T("Remove Oxygen Tank", "Quitar tanque de oxigeno"))
    elseif itemType == "Hat_ImprovisedGasMask" then
        addRemoveOption(context, playerIndex, item,
            T("Remove Rag Filter", "Quitar trapo (filtro)"))
    else
        addRemoveOption(context, playerIndex, item,
            T("Remove Filter", "Quitar filtro"))
    end
end

local function handleConsumableItem(context, playerIndex, player, item, itemType)
    local D = data()
    local C = convert()
    if not D.PutFilterConfig or not C then return end

    -- Avoid duplicate options if this item is also a shell/gear type
    if D.PutFilterConfig[itemType] or (D.FilteredToNofilter and D.FilteredToNofilter[itemType]) then
        return
    end

    for shellType, cfg in pairs(D.PutFilterConfig) do
        local match = false
        for _, f in ipairs(cfg.filters) do
            if itemType == f or itemType == stripModuleSafe(f) then
                match = true
                break
            end
        end
        if match then
            local shell = C.findEmptyShell(player, shellType)
            if shell then
                if cfg.kind == "tank" then
                    addPutOption(context, playerIndex, shell, item,
                        T("Put Tank on SCBA", "Poner tanque en SCBA"))
                elseif cfg.kind == "improvised" then
                    addPutOption(context, playerIndex, shell, item,
                        T("Put Rag on Mask", "Poner trapo en mascara"))
                else
                    addPutOption(context, playerIndex, shell, item,
                        T("Put Filter on Mask", "Poner filtro en mascara"))
                end
            end
        end
    end
end

local function onFillInventoryContextMenu(playerIndex, context, items)
    local player = getPlayerObj(playerIndex)
    if not player or not context or not items then return end
    local C = convert()
    if not C then
        print("[AirContamination] ERROR: AirContaminationConvert missing in context menu")
        return
    end

    local actual = nil
    if ISInventoryPane and ISInventoryPane.getActualItems then
        actual = ISInventoryPane.getActualItems(items)
    end
    if not actual or #actual < 1 then return end

    local item = actual[1]
    if not item then return end

    local itemType = C.getItemType(item)
    if not itemType then return end

    handleShellItem(context, playerIndex, player, item, itemType)
    handleGearItem(context, playerIndex, item, itemType)
    handleConsumableItem(context, playerIndex, player, item, itemType)
end

Events.OnFillInventoryObjectContextMenu.Add(onFillInventoryContextMenu)
