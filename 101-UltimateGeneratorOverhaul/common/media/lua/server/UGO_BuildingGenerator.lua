require "UGO_Electricity"
require "TimedActions/UGO_GeneratorActivation"

--- Function to initialize the generator
--- This function is called when the generator is not already loaded
--- It sets the initial values for the generator's mod data
--- @param square any Square where the generator is located
--- @param generator any Generator object
function initBuildingGenerator(square, generator, crafted)
    generator:getModData().emitter = nil
    generator:getModData().sound_GeneratorLoop = nil
    if not generator:getModData()['Loaded'] then
        generator:getModData()['Loaded'] = true
        generator:getModData()['PoweredOn'] = false
        generator:getModData()['LastHour'] = GameTime:getInstance():getWorldAgeHours()
        generator:getModData()['GeneratorMagazine'] = ZombRand(0, 5) == 0
        generator:getModData()['AutoPowerOn'] = false
        generator:getModData()['Consumption'] = 0.0
        generator:getModData()['proximityAlert'] = false
        generator:getModData()['marker'] = false

        if crafted then
            generator:getModData()['FuelAmount'] = 0
            generator:getModData()['Condition'] = 100
        else
            generator:getModData()['FuelAmount'] = ZombRand(0, 100)
            generator:getModData()['Condition'] = ZombRand(0, 100)
        end

        generator:transmitModData()
        square:transmitModdata()
    end

    local modData = UGOShared.getModData()
    if modData and square then
        local chunkWX = UGOShared.getChunkX(square)
        local chunkWY = UGOShared.getChunkY(square)
        local coordsChunk = UGOShared.coordsChunkToKey(chunkWX, chunkWY)
        if not modData.Generator[coordsChunk] then
            modData.Generator[coordsChunk] = {}
        end
        local coordsSquare = UGOShared.coordsToKey(square)
        modData.Generator[coordsChunk][coordsSquare] = true
    end
    UGOShared.transmitUGOModData()

    -- --- CODE DE DÉBOGAGE POUR AFFICHER LE CONTENU ---
    --print("--- [UGO] Début de l'inspection de modData.Generator ---")
    --local chunkCount = 0
    --local totalGenerators = 0

    --for chunkKey, squareTable in pairs(modData.Generator) do
    --    chunkCount = chunkCount + 1
    --    print("-> Chunk détecté : [" .. tostring(chunkKey) .. "]")

    --    -- On inspecte les générateurs dans ce chunk
    --    for squareKey, genObject in pairs(squareTable) do
    --        totalGenerators = totalGenerators + 1
    --        print("   * Générateur trouvé aux coordonnées : " .. tostring(squareKey))
    --    end
    --end

    --print("--- [UGO] Fin de l'inspection : " .. chunkCount .. " chunk(s) et " .. totalGenerators .. " générateur(s) au total. ---")
end

