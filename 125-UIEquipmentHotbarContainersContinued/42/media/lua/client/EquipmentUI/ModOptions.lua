---@diagnostic disable: need-check-nil, param-type-mismatch

local EQUIPMENT_UI_SETTINGS = require ("EquipmentUI/Settings")
local T = require("EquipmentUI/Text")
local ModuleFlags = require("EquipmentUI/ModuleFlags")

local EquipmentUIModOptions = PZAPI.ModOptions:create("EQUIPMENT_HOTBAR_CONTINUED", T("UI_optionscreen_binding_EquipmentUI"))

local key = "EQUIPMENT_UI_SCALE_INDEX"
local uiName = T("UI_equipment_options_scale")

EquipmentUIModOptions:addTitle(T("UI_equipment_options_modules_title"))
EquipmentUIModOptions:addDescription(T("UI_equipment_options_modules_desc"))

local hotbarReorderTickBox = EquipmentUIModOptions:addTickBox("HOTBAR_REORDER_ENABLED", T("UI_equipment_options_hotbar_reorder"), true, T("UI_equipment_options_hotbar_reorder_tooltip"))

local containerReorderTickBox = EquipmentUIModOptions:addTickBox("CONTAINER_REORDER_ENABLED", T("UI_equipment_options_container_reorder"), true, T("UI_equipment_options_container_reorder_tooltip"))

EquipmentUIModOptions:addSeparator()
EquipmentUIModOptions:addTitle(T("UI_equipment_options_settings_title"))

local hideEquippedItemsTickBox = EquipmentUIModOptions:addTickBox("HIDE_EQUIPPED_ITEMS", T("UI_equipment_options_hide_equipped_items"), false, T("UI_equipment_options_hide_equipped_items_tooltip"))

-- Lu au moment du clic, pas capturé maintenant : ReorderTheHotbar_ISHotbar.lua n'a peut-être
-- pas encore défini la globale EquipmentHotbarContinued_ReorderTheHotbar à ce stade du
-- chargement - et si le module hotbar est éteint, elle n'existera jamais.
EquipmentUIModOptions:addButton("RESET_HOTBAR_ORDER", T("UI_equipment_options_reset_hotbar_order"), T("UI_equipment_options_reset_hotbar_order_tooltip"), function()
    if EquipmentHotbarContinued_ReorderTheHotbar and EquipmentHotbarContinued_ReorderTheHotbar.resetOrder then
        EquipmentHotbarContinued_ReorderTheHotbar.resetOrder()
    end
end)

local uiScaleDropdown = EquipmentUIModOptions:addComboBox(key, uiName, T("UI_equipment_options_scale_tooltip"))
uiScaleDropdown:addItem("0.5x", false)
uiScaleDropdown:addItem("1x", true)
uiScaleDropdown:addItem("1.5x", false)
uiScaleDropdown:addItem("2x", false)
uiScaleDropdown:addItem("2.5x", false)
uiScaleDropdown:addItem("3x", false)
uiScaleDropdown:addItem("3.5x", false)
uiScaleDropdown:addItem("4x", false)

local wookiePresent = getActivatedMods():contains("WookieeGamepadSupport") or getActivatedMods():contains("\\WookieeGamepadSupport")
local toggleUiControllerBindDropdown = EquipmentUIModOptions:addComboBox("TOGGLE_UI_CONTROLLER_BIND_INDEX", T("UI_equipment_options_toggle_ui_controller_bind"), T("UI_equipment_options_toggle_ui_controller_bind_tooltip"))
toggleUiControllerBindDropdown:addItem(" A  /  X ", false)
toggleUiControllerBindDropdown:addItem(" B  /  O ", false)
toggleUiControllerBindDropdown:addItem(" X  /  [ ] ", false)
toggleUiControllerBindDropdown:addItem(" Y  /  /\\ ", false)
toggleUiControllerBindDropdown:addItem(" LB /  L1 ", false)
toggleUiControllerBindDropdown:addItem(" RB /  R1 ", false)
toggleUiControllerBindDropdown:addItem("  < /  - ", not wookiePresent)
toggleUiControllerBindDropdown:addItem("  > /  + ", false)
toggleUiControllerBindDropdown:addItem(" LS /  L3 ", wookiePresent)
toggleUiControllerBindDropdown:addItem(" RS /  R3 ", false)
-- Utilise les triangles gauche et droit comme iconographie pour les boutons start et select

-- Synchronise une porte de module avec ce qui a réellement été chargé au démarrage de la
-- session (voir ModuleFlags.lua).
--
-- Le timing vient du vanilla, MainOptions:apply() :
--   l.3757  self.resetLua = false           <- remis à zéro AVANT nos apply()
--   l.3762  options:apply()                 <- on tourne ici
--   l.3766  PZAPI.ModOptions:save()         <- l'ini est écrit APRÈS nous
--   l.3775  if self.restartRequired ...     <- SORT de la fonction
--   l.3784  if self.resetLua and not inGame -> DelayResetLua()
-- On peut donc poser resetLua ici et il sera honoré, avec un ini déjà à jour au moment du
-- rechargement. Comme restartRequired sort avant le branchement resetLua, les deux drapeaux
-- doivent rester exclusifs - d'où le if/elseif ci-dessous.
local function syncModuleFlag(self, optionId, loadedValue)
    local option = self:getOption(optionId)
    if option == nil then return end

    local desired = option:getValue() and true or false
    if desired == loadedValue then return end

    local mainOptions = MainOptions and MainOptions.instance
    if not mainOptions then return end

    local inGame = MainScreen and MainScreen.instance and MainScreen.instance.inGame

    if not inGame then
        -- Au menu principal : PZ recharge le Lua, les deux couches s'appliquent d'un coup.
        mainOptions.resetLua = true
    elseif desired then
        -- En jeu, rallumage d'un module non chargé : la couche exécution n'a rien à
        -- réactiver. On prévient avec le dialogue standard du jeu plutôt que de laisser une
        -- case cochée sans effet.
        mainOptions.restartRequired = true
    end
    -- En jeu, extinction : la couche exécution suffit, on n'affiche rien.
end

function EquipmentUIModOptions:apply()
    local scale = self:getOption("EQUIPMENT_UI_SCALE_INDEX"):getValue() * 0.5 -- x0.5 pour l'échelle réelle (marche parce que la liste va de 0.5x en 0.5x)
    EQUIPMENT_UI_SETTINGS:applyScale(scale)

    local hideEquippedItems = self:getOption("HIDE_EQUIPPED_ITEMS"):getValue()
    EQUIPMENT_UI_SETTINGS:applyHideEquippedItems(hideEquippedItems)

    local toggleUiControllerBindIndex = self:getOption("TOGGLE_UI_CONTROLLER_BIND_INDEX"):getValue()
    EQUIPMENT_UI_SETTINGS:applyToggleUiControllerBind(toggleUiControllerBindIndex)

    syncModuleFlag(self, "HOTBAR_REORDER_ENABLED", ModuleFlags.hotbarReorder)
    syncModuleFlag(self, "CONTAINER_REORDER_ENABLED", ModuleFlags.containerReorder)
end

-- Je ne me souviens plus pourquoi j'ai dû le faire de cette façon
local og_load = PZAPI.ModOptions.load
function PZAPI.ModOptions:load()
    og_load(self)
    pcall(function ()
        EquipmentUIModOptions:apply()
    end)
end

return EquipmentUIModOptions
