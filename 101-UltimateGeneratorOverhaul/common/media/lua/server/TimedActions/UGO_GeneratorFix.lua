require "TimedActions/ISBaseTimedAction"

GeneratorFix = ISBaseTimedAction:derive("GeneratorFix");

--- Checks if the action is valid before updating.
--- @return boolean If the action is valid.
function GeneratorFix:isValid()
    return self.generator:getModData()['Condition'] < 100
end

--- Waits for the action to become valid to start.
--- @return boolean If the action can start.
function GeneratorFix:waitToStart()
    self.character:faceThisObject(self.generator)
    return self.character:shouldBeTurning()
end

--- Starts the action.
function GeneratorFix:start()
    self:setActionAnim("Loot")
    self.character:SetVariable("LootPosition", "Low")
    self.character:reportEvent("EventLootItem")
    self.sound = self.character:playSound("GeneratorRepair")
end

--- Updates the action every tick.
function GeneratorAddFuel:update()
    self.character:faceThisObject(self.generator)
    self.character:setMetabolicTarget(Metabolics.HeavyDomestic);
end

--- Stops the action.
function GeneratorFix:stop()
    self.character:stopOrTriggerSound(self.sound)
    ISBaseTimedAction.stop(self)
end

--- Performs the action at the end.
function GeneratorFix:perform()
    self.character:stopOrTriggerSound(self.sound)

    local scrapE = self.character:getInventory():getFirstTypeRecurse("Base.ElectronicsScrap")
    local scrapM = self.character:getInventory():getFirstTypeRecurse("Base.ScrapMetal")
    if not scrapE and not scrapM then return end

    local detail = scrapE and { scrapObj = scrapE, perk = Perks.Electricity} or { scrapObj = scrapM, perk = Perks.Mechanics}
    local perkLevel = self.character:getPerkLevel(detail.perk)
    self.character:removeFromHands(detail.scrapObj)
    self.generator:getModData()['Condition'] = math.min(100, (self.generator:getModData()['Condition'] + (1 * (perkLevel / 4)) + 2))
    self.character:getInventory():Remove(detail.scrapObj)
    self.character:getXp():AddXP(detail.perk, perkLevel * 5)

    if self.generator:getModData()['Condition'] < 100 then
        local scrapItem = self.character:getInventory():getFirstTypeRecurse("Base.ElectronicsScrap") or
                          self.character:getInventory():getFirstTypeRecurse("Base.ScrapMetal")
        if scrapItem ~= nil then
            if scrapItem:getContainer() ~= self.character:getInventory() then
                ISTimedActionQueue.add(ISInventoryTransferAction:new(self.character, scrapItem, scrapItem:getContainer(), self.character:getInventory(), nil))
            end
            ISTimedActionQueue.add(GeneratorFix:new(self.character, self.generator))
        end
    end
    self.generator:transmitModData()

    ISBaseTimedAction.perform(self)
end

function GeneratorFix:new(character, generator)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.generator = generator
    o.stopOnWalk = true
    o.stopOnRun = true

    o.maxTime = 150 - (o.character:getPerkLevel(Perks.Electricity) * 3);
    if o.character:isTimedActionInstant() then
        o.maxTime = 1;
    end

    return o
end
