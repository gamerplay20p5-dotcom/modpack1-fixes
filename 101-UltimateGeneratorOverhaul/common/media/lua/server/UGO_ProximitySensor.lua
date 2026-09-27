
lightAlert = false

--- Check if the zombie is in range of a square with a proximity sensor
--- @param zombieSquare any IsoGridSquare
--- @return any generator
local function checkIfZombieIsInRange(zombieSquare)
    if not zombieSquare then return nil end
    local cx, cy, cz = zombieSquare:getX(), zombieSquare:getY(), zombieSquare:getZ()
    for dx = -3, 3 do
        for dy = -3, 3 do
            local square = getCell():getGridSquare(cx + dx, cy + dy, cz)
            local generator = square and square:getModData()['generator']
            if generator then return generator end
        end
    end
    return nil
end

--- Function for player yell when a zombie is near to a building
--- @param generator any generator
local function playerSayZombieCloseBuilding(generator)
    for i=0, getNumActivePlayers()-1 do
        local player = getSpecificPlayer(i)
        if player and not player:isDead() and player:getCurrentRoomDef() then
            if generator:getSquare():getBuilding():getDef():getID() == player:getCurrentRoomDef():getBuilding():getID() then
                local rand = ZombRand(3)
                if rand == 0 then player:Say(getText('UI_ProximitySensor_catchSentence_1'))
                elseif rand == 1 then player:Say(getText('UI_ProximitySensor_catchSentence_2'))
                else player:Say(getText('UI_ProximitySensor_catchSentence_3'))
                end
            end
        end
    end
end

--- Function to check if a zombie is near to a building with sensor
--- @param zombie any IsoZombie
local function onZombieCheckSensorNearby(zombie)

    -- Check if the zombie is alive and not crawling and there is no alert
    if lightAlert == false and zombie and zombie:isAlive() and not zombie:isCrawling() then
        local generator = checkIfZombieIsInRange(zombie:getCurrentSquare())
        if generator then
            lightAlert = true
            generator:getSquare():getBuilding():forceAwake()
            playerSayZombieCloseBuilding(generator)

            local lightsOn = false
            --- Function to handle blinking light
            --- Stops blinking when the zombie is out of range every 250 ticks
            --- Light on 50 out of 80 ticks and light off on remaining ticks
            --- @param tick number
            local function handleBlinkLight_callback(tick)
                if tick % 250 ~= 0 or checkIfZombieIsInRange(zombie:getCurrentSquare()) ~= nil then
                    if tick % 80 < 50 and not lightsOn then
                        lightsOn = true
                        toggleAllLightsSwitchAction(generator, true)
                    elseif tick % 80 >= 50 and lightsOn then
                        lightsOn = false
                        toggleAllLightsSwitchAction(generator, false)
                    end
                else
                    lightAlert = false
                    toggleAllLightsSwitchAction(generator, true)
                    Events.OnTick.Remove(handleBlinkLight_callback)
                end
            end
            Events.OnTick.Add(handleBlinkLight_callback)

            --- Function to handle blinking light
            --- Stops sound when the zombie is out of sensor range or
            --- when player is out of the building
            local function handleSound_callback()
                if checkIfZombieIsInRange(zombie:getCurrentSquare()) ~= nil then
                    for i=0, getNumActivePlayers()-1 do
                        local player = getSpecificPlayer(i)
                        if player and not player:isDead() and player:getCurrentRoomDef() then
                            if generator:getSquare():getBuilding():getDef():getID() == player:getCurrentRoomDef():getBuilding():getID() then
                                player:playSound("activateAlarm")
                            end
                        end
                    end
                else
                    Events.EveryOneMinute.Remove(handleSound_callback)
                end
            end
            Events.EveryOneMinute.Add(handleSound_callback)
        end
    end
end
Events.OnZombieUpdate.Add(onZombieCheckSensorNearby)