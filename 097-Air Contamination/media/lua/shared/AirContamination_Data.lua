-- AirContamination_Data.lua
AirContaminationData = AirContaminationData or {}

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- MASK PROTECTION TABLE
-- isNoFilter: fixed protection (cloth / empty mask / no tank). Not drained.
-- usesOxygen: SCBA / hazmat tank gear; protection gated on tank uses (+ activation).
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
AirContaminationData.MaskProtection = {
    -- GAS MASKS (degradable filter when installed)
    ["Hat_GasMask"]                    = { protection = 1.00, isNoFilter = false },
    ["Hat_NBCmask"]                    = { protection = 1.00, isNoFilter = false },
    ["Hat_ImprovisedGasMask"]          = { protection = 0.85, isNoFilter = false },

    ["Hat_GasMask_nofilter"]           = { protection = 0.25, isNoFilter = true },
    ["Hat_NBCmask_nofilter"]           = { protection = 0.25, isNoFilter = true },
    ["Hat_ImprovisedGasMask_nofilter"] = { protection = 0.20, isNoFilter = true },

    -- GP5 CIVILIAN (optional mod GP5Civilian)
    ["GasMask_GP5"]                    = { protection = 1.00, isNoFilter = false },
    ["GasMask_GP5_Black"]              = { protection = 1.00, isNoFilter = false },
    ["GasMask_GP5_Olive"]              = { protection = 1.00, isNoFilter = false },

    ["GasMask_GP5_Empty"]              = { protection = 0.25, isNoFilter = true },
    ["GasMask_GP5_Black_Empty"]        = { protection = 0.25, isNoFilter = true },
    ["GasMask_GP5_Olive_Empty"]        = { protection = 0.25, isNoFilter = true },

    -- UMBRELLA CORP UNIFORM (optional mod [J&G] Umbrella Corp Uniform)
    ["Umbrella_Corp_GasMask"]          = { protection = 1.00, isNoFilter = false },
    ["Umbrella_Corp_GasMask_NoFilter"]   = { protection = 0.25, isNoFilter = true },
    ["Umbrella_Corp_Balaclava"]        = { protection = 0.10, isNoFilter = true },

    -- RESPIRATORS
    ["Hat_BuildersRespirator"]         = { protection = 1.00, isNoFilter = false },
    ["Hat_BuildersRespirator_nofilter"] = { protection = 0.15, isNoFilter = true },

    -- SCBA / oxygen gear
    ["SCBA"]                           = { protection = 1.00, isNoFilter = false, usesOxygen = true },
    ["SCBA_notank"]                    = { protection = 0.10, isNoFilter = true,  usesOxygen = true },
    -- Hazmat: ActivatedItem + oxygen tank via put_oxygen_tank; drainable when tank attached
    ["HazmatSuit"]                     = { protection = 1.00, isNoFilter = false, usesOxygen = true },

    -- DUST MASK
    ["Hat_DustMask"]                   = { protection = 0.40, isNoFilter = true },

    -- MASCARILLA QUIRURGICA
    ["Hat_SurgicalMask"]               = { protection = 0.20, isNoFilter = true },

    -- BANDANAS
    ["Hat_BandanaMask"]                = { protection = 0.10, isNoFilter = true },
    ["Hat_BandanaMask_Green"]          = { protection = 0.10, isNoFilter = true },
    ["Hat_BandanaMaskTINT"]            = { protection = 0.10, isNoFilter = true },
    ["Hat_RagBandanaMask"]             = { protection = 0.08, isNoFilter = true },

    -- BALACLAVAS
    ["Hat_BalaclavaFace"]              = { protection = 0.08, isNoFilter = true },
    ["Hat_BalaclavaFull"]              = { protection = 0.10, isNoFilter = true },

    -- SHEMAGHS mascara
    ["ShemaghScarfFace"]               = { protection = 0.10, isNoFilter = true },
    ["ShemaghScarfFace_Green"]         = { protection = 0.10, isNoFilter = true },

    -- HEAD SACKS
    ["Hat_HeadSack_Burlap"]            = { protection = 0.05, isNoFilter = true },
    ["Hat_HeadSack_Cotton"]            = { protection = 0.05, isNoFilter = true },
    ["Hat_HeadSack_Hide"]              = { protection = 0.06, isNoFilter = true },
    ["Hat_HeadSack_Garbage"]           = { protection = 0.08, isNoFilter = true },
    ["Hat_HeadSack_Tarp"]              = { protection = 0.08, isNoFilter = true },

    -- SHEMAGHS fullhat
    ["Hat_ShemaghFull_Burlap"]         = { protection = 0.05, isNoFilter = true },
    ["Hat_ShemaghFace_Burlap"]         = { protection = 0.05, isNoFilter = true },
    ["Hat_ShemaghFull_Cotton"]         = { protection = 0.05, isNoFilter = true },
    ["Hat_ShemaghFace_Cotton"]         = { protection = 0.05, isNoFilter = true },

    -- HALLOWEEN / DECORATIVAS
    ["Hat_HalloweenMaskDevil"]         = { protection = 0.03, isNoFilter = true },
    ["Hat_HalloweenMaskMonster"]       = { protection = 0.03, isNoFilter = true },
    ["Hat_HalloweenMaskPumpkin"]       = { protection = 0.03, isNoFilter = true },
    ["Hat_HalloweenMaskSkeleton"]      = { protection = 0.03, isNoFilter = true },
    ["Hat_HalloweenMaskVampire"]       = { protection = 0.03, isNoFilter = true },
    ["Hat_HalloweenMaskWitch"]         = { protection = 0.03, isNoFilter = true },
    ["Hat_HockeyMask"]                 = { protection = 0.03, isNoFilter = true },
    ["Hat_HockeyMask_Metal"]           = { protection = 0.03, isNoFilter = true },
    ["Hat_HockeyMask_Copper"]          = { protection = 0.03, isNoFilter = true },
    ["Hat_HockeyMask_Gold"]            = { protection = 0.03, isNoFilter = true },
    ["Hat_HockeyMask_Silver"]          = { protection = 0.03, isNoFilter = true },
    ["Hat_HockeyMask_MetalScrap"]      = { protection = 0.03, isNoFilter = true },
    ["Hat_HockeyMask_Wood"]            = { protection = 0.03, isNoFilter = true },
    ["Hat_HockeyMask_Hide"]            = { protection = 0.03, isNoFilter = true },
    ["Hat_BoneMask"]                   = { protection = 0.02, isNoFilter = true },
    ["WeldingMask"]                    = { protection = 0.02, isNoFilter = true },
}