--- Function to handle the generator when it is loaded
--- Initializes the generator and sets its state
--- Handles EveryMinute events for the generator : Starts the generator if it is powered on at game start
--- Handles EveryTenMinutes events for the generator : Checks if there are new items in the generator's range
--- Handles EveryHours events for the generator : Consume fuel and check if the generator is still powered on
--- @param generator any Generator object
function onLoadGenerator(generator)
    local square = generator:getSquare()
    initBuildingGenerator(square, generator, false)

    local gameShutdownElec = SandboxVars.ElecShutModifier <= GameTime:getInstance():getNightsSurvived()
    local isOKToStart = generator:getModData()['Condition'] > 0 and generator:getModData()['FuelAmount'] > 0

    -- Power ON automatically if the generator is set AutoPowerOn
    if not square:haveElectricity() and gameShutdownElec and generator:getModData()['AutoPowerOn'] == true and isOKToStart then
        generator:getModData()['PoweredOn'] = true
    end

    UGOElectricity.setGenerator(generator, generator:getModData().PoweredOn == true and isOKToStart)

    -- Function to check if there is new items in the generator's range every 10 minutes
    local function EveryTenMinutes()
        local sq = generator:getSquare()
        if not sq or generator:getObjectIndex() < 0 or
           getCell():getGridSquare(sq:getX(), sq:getY(), sq:getZ()) ~= sq then
            Events.EveryTenMinutes.Remove(EveryTenMinutes)
            return
        end
        UGOElectricity.recalculateConsumption(generator)
        generator:transmitModData()
    end
    Events.EveryTenMinutes.Add(EveryTenMinutes)


    -- Function to handle the generator's power consumption / condition every hour
    local function EveryHours_callback()
        local sq = generator:getSquare()
        if not sq or generator:getObjectIndex() < 0 or
           getCell():getGridSquare(sq:getX(), sq:getY(), sq:getZ()) ~= sq then
            Events.EveryHours.Remove(EveryHours_callback)
            return
        end
        if generator:getModData()['PoweredOn'] == true then
            local gameHourTime = math.floor(getGameTime():getWorldAgeHours())
            local lastHour = math.floor(generator:getModData()['LastHour'] or gameHourTime)
            local elapseHours = gameHourTime - lastHour

            for _ = 1, elapseHours do
                print("Hour passed")
                generator:getModData()['FuelAmount'] = math.max(generator:getModData()['FuelAmount'] - generator:getModData()['Consumption'], 0)

                -- Reduce the generator's condition by a random amount.
                -- Every hour, a random number between 0 and the generator's current condition is generated.
                -- If the random number is less than 10, the generator's condition is reduced by 0 to 0.9.
                local randCondition = ZombRand(0, generator:getModData()['Condition'])
                generator:getModData()['Condition'] = math.max(generator:getModData()['Condition'] - (randCondition < 10 and (randCondition / 10) or 0), 0)

                if generator:getModData()['FuelAmount'] <= 0 or generator:getModData()['Condition'] <= 0 then
                    GeneratorActivation:handleGenerator(generator, false)
                end
            end
            generator:getModData()['LastHour'] = GameTime:getInstance():getWorldAgeHours()
        end
        square:transmitModdata()
        generator:transmitModData()
    end
    Events.EveryHours.Add(EveryHours_callback)

    -- Initialize the generator's proximity alert
    if generator:getModData()['proximityAlert'] == true then
        -- Permit to start the generator one minute after initialization (wait)
        local function handleSensorInit_callback()
            local sensorSquare
            local adjacentSquares = {
                square,                                     -- Center
                square:getAdjacentSquare(IsoDirections.N),  -- North
                square:getAdjacentSquare(IsoDirections.S),  -- South
                square:getAdjacentSquare(IsoDirections.W),  -- West
                square:getAdjacentSquare(IsoDirections.E),  -- East
                square:getAdjacentSquare(IsoDirections.NW), -- North West
                square:getAdjacentSquare(IsoDirections.NE), -- North East
                square:getAdjacentSquare(IsoDirections.SW), -- South West
                square:getAdjacentSquare(IsoDirections.SE)  -- South East
            }

            for i = 1, #adjacentSquares do
                if adjacentSquares[i]:getBuilding() then
                    sensorSquare = adjacentSquares[i]
                    break
                end
            end
            ProximitySensorActivation:handleProximitySensor(sensorSquare, generator, true)
            Events.EveryOneMinute.Remove(handleSensorInit_callback)
        end
        Events.EveryOneMinute.Add(handleSensorInit_callback)
    end
end
MapObjects.OnLoadWithSprite({ "security_01_0", "security_01_1", "security_01_2", "security_01_3" }, onLoadGenerator, 5)

--- Function to toggle the generator's power
--- This function is called when the player interacts with the generator
--- Start the generator if there is fuel and condition
--- @param _ any Target object
--- @param player any player
--- @param generator any generator
function togglePower(_, player, generator)
    if luautils.walkAdj(player, generator:getSquare()) then
        ISTimedActionQueue.add(GeneratorActivation:new(player, generator, not generator:getModData()['PoweredOn']))
    end

end

--- Function to toggle the generator's auto power
--- Start the generator if on and if it is not already started
--- If there is no fuel or condition, it will not start
--- @param _ any Target object
--- @param player any player
--- @param generator any generator
function toggleAutoPower(_, player, generator)
    generator:getModData()['AutoPowerOn'] = not generator:getModData()['AutoPowerOn']
    if generator:getModData()['AutoPowerOn'] == true then
        if generator:getModData()['PoweredOn'] == false then
            if luautils.walkAdj(player, generator:getSquare()) then
                ISTimedActionQueue.add(GeneratorActivation:new(player, generator, true))
            end
        end
    end
    generator:getSquare():transmitModdata()
    generator:transmitModData()
