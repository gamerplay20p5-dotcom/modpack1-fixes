local function isModPresent(modId)
    return getActivatedMods():contains(modId) or getActivatedMods():contains("\\"..modId)
end

---@class EquipmentUISettings
---@field public GOOD_COLOR table
---@field public MIDDLE_COLOR table
---@field public BAD_COLOR table
---@field public EQUIPMENT_WIDTH number
---@field public EQUIPMENT_UI_X_OFFSET number
---@field public EQUIPMENT_UI_Y_OFFSET number
---@field public EQUIPMENT_UI_BOTTOM_PADDING number
---@field public EQUIPMENT_DYNAMIC_SLOT_MARGIN number
---@field public EQUIPMENT_DYNAMIC_SLOT_X_OFFSET number
---@field public EQUIPMENT_DYNAMIC_SLOT_Y_OFFSET number
---@field public SLOT_SIZE number
---@field public SUPER_SLOT_SIZE number
---@field public SUPER_SLOT_VERTICAL_OFFSET number
---@field public SUPER_SLOT_SUB_ITEM_WIDTH number
---@field public SUB_SLOT_THING number
---@field public WEAPON_SLOT_SIZE number
---@field public WEAPON_SLOT_PRIMARY_SIZE number
---@field public WEAPON_SLOT_SECONDARY_SIZE number
---@field public WEAPON_SLOT_PRIMARY_OFFSET number
---@field public WEAPON_SLOT_SECONDARY_X_OFFSET number
---@field public WEAPON_SLOT_SECONDARY_Y_OFFSET number
---@field public HOTBAR_SLOT_Y_OFFSET number
---@field public HOTBAR_SLOT_X_OFFSET number
---@field public HOTBAR_SLOT_MARGIN number
---@field public SCALE number
---@field public HIDE_EQUIPPED_ITEMS boolean
---@field public TOGGLE_UI_CONTROLLER_BIND number
---@field public InventoryTetris any est-ce qu'Inventory Tetris est installé ?
---@field public OnScaleChanged fun(scale: number)[]
---@field public applyScale fun(self: EquipmentUISettings, scale: number)
---@field public applyHideEquippedItems fun(self: EquipmentUISettings, hide: boolean)
---@field public applyToggleUiControllerBind fun(self: EquipmentUISettings, bindIndex: number)


---@diagnostic disable-next-line: missing-fields
---@type EquipmentUISettings
local EQUIPMENT_UI_SETTINGS = {}

EQUIPMENT_UI_SETTINGS.GOOD_COLOR = {r=0.0, g=1.0, b=0.0, a=1.0}
EQUIPMENT_UI_SETTINGS.MIDDLE_COLOR = {r=1.0, g=1.0, b=0.0, a=1.0}
EQUIPMENT_UI_SETTINGS.BAD_COLOR = {r=1.0, g=0.0, b=0.0, a=1.0}

local tetrisPresent = isModPresent("INVENTORY_TETRIS")
if tetrisPresent then
    -- pcall : si la structure interne d'Inventory Tetris change (mise a jour de leur cote), ce
    -- require ne doit pas planter et emporter tout le chargement de ce mod (hotbar reorder,
    -- panneau equipement, etc.) avec lui.
    local ok, tetrisModule = pcall(require, "InventoryTetris/InventoryTetris")
    EQUIPMENT_UI_SETTINGS.InventoryTetris = (ok and tetrisModule) or tetrisPresent
end

-- Sert aussi à donner les valeurs par défaut

-- INTERFACE D'ÉQUIPEMENT
EQUIPMENT_UI_SETTINGS.applyScale = function(self, scale)
    self.EQUIPMENT_WIDTH = 220 * scale
    self.EQUIPMENT_UI_X_OFFSET = 44 * scale
    self.EQUIPMENT_UI_Y_OFFSET = 24 * scale
    self.EQUIPMENT_UI_BOTTOM_PADDING = 8 * scale

    self.EQUIPMENT_DYNAMIC_SLOT_MARGIN = 4 * scale
    self.EQUIPMENT_DYNAMIC_SLOT_X_OFFSET = 16 * scale
    self.EQUIPMENT_DYNAMIC_SLOT_Y_OFFSET = 352 * scale

    self.SLOT_SIZE = 34 * scale
    self.SUPER_SLOT_SIZE = 38 * scale
    self.SUPER_SLOT_VERTICAL_OFFSET = 10 * scale
    self.SUPER_SLOT_SUB_ITEM_WIDTH = 12 * scale
    self.SUB_SLOT_THING = 5 * scale -- Voilà pourquoi je devrais m'occuper des nombres magiques avant d'oublier à quoi ils servent

    self.WEAPON_SLOT_SIZE = 46 * scale
    self.WEAPON_SLOT_PRIMARY_SIZE = 32 * scale
    self.WEAPON_SLOT_SECONDARY_SIZE = 24 * scale

    self.WEAPON_SLOT_PRIMARY_OFFSET = 22 * scale
    self.WEAPON_SLOT_SECONDARY_X_OFFSET = 25 * scale
    self.WEAPON_SLOT_SECONDARY_Y_OFFSET = 17 * scale

    self.HOTBAR_SLOT_Y_OFFSET = 26 * scale
    self.HOTBAR_SLOT_X_OFFSET = 7 * scale
    self.HOTBAR_SLOT_MARGIN = 4 * scale

    self.SCALE = scale

    for _, callback in pairs(self.OnScaleChanged) do
        callback(scale)
    end
end

EQUIPMENT_UI_SETTINGS.OnScaleChanged = {}
EQUIPMENT_UI_SETTINGS:applyScale(1)

-- MASQUER LES OBJETS ÉQUIPÉS
EQUIPMENT_UI_SETTINGS.applyHideEquippedItems = function(self, hide)
    self.HIDE_EQUIPPED_ITEMS = hide
end
EQUIPMENT_UI_SETTINGS:applyHideEquippedItems(false)

-- BASCULE DE LA TOUCHE MANETTE POUR L'INTERFACE
local DEFAULT_CONTROLLER_BIND = isModPresent("WookieeGamepadSupport") and 9 or 7

EQUIPMENT_UI_SETTINGS.applyToggleUiControllerBind = function(self, bindIndex)
    self.TOGGLE_UI_CONTROLLER_BIND = bindIndex - 1 
end

EQUIPMENT_UI_SETTINGS:applyToggleUiControllerBind(DEFAULT_CONTROLLER_BIND)

return EQUIPMENT_UI_SETTINGS
