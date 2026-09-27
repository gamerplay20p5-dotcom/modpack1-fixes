require "TimedActions/ISBaseTimedAction"

GeneratorAddFuel = ISBaseTimedAction:derive("GeneratorAddFuel");

--- Checks if the action is valid before updating.
--- @return boolean If the action is valid.
function GeneratorAddFuel:isValid()
    return self.generator:getModData()['FuelAmount'] < 100
end

--- Waits for the action to become valid to start.
--- @return boolean If the action can start.
function GeneratorAddFuel:waitToStart()
    self.character:faceThisObject(self.generator)
    return self.character:shouldBeTurning()
end

--- Starts the action.
function GeneratorAddFuel:start()
    self:setActionAnim("refuelgascan")
    self:setOverrideHandModels(self.petrolCan:getStaticModel(), nil)
    self.sound = self.character:playSound("GeneratorAddFuel")
end

--- Updates the action every tick.
function GeneratorAddFuel:update()
    self.character:faceThisObject(self.generator)
    self.character:setMetabolicTarget(Metabolics.HeavyDomestic);
end

--- Stops the action.
function GeneratorAddFuel:stop()
    self.character:stopOrTriggerSound(self.sound)
    ISBaseTimedAction.stop(self);
end

--- Performs the action at the end.
function GeneratorAddFuel:perform()
    self.character:stopOrTriggerSound(self.sound)

    local fuelAmount = self.petrolCan:getFluidContainer():getAmount() or 0
    local spaceLeft = 100 - self.generator:getModData()['FuelAmount']
    local fuelAmountTotal = self.generator:getModData()['FuelAmount'] + math.min(fuelAmount, spaceLeft)
    self.generator:getModData()['FuelAmount'] = math.min(fuelAmountTotal, 100)

    self.petrolCan:getFluidContainer():adjustAmount(fuelAmount - spaceLeft)

    self.generator:getSquare():transmitModdata()
    self.generator:transmitModData()
    ISBaseTimedAction.perform(self)
end

--- Constructor for the GeneratorAddFuel class.
--- @field character any IsoGameCharacter
--- @field generator any IsoGenerator
function GeneratorAddFuel:new(character, generator, petrolCan)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.generator = generator;
    o.petrolCan = petrolCan;
    o.stopOnWalk = true;
    o.stopOnRun = true;

    o.maxTime = 150
    if o.petrolCan then
        if o.character:isTimedActionInstant() then
            o.maxTime = 1
        end
        o.maxTime = o.petrolCan:getFluidContainer():getAmount() * 25
    end

    return o;
end