end

local function predicatePetrol(item)
    return item:getFluidContainer() and item:getFluidContainer():contains(Fluid.Petrol)
end

--- Function to fill the generator
--- This function checks if the player has the required items to fill the generator
--- @param _ any Target object
--- @param player any player
--- @param generator any generator
function addFuelGenerator(_, player, generator)
    if luautils.walkAdj(player, generator:getSquare()) then
        local allPetrol = player:getInventory():getAllEvalRecurse(predicatePetrol)

        if allPetrol:size() == 0 then
            player:Say(getText('UI_BuildingGenerator_needFuelCan'))
        end

        for i = 0, allPetrol:size() - 1 do
            local item = allPetrol:get(i)
            if item:getFluidContainer():getAmount() > 0 then
                ISTimedActionQueue.add(GeneratorAddFuel:new(player, generator, item))
            end
        end
    end
end

--- Function to repair the generator
--- This function checks if the player has the required items to repair the generator
--- @param _ any Target object
--- @param player any player
--- @param generator any generator
function fixGenerator(_, player, generator)
    local containsScrapE = player:getInventory():getFirstTypeRecurse("Base.ElectronicsScrap") ~= nil
    local containsScrapM = player:getInventory():getFirstTypeRecurse("Base.ScrapMetal") ~= nil

    if not player:isRecipeKnown("Generator") and
           player:getPerkLevel(Perks.Electricity) < 3 and
           player:getPerkLevel(Perks.Mechanics) < 3 then
        player:Say(getText('UI_BuildingGenerator_fixNeedKnowledge'))
    elseif generator:getModData()['PoweredOn'] == true then
        player:Say(getText('UI_BuildingGenerator_fixGenStillOn'))
    elseif not (containsScrapE or containsScrapM) then
        player:Say(getText('UI_BuildingGenerator_fixNeedScrap'))
    elseif luautils.walkAdj(player, generator:getSquare()) then
        ISTimedActionQueue.add(GeneratorFix:new(player, generator))
    end
end

--- Function to take the magazine from the generator
--- @param _ any Target object
--- @param player any player
--- @param generator any generator
function takeMagazine(_, player, generator)
    if luautils.walkAdj(player, generator:getSquare()) then
        generator:getModData()['GeneratorMagazine'] = false
        generator:getSquare():transmitModdata()
        generator:transmitModData()
        player:getInventory():AddItem("Base.ElectronicsMag4")
    end
end

--- Function to toggle all lights in the building
--- Walk adjacent to the generator and check if the square is inside a building
--- @param generator any generator
--- @param activate boolean to activate or deactivate the lights
function toggleAllLightsSwitchAction(generator, activate)
    local roomDefs = generator:getSquare():getBuilding():getDef():getRooms() or ArrayList.new()
    for i = 0, roomDefs:size() - 1 do
        local roomDef = roomDefs:get(i)
        local rects = roomDef:getRects()
        for j = 0, rects:size() - 1 do
            local rect = rects:get(j)
            for dx = 0, rect:getW() - 1 do
                for dy = 0, rect:getH() - 1 do
                    local square = getCell():getGridSquare(rect:getX() + dx, rect:getY() + dy, roomDef:getZ())
                    local chunk = square:getChunk()
                    local chunkLevel = chunk:getLevelData(square:getZ())
                    if chunkLevel then
                        local objects = square:getObjects()
                        for k = 0, objects:size() - 1 do
                            local object = objects:get(k)
                            if instanceof(object, 'IsoLightSwitch') and object:isActivated() ~= activate then
                                object:toggle()
                            end
                        end
                    end
                end
            end
        end
    end
end

--- Function to toggle all lights in the building
--- Walk adjacent to the generator and check if the square is inside a building
--- @param _ any Target object
--- @param player any player
--- @param generator any generator
--- @param activate boolean to activate or deactivate the lights
function toggleAllLightsSwitch(_, player, generator, activate)
    if luautils.walkAdj(player, generator:getSquare()) then
        toggleAllLightsSwitchAction(generator, activate)
    end
