---@diagnostic disable: redundant-parameter

---@class (partial) ISUIElement
---@field public controllerNode ControllerNode

--- ControllerNode s'injecte dans un élément d'UI pour gérer la navigation manette et le focus,
--- sans avoir à écrire toute la logique de navigation à la main.
---@class ControllerNode
---@field uiElement ISUIElement
---@field processRealEvents boolean
---@field childrenNodeProvider function
---@field childrenNodeProviderArgs table
---@field selectedChild ControllerNode
---@field handleJoypadDown function
---@field handleJoypadDir function
---@field handleLoseJoypadFocus function
---@field handleGainJoypadFocus function
---@field isFocused boolean
local ControllerNode = {}
ControllerNode.FOCUS_COLOR = { r = 0.2, g = 1.0, b = 1.0, a = 0.4 }
ControllerNode.menuFocusSupression = {}

---@param uiElement ISUIElement
---@return ControllerNode
function ControllerNode:injectControllerNode(uiElement, processRealEvents)
    local o = {}
    setmetatable(o, { __index = ControllerNode })
    self.__index = self

    o.uiElement = uiElement
    o.processRealEvents = processRealEvents
    uiElement.controllerNode = o
    o:hookJoypadEvents()

    ---@cast o ControllerNode
    return o
end

---@param playerObj IsoPlayer
function ControllerNode:isController(playerObj)
    return playerObj:getJoypadBind() ~= -1
end

---@return ControllerNode
function ControllerNode:doSimpleFocusHighlight()
    self.og_render = self.uiElement.render
    self.uiElement.render = function(uiElement)
        self.og_render(uiElement)
        if self.isFocused then
            uiElement:drawRectBorder(0, 0, uiElement:getWidth(), uiElement:getHeight(), 0.4, self.FOCUS_COLOR.r, self.FOCUS_COLOR.g, self.FOCUS_COLOR.b)
            uiElement:drawRectBorder(1, 1, uiElement:getWidth() - 2, uiElement:getHeight() - 2, 0.4, self.FOCUS_COLOR.r, self.FOCUS_COLOR.g, self.FOCUS_COLOR.b)
        end
    end
    return self
end

--- Fournit les nœuds enfants valides de ce nœud (utile si la liste change dynamiquement).
---@return ControllerNode
function ControllerNode:setChildrenNodeProvider(func, ...)
    self.childrenNodeProvider = func
    self.childrenNodeProviderArgs = {...}
    return self
end

--- Définit un gestionnaire personnalisé pour l'événement d'appui sur bouton manette.
---@return ControllerNode
function ControllerNode:setJoypadDownHandler(func)
    self.handleJoypadDown = func
    return self
end

--- Gestionnaire personnalisé pour la direction manette (un seul gestionnaire pour les 4 directions,
--- contrairement au jeu de base qui les sépare).
---@return ControllerNode
function ControllerNode:setJoypadDirHandler(func)
    self.handleJoypadDir = func
    return self
end

---@return ControllerNode
function ControllerNode:setLoseJoypadFocusHandler(func)
    self.handleLoseJoypadFocus = func
    return self
end

---@return ControllerNode
function ControllerNode:setGainJoypadFocusHandler(func)
    self.handleGainJoypadFocus = func
    return self
end

function ControllerNode:hookJoypadEvents()
    self.og_onJoypadDown = self.uiElement.onJoypadDown
    self.uiElement.onJoypadDown = function(uiElement, button, joypadData)
        self:onJoypadDown(button, joypadData)
    end

    self.og_onJoypadDirLeft = self.uiElement.onJoypadDirLeft
    self.uiElement.onJoypadDirLeft = function(uiElement, joypadData)
        self:onJoypadDir(-1, 0, joypadData)
    end

    self.og_onJoypadDirRight = self.uiElement.onJoypadDirRight
    self.uiElement.onJoypadDirRight = function(uiElement, joypadData)
        self:onJoypadDir(1, 0, joypadData)
    end

    self.og_onJoypadDirUp = self.uiElement.onJoypadDirUp
    self.uiElement.onJoypadDirUp = function(uiElement, joypadData)
        self:onJoypadDir(0, -1, joypadData)
    end

    self.og_onJoypadDirDown = self.uiElement.onJoypadDirDown
    self.uiElement.onJoypadDirDown = function(uiElement, joypadData)
        self:onJoypadDir(0, 1, joypadData)
    end

    self.og_onLoseJoypadFocus = self.uiElement.onLoseJoypadFocus
    self.uiElement.onLoseJoypadFocus = function(uiElement, joypadData)
        self:onLoseJoypadFocus(joypadData)
    end

    self.og_onGainJoypadFocus = self.uiElement.onGainJoypadFocus
    self.uiElement.onGainJoypadFocus = function(uiElement, joypadData)
        self:onGainJoypadFocus(joypadData)
    end
