local ReorderContainersService = require("ReorderContainers/ReorderContainersService")
local ContainerColors = require("ReorderContainers/ContainerColors")

---@class SortableBackpackButton : ISButton
---@field public playerNum integer
---@field public inventory ItemContainer
---@field public invPage ISInventoryPage
---@field public pre_reorder_onMouseDown fun(self: SortableBackpackButton, x: number, y: number): void
---@field public pre_reorder_onMouseMove fun(self: SortableBackpackButton, dx: number, dy: number): void
---@field public pre_reorder_onMouseMoveOutside fun(self: SortableBackpackButton, dx: number, dy: number): void
---@field public pre_reorder_onMouseUp fun(self: SortableBackpackButton, x: number, y: number): void
---@field public pre_reorder_onMouseUpOutside fun(self: SortableBackpackButton, x: number, y: number): void
---@field public pre_reorder_render fun(self: SortableBackpackButton): void
local SortableBackpackButton = {}

---@param button ISButton
---@param inventoryPage ISInventoryPage
---@return SortableBackpackButton
function SortableBackpackButton:inject(button, inventoryPage)
    ---@cast button SortableBackpackButton

    button.invPage = inventoryPage
    button.playerNum = inventoryPage.player
    
    -- Les boutons sont réutilisés, faut pas écraser les fonctions d'origine
    if not button.pre_reorder_onMouseDown then
        button.pre_reorder_onMouseDown = button.onMouseDown
    end
    button.onMouseDown = SortableBackpackButton.onMouseDown
    
    if not button.pre_reorder_onMouseMove then
        button.pre_reorder_onMouseMove = button.onMouseMove
    end
    button.onMouseMove = SortableBackpackButton.onMouseMove

    if not button.pre_reorder_onMouseMoveOutside then
        button.pre_reorder_onMouseMoveOutside = button.onMouseMoveOutside
    end
    button.onMouseMoveOutside = SortableBackpackButton.onMouseMoveOutside

    if not button.pre_reorder_onMouseUp then
        button.pre_reorder_onMouseUp = button.onMouseUp
    end
    button.onMouseUp = SortableBackpackButton.onMouseUp

    if not button.pre_reorder_onMouseUpOutside then
        button.pre_reorder_onMouseUpOutside = button.onMouseUpOutside
    end
    button.onMouseUpOutside = SortableBackpackButton.onMouseUpOutside

    if not button.pre_reorder_render then
        button.pre_reorder_render = button.render
    end
    button.render = SortableBackpackButton.render

    return button
end

-- Fond coloré derrière l'icône du bouton si ce conteneur a une couleur assignée
-- (clic droit > Assigner une couleur). Dessiné avant le rendu d'origine, qui a un
-- fond transparent par défaut, donc la couleur passe dessous sans rien cacher.
function SortableBackpackButton:render()
    local color = ContainerColors.getByKey(ReorderContainersService.getContainerColorKey(getSpecificPlayer(self.playerNum), self.inventory))
    if color then
        self:drawRect(0, 0, self:getWidth(), self:getHeight(), 0.55, color.r, color.g, color.b)
    end
    self.pre_reorder_render(self)
end

function SortableBackpackButton:onMouseDown(x, y)
    self.pre_reorder_onMouseDown(self, x, y)
    self.reorderStartMouseY = getMouseY()
    self.reorderStartY = self:getY()

    self.canDragToReorder = ReorderContainersService.isContainerReorderEnabled() and not ReorderContainersService.isLocked(self.invPage) and ReorderContainersService.isSortingEnabled(self.invPage)
end

function SortableBackpackButton:onMouseMove(dx, dy, skipOgMouseMove)
    if not skipOgMouseMove then -- skipOgMouseMove est vrai quand on vient de onMouseMoveOutside
        self.pre_reorder_onMouseMove(self, dx, dy)
    end

    if self.pressed and self.canDragToReorder then
        if math.abs(self.reorderStartMouseY - getMouseY()) > self.invPage.buttonSize/2 then
            self.draggingToReorder = true
        end

        local parent = self.parent
        if self.draggingToReorder and parent then
            local x = getMouseX()
            local y = getMouseY()
            local parentY = parent:getAbsoluteY()
            local newY = y - parentY - self:getHeight() / 2
            
            newY = math.max(-4, newY)

            self:setY(newY)
            self:bringToTop()
    
            self.draggingToReorder = true
        end
    end
end

function SortableBackpackButton:onMouseMoveOutside(dx, dy)
    self.pre_reorder_onMouseMoveOutside(self, dx, dy)
    if self.pressed and self.canDragToReorder then
        SortableBackpackButton.onMouseMove(self, dx, dy, true)
    end
end

function SortableBackpackButton:onMouseUp(x, y)
    local page = self.invPage
    if page and self.draggingToReorder then
        self.pressed = false;
        self.draggingToReorder = false
        page:reorderContainerButtons(self)
        page:refreshBackpacks()
    else
        self.pre_reorder_onMouseUp(self, x, y)
    end
end

function SortableBackpackButton:onMouseUpOutside(x, y)
    local page = self.invPage
    if page and self.draggingToReorder then
        self.pressed = false;
        self.draggingToReorder = false
        page:reorderContainerButtons(self)
        page:refreshBackpacks()
    else
        self.pre_reorder_onMouseUpOutside(self, x, y)
    end
end

return SortableBackpackButton