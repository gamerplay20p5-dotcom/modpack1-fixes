require "UGO_Electricity"
require "TimedActions/ISBaseTimedAction"

GeneratorActivation = ISBaseTimedAction:derive("GeneratorActivation");

--- Checks if the action is valid before updating.
--- @return boolean If the action is valid.
function GeneratorActivation:isValid()
	if self.activate == true then
		if self.generator:getModData()['Condition'] <= 0 then
			self.character:Say(getText('UI_GeneratorActivation_genBroken'))
			return false
		elseif self.generator:getModData()['FuelAmount'] <= 0 then
			self.character:Say(getText('UI_GeneratorActivation_genEmpty'))
			return false
		end
	end
	return true
end

--- Waits for the action to become valid to start.
--- @return boolean If the action can start.
function GeneratorActivation:waitToStart()
	self.character:faceThisObject(self.generator)
	return self.character:shouldBeTurning()
end

--- Starts the action.
function GeneratorActivation:start()
	self:setActionAnim("Loot")
	self.character:SetVariable("LootPosition", "Mid")
	self.character:reportEvent("EventLootItem")
end

--- Updates the action every tick.
function GeneratorActivation:update()
	self.character:faceThisObject(self.generator)
	self.character:setMetabolicTarget(Metabolics.HeavyDomestic);
end

--- Stops the action.
function GeneratorActivation:stop()
    ISBaseTimedAction.stop(self);
end

--- Performs the action at the end.
function GeneratorActivation:perform()
	if self.activate then
		if (self.generator:getModData()['Condition'] <= 50 and ZombRand(2) == 0) or
		   (self.generator:getModData()['Condition'] <= 20 and ZombRand(10) == 0) then
			self.character:playSound("GeneratorFailedToStart")
			ISTimedActionQueue.add(GeneratorActivation:new(self.character, self.generator, true))
		else
			self.character:playSound("GeneratorStarting")
			UGOElectricity.requestGenerator(self.character, self.generator, self.activate)
		end
	else
		self.character:playSound("GeneratorStopping")
		UGOElectricity.requestGenerator(self.character, self.generator, self.activate)
	end

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

--- Constructor for the GeneratorActivation class.
--- @field character any IsoGameCharacter
--- @field generator any IsoGenerator
--- @field activate boolean If the generator should be activated or deactivated.
function GeneratorActivation:new(character, generator, activate)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character;
	o.generator = generator;
	o.activate = activate;
	o.stopOnWalk = true;
	o.stopOnRun = true;

	o.maxTime = 30;
	if o.character:isTimedActionInstant() then
		o.maxTime = 1
	end

	return o;
end

-- Authoritative callers: load, fuel exhaustion, destruction, automatic start.
function GeneratorActivation:handleGenerator(generator, activate)
    return UGOElectricity.setGenerator(generator, activate)
end

-- Consumer membership describes capability, not whether UGO is currently on.
function GeneratorActivation:handleObjectInBuilding(generator, square, activate)
    if not square or not square:getChunk() then return end
    local objects = square:getObjects()
    for i = 0, objects:size()-1 do
        local obj = objects:get(i)
        if obj:couldBePoweredByGenerator() then
            square:getChunk():addObjectPoweredByGenerator(obj)
            obj:checkHaveElectricity()
        end
    end
end

function onObjectAboutToBeRemoved(object)
    if isClient() then return end
    if UGOShared.isGeneratorCustom(object) then
        local modData = object:getModData()
        if modData then
            GeneratorActivation:handleGenerator(object, false)

            local modDataUGO = UGOShared.getModData()
            if modDataUGO.Generator then
                local square = object:getSquare()

                local chunkWX = UGOShared.getChunkX(square)
                local chunkWY = UGOShared.getChunkY(square)
                local coordsChunk = UGOShared.coordsChunkToKey(chunkWX, chunkWY)

                local coordsSquare = UGOShared.coordsToKey(square)
                if modDataUGO.Generator[coordsChunk] then
                    modDataUGO.Generator[coordsChunk][coordsSquare] = nil
                end
            end
        end
    end

    if instanceof(object, 'IsoLightSwitch') then
        local modDataUGO = UGOShared.getModData()
        if modDataUGO.LightSensor then
            local square = object:getSquare()

            local chunkWX = UGOShared.getChunkX(square)
            local chunkWY = UGOShared.getChunkY(square)
            local coordsChunk = UGOShared.coordsChunkToKey(chunkWX, chunkWY)

            local coordsSquare = UGOShared.coordsToKey(square)
            if modDataUGO.LightSensor[coordsChunk] then
                modDataUGO.LightSensor[coordsChunk][coordsSquare] = nil
            end
        end
    end
end

Events.OnObjectAboutToBeRemoved.Remove(onObjectAboutToBeRemoved)
Events.OnObjectAboutToBeRemoved.Add(onObjectAboutToBeRemoved)