end

--- Function to toggle the proximity alert
--- This function checks if the player has the required items to toggle the proximity alert
function toggleProximityAlert(_, player, generator)
    if luautils.walkAdj(player, generator:getSquare()) then
        ISTimedActionQueue.add(ProximitySensorActivation:new(player, generator))
    end
end

--function toggleMarker(_, generator, activate)
--    local color = activate and getCore():getGoodHighlitedColor() or getCore():getBadHighlitedColor()
--    local roomDefs = generator:getSquare():getBuilding():getDef():getRooms() or ArrayList.new()
--    for i = 0, roomDefs:size() - 1 do
--        local squares = roomDefs:get(i):getIsoRoom():getSquares() or ArrayList.new()
--        for j = 0, squares:size() - 1 do
--            local square = squares:get(j)
--            if square then
--                local x = square:getX()
--                local y = square:getY()
--                local z = square:getZ()
--                addAreaHighlight(x, y, x+1, y+1, z, color:getR(), color:getG(), color:getB(), 0.1)
--            end
--        end
--    end
--    generator:getModData()['marker'] = true
--    generator:getSquare():transmitModdata()
--    generator:transmitModData()
--end


--- Generate context option menu
--- @param player any Player
--- @param menu any ISContextMenu
--- @param generator any IsoObject
function doBuildMenuGenerator(player, menu, generator)
    if not generator then return end

    local isoPlayer = getSpecificPlayer(player)

    -- Generate option menu for start generator
    local msgTogglePower = generator:getModData()['PoweredOn'] == false
            and getText('ContextMenu_BuildingGenerator_powerOn') or getText('ContextMenu_BuildingGenerator_powerOff')
    addCustomOption(menu:addOption(msgTogglePower, nil, togglePower, isoPlayer, generator),
                    generator:getModData()['PoweredOn'] == false,
                    getText('ContextMenu_BuildingGenerator_powerOnTooltip'), getText('ContextMenu_BuildingGenerator_powerOffTooltip'))

    -- Generate sub menu for status
    local subContextStatus = ISContextMenu:getNew(menu)
	local fuelAmount = math.floor(100 * generator:getModData()['FuelAmount']) / 100
	local consumption = math.floor(100 * generator:getModData()['Consumption']) / 100
	local estimateTime = generator:getModData()['Consumption'] ~= 0 and math.floor(generator:getModData()['FuelAmount'] / generator:getModData()['Consumption']) or 0
	local condition = math.floor(100 * generator:getModData()['Condition']) / 100

    menu:addSubMenu(menu:addOption(getText('ContextMenu_BuildingGenerator_status')), subContextStatus)
    subContextStatus:addOption(getText('ContextMenu_BuildingGenerator_fuelAmount') .. fuelAmount .. "L")
    subContextStatus:addOption(getText('ContextMenu_BuildingGenerator_consumption') .. consumption .. "L/h")
    subContextStatus:addOption(getText('ContextMenu_BuildingGenerator_estimateTime_1') .. estimateTime .. getText('ContextMenu_BuildingGenerator_estimateTime_2'))
    subContextStatus:addOption(getText('ContextMenu_BuildingGenerator_condition') .. condition .. "%")
    subContextStatus:addOption(generator:getModData()['AutoPowerOn'] == true
            and getText('ContextMenu_BuildingGenerator_autoOn') or getText('ContextMenu_BuildingGenerator_autoOff'))

    -- Generate option menu for autostart
    local msgToggleAutoStart = generator:getModData()['AutoPowerOn'] == false
            and getText('ContextMenu_BuildingGenerator_activateAutoOn') or getText('ContextMenu_BuildingGenerator_activateAutoOff')
    addCustomOption(menu:addOption(msgToggleAutoStart, nil, toggleAutoPower, isoPlayer, generator),
                    generator:getModData()['AutoPowerOn'] == false,
                    getText('ContextMenu_BuildingGenerator_activateAutoOnTooltip'), getText('ContextMenu_BuildingGenerator_activateAutoOffTooltip'))

    -- Generate option menu for filling generator
    addCustomOptionDisabledOpt(menu:addOption(getText('ContextMenu_BuildingGenerator_addFuel'), nil, addFuelGenerator, isoPlayer, generator),
                               generator:getModData()['FuelAmount'] < 100,
                               getText('ContextMenu_BuildingGenerator_addFuelTooltipSuccess'), getText('ContextMenu_BuildingGenerator_addFuelTooltipError'))

    -- Generate option menu for fixing generator
    addCustomOptionDisabledOpt(menu:addOption(getText('ContextMenu_BuildingGenerator_fix'), nil, fixGenerator, isoPlayer, generator),
                               generator:getModData()['Condition'] < 100,
                               getText('ContextMenu_BuildingGenerator_fixTooltipSuccess'), getText('ContextMenu_BuildingGenerator_fixTooltipError'))

    -- Generate option menu for retrieving generator magazine
    addCustomOptionDisabledOpt(menu:addOption(getText('ContextMenu_BuildingGenerator_mag'), nil, takeMagazine, isoPlayer, generator),
                               generator:getModData()['GeneratorMagazine'] == true,
                               getText('ContextMenu_BuildingGenerator_magTooltipSuccess'), getText('ContextMenu_BuildingGenerator_magTooltipError'))

    -- Generate option menu for adding proximity sensor for zombies
    local msgToggleProximitySensor = generator:getModData()['proximityAlert'] == false
            and getText('ContextMenu_BuildingGenerator_SensorAlertOn') or getText('ContextMenu_BuildingGenerator_SensorAlertOff')
    addCustomOption(menu:addOption(msgToggleProximitySensor, nil, toggleProximityAlert, isoPlayer, generator),
                    generator:getModData()['proximityAlert'] == false,
                    getText('ContextMenu_BuildingGenerator_SensorAlertOnTooltip'), getText('ContextMenu_BuildingGenerator_SensorAlertOffTooltip'))

    -- Generate sub menu for status
    local subContextLights = ISContextMenu:getNew(menu)
    menu:addSubMenu(menu:addOption(getText('ContextMenu_BuildingGenerator_toggleLights')), subContextLights)
    -- Generate option menu for toggling all lights on
    addCustomOption(subContextLights:addOption(getText('ContextMenu_BuildingGenerator_toggleLightsOn'), nil, toggleAllLightsSwitch, isoPlayer, generator, true),
                    true, getText('ContextMenu_BuildingGenerator_toggleLightsOnTooltip'), "")

    -- Generate option menu for toggling all lights off
    addCustomOption(subContextLights:addOption(getText('ContextMenu_BuildingGenerator_toggleLightsOff'), nil, toggleAllLightsSwitch, isoPlayer, generator, false),
                    true, getText('ContextMenu_BuildingGenerator_toggleLightsOffTooltip'), "")

    ---- Generate option menu for toggling marker
    --local msgToggleMarker = generator:getModData()['marker'] == false
    --        and "Marker on" or "Marker off"
    --addCustomOption(menu:addOption(msgToggleMarker, nil, toggleMarker, generator, not generator:getModData()['marker']),
    --                true, "Toggle Marker", "")
end

--- Context menu generator for building generator
--- Get first world object and check if it is a generator
--- Init generator and call doBuildMenuGenerator
--- @param player any Player
--- @param menu any ISContextMenu
--- @param worldObjects any IsoObject[]
function doBuildMenu(player, menu, worldObjects)
    if #worldObjects == 0 then return end

    if worldObjects[1] and worldObjects[1]:getSquare() then
        local square = worldObjects[1]:getSquare()
        if square:getObjects() then
            for i = 0, square:getObjects():size() - 1 do
                local object = square:getObjects():get(i)
                if UGOShared.isGeneratorCustom(object) then
                    initBuildingGenerator(square, object, true)
                    if object:getModData().Loaded then
                        doBuildMenuGenerator(player, menu, object)
                    end
                end
            end
        end
    end
end
Events.OnPreFillWorldObjectContextMenu.Add(doBuildMenu)
Events.OnObjectAdded.Add(function(object)
    if UGOShared.isGeneratorCustom(object) then
        initBuildingGenerator(object:getSquare(), object, true)
        onLoadGenerator(object)
    end
end)