-- Empty shell â†’ with-filter / with-tank type (Put).
AirContaminationData.NofilterToFiltered = {
    ["Hat_GasMask_nofilter"] = "Hat_GasMask",
    ["Hat_NBCmask_nofilter"] = "Hat_NBCmask",
    ["Hat_BuildersRespirator_nofilter"] = "Hat_BuildersRespirator",
    ["Hat_ImprovisedGasMask_nofilter"] = "Hat_ImprovisedGasMask",
    ["SCBA_notank"] = "SCBA",
    ["GasMask_GP5_Empty"] = "GasMask_GP5",
    ["GasMask_GP5_Black_Empty"] = "GasMask_GP5_Black",
    ["GasMask_GP5_Olive_Empty"] = "GasMask_GP5_Olive",
    ["Umbrella_Corp_GasMask_NoFilter"] = "Umbrella_Corp_GasMask",
}

-- With-filter / with-tank â†’ empty shell (Remove). Inverse of above.
AirContaminationData.FilteredToNofilter = {
    ["Hat_GasMask"] = "Hat_GasMask_nofilter",
    ["Hat_NBCmask"] = "Hat_NBCmask_nofilter",
    ["Hat_BuildersRespirator"] = "Hat_BuildersRespirator_nofilter",
    ["Hat_ImprovisedGasMask"] = "Hat_ImprovisedGasMask_nofilter",
    ["SCBA"] = "SCBA_notank",
    ["GasMask_GP5"] = "GasMask_GP5_Empty",
    ["GasMask_GP5_Black"] = "GasMask_GP5_Black_Empty",
    ["GasMask_GP5_Olive"] = "GasMask_GP5_Olive_Empty",
    ["Umbrella_Corp_GasMask"] = "Umbrella_Corp_GasMask_NoFilter",
}

