BuildRecipeCode = BuildRecipeCode or {}

BuildRecipeCode.lightSwitch = {}
BuildRecipeCode.lightSwitch.OnCreate = function(data)
    local thumpable = data.thumpable
    local sprite = getSprite(thumpable:getSprite():getName())
    local cell = getCell()
    local square = thumpable:getSquare()
    local sx, sy, sz = square:getX(), square:getY(), square:getZ()
    local object = IsoLightSwitch.new(cell, square, sprite, square:getRoomID())

    object:setActivated(false)
    object:createContainersFromSpriteProperties()
    object:addLightSourceFromSprite()
    square:AddSpecialObject(object)

    local room = square:getRoom()
    if thumpable:getSquare() ~= nil then
        thumpable:removeFromWorld()
        thumpable:removeFromSquare()
        thumpable:setSquare(nil)
    end
    return { replaceObject = true, object = object }
end