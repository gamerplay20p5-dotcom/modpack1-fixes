-- Lit ModOptions.ini directement, au chargement, avant tout fichier de patch.
--
-- Pourquoi ne pas passer par PZAPI.ModOptions : PZAPI.ModOptions:load() n'est appele que
-- depuis MainOptions:create() (MainOptions.lua:410), c'est-a-dire a la construction du menu
-- principal, donc APRES le chargement de nos fichiers. Au moment ou les gardes s'executent,
-- la valeur cochee par le joueur n'est pas encore en memoire. On lit donc l'ini nous-memes.
--
-- Regle de securite : toute anomalie vaut true. Fichier absent (premiere partie), illisible,
-- cle manquante, valeur inattendue, exception : on charge le mod complet, c'est-a-dire le
-- comportement d'avant cette version. Le pire scenario est le statu quo.

local MOD_ID = "EQUIPMENT_HOTBAR_CONTINUED"

local ModuleFlags = {
    hotbarReorder = true,
    containerReorder = true,
}

local KEY_TO_FIELD = {
    HOTBAR_REORDER_ENABLED = "hotbarReorder",
    CONTAINER_REORDER_ENABLED = "containerReorder",
}

-- Decoupage maison plutot que luautils.split : ce fichier se charge tres tot et ne doit
-- dependre de rien. Une ligne malformee ne matche simplement pas et laisse la valeur a true.
local function splitPipe(line)
    local parts = {}
    for field in string.gmatch(line, "[^|]+") do
        parts[#parts + 1] = field
    end
    return parts
end

-- Format des lignes visees : tickbox|EQUIPMENT_HOTBAR_CONTINUED|HOTBAR_REORDER_ENABLED|false
local function readFlags()
    local file = getFileReader("ModOptions.ini", true)
    if not file then return end

    while true do
        local line = file:readLine()
        if line == nil then
            file:close()
            return
        end

        local parts = splitPipe(line)
        if #parts >= 4 and parts[1] == "tickbox" and parts[2] == MOD_ID then
            local field = KEY_TO_FIELD[parts[3]]
            -- Seul "false" explicite desactive. Tout le reste laisse true.
            if field and parts[4] == "false" then
                ModuleFlags[field] = false
            end
        end
    end
end

pcall(readFlags)

return ModuleFlags
