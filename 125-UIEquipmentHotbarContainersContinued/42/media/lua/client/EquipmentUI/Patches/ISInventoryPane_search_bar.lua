-- Bouton de recherche dans la barre de titre de chaque fenêtre d'inventaire (principal,
-- butin, coffres, sacs), qui se déplie en filtre texte en direct.
local SETTINGS = require("EquipmentUI/Settings")
local T = require("EquipmentUI/Text")

local SEARCH_ICON_TEX = getTexture("media/ui/UiGhoosty/Search-icon.png")

-- Normalise pour comparer : "Nail_Gun", "nail gun" et "NAIL, GUN!" donnent tous "nail gun".
local function normalizeSearchText(text)
    text = string.lower(text)
    text = string.gsub(text, "[%p_]", " ")
    text = string.gsub(text, "%s+", " ")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

local function splitWords(text)
    local words = {}
    for word in string.gmatch(text, "%S+") do
        words[#words + 1] = word
    end
    return words
end

-- Chaque mot tapé doit préfixer un mot du texte : "hu ja" trouve "Hunting Jacket",
-- mais "gun" seul ne remonte pas "Shotgun".
local function wordsMatch(queryWords, candidateWords)
    for _, queryWord in ipairs(queryWords) do
        local found = false
        for _, candidateWord in ipairs(candidateWords) do
            if string.sub(candidateWord, 1, #queryWord) == queryWord then
                found = true
                break
            end
        end
        if not found then
            return false
        end
    end
    return true
end

---@param item InventoryItem
---@param queryWords string[]
local function itemMatchesSearch(item, queryWords)
    if #queryWords == 0 then
        return true
    end

    local nameWords = splitWords(normalizeSearchText(item:getDisplayName()))
    if wordsMatch(queryWords, nameWords) then
        return true
    end

    local category = item:getDisplayCategory() or item:getCategory()
    if category then
        -- getText() renvoie la clé brute si la catégorie est inconnue - même souci que T() ailleurs.
        local categoryKey = "IGUI_ItemCat_" .. category
        local categoryText = getText(categoryKey)
        if categoryText == categoryKey then
            categoryText = category
        end
        local categoryWords = splitWords(normalizeSearchText(categoryText))
        if wordsMatch(queryWords, categoryWords) then
            return true
        end
    end

    return false
end

local function onSearchTextChange(box)
    if not box or not box.target then return end
    local text = box:getInternalText()
    box.target.searchText = text
    -- Découpé une fois par frappe, pas une fois par objet affiché - la seule partie du
    -- filtre qu'on peut mettre en cache facilement.
    box.target.searchQueryWords = splitWords(normalizeSearchText(text))
end

-- Entrée arrête juste la saisie, la barre reste ouverte et le filtre actif -
-- reclique dedans pour continuer à taper.
local function onSearchCommandEntered(box)
    if not box then return end
    box:unfocus()
end

-- Proportionnel à la largeur de la fenêtre, borné pour rester utilisable dans les deux extrêmes.
---@return number
function ISInventoryPage:searchBoxWidth()
    return math.max(80, math.min(260, self:getWidth() * 0.4))
end

function ISInventoryPage:openSearchBar()
    local boxHeight = self.searchIconButton:getHeight()
    local boxWidth = self:searchBoxWidth()
    local boxX = self:getWidth() / 2 - boxWidth / 2

    if not self.searchEntryBox then
        local box = ISTextEntryBox:new("", boxX, self.searchIconButton:getY(), boxWidth, boxHeight)
        box:initialise()
        box:instantiate()
        box:setClearButton(true)
        box:setPlaceholderText(T("UI_equipment_search_placeholder"))
        box.onTextChange = onSearchTextChange
        box.onCommandEntered = onSearchCommandEntered
        box.target = self
        self:addChild(box)
        self.searchEntryBox = box
    else
        -- Recentrée/redimensionnée à chaque ouverture, au cas où la fenêtre ait changé de taille.
        self.searchEntryBox:setX(boxX)
        self.searchEntryBox:setWidth(boxWidth)
    end

    self.searchOpen = true
    self.searchEntryBox:setVisible(true)
    self.searchEntryBox:bringToTop()
    self.searchEntryBox:focus()
    self.searchIconButton:setVisible(false)
end

function ISInventoryPage:closeSearchBar()
    self.searchOpen = false
    self.searchText = ""
    if self.searchEntryBox then
        if self.searchEntryBox:isFocused() then
            self.searchEntryBox:unfocus()
        end
        self.searchEntryBox:setVisible(false)
    end
    if self.searchIconButton then
        self.searchIconButton:setVisible(true)
    end
end

local og_createChildren = ISInventoryPage.createChildren
function ISInventoryPage:createChildren()
    og_createChildren(self)

    self.searchText = ""
    self.searchOpen = false

    local buttonHeight = self:titleBarHeight() - 2
    local label = T("UI_equipment_search_button")
    local iconSize = math.max(10, buttonHeight - 4)
    -- iconTexture est le champ natif d'ISButton pour une icône à côté du texte (ISButton.lua:238-245),
    -- ça décale le texte tout seul.
    local buttonWidth = iconSize + 5 + getTextManager():MeasureStringX(UIFont.Small, label) + 12
    -- Centré dans la barre de titre pour rester dégagé du titre (longueur variable) à gauche
    -- et du compteur/pin à droite.
    local x = self:getWidth() / 2 - buttonWidth / 2

    local searchButton = ISButton:new(x, 1, buttonWidth, buttonHeight, label, self)
    searchButton.borderColor.a = 0.0
    searchButton.backgroundColor.a = 0
    searchButton.backgroundColorMouseOver.a = 0.3
    searchButton.iconTexture = SEARCH_ICON_TEX
    searchButton.joypadTextureWH = iconSize
    searchButton:setTooltip(T("UI_equipment_search_button_tooltip"))
    searchButton:initialise()
    searchButton:instantiate()
    self:addChild(searchButton)
    self.searchIconButton = searchButton

    searchButton:setOnClick(function()
        if self.searchOpen then
            self:closeSearchBar()
        else
            self:openSearchBar()
        end
    end)
end

local og_render = ISInventoryPage.render
function ISInventoryPage:render()
    og_render(self)

    if not self.searchIconButton then return end

    -- Le vanilla replie chaque page à la création (ISInventoryPage.lua:194) : sans ce check,
    -- l'icône apparaîtrait sur des fenêtres jamais ouvertes par le joueur.
    local reallyOpen = self:isVisible() and (self.pin or not self.isCollapsed)

    if not reallyOpen then
        self.searchIconButton:setVisible(false)
        if self.searchOpen then
            self:closeSearchBar()
        end
        return
    end

    -- Recalculé à chaque frame : la fenêtre peut être redimensionnée après coup, un x figé
    -- finirait par dépasser du cadre.
    self.searchIconButton:setX(self:getWidth() / 2 - self.searchIconButton:getWidth() / 2)

    if not self.searchOpen then
        self.searchIconButton:setVisible(true)
    end
end

-- Enveloppé ici au chargement du fichier, pas via OnGameStart comme hide_equipped_items.lua,
-- pour s'installer AVANT ce wrapper-là et devenir la couche interne - sinon les deux filtres
-- s'écrasent au lieu de se combiner.
local og_renderdetails = ISInventoryPane.renderdetails
function ISInventoryPane:renderdetails(doDragged)
    local inventoryPage = self.parent
    local searchText = inventoryPage and inventoryPage.searchText

    if SETTINGS.InventoryTetris or not searchText or searchText == "" then
        og_renderdetails(self, doDragged)
        return
    end

    local queryWords = inventoryPage.searchQueryWords or splitWords(normalizeSearchText(searchText))
    local filtered = {}
    for k, v in ipairs(self.itemslist) do
        local item = v and v.items and v.items[1]
        if item and itemMatchesSearch(item, queryWords) then
            filtered[#filtered + 1] = v
        end
    end

    local cached = self.itemslist
    self.itemslist = filtered
    og_renderdetails(self, doDragged)
    self.itemslist = cached
end