end

function ControllerNode:unhookJoypadEvents()
    self.uiElement.onJoypadDown = self.og_onJoypadDown
    self.uiElement.onJoypadDirLeft = self.og_onJoypadDirLeft
    self.uiElement.onJoypadDirRight = self.og_onJoypadDirRight
    self.uiElement.onJoypadDirUp = self.og_onJoypadDirUp
    self.uiElement.onJoypadDirDown = self.og_onJoypadDirDown
    self.uiElement.onLoseJoypadFocus = self.og_onLoseJoypadFocus
    self.uiElement.onGainJoypadFocus = self.og_onGainJoypadFocus
end

-- Tous les événements manette sont gérés par le nœud contrôleur et suivent le même schéma que celui-ci
function ControllerNode:onJoypadDown(button, joypadData)
    -- Si on a un nœud enfant sélectionné, on essaie d'abord de lui transmettre l'événement
    if self.selectedChild and self.selectedChild:onJoypadDown(button, joypadData) then
        return true
    end

    -- Si on a un gestionnaire personnalisé pour cet événement, on l'appelle maintenant
    if self.handleJoypadDown and self.handleJoypadDown(self.uiElement, button, joypadData) then
        return true
    end

    -- Enfin, on délègue à l'élément d'UI d'origine s'il a le focus manette
    if self.processRealEvents then
        self.og_onJoypadDown(self.uiElement, button, joypadData)
    end
    return false
end

function ControllerNode:onJoypadDir(dx, dy, joypadData)
    if self.selectedChild and self.selectedChild:onJoypadDir(dx, dy, joypadData) then
        return true
    end

    if self.handleJoypadDir and self.handleJoypadDir(self.uiElement, dx, dy, joypadData) then
        return true
    end

    if self.childrenNodeProvider then
        local childrenNodes = self.childrenNodeProvider(unpack(self.childrenNodeProviderArgs))
        if self:tryNavigateChildren(childrenNodes, dx, dy) then
            return true
        end
    end

    if self.processRealEvents then
        if dx == -1 then
            self.og_onJoypadDirLeft(self.uiElement, joypadData)
        elseif dx == 1 then
            self.og_onJoypadDirRight(self.uiElement, joypadData)
        elseif dy == -1 then
            self.og_onJoypadDirUp(self.uiElement, joypadData)
        elseif dy == 1 then
            self.og_onJoypadDirDown(self.uiElement, joypadData)
        end
    end
    return false
end

--- Navigue vers l'enfant le plus proche dans la direction donnée, en remontant la hiérarchie
--- des nœuds jusqu'à ce que l'un d'eux traite l'entrée. C'est le cœur du nœud contrôleur.
function ControllerNode:tryNavigateChildren(children, dx, dy)
    if not children or #children == 0 then
        return false
    end

    local selectedChild = self.selectedChild
    if not selectedChild then
        self.selectedChild = children[1]
        self.selectedChild:onGainJoypadFocus()
        return true
    end

    local x = selectedChild.uiElement:getAbsoluteX()
    local y = selectedChild.uiElement:getAbsoluteY()

    -- Utilise la direction de l'entrée pour déterminer le prochain enfant à sélectionner
    local nearestChild = nil
    local nearestDistance = math.huge
    for _, child in ipairs(children) do
        if child ~= selectedChild then
            local cx = child.uiElement:getAbsoluteX()
            local cy = child.uiElement:getAbsoluteY()

            local isLeft = dx == -1 and cx < x
            local isRight = dx == 1 and cx > x
            local isUp = dy == -1 and cy < y
            local isDown = dy == 1 and cy > y
            if isLeft or isRight or isUp or isDown then
                -- Une heuristique moyenne, mais qui devrait fonctionner pour la plupart des mises en page d'UI actuelles
                ---@type number
                local distance = math.abs(cx - x) + math.abs(cy - y)

                local angle = math.atan2(cy - y, cx - x)
                local isAngleGood = false
                if isRight then
                    isAngleGood = angle > -math.pi/4 and angle < math.pi/4
                elseif isLeft then
                    isAngleGood = angle > 3*math.pi/4 or angle < -3*math.pi/4
                elseif isUp then
                    isAngleGood = angle > -3*math.pi/4 and angle < -math.pi/4
                elseif isDown then
                    isAngleGood = angle > math.pi/4 and angle < 3*math.pi/4
                end

                if isAngleGood and distance < nearestDistance then
                    nearestChild = child
                    nearestDistance = distance
                end
            end
        end
    end

    if nearestChild then
        self:setSelectedChild(nearestChild)
        return true
    end
