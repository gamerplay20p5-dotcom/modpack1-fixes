
--- Utility function to add custom option to the context menu
--- @param option any ISContextMenuOption
--- @param condition any boolean
--- @param successText any string
--- @param errorText any string
function addCustomOption(option, condition, successText, errorText)
    local toolTip = ISToolTip:new();
    toolTip:initialise();
    toolTip:setVisible(false);
    toolTip.description = condition and successText or errorText;
    option.toolTip = toolTip
    return option
end

--- Utility function to add custom option to the context menu
--- Add notAvailable option to the context menu
--- @param option any ISContextMenuOption
--- @param condition any boolean
--- @param successText any string
--- @param errorText any string
function addCustomOptionDisabledOpt(option, condition, successText, errorText)
    addCustomOption(option, condition, successText, errorText)
    option.notAvailable = not condition
end