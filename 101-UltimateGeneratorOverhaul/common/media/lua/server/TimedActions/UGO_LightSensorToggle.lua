require "TimedActions/ISBaseTimedAction"

LightSensorAddRemove = ISBaseTimedAction:derive("LightSensorAddRemove");

--- Checks if the action is valid before updating.
--- @return boolean If the action is valid.
function LightSensorAddRemove:isValid()
    return true
end

--- Waits for the action to become valid to start.
--- @return boolean If the action can start.
function LightSensorAddRemove:waitToStart()
    self.character:faceThisObject(self.object)
    return self.character:shouldBeTurning()
end

--- Starts the action.
function LightSensorAddRemove:start()
    self:setActionAnim("Loot")
    self:setOverrideHandModels(nil, nil)
    self.sound = self.character:playSound("Screwdriver")
end

--- Updates the action every tick.
function LightSensorAddRemove:update()
    self.character:faceThisObject(self.object)
    self.character:setMetabolicTarget(Metabolics.HeavyDomestic);
end

--- Stops the action.
function LightSensorAddRemove:stop()
    self.character:stopOrTriggerSound(self.sound)
    ISBaseTimedAction.stop(self);
end

--- Performs the action at the end.
function LightSensorAddRemove:perform()
    self.character:stopOrTriggerSound(self.sound)

    if self.toAdd then
        local scrap = self.character:getInventory():getFirstTypeRecurse("Base.ElectronicsScrap")
        if not scrap then return end

        self.character:removeFromHands(scrap)
        self.character:getInventory():Remove(scrap)
        self.character:getXp():AddXP(Perks.Electricity, self.character:getPerkLevel(Perks.Electricity) * 5)
    else
        self.character:getInventory():AddItem("Base.ElectronicsScrap")
    end

    self.object:getModData()['LightSensor'] = self.toAdd
    self.character:Say(self.toAdd and "Sensor added" or "Sensor removed")

    self.object:getSquare():transmitModdata()
    self.object:transmitModData()
    ISBaseTimedAction.perform(self)
end

--- Constructor for the LightSensorAddRemove class.
--- @field character any IsoGameCharacter
--- @field generator any IsoGenerator
function LightSensorAddRemove:new(character, object, toAdd)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.object = object;
    o.toAdd = toAdd;
    o.stopOnWalk = true;
    o.stopOnRun = true;

    o.maxTime = 50
    if o.character:isTimedActionInstant() then
        o.maxTime = 1
    end

    return o;
end