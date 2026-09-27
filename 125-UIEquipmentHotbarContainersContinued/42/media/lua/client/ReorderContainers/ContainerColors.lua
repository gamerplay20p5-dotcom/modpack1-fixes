-- Palette fixe pour taguer les conteneurs. Les noms de couleur viennent des clés
-- vanilla ContextMenu_* (deja traduites dans toutes les langues du jeu), pas besoin
-- de nos propres traductions pour ca.
local ContainerColors = {}

ContainerColors.PALETTE = {
    { key = "red",    textKey = "ContextMenu_Red",    r = 0.9,  g = 0.2,  b = 0.2  },
    { key = "orange", textKey = "ContextMenu_Orange", r = 0.95, g = 0.55, b = 0.15 },
    { key = "yellow", textKey = "ContextMenu_Yellow", r = 0.9,  g = 0.85, b = 0.2  },
    { key = "green",  textKey = "ContextMenu_Green",  r = 0.25, g = 0.75, b = 0.3  },
    { key = "cyan",   textKey = "ContextMenu_Cyan",   r = 0.2,  g = 0.75, b = 0.8  },
    { key = "blue",   textKey = "ContextMenu_Blue",   r = 0.25, g = 0.5,  b = 0.9  },
    { key = "purple", textKey = "ContextMenu_Purple", r = 0.55, g = 0.35, b = 0.85 },
    { key = "pink",   textKey = "ContextMenu_Pink",   r = 0.9,  g = 0.45, b = 0.7  },
    { key = "brown",  textKey = "ContextMenu_Brown",  r = 0.55, g = 0.35, b = 0.2  },
    { key = "grey",   textKey = "ContextMenu_Grey",   r = 0.55, g = 0.55, b = 0.55 },
}

---@param key string|nil
---@return table|nil
function ContainerColors.getByKey(key)
    if not key then return nil end
    for _, entry in ipairs(ContainerColors.PALETTE) do
        if entry.key == key then
            return entry
        end
    end
    return nil
end

return ContainerColors