-- Context-menu Put: which consumable types attach to each empty shell.
AirContaminationData.PutFilterConfig = {
    ["Hat_GasMask_nofilter"] = {
        kind = "gasmask",
        filters = { "GasmaskFilter", "GasmaskFilterCrafted" },
    },
    ["Hat_NBCmask_nofilter"] = {
        kind = "gasmask",
        filters = { "GasmaskFilter", "GasmaskFilterCrafted" },
    },
    ["Hat_BuildersRespirator_nofilter"] = {
        kind = "respirator",
        filters = { "RespiratorFilters", "RespiratorFiltersRecharged" },
    },
    ["Hat_ImprovisedGasMask_nofilter"] = {
        kind = "improvised",
        -- Vanilla PutRag uses RippedSheets; RagFilter is the drainable rag filter.
        filters = { "RippedSheets", "RagFilter" },
    },
    ["GasMask_GP5_Empty"] = {
        kind = "gasmask",
        filters = { "GP5_Filter" },
    },
    ["GasMask_GP5_Black_Empty"] = {
        kind = "gasmask",
        filters = { "GP5_Filter" },
    },
    ["GasMask_GP5_Olive_Empty"] = {
        kind = "gasmask",
        filters = { "GP5_Filter" },
    },
    ["SCBA_notank"] = {
        kind = "tank",
        filters = { "Oxygen_Tank" },
        requireUnequipped = true,
    },
    ["Umbrella_Corp_GasMask_NoFilter"] = {
        kind = "gasmask",
        filters = { "GasmaskFilter", "GasmaskFilterCrafted" },
    },
}

-- Filter/tank type returned on safe Remove (remaining uses copied when drainable).
AirContaminationData.ReturnFilterType = {
    ["Hat_GasMask"] = "GasmaskFilter",
    ["Hat_NBCmask"] = "GasmaskFilter",
    ["Hat_BuildersRespirator"] = "RespiratorFilters",
    ["Hat_ImprovisedGasMask"] = "RippedSheets",
    ["SCBA"] = "Oxygen_Tank",
    ["GasMask_GP5"] = "GP5_Filter",
    ["GasMask_GP5_Black"] = "GP5_Filter",
    ["GasMask_GP5_Olive"] = "GP5_Filter",
    ["Umbrella_Corp_GasMask"] = "GasmaskFilter",
}

-- GP5 uses hasFilter()/setFilterType on the full mask type. Empty shells
-- (GasMask_GP5_*_Empty) are Hidden in GP5Civilian â€” do not type-swap to them.
AirContaminationData.EmbeddedFilterMasks = {
    ["GasMask_GP5"] = { filterType = "GP5_Filter" },
    ["GasMask_GP5_Black"] = { filterType = "GP5_Filter" },
    ["GasMask_GP5_Olive"] = { filterType = "GP5_Filter" },
}

-- Body location IDs (ItemBodyLocation / B42 constants); used for optional slot lookups
AirContaminationData.MaskSlots = {
    "MASK_EYES",
    "MASK",
    "MASK_FULL",
    "FULL_HAT",
    "SCBA",
    "SCBANOTANK",
    "FULL_SUIT_HEAD",
}

AirContaminationData.SpeedMultipliers = {
    [1] = 0.5,
    [2] = 1.0,
    [3] = 2.0,
}

AirContaminationData.FilterMultipliers = {
    [1] = 0.25,
    [2] = 0.50,
    [3] = 1.00,
    [4] = 2.00,
    [5] = 4.00,
}

-- Floor protection when a filterable/oxygen item has no remaining uses
AirContaminationData.EmptyFilterProtectionFactor = 0.15
AirContaminationData.EmptyOxygenProtection = 0.10

AirContaminationData.BaseDamagePerTick = 0.35
AirContaminationData.RecoveryPerTick = 0.10

AirContaminationData.MoodleThresholds = {
    { minHealth = 0.75, level = 0 },
    { minHealth = 0.50, level = 1 },
    { minHealth = 0.25, level = 2 },
    { minHealth = 0.00, level = 3 },
}

AirContaminationData.DelayDays = {
    [1] = 0,
    [2] = 7,
    [3] = 15,
}

AirContaminationData.StartingItems = {
    { type = "Hat_SurgicalMask", count = 2 },
}