end

function ControllerNode:setSelectedChild(childNode)
    if not self.isFocused then
        self.selectedChild = childNode
        return
    end

    if self.selectedChild then
        self.selectedChild:onLoseJoypadFocus()
    end
    self.selectedChild = childNode
    if self.selectedChild then
        self.selectedChild:onGainJoypadFocus()
    end
end

function ControllerNode:validateSelectedChild()
    if not self.selectedChild then
        return true
    end

    local children = self.childrenNodeProvider and self.childrenNodeProvider(unpack(self.childrenNodeProviderArgs)) or {}
    for _, child in ipairs(children) do
        if child == self.selectedChild then
            return true
        end
    end
    return false
end

function ControllerNode:refreshSelectedChild()
    if self:validateSelectedChild() then
        return
    end

    local children = self.childrenNodeProvider and self.childrenNodeProvider(unpack(self.childrenNodeProviderArgs)) or {}
    self.selectedChild = children[1]
    if self.selectedChild then
        self.selectedChild:onGainJoypadFocus()
    end
end

function ControllerNode:getLeafChild()
    local current = self
    while current.selectedChild do
        current = current.selectedChild
    end
    return current
end

-- Pas de retour anticipé ici, tout le monde a besoin de savoir quand le focus est perdu/gagné
function ControllerNode:onLoseJoypadFocus(joypadData)
    -- On ne traite pas les événements de perte de focus du controllerNode lors de l'ouverture d'un menu contextuel
    if not joypadData or not ControllerNode.menuFocusSupression[joypadData.player] then
        self.isFocused = false
        if self.selectedChild then
            self.selectedChild:onLoseJoypadFocus(joypadData)
        end
        if self.handleLoseJoypadFocus then
            self.handleLoseJoypadFocus(self.uiElement, joypadData)
        end
    end

    if joypadData then
        ControllerNode.menuFocusSupression[joypadData.player] = nil
    end

    if self.processRealEvents then
        self.og_onLoseJoypadFocus(self.uiElement, joypadData)
    end
end

function ControllerNode:onGainJoypadFocus(joypadData)
    self.isFocused = true

    if self.selectedChild and not self:validateSelectedChild() then
        self.selectedChild = nil -- Pas de onLoseJoypadFocus car il ne devrait de toute façon pas avoir le focus à ce stade
    end

    if not self.selectedChild then
        local children = self.childrenNodeProvider and self.childrenNodeProvider(unpack(self.childrenNodeProviderArgs)) or {}
        self.selectedChild = children[1]
    end

    if self.selectedChild then
        self.selectedChild:onGainJoypadFocus(joypadData)
    else
        self.ensureVisible(self.uiElement)
    end
    if self.handleGainJoypadFocus then
        self.handleGainJoypadFocus(self.uiElement, joypadData)
    end
    if self.processRealEvents then
        self.og_onGainJoypadFocus(self.uiElement, joypadData)
    end
end

function ControllerNode:focusContextMenu(playerNum, menu)
    -- Empêche les nœuds contrôleurs de perdre visuellement le focus lors de l'ouverture du menu
    ControllerNode.menuFocusSupression[playerNum] = true

    local origin = getJoypadFocus(playerNum)
    menu.origin = origin
    menu.mouseOver = 1
    setJoypadFocus(playerNum, menu)
end

-- A CORRIGER
function ControllerNode.ensureVisible(uiElement)
    local current = uiElement.parent
    while current do
        if current.hscroll then
            current:ensureChildIsVisible(uiElement, 50)
            return
        end
        current = current.parent
    end
end

return ControllerNode