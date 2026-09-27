
--- Function to handle light sensors
--- This function is called every minute to check if the light sensors are active
--- It will check for each player in the game and their current room
local function checkLightSensors(tick)
    if tick % 10 ~= 0 then return end
    for i=0, getNumActivePlayers()-1 or ArrayList:new() do
        local player = getSpecificPlayer(i)
        if player and not player:isDead() and player:getCurrentRoomDef() then
            local roomDefId = player:getCurrentRoomDef():getID()

            local squares = player:getCurrentRoomDef():getIsoRoom():getSquares() or ArrayList.new()
            for j = 0, squares:size() - 1 do
                local objects = squares:get(j):getObjects() or ArrayList.new()
                for k = 0, objects:size() - 1 do
                    local object = objects:get(k)
                    if instanceof(object, 'IsoLightSwitch') and object:getModData()['LightSensor'] == true then
                        local before = object:isActivated()
                        object:setActive(true)

                        local function handleShutdownLight_callback()
                            if not player:getCurrentRoomDef() or player:getCurrentRoomDef():getID() ~= roomDefId then
                                object:setActive(false)
                                Events.OnTick.Remove(handleShutdownLight_callback)
                            else
                                --object:setActive(true)
                            end
                        end
                        if not before then
                            Events.OnTick.Add(handleShutdownLight_callback)
                        end
                    end
                end
            end
        end
    end
end
Events.OnTick.Add(checkLightSensors)


--- Function to add/remove sensor
--- This function is called when the player interacts with the object
--- @param _ any Target object
--- @param player any player
--- @param object any object
function toggleSensor(_, player, object)
    if player:getPerkLevel(Perks.Electricity) < 2 then
        player:Say(getText('UI_LightSensor_knowledge'))
        player:Say(getText('UI_LightSensor_knowledgeElec'))
    elseif not object:getModData()['LightSensor'] and
            not (player:getInventory():getFirstTypeRecurse("Base.ElectronicsScrap") ~= nil) then
        player:Say(getText('UI_LightSensor_needScrap'))
    elseif luautils.walkAdj(player, object:getSquare()) then
        ISTimedActionQueue.add(LightSensorAddRemove:new(player, object, not object:getModData()['LightSensor']))
        --Events.OnTick.Remove(checkLightSensors)
    end
end

--- Generate context option menu
--- @param player any Player
--- @param menu any ISContextMenu
--- @param object any IsoObject
function doBuildMenuObject(player, menu, object)
    if not object then return end

    -- Generate option menu for add/remove Sensor
    local msgToggleSensor = object:getModData()['LightSensor'] == false
            and getText('ContextMenu_LightSensor_addSensor') or getText('ContextMenu_LightSensor_removeSensor')
    addCustomOption(menu:addOption(msgToggleSensor, nil, toggleSensor, getSpecificPlayer(player), object),
                    object:getModData()['LightSensor'] == false,
                    getText('ContextMenu_LightSensor_addSensorTooltip'), getText('ContextMenu_LightSensor_removeSensorTooltip'))
end


--- Function to initialize the object
--- This function is called when the object is not already loaded
--- It sets the initial values for the object's mod data
--- @param square any Square where the object is located
--- @param object any Object
function initObjectWithSensor(square, object)
    if not object:getModData()['Loaded'] then
        object:getModData()['Loaded'] = true
        object:getModData()['LightSensor'] = false
        object:getModData()['AlertSensor'] = false

        object:transmitModData()
        square:transmitModdata()
    end

    local modData = UGOShared.getModData()
    if modData and square then
        local chunkWX = UGOShared.getChunkX(square)
        local chunkWY = UGOShared.getChunkY(square)
        local coordsChunk = UGOShared.coordsChunkToKey(chunkWX, chunkWY)
        if not modData.LightSensor[coordsChunk] then
            modData.LightSensor[coordsChunk] = {}
        end
        local coordsSquare = UGOShared.coordsToKey(square)
        modData.LightSensor[coordsChunk][coordsSquare] = object
    end
    UGOShared.transmitUGOModData()
end

--- Context menu object for sensor object
--- Get first world object and check if it is a sensor object like
--- Init Object and call doBuildMenuObject
--- @param player any Player
--- @param menu any ISContextMenu
--- @param worldObjects any IsoObject[]
Events.OnPreFillWorldObjectContextMenu.Add(function(player, menu, worldObjects)
    if #worldObjects == 0 then return end

    local square = worldObjects[1]:getSquare()
    for i = 0, square:getObjects():size() - 1 do
        local object = square:getObjects():get(i)
        if instanceof(object, 'IsoLightSwitch') then
            initObjectWithSensor(square, object)
            doBuildMenuObject(player, menu, object)
        end
    end
end)